#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GTC Data Analysis Example
Demonstrates Python replacement for MATLAB history.m GUI
"""

import sys
import numpy as np
from pathlib import Path

# Add parent directory to path so we can import gtc module
sys.path.insert(0, str(Path(__file__).parent.parent))

from gtc import create_context, HistoryPlotter


def main():
    # Example data path - change this to your GTC data directory
    data_path = Path(__file__).parent.parent / "data"
    
    print("=" * 60)
    print("GTC Data Analysis - Python Example")
    print("=" * 60)
    
    # Check if history.out exists
    history_file = data_path / "history.out"
    if not history_file.exists():
        print(f"\nNo history.out found at {data_path}")
        print("Please place your GTC data files in the matlab/ directory")
        print("\nExpected files:")
        print("  - history.out    : Time history data")
        print("  - gtc.out        : GTC output parameters")
        print("  - snap*.out      : Snapshot data (optional)")
        return
    
    # Load all data
    print(f"\nLoading data from: {data_path}")
    ctx = create_context(str(data_path))

    print("\n✓ GTC Parameters loaded:")
    if ctx.params:
        print(f"  - mstep: {ctx.params.mstep}")
        print(f"  - ndiag: {ctx.params.ndiag}")
        print(f"  - dt0: {ctx.params.dt0}")
        print(f"  - mpsi: {ctx.params.mpsi}")
        print(f"  - mtoroidal: {ctx.params.mtoroidal}")
        
        # Calculate dt from gtc.out parameters
        dt = ctx.params.dt0 * ctx.params.ndiag if ctx.params.dt0 > 0 else 1.0
        print(f"  - dt (dt0*ndiag): {dt}")
    else:
        dt = 1.0

    print("\n✓ History data loaded:")
    if ctx.history_data:
        header = ctx.history_data.header
        print(f"  - Time steps: {header.ntime}")
        print(f"  - Species: {header.nspecies}")
        print(f"  - Fields: {header.nfield}")
        print(f"  - Modes: {header.modes}")

        # Re-read history with correct dt
        from gtc.history_reader import HistoryReader
        reader = HistoryReader(str(data_path / 'history.out'))
        reader.data = ctx.history_data
        # Update time array with correct dt
        reader.data.time = np.arange(1, header.ntime + 1) * dt
        
        # Create plotter
        plotter = HistoryPlotter(ctx.history_data)
        
        # Example 1: Plot field time evolution
        print("\n📈 Creating field time evolution plot...")
        fig1 = plotter.plot_field_time(
            field_idx=0,  # phi
            title="Phi Field Time Evolution"
        )
        fig1.savefig(data_path / "example_field_time.png", dpi=150)
        print(f"  Saved: {data_path / 'example_field_time.png'}")
        
        # Example 2: Plot mode evolution with spectrum
        if header.modes > 0:
            print("\n📈 Creating mode evolution plot...")
            fig2 = plotter.plot_mode_evolution(
                field_idx=0,  # phi
                mode_idx=0    # Mode 1
            )
            fig2.savefig(data_path / "example_mode_evolution.png", dpi=150)
            print(f"  Saved: {data_path / 'example_mode_evolution.png'}")
        
        # Example 3: Plot particle data
        print("\n📈 Creating particle diagnostics plot...")
        fig3 = plotter.plot_particle_data(
            species_idx=0  # Ion
        )
        fig3.savefig(data_path / "example_ion_diag.png", dpi=150)
        print(f"  Saved: {data_path / 'example_ion_diag.png'}")
        
        # Example 4: Calculate growth rate and frequency for all 8 modes
        print("\n📊 Calculating growth rate and frequency for all 8 modes...")
        
        print("\n    Field: phi")
        print("    " + "-" * 56)
        for mode_idx in range(8):
            gamma, omega, info = reader.get_growth_rate(field_idx=0, mode_idx=mode_idx)
            marker = "★" if info['r2_best'] > 0.99 else " "
            print(f"    {marker} Mode {mode_idx+1:2d}: γ={gamma:8.6f}, ω={omega:8.6f}, R²={info['r2_best']:.4f}")
        
        # Convert to physical units if parameters available
        if ctx.params and ctx.params.utime > 0:
            print(f"\n    Conversion: 1 (R₀/cₛ)⁻¹ = {ctx.frequency_gtc_axis:.6e} rad/s")
    
    print("\n" + "=" * 60)
    print("Example completed successfully!")
    print("=" * 60)
    print("\nNext steps:")
    print("  1. Run the GUI: python main.py")
    print("  2. Load your GTC data files")
    print("  3. Explore the interactive plots")


if __name__ == "__main__":
    main()
