#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Snapshot Analysis Panel
Based on MATLAB snapshot.m by Hua-sheng XIE & Yuehao Ma
"""

from PyQt6.QtWidgets import (QWidget, QVBoxLayout, QHBoxLayout, QGridLayout,
                             QPushButton, QLabel, QFileDialog, QScrollArea,
                             QLineEdit, QStatusBar, QMessageBox, QDialog,
                             QApplication, QTabWidget)
from PyQt6.QtCore import Qt
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

from gtc.snapshot_reader import SnapshotReader


class PlotWindow(QDialog):
    """Independent plot window with save/export/copy options"""

    def __init__(self, fig, title, parent=None):
        super().__init__(parent)
        self.setWindowTitle(title)
        self.setMinimumSize(900, 600)
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


class SpectrumWindow(QDialog):
    """Spectrum analysis window with multiple tabs and fullscreen support"""
    
    def __init__(self, figs, titles, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Spectrum Analysis")
        self.setMinimumSize(1200, 800)
        self.setStyleSheet("""
            QDialog {
                background-color: #ffffff;
            }
        """)
        
        self.figures = figs
        self.canvas_list = []
        self.is_fullscreen = False
        self.original_geometry = None
        
        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        
        # Tab widget
        self.tabs = QTabWidget()
        self.tabs.setStyleSheet("""
            QTabWidget::pane {
                border: 1px solid #cccccc;
                background-color: #ffffff;
            }
            QTabBar::tab {
                background-color: #f5f5f5;
                color: #333333;
                padding: 10px 20px;
                margin: 2px;
                border-radius: 4px;
                font-weight: bold;
                border: 1px solid #cccccc;
            }
            QTabBar::tab:selected {
                background-color: #ffffff;
                color: #1f77b4;
                border-bottom: 1px solid #ffffff;
            }
            QTabBar::tab:hover {
                background-color: #e8e8e8;
            }
        """)
        
        for i, (fig, title) in enumerate(zip(figs, titles)):
            canvas = FigureCanvas(fig)
            canvas.setStyleSheet("background-color: #ffffff;")
            self.canvas_list.append(canvas)
            self.tabs.addTab(canvas, title)
        
        layout.addWidget(self.tabs)
        
        # Toolbar at bottom
        toolbar_layout = QHBoxLayout()
        toolbar_layout.setContentsMargins(10, 10, 10, 10)
        
        save_btn = QPushButton("💾 Save Plot")
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
        save_btn.clicked.connect(self.save_current_plot)
        
        fullscreen_btn = QPushButton("⛶ Fullscreen")
        fullscreen_btn.setStyleSheet("""
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
        toolbar_layout.addWidget(fullscreen_btn)
        toolbar_layout.addWidget(close_btn)
        toolbar_layout.addStretch()
        
        layout.addLayout(toolbar_layout)
    
    def save_current_plot(self):
        """Save current plot to file"""
        from PyQt6.QtWidgets import QFileDialog
        current_idx = self.tabs.currentIndex()
        fig = self.figures[current_idx]
        
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
    
    def toggle_fullscreen(self):
        """Toggle fullscreen mode"""
        if self.is_fullscreen:
            self.showNormal()
            self.is_fullscreen = False
        else:
            self.original_geometry = self.geometry()
            self.showFullScreen()
            self.is_fullscreen = True
    
    def closeEvent(self, event):
        """Handle window close"""
        if self.is_fullscreen:
            self.showNormal()
        event.accept()


