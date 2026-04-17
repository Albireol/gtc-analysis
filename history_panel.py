#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
History Analysis Panel
Based on MATLAB history.m by Hua-sheng XIE & Yuehao Ma

Each button opens a new independent figure window with save/export options.
"""

from PyQt6.QtWidgets import (QWidget, QVBoxLayout, QHBoxLayout, QGridLayout,
                             QPushButton, QLabel, QFileDialog, QScrollArea,
                             QGroupBox, QComboBox, QLineEdit, QSpinBox,
                             QMessageBox, QStatusBar, QFrame, QApplication,
                             QDialog)
from PyQt6.QtCore import Qt, QTimer
from PyQt6.QtGui import QPixmap, QClipboard
import numpy as np
import sys
from pathlib import Path
from io import BytesIO
import matplotlib
matplotlib.use('QtAgg')
import matplotlib.pyplot as plt
from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent))

from gtc.history_reader import HistoryReader
from gtc.history_plotter import HistoryPlotter
from gtc.context import create_context


class PlotWindow(QDialog):
    """Independent plot window with save/export/copy options"""

    def __init__(self, fig, title, parent=None):
        super().__init__(parent)
        self.setWindowTitle(title)
        self.setMinimumSize(1000, 700)
        self.setStyleSheet("""
            QDialog {
                background-color: #ffffff;
            }
        """)
        
        self.figure = fig
        self.is_fullscreen = False

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)

        # Create canvas
        self.canvas = FigureCanvas(fig)
        self.canvas.setStyleSheet("background-color: #ffffff;")
        layout.addWidget(self.canvas)

        # Toolbar at bottom
        toolbar_layout = QHBoxLayout()
        toolbar_layout.setContentsMargins(10, 10, 10, 10)

        save_btn = QPushButton("💾 Save")
        save_btn.setStyleSheet("""
            QPushButton {
                background-color: #2ca02c;
                color: white;
                border: none;
                padding: 8px 16px;
                border-radius: 4px;
                font-weight: bold;
                font-size: 13px;
            }
            QPushButton:hover {
                background-color: #228c22;
            }
        """)
        save_btn.clicked.connect(lambda: self.save_plot(fig))

        copy_btn = QPushButton("📋 Copy")
        copy_btn.setStyleSheet("""
            QPushButton {
                background-color: #1f77b4;
                color: white;
                border: none;
                padding: 8px 16px;
                border-radius: 4px;
                font-weight: bold;
                font-size: 13px;
            }
            QPushButton:hover {
                background-color: #0d5a99;
            }
        """)
        copy_btn.clicked.connect(lambda: self.copy_to_clipboard(fig))

        fullscreen_btn = QPushButton("⛶ Fullscreen")
        fullscreen_btn.setStyleSheet("""
            QPushButton {
                background-color: #939598;
                color: white;
                border: none;
                padding: 8px 16px;
                border-radius: 4px;
                font-weight: bold;
                font-size: 13px;
            }
            QPushButton:hover {
                background-color: #6d6f72;
            }
        """)
        fullscreen_btn.clicked.connect(self.toggle_fullscreen)

        close_btn = QPushButton("❌ Close")
        close_btn.setStyleSheet("""
            QPushButton {
                background-color: #d62728;
                color: white;
                border: none;
                padding: 8px 16px;
                border-radius: 4px;
                font-weight: bold;
                font-size: 13px;
            }
            QPushButton:hover {
                background-color: #c22525;
            }
        """)
        close_btn.clicked.connect(self.close)

        toolbar_layout.addStretch()
        toolbar_layout.addWidget(save_btn)
        toolbar_layout.addWidget(copy_btn)
        toolbar_layout.addWidget(fullscreen_btn)
        toolbar_layout.addWidget(close_btn)
        toolbar_layout.addStretch()

        layout.addLayout(toolbar_layout)

    def save_plot(self, fig):
        """Save plot to file"""
        file_name, _ = QFileDialog.getSaveFileName(
            self, "Save Plot", "",
            "PNG Files (*.png);;PDF Files (*.pdf);;SVG Files (*.svg);;All Files (*)"
        )
        if file_name:
            try:
                fig.savefig(file_name, dpi=150, bbox_inches='tight')
                self.parent().statusbar.showMessage(f"Plot saved to {file_name}")
            except Exception as e:
                QMessageBox.critical(self, "Error", f"Failed to save plot:\n{str(e)}")

    def copy_to_clipboard(self, fig):
        """Copy plot to clipboard"""
        try:
            # Save figure to bytes buffer
            buf = BytesIO()
            fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
            buf.seek(0)
            
            # Create QPixmap from bytes
            pixmap = QPixmap()
            pixmap.loadFromData(buf.read())
            
            # Copy to clipboard
            clipboard = QApplication.clipboard()
            clipboard.setPixmap(pixmap)
            
            self.parent().statusbar.showMessage("Plot copied to clipboard!")
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Failed to copy:\n{str(e)}")

    def toggle_fullscreen(self):
        """Toggle fullscreen mode"""
        if self.is_fullscreen:
            self.showNormal()
            self.is_fullscreen = False
        else:
            self.showFullScreen()
            self.is_fullscreen = True


class HistoryPanel(QWidget):
    """History data analysis panel"""

    def __init__(self):
        super().__init__()
        self.context = None
        self.history_reader = None
        self.history_plotter = None
        self.open_windows = []

        self.init_ui()

    def init_ui(self):
        """Initialize the UI"""
        layout = QVBoxLayout(self)
        layout.setContentsMargins(15, 15, 15, 15)
        layout.setSpacing(15)

        # Header
        header = QLabel("📈 History Data Analysis")
        header.setStyleSheet("""
            font-size: 24px;
            font-weight: bold;
            color: #1f77b4;
            padding: 10px;
        """)
        layout.addWidget(header)

        # File selection
        file_layout = QHBoxLayout()
        file_label = QLabel("Data Directory:")
        file_label.setStyleSheet("color: #333333; font-size: 14px; font-weight: bold;")

        self.dir_path = QLineEdit()
        self.dir_path.setPlaceholderText("Select GTC data directory...")
        self.dir_path.setStyleSheet("""
            QLineEdit {
                background-color: #ffffff;
                color: #333333;
                border: 2px solid #1f77b4;
                padding: 8px;
                border-radius: 4px;
                font-size: 13px;
            }
            QLineEdit:focus {
                border: 2px solid #0d5a99;
                background-color: #f0f7ff;
            }
        """)

        self.btn_browse = QPushButton("📁 Browse")
        self.btn_browse.setStyleSheet("""
            QPushButton {
                background-color: #1f77b4;
                color: white;
                border: none;
                padding: 8px 16px;
                border-radius: 4px;
                font-weight: bold;
                font-size: 13px;
            }
            QPushButton:hover {
                background-color: #0d5a99;
            }
            QPushButton:pressed {
                background-color: #0a4270;
            }
        """)
        self.btn_browse.clicked.connect(self.browse_directory)

        self.btn_load = QPushButton("📥 Load Data")
        self.btn_load.setStyleSheet("""
            QPushButton {
                background-color: #2ca02c;
                color: white;
                border: none;
                padding: 8px 16px;
                border-radius: 4px;
                font-weight: bold;
                font-size: 13px;
            }
            QPushButton:hover {
                background-color: #228c22;
            }
            QPushButton:pressed {
                background-color: #1a6b1a;
            }
        """)
        self.btn_load.clicked.connect(self.load_data)

        file_layout.addWidget(file_label)
        file_layout.addWidget(self.dir_path)
        file_layout.addWidget(self.btn_browse)
        file_layout.addWidget(self.btn_load)
        layout.addLayout(file_layout)

        # Status label
        self.status_label = QLabel("Ready - Load GTC data directory to begin")
        self.status_label.setStyleSheet("""
            color: #666666;
            padding: 5px;
            background-color: #f5f5f5;
            border-radius: 4px;
            border-left: 3px solid #1f77b4;
        """)
        layout.addWidget(self.status_label)

        # Info label
        info_label = QLabel("💡 Tip: Click any button to open a new plot window. Each window can be saved independently.")
        info_label.setStyleSheet("""
            color: #1f77b4;
            padding: 8px;
            background-color: #f0f7ff;
            border-radius: 4px;
            font-style: italic;
            border: 1px solid #cce0ff;
        """)
        layout.addWidget(info_label)

        # Button grid with scroll
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setStyleSheet("""
            QScrollArea {
                background-color: #ffffff;
                border: 1px solid #cccccc;
                border-radius: 4px;
            }
        """)

        button_widget = QWidget()
        button_widget.setStyleSheet("""
            QWidget {
                background-color: #ffffff;
            }
        """)
        button_layout = QGridLayout(button_widget)
        button_layout.setSpacing(8)
        button_layout.setContentsMargins(10, 10, 10, 10)

        # Button definitions: (row, col, label, callback, width)
        buttons = [
            # Row 1 - phi
            (0, 0, "ϕ (Phi)", self.on_phi, 100),
            (0, 1, "RMS", self.on_phi_rms, 80),
            (0, 2, "Mode 1", lambda: self.on_mode(0, 'phi'), 80),
            (0, 3, "Mode 2", lambda: self.on_mode(1, 'phi'), 80),
            (0, 4, "Mode 3", lambda: self.on_mode(2, 'phi'), 80),
            (0, 5, "Mode 4", lambda: self.on_mode(3, 'phi'), 80),
            (0, 6, "Mode 5", lambda: self.on_mode(4, 'phi'), 80),
            (0, 7, "Mode 6", lambda: self.on_mode(5, 'phi'), 80),
            (0, 8, "Mode 7", lambda: self.on_mode(6, 'phi'), 80),
            (0, 9, "Mode 8", lambda: self.on_mode(7, 'phi'), 80),

            # Row 2 - a_par
            (1, 0, "A‖ (A-para)", self.on_apara, 100),
            (1, 1, "Zonal A‖", self.on_apara_rms, 80),
            (1, 2, "Mode 1", lambda: self.on_mode(0, 'apara'), 80),
            (1, 3, "Mode 2", lambda: self.on_mode(1, 'apara'), 80),
            (1, 4, "Mode 3", lambda: self.on_mode(2, 'apara'), 80),
            (1, 5, "Mode 4", lambda: self.on_mode(3, 'apara'), 80),
            (1, 6, "Mode 5", lambda: self.on_mode(4, 'apara'), 80),
            (1, 7, "Mode 6", lambda: self.on_mode(5, 'apara'), 80),
            (1, 8, "Mode 7", lambda: self.on_mode(6, 'apara'), 80),
            (1, 9, "Mode 8", lambda: self.on_mode(7, 'apara'), 80),

            # Row 3 - fluidne
            (2, 0, "nₑ (fluidne)", self.on_fluidne, 100),
            (2, 1, "Zonal nₑ", self.on_fluidne_rms, 80),
            (2, 2, "Mode 1", lambda: self.on_mode(0, 'fluidne'), 80),
            (2, 3, "Mode 2", lambda: self.on_mode(1, 'fluidne'), 80),
            (2, 4, "Mode 3", lambda: self.on_mode(2, 'fluidne'), 80),
            (2, 5, "Mode 4", lambda: self.on_mode(3, 'fluidne'), 80),
            (2, 6, "Mode 5", lambda: self.on_mode(4, 'fluidne'), 80),
            (2, 7, "Mode 6", lambda: self.on_mode(5, 'fluidne'), 80),
            (2, 8, "Mode 7", lambda: self.on_mode(6, 'fluidne'), 80),
            (2, 9, "Mode 8", lambda: self.on_mode(7, 'fluidne'), 80),

            # Row 4 - Ion/EP
            (3, 0, "Ion Density", self.on_ion_density, 100),
            (3, 1, "Ion Momentum", self.on_ion_momentum, 100),
            (3, 2, "Ion Energy", self.on_ion_energy, 100),
            (3, 3, "Ion PM Flux", self.on_ion_pmflux, 100),
            (3, 4, "Ion E Flux", self.on_ion_eflux, 100),
            (3, 5, "EP Density", self.on_ep_density, 100),
            (3, 6, "EP Momentum", self.on_ep_momentum, 100),
            (3, 7, "EP Energy", self.on_ep_energy, 100),
            (3, 8, "EP PM Flux", self.on_ep_pmflux, 100),
            (3, 9, "EP E Flux", self.on_ep_eflux, 100),

            # Row 5 - Electron & Controls
            (4, 0, "e⁻ Density", self.on_ele_density, 100),
            (4, 1, "e⁻ Momentum", self.on_ele_momentum, 100),
            (4, 2, "e⁻ Energy", self.on_ele_energy, 100),
            (4, 3, "e⁻ PM Flux", self.on_ele_pmflux, 100),
            (4, 4, "e⁻ E Flux", self.on_ele_eflux, 100),
            (4, 5, "⏱ Time Range", self.on_time_range, 100),
            (4, 6, "📊 Freq Range", self.on_freq_range, 100),
            (4, 7, "❌ Clear All", self.on_clear_all, 100),
            (4, 8, "🔙 To Main", self.on_back_to_main, 100),
            (4, 9, "", lambda: None, 100),  # Empty button
        ]

        for row, col, label, callback, width in buttons:
            if not label:
                continue
            btn = QPushButton(label)
            btn.setFixedHeight(40)
            btn.setFixedWidth(width)
            btn.setStyleSheet("""
                QPushButton {
                    background-color: #ffffff;
                    color: #1f77b4;
                    border: 2px solid #1f77b4;
                    border-radius: 6px;
                    font-weight: bold;
                    font-size: 11px;
                }
                QPushButton:hover {
                    background-color: #f0f7ff;
                    border: 2px solid #0d5a99;
                    color: #0d5a99;
                }
                QPushButton:pressed {
                    background-color: #e0f0ff;
                    border: 2px solid #0a4270;
                    color: #0a4270;
                }
                QPushButton:disabled {
                    color: #cccccc;
                    border: 2px solid #e0e0e0;
                    background-color: #f9f9f9;
                }
            """)
            
            # Wrap callback to catch exceptions
            def make_callback(cb):
                def wrapped():
                    try:
                        cb()
                    except Exception as e:
                        import traceback
                        error_msg = f"Error in {getattr(cb, '__name__', 'callback')}: {e}"
                        self.statusbar.showMessage(error_msg)
                        traceback.print_exc()
                return wrapped
            
            btn.clicked.connect(make_callback(callback))
            btn.setEnabled(False)  # Disabled until data is loaded
            button_layout.addWidget(btn, row, col)

        # Store button references for enabling/disabling
        self.buttons = []
        for i in range(button_layout.count()):
            widget = button_layout.itemAt(i).widget()
            if isinstance(widget, QPushButton):
                self.buttons.append(widget)

        scroll.setWidget(button_widget)
        layout.addWidget(scroll)

        # Status bar at bottom
        self.statusbar = QStatusBar()
        self.statusbar.setStyleSheet("""
            QStatusBar {
                color: #333333;
                background-color: #f5f5f5;
                border-top: 1px solid #cccccc;
                padding: 5px;
            }
        """)
        layout.addWidget(self.statusbar)

    def set_buttons_enabled(self, enabled):
        """Enable or disable all action buttons"""
        for btn in self.buttons:
            btn.setEnabled(enabled)

    def browse_directory(self):
        """Open dialog to select data directory"""
        dir_name = QFileDialog.getExistingDirectory(
            self, "Select GTC Data Directory", "",
            QFileDialog.Option.ShowDirsOnly
        )
        if dir_name:
            self.dir_path.setText(dir_name)

    def load_data(self):
        """Load and parse GTC data"""
        data_dir = self.dir_path.text().strip()
        if not data_dir:
            QMessageBox.warning(self, "No Directory", "Please select a data directory first.")
            return

        data_path = Path(data_dir)
        history_file = data_path / "history.out"

        if not history_file.exists():
            QMessageBox.warning(
                self, "File Not Found",
                f"history.out not found in:\n{data_dir}"
            )
            return

        try:
            self.statusbar.showMessage(f"Loading data from {data_dir}...")
            QApplication.processEvents()

            # Create context and load all data
            self.context = create_context(str(data_path))

            # Create history reader for growth rate calculations
            self.history_reader = HistoryReader(str(history_file))
            self.history_reader.data = self.context.history_data

            # Update time array with correct dt
            dt = self.context.tstep_ndiag if self.context.tstep_ndiag > 0 else 1.0
            self.history_reader.data.time = np.arange(
                1, self.context.history_data.header.ntime + 1
            ) * dt

            # Create plotter
            self.history_plotter = HistoryPlotter(self.context.history_data)

            header = self.context.history_data.header
            self.status_label.setText(
                f"✓ Loaded: {header.ntime} steps, {header.nspecies} species, "
                f"{header.nfield} fields, {header.modes} modes"
            )
            self.status_label.setStyleSheet("""
                color: #3fb950;
                padding: 5px;
                background-color: #161b22;
                border-radius: 4px;
            """)

            self.set_buttons_enabled(True)
            self.statusbar.showMessage("Data loaded successfully!")

        except Exception as e:
            QMessageBox.critical(self, "Error", f"Failed to load data:\n{str(e)}")
            self.statusbar.showMessage("Error loading data")

    def open_plot_window(self, fig, title):
        """Open a new independent plot window"""
        window = PlotWindow(fig, title, self)
        window.show()
        self.open_windows.append(window)
        self.statusbar.showMessage(f"Opened: {title}")

    def on_phi(self):
        """Plot phi field time series"""
        if not self.history_plotter:
            return

        fig = self.history_plotter.plot_field_time(
            field_idx=0,
            title="ϕ (Phi) Field Time Evolution"
        )
        self.open_plot_window(fig, "ϕ (Phi) Field Time Evolution")

    def on_phi_rms(self):
        """Plot phi RMS"""
        if not self.context or not self.history_reader:
            return
        self._plot_field_quantity(0, 3, "ϕ RMS (Total)")

    def on_apara(self):
        """Plot A‖ field time series"""
        if not self.history_plotter:
            return

        fig = self.history_plotter.plot_field_time(
            field_idx=1,
            title="A‖ (A-para) Field Time Evolution"
        )
        self.open_plot_window(fig, "A‖ (A-para) Field Time Evolution")

    def on_apara_rms(self):
        """Plot A‖ RMS"""
        self._plot_field_quantity(1, 3, "A‖ RMS (Total)")

    def on_fluidne(self):
        """Plot fluidne field time series"""
        if not self.history_plotter:
            return

        fig = self.history_plotter.plot_field_time(
            field_idx=2,
            title="nₑ (fluidne) Field Time Evolution"
        )
        self.open_plot_window(fig, "nₑ (fluidne) Field Time Evolution")

    def on_fluidne_rms(self):
        """Plot fluidne RMS"""
        self._plot_field_quantity(2, 3, "nₑ RMS (Total)")

    def _plot_field_quantity(self, field_idx, quantity_idx, title):
        """Helper to plot a field quantity"""
        if not self.context or not self.history_reader:
            return

        data = self.context.history_data.field_time[:, quantity_idx, field_idx]
        time = self.history_reader.data.time

        fig = Figure(figsize=(10, 8))
        fig.patch.set_facecolor('#0d1117')
        ax = fig.add_subplot(111)
        ax.plot(time, data, linewidth=2, color=self.history_plotter.COLORS['primary'])
        ax.set_xlabel("Time (R₀/cₛ)", fontsize=12)
        ax.set_ylabel("Amplitude", fontsize=12)
        ax.set_title(title, fontsize=14, fontweight='bold')
        ax.grid(True, alpha=0.3, linestyle='--')
        fig.tight_layout()

        self.open_plot_window(fig, title)

    def on_mode(self, mode_idx, field_name):
        """Plot mode evolution for a specific mode"""
        self.statusbar.showMessage(f"Loading {field_name} Mode {mode_idx+1}...")
        
        if not self.history_reader:
            self.statusbar.showMessage("Error: No history reader available")
            return
        if not self.history_plotter:
            self.statusbar.showMessage("Error: No history plotter available")
            return

        field_map = {'phi': 0, 'apara': 1, 'fluidne': 2}
        field_idx = field_map.get(field_name, 0)
        
        self.statusbar.showMessage(f"Calculating growth rate for {field_name} Mode {mode_idx+1}...")

        # Calculate growth rate and frequency
        try:
            gamma, omega, info = self.history_reader.get_growth_rate(
                field_idx=field_idx, mode_idx=mode_idx
            )
        except Exception as e:
            self.statusbar.showMessage(f"Error calculating growth rate: {e}")
            return

        # Create mode evolution plot (matching MATLAB 2x3 layout)
        try:
            tstep_ndiag = self.context.tstep_ndiag if self.context.tstep_ndiag > 0 else 1.0
            fig = self.history_plotter.plot_mode_evolution(
                field_idx=field_idx,
                mode_idx=mode_idx,
                tstep_ndiag=tstep_ndiag
            )
        except Exception as e:
            import traceback
            traceback.print_exc()
            self.statusbar.showMessage(f"Error creating plot: {e}")
            return

        # Add growth rate info to title
        marker = "★" if info['r2_best'] > 0.99 else " "
        title = f"{field_name} Mode {mode_idx+1}: γ={gamma:.6f}, ω={omega:.6f} {marker}"
        self.open_plot_window(fig, title)
        self.statusbar.showMessage(title)

    def on_ion_density(self):
        self._plot_particle_quantity(0, 0, "Ion Density")

    def on_ion_momentum(self):
        self._plot_particle_quantity(0, 2, "Ion Momentum")

    def on_ion_energy(self):
        self._plot_particle_quantity(0, 4, "Ion Energy")

    def on_ion_pmflux(self):
        self._plot_particle_quantity(0, 7, "Ion Momentum Flux")

    def on_ion_eflux(self):
        self._plot_particle_quantity(0, 8, "Ion Energy Flux")

    def on_ep_density(self):
        self._plot_particle_quantity(2, 0, "EP Density")

    def on_ep_momentum(self):
        self._plot_particle_quantity(2, 2, "EP Momentum")

    def on_ep_energy(self):
        self._plot_particle_quantity(2, 4, "EP Energy")

    def on_ep_pmflux(self):
        self._plot_particle_quantity(2, 7, "EP Momentum Flux")

    def on_ep_eflux(self):
        self._plot_particle_quantity(2, 8, "EP Energy Flux")

    def on_ele_density(self):
        self._plot_particle_quantity(1, 0, "Electron Density")

    def on_ele_momentum(self):
        self._plot_particle_quantity(1, 2, "Electron Momentum")

    def on_ele_energy(self):
        self._plot_particle_quantity(1, 4, "Electron Energy")

    def on_ele_pmflux(self):
        self._plot_particle_quantity(1, 7, "Electron Momentum Flux")

    def on_ele_eflux(self):
        self._plot_particle_quantity(1, 8, "Electron Energy Flux")

    def _plot_particle_quantity(self, species_idx, quantity_idx, title):
        """Helper to plot a particle quantity"""
        if not self.context or not self.history_reader:
            return

        data = self.context.history_data.particle_data[:, quantity_idx, species_idx]
        time = self.history_reader.data.time

        species_names = ['Ion', 'Electron', 'EP']
        species = species_names[species_idx] if species_idx < len(species_names) else f"Species {species_idx}"

        fig = Figure(figsize=(10, 8))
        fig.patch.set_facecolor('#0d1117')
        ax = fig.add_subplot(111)
        ax.plot(time, data, linewidth=2, color=self.history_plotter.COLORS['primary'])
        ax.set_xlabel("Time (R₀/cₛ)", fontsize=12)
        ax.set_ylabel("Amplitude", fontsize=12)
        ax.set_title(f"{species} - {title}", fontsize=14, fontweight='bold')
        ax.grid(True, alpha=0.3, linestyle='--')
        fig.tight_layout()

        self.open_plot_window(fig, f"{species} - {title}")

    def on_time_range(self):
        QMessageBox.information(
            self, "Time Range",
            "Time range selection will be implemented in a future update."
        )

    def on_freq_range(self):
        QMessageBox.information(
            self, "Frequency Range",
            "Frequency range selection will be implemented in a future update."
        )

    def on_clear_all(self):
        """Close all open plot windows"""
        for window in self.open_windows:
            window.close()
        self.open_windows = []
        self.statusbar.showMessage("All plot windows closed")

    def on_back_to_main(self):
        """Reset to main view"""
        self.on_clear_all()
        self.statusbar.showMessage("Ready")
