#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GTC Data Analysis GUI - Main Entry Point
Author: Albireo
Based on MATLAB GUI by Hua-sheng XIE & Yuehao Ma
"""

import sys
from PyQt6.QtWidgets import QApplication, QMainWindow, QTabWidget, QVBoxLayout, QWidget
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QFont

from history_panel import HistoryPanel
from snapshot_panel import SnapshotPanel
from equilibrium_panel import EquilibriumPanel


class GTCAnalysisGUI(QMainWindow):
    """Main window for GTC Analysis GUI"""

    def __init__(self):
        super().__init__()
        self.setWindowTitle("GTC Data Analysis")
        self.setMinimumSize(1200, 800)
        self.setStyleSheet("""
            QMainWindow {
                background-color: #ffffff;
            }
        """)
        
        # Central widget
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        layout = QVBoxLayout(central_widget)
        layout.setContentsMargins(10, 10, 10, 10)
        
        # Tab widget
        self.tabs = QTabWidget()
        self.tabs.setStyleSheet("""
            QTabWidget::pane {
                border: 1px solid #cccccc;
                background-color: #ffffff;
                border-radius: 4px;
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
        
        # Add tabs
        self.history_panel = HistoryPanel()
        self.snapshot_panel = SnapshotPanel()
        self.equilibrium_panel = EquilibriumPanel()

        self.tabs.addTab(self.history_panel, "📈 History Analysis")
        self.tabs.addTab(self.snapshot_panel, "📊 Snapshot Analysis")
        self.tabs.addTab(self.equilibrium_panel, "⚖️ Equilibrium")
        
        layout.addWidget(self.tabs)
        
        # Status bar
        self.statusBar().showMessage("Ready - Load GTC data file to begin")
        self.statusBar().setStyleSheet("""
            QStatusBar {
                color: #333333;
                background-color: #f5f5f5;
                border-top: 1px solid #cccccc;
                padding: 5px;
            }
        """)


def main():
    app = QApplication(sys.argv)
    app.setFont(QFont("Segoe UI", 10))
    
    # Set application style
    app.setStyle("Fusion")
    
    window = GTCAnalysisGUI()
    window.show()
    
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
