#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GTC Data Analysis Package

Python reimplementation of MATLAB GTC data processing GUI
By Hua-sheng XIE & Yuehao Ma

Usage:
    from gtc import create_context, HistoryPlotter

    # Load all data
    ctx = create_context("/path/to/gtc/data")

    # Plot history data
    if ctx.history_data:
        plotter = HistoryPlotter(ctx.history_data)
        fig = plotter.plot_mode_evolution(field_idx=0, mode_idx=0)
"""

from .history_reader import HistoryReader, HistoryData, HistoryHeader
from .gtc_reader import GTCParameters, GTCOutputReader, read_gtc_parameters
from .context import GTCContext, create_context
from .history_plotter import HistoryPlotter
from .snapshot_reader import SnapshotReader, SnapshotData, SnapshotHeader
from .equilibrium_reader import EquilibriumReader, ProfileData, SpdataData

__version__ = "1.0.0"
__all__ = [
    # Core data structures
    "HistoryData",
    "HistoryHeader",
    "GTCParameters",
    "GTCContext",
    "SnapshotData",
    "SnapshotHeader",
    "ProfileData",
    "SpdataData",

    # Readers
    "HistoryReader",
    "GTCOutputReader",
    "SnapshotReader",
    "EquilibriumReader",

    # Utilities
    "read_gtc_parameters",
    "create_context",
    "HistoryPlotter",
]