class SnapshotPanel(QWidget):
    """Snapshot data analysis panel"""

    def __init__(self):
        super().__init__()
        self.snapshot_reader = None
        self.open_windows = []

        self.init_ui()

    def init_ui(self):
        """Initialize the UI"""
        layout = QVBoxLayout(self)
        layout.setContentsMargins(15, 15, 15, 15)
        layout.setSpacing(15)

        # Header
        header = QLabel("📊 Snapshot Data Analysis")
        header.setStyleSheet("""
            font-size: 24px;
            font-weight: bold;
            color: #1f77b4;
            padding: 10px;
        """)
        layout.addWidget(header)

        # File selection
        file_layout = QHBoxLayout()
        file_label = QLabel("Data File:")
        file_label.setStyleSheet("color: #333333; font-size: 14px; font-weight: bold;")

        self.file_path = QLineEdit()
        self.file_path.setPlaceholderText("Select snap*.out file...")
        self.file_path.setStyleSheet("""
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
        """)
        self.btn_browse.clicked.connect(self.browse_file)

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
        """)
        self.btn_load.clicked.connect(self.load_data)

        file_layout.addWidget(file_label)
        file_layout.addWidget(self.file_path)
        file_layout.addWidget(self.btn_browse)
        file_layout.addWidget(self.btn_load)
        layout.addLayout(file_layout)

        # Status label
        self.status_label = QLabel("Ready - Load snapshot file to begin")
        self.status_label.setStyleSheet("""
            color: #666666;
            padding: 5px;
            background-color: #f5f5f5;
            border-radius: 4px;
            border-left: 3px solid #1f77b4;
        """)
        layout.addWidget(self.status_label)

        # Button grid
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

        # Button definitions
        buttons = [
            # Row 1 - Ion
            (0, 0, "🧊 Density", lambda: self.on_profile(0, 0), 100),
            (0, 1, "💨 Flow", lambda: self.on_profile(0, 1), 100),
            (0, 2, "⚡ Energy", lambda: self.on_profile(0, 2), 100),
            (0, 3, "📈 PDF-E", lambda: self.on_pdf(0, 0), 100),
            (0, 4, "📐 PDF-λ", lambda: self.on_pdf(0, 1), 100),

            # Row 2 - Electron
            (1, 0, "🧊 Density", lambda: self.on_profile(1, 0), 100),
            (1, 1, "💨 Flow", lambda: self.on_profile(1, 1), 100),
            (1, 2, "⚡ Energy", lambda: self.on_profile(1, 2), 100),
            (1, 3, "📈 PDF-E", lambda: self.on_pdf(1, 0), 100),
            (1, 4, "📐 PDF-λ", lambda: self.on_pdf(1, 1), 100),

            # Row 3 - EP
            (2, 0, "🧊 Density", lambda: self.on_profile(2, 0), 100),
            (2, 1, "💨 Flow", lambda: self.on_profile(2, 1), 100),
            (2, 2, "⚡ Energy", lambda: self.on_profile(2, 2), 100),
            (2, 3, "📈 PDF-E", lambda: self.on_pdf(2, 0), 100),
            (2, 4, "📐 PDF-λ", lambda: self.on_pdf(2, 1), 100),

            # Row 4 - Phi
            (3, 0, "Φ Flux", lambda: self.on_flux(0), 100),
            (3, 1, "Φ Spectrum", lambda: self.on_spectrum_full(0), 100),
            (3, 2, "Φ Poloidal", lambda: self.on_poloidal(0), 100),
            (3, 3, "Φ r/a", lambda: self.on_radial_profile(0), 100),
            (3, 4, "", lambda: None, 100),

            # Row 5 - A-para
            (4, 0, "A‖ Flux", lambda: self.on_flux(1), 100),
            (4, 1, "A‖ Spectrum", lambda: self.on_spectrum_full(1), 100),
            (4, 2, "A‖ Poloidal", lambda: self.on_poloidal(1), 100),
            (4, 3, "A‖ r/a", lambda: self.on_radial_profile(1), 100),
            (4, 4, "", lambda: None, 100),

            # Row 6 - Fluidne
            (5, 0, "nₑ Flux", lambda: self.on_flux(2), 100),
            (5, 1, "nₑ Spectrum", lambda: self.on_spectrum_full(2), 100),
            (5, 2, "nₑ Poloidal", lambda: self.on_poloidal(2), 100),
            (5, 3, "nₑ r/a", lambda: self.on_radial_profile(2), 100),
            (5, 4, "", lambda: None, 100),

            # Row 7 - Controls
            (6, 0, "❌ Clear All", self.on_clear_all, 100),
            (6, 1, "🔙 To Main", self.on_back_to_main, 100),
            (6, 2, "", lambda: None, 100),
            (6, 3, "", lambda: None, 100),
            (6, 4, "", lambda: None, 100),
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
            btn.clicked.connect(callback)
            btn.setEnabled(False)
            button_layout.addWidget(btn, row, col)

        # Store button references
        self.buttons = []
        for i in range(button_layout.count()):
            widget = button_layout.itemAt(i).widget()
            if isinstance(widget, QPushButton):
                self.buttons.append(widget)

        scroll.setWidget(button_widget)
        layout.addWidget(scroll)

        # Status bar
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

    def browse_file(self):
        """Open file dialog to select snapshot file"""
        from PyQt6.QtWidgets import QFileDialog
        file_name, _ = QFileDialog.getOpenFileName(
            self, "Select Snapshot File", "",
            "GTC Snapshot Files (*.out);;All Files (*)"
        )
        if file_name:
            self.file_path.setText(file_name)

    def load_data(self):
        """Load and parse snapshot data"""
        file_path = self.file_path.text().strip()
        if not file_path:
            QMessageBox.warning(self, "No File", "Please select a snapshot file first.")
            return

        try:
            self.statusbar.showMessage(f"Loading: {file_path}")
            QApplication.processEvents()

            self.snapshot_reader = SnapshotReader(file_path)
            self.snapshot_reader.read()

            header = self.snapshot_reader.data.header
            self.status_label.setText(
                f"✓ Loaded: {header.nspecies} species, {header.nfield} fields, "
                f"{header.mpsi+1} ψ, {header.mtgrid+1} θ, {header.mtoroidal} ζ"
            )
            self.status_label.setStyleSheet("""
                color: #3fb950;
                padding: 5px;
                background-color: #f0f7ff;
                border-radius: 4px;
                border-left: 3px solid #2ca02c;
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

    def on_profile(self, species_idx: int, quantity_idx: int):
        """Plot profile (density/flow/energy)"""
        if not self.snapshot_reader:
            return
        
        species_names = ['Ion', 'Electron', 'EP']
        quantity_names = ['Density', 'Flow', 'Energy']
        title = f"{species_names[species_idx]} - {quantity_names[quantity_idx]}"
        
        try:
            fig = self.snapshot_reader.get_profile_plot(species_idx, quantity_idx, title)
            self.open_plot_window(fig, title)
        except Exception as e:
            self.statusbar.showMessage(f"Error: {e}")

    def on_pdf(self, species_idx: int, energy_idx: int):
        """Plot PDF in energy or pitch angle"""
        if not self.snapshot_reader:
            return
        
        species_names = ['Ion', 'Electron', 'EP']
        pdf_types = ['Energy', 'Pitch Angle']
        title = f"{species_names[species_idx]} - PDF in {pdf_types[energy_idx]}"
        
        try:
            fig = self.snapshot_reader.get_pdf_plot(species_idx, energy_idx, title)
            self.open_plot_window(fig, title)
        except Exception as e:
            self.statusbar.showMessage(f"Error: {e}")

    def on_flux(self, field_idx: int):
        """Plot flux surface"""
        if not self.snapshot_reader:
            return
        
        field_names = ['Phi', 'A-para', 'Fluidne']
        title = f"{field_names[field_idx]} on Flux Surface"
        
        try:
            fig = self.snapshot_reader.get_flux_surface_plot(field_idx, title)
            self.open_plot_window(fig, title)
        except Exception as e:
            self.statusbar.showMessage(f"Error: {e}")

    def on_spectrum_full(self, field_idx: int):
        """Open spectrum analysis window with multiple tabs"""
        if not self.snapshot_reader:
            return
        
        field_names = ['Phi', 'A-para', 'Fluidne']
        
        try:
            figs, titles = self.snapshot_reader.get_spectrum_plots(field_idx)
            # Prefix titles with field name
            titles = [f"{field_names[field_idx]} - {t}" for t in titles]
            
            window = SpectrumWindow(figs, titles, self)
            window.show()
            self.open_windows.append(window)
            self.statusbar.showMessage(f"Opened spectrum analysis: {field_names[field_idx]}")
        except Exception as e:
            import traceback
            traceback.print_exc()
            self.statusbar.showMessage(f"Error: {e}")

    def on_poloidal(self, field_idx: int):
        """Plot poloidal contour"""
        if not self.snapshot_reader:
            return
        
        field_names = ['Phi', 'A-para', 'Fluidne']
        title = f"{field_names[field_idx]} on Poloidal Plane"
        
        try:
            fig = self.snapshot_reader.get_poloidal_plot(field_idx, title)
            self.open_plot_window(fig, title)
        except Exception as e:
            self.statusbar.showMessage(f"Error: {e}")

    def on_theta_profile(self, field_idx: int):
        """Plot poloidal profile (theta) with point value and RMS"""
        if not self.snapshot_reader:
            return
        
        field_names = ['Phi', 'A-para', 'Fluidne']
        title = f"{field_names[field_idx]} Poloidal Profile"
        
        try:
            fig = self.snapshot_reader.get_poloidal_profile_plot(field_idx, title=title)
            self.open_plot_window(fig, title)
        except Exception as e:
            self.statusbar.showMessage(f"Error: {e}")

    def on_radial_profile(self, field_idx: int):
        """Plot radial (r/a) profile with point value and RMS"""
        if not self.snapshot_reader:
            return
        
        field_names = ['Phi', 'A-para', 'Fluidne']
        title = f"{field_names[field_idx]} Radial Profile"
        
        try:
            fig = self.snapshot_reader.get_radial_profile_plot(field_idx, title)
            self.open_plot_window(fig, title)
        except Exception as e:
            self.statusbar.showMessage(f"Error: {e}")

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
