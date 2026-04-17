#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Equilibrium Analysis Panel
Based on MATLAB cal_spdata.m and cal_prodata.m
"""

from PyQt6.QtWidgets import (QWidget, QVBoxLayout, QHBoxLayout, QGridLayout,
                             QPushButton, QLabel, QFileDialog, QScrollArea,
                             QLineEdit, QStatusBar, QMessageBox, QDialog,
                             QApplication)
from PyQt6.QtCore import Qt
import sys
from pathlib import Path
from io import BytesIO
import numpy as np
import matplotlib
matplotlib.use('QtAgg')
import matplotlib.pyplot as plt
from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent))

from gtc.equilibrium_reader import EquilibriumReader


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


class EquilibriumPanel(QWidget):
    """Equilibrium data analysis panel"""

    def __init__(self):
        super().__init__()
        self.eq_reader = None
        self.open_windows = []

        self.init_ui()

    def init_ui(self):
        """Initialize the UI"""
        layout = QVBoxLayout(self)
        layout.setContentsMargins(15, 15, 15, 15)
        layout.setSpacing(15)

        # Header
        header = QLabel("⚖️ Equilibrium Analysis")
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
        """)
        self.btn_load.clicked.connect(self.load_data)

        file_layout.addWidget(file_label)
        file_layout.addWidget(self.dir_path)
        file_layout.addWidget(self.btn_browse)
        file_layout.addWidget(self.btn_load)
        layout.addLayout(file_layout)

        # Status label
        self.status_label = QLabel("Ready - Load equilibrium data to begin")
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
            # Row 1 - Density profiles
            (0, 0, "🧊 ne", lambda: self.on_density('ne'), 80),
            (0, 1, "🧊 ni", lambda: self.on_density('ni'), 80),
            (0, 2, "🧊 nf", lambda: self.on_density('nf'), 80),
            (0, 3, "🧊 nα", lambda: self.on_density('na'), 80),

            # Row 2 - Temperature profiles
            (1, 0, "🌡️ Te", lambda: self.on_temperature('Te'), 80),
            (1, 1, "🌡️ Ti", lambda: self.on_temperature('Ti'), 80),
            (1, 2, "🌡️ Tf", lambda: self.on_temperature('Tf'), 80),
            (1, 3, "🌡️ Tα", lambda: self.on_temperature('Ta'), 80),

            # Row 3 - Pressure profiles
            (2, 0, "📈 Pe", lambda: self.on_pressure('Pe'), 80),
            (2, 1, "📈 Pi", lambda: self.on_pressure('Pi'), 80),
            (2, 2, "📈 Pf", lambda: self.on_pressure('Pf'), 80),
            (2, 3, "📈 Pα", lambda: self.on_pressure('Pa'), 80),

            # Row 4 - Equilibrium
            (3, 0, "q Profile", self.on_q_profile, 100),
            (3, 1, "Beta", self.on_beta, 100),
            (3, 2, "", lambda: None, 100),
            (3, 3, "", lambda: None, 100),

            # Row 5 - Controls
            (4, 0, "📊 All Profiles", self.on_all_profiles, 120),
            (4, 1, "❌ Clear All", self.on_clear_all, 120),
            (4, 2, "🔙 To Main", self.on_back_to_main, 120),
            (4, 3, "", lambda: None, 120),
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

    def browse_directory(self):
        """Open dialog to select data directory"""
        from PyQt6.QtWidgets import QFileDialog
        dir_name = QFileDialog.getExistingDirectory(
            self, "Select GTC Data Directory", "",
            QFileDialog.Option.ShowDirsOnly
        )
        if dir_name:
            self.dir_path.setText(dir_name)

    def load_data(self):
        """Load equilibrium data"""
        data_dir = self.dir_path.text().strip()
        if not data_dir:
            QMessageBox.warning(self, "No Directory", "Please select a data directory first.")
            return

        data_path = Path(data_dir)
        profile_file = data_path / "profile.dat"
        spdata_file = data_path / "spdata.dat"

        if not profile_file.exists():
            QMessageBox.warning(self, "File Not Found", f"profile.dat not found in:\n{data_dir}")
            return

        try:
            self.statusbar.showMessage(f"Loading equilibrium data from {data_dir}...")
            QApplication.processEvents()

            self.eq_reader = EquilibriumReader(str(data_path))
            self.eq_reader.read_profile()
            
            if spdata_file.exists():
                self.eq_reader.read_spdata()

            self.status_label.setText(
                f"✓ Loaded: {len(self.eq_reader.profile_data.psi)} radial points"
            )
            self.status_label.setStyleSheet("""
                color: #3fb950;
                padding: 5px;
                background-color: #f0f7ff;
                border-radius: 4px;
                border-left: 3px solid #2ca02c;
            """)

            self.set_buttons_enabled(True)
            self.statusbar.showMessage("Equilibrium data loaded successfully!")

        except Exception as e:
            QMessageBox.critical(self, "Error", f"Failed to load data:\n{str(e)}")
            self.statusbar.showMessage("Error loading data")

    def open_plot_window(self, fig, title):
        """Open a new independent plot window"""
        window = PlotWindow(fig, title, self)
        window.show()
        self.open_windows.append(window)
        self.statusbar.showMessage(f"Opened: {title}")

    def _get_r_over_a(self):
        """Get normalized radius r/a"""
        if not self.eq_reader or not self.eq_reader.profile_data:
            return None
        r = self.eq_reader.profile_data.r
        return r / r[-1] if r[-1] != 0 else r

    def on_density(self, species):
        """Plot density profile"""
        if not self.eq_reader or not self.eq_reader.profile_data:
            return
        
        r_n = self._get_r_over_a()
        if r_n is None:
            return
        
        p = self.eq_reader.profile_data
        
        fig, ax = plt.subplots(figsize=(8, 6))
        fig.patch.set_facecolor('white')
        ax.set_facecolor('white')
        
        species_map = {
            'ne': ('Electron Density', 'k-', r'$n_e$'),
            'ni': ('Ion Density', 'b-', r'$n_i$'),
            'nf': ('Fast Ion Density', 'r-', r'$n_f$'),
            'na': ('Alpha Density', 'm-', r'$n_\alpha$')
        }
        
        title, style, label = species_map.get(species, ('Density', 'k-', 'n'))
        data = getattr(p, species) * 1e6  # Convert to m^-3
        
        ax.plot(r_n, data, style, linewidth=1.5, label=label)
        ax.set_xlabel('$r/a$', fontsize=14)
        ax.set_ylabel(f'{label} [m$^{{-3}}$]', fontsize=12)
        ax.set_title(title, fontsize=14, fontweight='bold')
        ax.grid(True, alpha=0.3, linestyle='--')
        ax.set_xlim([0, 1])
        
        plt.tight_layout()
        self.open_plot_window(fig, title)

    def on_temperature(self, species):
        """Plot temperature profile"""
        if not self.eq_reader or not self.eq_reader.profile_data:
            return
        
        r_n = self._get_r_over_a()
        if r_n is None:
            return
        
        p = self.eq_reader.profile_data
        
        fig, ax = plt.subplots(figsize=(8, 6))
        fig.patch.set_facecolor('white')
        ax.set_facecolor('white')
        
        species_map = {
            'Te': ('Electron Temperature', 'k-', r'$T_e$'),
            'Ti': ('Ion Temperature', 'b-', r'$T_i$'),
            'Tf': ('Fast Ion Temperature', 'r-', r'$T_f$'),
            'Ta': ('Alpha Temperature', 'm-', r'$T_\alpha$')
        }
        
        title, style, label = species_map.get(species, ('Temperature', 'k-', 'T'))
        data = getattr(p, species)
        
        ax.plot(r_n, data, style, linewidth=1.5, label=label)
        ax.set_xlabel('$r/a$', fontsize=14)
        ax.set_ylabel(f'{label} [eV]', fontsize=12)
        ax.set_title(title, fontsize=14, fontweight='bold')
        ax.grid(True, alpha=0.3, linestyle='--')
        ax.set_xlim([0, 1])
        
        plt.tight_layout()
        self.open_plot_window(fig, title)

    def on_pressure(self, species):
        """Plot pressure profile"""
        if not self.eq_reader or not self.eq_reader.profile_data:
            return
        
        r_n = self._get_r_over_a()
        if r_n is None:
            return
        
        p = self.eq_reader.profile_data
        
        # Calculate pressure: P = n * T * eV_to_Pa_conversion
        # P [Pa] = n [10^6 m^-3] * T [eV] * 1e6 * 1.602e-19
        eV_to_Pa = 1.602e-19
        
        species_map = {
            'Pe': ('Electron Pressure', 'k-', r'$P_e$'),
            'Pi': ('Ion Pressure', 'b-', r'$P_i$'),
            'Pf': ('Fast Ion Pressure', 'r-', r'$P_f$'),
            'Pa': ('Alpha Pressure', 'm-', r'$P_\alpha$')
        }
        
        n_key = species[0] + 'n' if species[0] != 'n' else 'n'
        t_key = species[0] + 'T' if species[0] != 'T' else 'T'
        
        if species == 'Pe':
            n_data = p.ne * 1e6
            T_data = p.Te
        elif species == 'Pi':
            n_data = p.ni * 1e6
            T_data = p.Ti
        elif species == 'Pf':
            n_data = p.nf * 1e6
            T_data = p.Tf
        elif species == 'Pa':
            n_data = p.na * 1e6
            T_data = p.Ta
        else:
            return
        
        P_data = n_data * T_data * eV_to_Pa
        
        title, style, label = species_map.get(species, ('Pressure', 'k-', 'P'))
        
        fig, ax = plt.subplots(figsize=(8, 6))
        fig.patch.set_facecolor('white')
        ax.set_facecolor('white')
        
        ax.plot(r_n, P_data, style, linewidth=1.5, label=label)
        ax.set_xlabel('$r/a$', fontsize=14)
        ax.set_ylabel(f'{label} [Pa]', fontsize=12)
        ax.set_title(title, fontsize=14, fontweight='bold')
        ax.grid(True, alpha=0.3, linestyle='--')
        ax.set_xlim([0, 1])
        
        plt.tight_layout()
        self.open_plot_window(fig, title)

    def on_q_profile(self):
        """Plot q profile and magnetic shear"""
        try:
            if not self.eq_reader or not self.eq_reader.spdata_data:
                self.statusbar.showMessage("Error: Spdata not loaded")
                return
            
            sp = self.eq_reader.spdata_data
            
            self.statusbar.showMessage("Plotting q profile...")
            
            # Get r/a from spdata (use first spline point, all psi)
            r_sp = sp.rpsi[0, 1:-1]
            r_n = r_sp / r_sp[-1] if r_sp[-1] != 0 else r_sp
            
            # Get q profile (first spline point)
            q = sp.qpsi[0, 1:-1]
            
            # Get psi for shear calculation
            psi = sp.psi[1:-1]
            
            # Calculate shear: s = (psi/q) * dq/dpsi
            dq_dpsi = np.gradient(q, psi)
            s_profile = (psi / q) * dq_dpsi
            
            fig, ax1 = plt.subplots(figsize=(10, 6))
            fig.patch.set_facecolor('white')
            ax1.set_facecolor('white')
            
            # Plot q profile
            line1 = ax1.plot(r_n, q, 'b-', linewidth=2, label='q')
            ax1.set_xlabel('r/a', fontsize=14)
            ax1.set_ylabel('Safety Factor q', fontsize=12, color='b')
            ax1.tick_params(axis='y', labelcolor='b')
            ax1.grid(True, alpha=0.3, linestyle='--')
            
            # Plot shear on secondary axis
            ax2 = ax1.twinx()
            ax2.set_facecolor('white')
            line2 = ax2.plot(r_n, s_profile, 'r-', linewidth=2, label='s')
            ax2.set_ylabel('Magnetic Shear s', fontsize=12, color='r')
            ax2.tick_params(axis='y', labelcolor='r')
            
            # Combined title
            fig.suptitle('Equilibrium Profiles & Magnetic Shear', fontsize=14, fontweight='bold')
            
            # Combined legend
            lines = line1 + line2
            labels = [l.get_label() for l in lines]
            ax1.legend(lines, labels, loc='upper right')
            
            plt.tight_layout()
            self.open_plot_window(fig, 'q Profile & Shear')
            self.statusbar.showMessage("q profile plot opened")
        except Exception as e:
            import traceback
            error_msg = f"Error plotting q profile: {e}\n{traceback.format_exc()}"
            self.statusbar.showMessage(f"Error: {e}")
            QMessageBox.critical(self, "Error", error_msg)

    def on_beta(self):
        """Plot beta profile"""
        try:
            if not self.eq_reader or not self.eq_reader.profile_data or not self.eq_reader.spdata_data:
                self.statusbar.showMessage("Error: Data not loaded")
                return
            
            p = self.eq_reader.profile_data
            sp = self.eq_reader.spdata_data
            
            self.statusbar.showMessage("Plotting beta...")
            
            r_n = self._get_r_over_a()
            
            # Calculate pressure in Pa
            eV_to_Pa = 1.602e-19
            Pe = p.Te * p.ne * 1e6 * eV_to_Pa
            Pi = p.Ti * p.ni * 1e6 * eV_to_Pa
            Pf = p.Tf * p.nf * 1e6 * eV_to_Pa
            Pa = p.Ta * p.na * 1e6 * eV_to_Pa
            P_total = Pe + Pi + Pf + Pa
            
            # Get B field for beta calculation
            # bsp shape: (spdim_2d, lsp+1, lst+1)
            B_raw = sp.bsp[0, 1:-1, :-1].mean(axis=1)  # Shape: (lsp,)
            r_sp = sp.rpsi[0, 1:-1]  # Shape: (lsp,)
            r_n_sp = r_sp / r_sp[-1] if r_sp[-1] != 0 else r_sp
            
            # Interpolate B to profile grid
            B_on_P_grid = np.interp(r_n, r_n_sp, B_raw)
            
            # Calculate beta: beta = P / (B^2 / 2*mu0)
            mu0 = 4 * np.pi * 1e-7
            beta_e = Pe / (B_on_P_grid**2 / (2 * mu0)) * 100  # In percent
            beta_i = Pi / (B_on_P_grid**2 / (2 * mu0)) * 100
            beta_f = Pf / (B_on_P_grid**2 / (2 * mu0)) * 100
            beta_a = Pa / (B_on_P_grid**2 / (2 * mu0)) * 100
            beta_total = beta_e + beta_i + beta_f + beta_a
            
            fig, ax = plt.subplots(figsize=(10, 6))
            fig.patch.set_facecolor('white')
            ax.set_facecolor('white')
            
            ax.plot(r_n, beta_total, 'k-', linewidth=1.5, label='beta_total')
            ax.plot(r_n, beta_e, 'b-', linewidth=1.5, label='beta_e')
            ax.plot(r_n, beta_i, 'g-', linewidth=1.5, label='beta_i')
            ax.plot(r_n, beta_f, 'r-', linewidth=1.5, label='beta_f')
            ax.plot(r_n, beta_a, 'm-', linewidth=1.5, label='beta_alpha')
            
            ax.set_xlabel('r/a', fontsize=14)
            ax.set_ylabel('Beta', fontsize=12)
            ax.set_title('Beta Profiles', fontsize=14, fontweight='bold')
            ax.grid(True, alpha=0.3, linestyle='--')
            ax.legend(loc='upper right')
            ax.set_xlim([0, 1])
            
            plt.tight_layout()
            self.open_plot_window(fig, 'Beta Profiles')
            self.statusbar.showMessage("Beta plot opened")
        except Exception as e:
            import traceback
            error_msg = f"Error plotting beta: {e}\n{traceback.format_exc()}"
            self.statusbar.showMessage(f"Error: {e}")
            QMessageBox.critical(self, "Error", error_msg)

    def on_all_profiles(self):
        """Plot all density and temperature profiles in one figure"""
        if not self.eq_reader or not self.eq_reader.profile_data:
            return
        
        r_n = self._get_r_over_a()
        if r_n is None:
            return
        
        p = self.eq_reader.profile_data
        
        fig, axes = plt.subplots(2, 4, figsize=(16, 8))
        fig.patch.set_facecolor('white')
        
        # Density profiles
        densities = [
            ('ne', 'Electron', 'k-'),
            ('ni', 'Ion', 'b-'),
            ('nf', 'Fast Ion', 'r-'),
            ('na', 'Alpha', 'm-')
        ]
        
        for idx, (key, label, style) in enumerate(densities):
            ax = axes[0, idx]
            ax.set_facecolor('white')
            data = getattr(p, key) * 1e6
            ax.plot(r_n, data, style, linewidth=1.5)
            ax.set_xlabel('$r/a$', fontsize=12)
            ax.set_ylabel(f'$n_{key[0]}$ [m$^{{-3}}$]', fontsize=12)
            ax.set_title(f'{label} Density', fontsize=12, fontweight='bold')
            ax.grid(True, alpha=0.3, linestyle='--')
            ax.set_xlim([0, 1])
        
        # Temperature profiles
        temperatures = [
            ('Te', 'Electron', 'k-'),
            ('Ti', 'Ion', 'b-'),
            ('Tf', 'Fast Ion', 'r-'),
            ('Ta', 'Alpha', 'm-')
        ]
        
        for idx, (key, label, style) in enumerate(temperatures):
            ax = axes[1, idx]
            ax.set_facecolor('white')
            data = getattr(p, key)
            ax.plot(r_n, data, style, linewidth=1.5)
            ax.set_xlabel('$r/a$', fontsize=12)
            ax.set_ylabel(f'$T_{key[0]}$ [eV]', fontsize=12)
            ax.set_title(f'{label} Temperature', fontsize=12, fontweight='bold')
            ax.grid(True, alpha=0.3, linestyle='--')
            ax.set_xlim([0, 1])
        
        fig.suptitle('Equilibrium Profiles', fontsize=16, fontweight='bold')
        plt.tight_layout()
        self.open_plot_window(fig, 'All Equilibrium Profiles')

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
