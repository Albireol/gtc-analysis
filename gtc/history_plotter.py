#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GTC History Data Plotting Utilities
Modern replacement for MATLAB history.m plotting functions

MATLAB layout (2x3):
┌─────────────────────────────────────────────────────────────┐
│ (231) history of real & imag components │ (234) log amplitude│
│     [Real/Imag vs Time]                  │ amplitude history │
│                                          ├──────────────────┤
│                                          │ (236) FFT spectrum│
├──────────────────────────────────────────┤ power spectral    │
│ (232) amplitude normalized by growth rate│                   │
│     [Growth rate fit with R²]            │                   │
└──────────────────────────────────────────┴───────────────────┘
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.figure import Figure
from typing import Optional, List, Tuple

from .history_reader import HistoryData


class HistoryPlotter:
    """Plotting utilities for GTC history data"""

    # Color scheme - Light background, high contrast (scientific publication style)
    COLORS = {
        'primary': '#1f77b4',      # Blue
        'secondary': '#ff7f0e',    # Orange
        'accent': '#d62728',       # Red
        'success': '#2ca02c',      # Green
        'warning': '#9467bd',      # Purple
        'danger': '#e377c2',       # Pink
        'grid': '#cccccc',         # Light gray
        'text': '#000000',         # Black
        'text_muted': '#666666',   # Dark gray
        'background': '#ffffff',   # White
        'figure_bg': '#ffffff'     # White
    }

    def __init__(self, data: HistoryData):
        self.data = data
        self.style_light()

    def style_light(self):
        """Apply light theme styling for scientific publication"""
        self.colors = self.COLORS

    def plot_mode_evolution(
        self,
        field_idx: int,
        mode_idx: int,
        figsize: Tuple[int, int] = (15, 7),
        tstep_ndiag: float = 1.0
    ) -> Figure:
        """
        Plot mode evolution with 2x3 layout (matching MATLAB history.m)
        
        Layout (subplot positions) - 2 rows x 3 columns:
        ┌─────────────────────────────────────────────────────────────────────┐
        │ (231) Real & Imag        │ (232) Normalized     │ (233) power       │
        │      components          │      by gamma        │      spectral     │
        ├──────────────────────────┼──────────────────────┼───────────────────┤
        │ (234) log10 amplitude    │ (235) omega_simple   │ (236) FFT         │
        │      history             │      (peak detect)   │      spectrum     │
        └──────────────────────────┴──────────────────────┴───────────────────┘

        Parameters
        ----------
        field_idx : int
            Field index (0=phi, 1=a_par, 2=fluidne)
        mode_idx : int
            Mode index (0-based)
        figsize : tuple
            Figure size (width, height)
        tstep_ndiag : float
            Time step * ndiag in R0/Cs units
        """
        from .history_reader import HistoryReader
        
        fig = plt.figure(figsize=figsize, facecolor='white', edgecolor='none')
        fig.patch.set_facecolor('white')

        # Get mode data
        yr = self.data.field_mode[:, 0, mode_idx, field_idx]
        yi = self.data.field_mode[:, 1, mode_idx, field_idx]
        time = self.data.time
        nt = len(time)
        
        # Calculate amplitude
        amplitude = np.sqrt(yr**2 + yi**2)
        amplitude = np.clip(amplitude, 1e-20, None)
        log_amp = np.log10(amplitude)
        ln_amp = np.log(amplitude)

        # Calculate growth rate using auto-detection (matching cal_gamma.m)
        reader = HistoryReader.__new__(HistoryReader)
        reader.data = self.data
        gamma, omega, info = reader.get_growth_rate(
            field_idx=field_idx, mode_idx=mode_idx
        )
        ind0, ind1, ind2 = info['ind0'], info['ind1'], info['ind2']
        r2_best = info['r2_best']
        gamma_poly = info.get('gamma_poly', [gamma, 0])

        # Time array for fitting (matching MATLAB cal_gamma.m)
        dt = tstep_ndiag
        t = time  # Already in correct format: dt, 2*dt, 3*dt, ..., nt*dt
        
        # Fit range (inclusive end in MATLAB, so use ind1:ind2+1 in Python)
        t_fit = t[ind1:ind2+1]
        ln_amp_fit = ln_amp[ind1:ind2+1]
        
        # Calculate fit line (in log10 scale for plotting)
        if len(t_fit) > 1 and len(gamma_poly) > 1:
            # gamma_poly is fitted on ln(amplitude), convert to log10
            fit_line_ln = gamma_poly[0] * t_fit + gamma_poly[1]
            fit_line = fit_line_ln / np.log(10)  # Convert ln to log10
        else:
            fit_line_ln = gamma * t_fit + ln_amp_fit[0] - gamma * t_fit[0]
            fit_line = fit_line_ln / np.log(10)

        # Normalized signals (matching MATLAB cal_omega_fft.m auto_fft=4)
        t_norm = t_fit
        yr_norm = yr[ind1:ind2+1] / np.exp(gamma * t_fit)
        yi_norm = yi[ind1:ind2+1] / np.exp(gamma * t_fit)

        # ============ Plot (231): Real & Imag Components ============
        ax1 = fig.add_subplot(2, 3, 1)
        ax1.set_facecolor('white')
        ax1.plot(t, yr, linewidth=1.5, color=self.colors['primary'], label='Real', zorder=3)
        ax1.plot(t, yi, linewidth=1.5, color=self.colors['secondary'], label='Imag', zorder=3)
        
        # Mark linear region
        if ind0 < ind2:
            ax1.axvspan(t[ind0], t[ind2], alpha=0.15, color=self.colors['success'], 
                       label=f'Linear (R²={r2_best:.2f})', zorder=1)
        
        ax1.set_ylabel("Amplitude", fontsize=10, color=self.colors['text'])
        ax1.set_title(f"(231) Mode {mode_idx+1} - Real & Imag", fontsize=10, fontweight='bold')
        ax1.legend(loc='upper left', fontsize=8, framealpha=1)
        ax1.grid(True, alpha=0.3, linestyle='--', linewidth=0.8, color=self.colors['grid'], zorder=0)
        ax1.set_xlim([t[0], t[-1]])
        ax1.tick_params(colors=self.colors['text'])

        # ============ Plot (232): Growth Rate Normalized ============
        ax2 = fig.add_subplot(2, 3, 2)
        ax2.set_facecolor('white')
        ax2.plot(t_norm, yr_norm, linewidth=1.5, color=self.colors['primary'], 
                label='Real', zorder=3)
        ax2.plot(t_norm, yi_norm, linewidth=1.5, color=self.colors['secondary'], 
                label='Imag', zorder=3)
        ax2.set_ylabel("Norm. Amplitude", fontsize=10, color=self.colors['text'])
        ax2.set_xlabel(f"Time (R₀/cₛ)", fontsize=9, color=self.colors['text'])
        ax2.set_title(f"(232) γ = {gamma:.4f}", fontsize=10, fontweight='bold')
        ax2.legend(loc='upper left', fontsize=8, framealpha=1)
        ax2.grid(True, alpha=0.3, linestyle='--', linewidth=0.8, color=self.colors['grid'], zorder=0)
        ax2.set_xlim([t_norm[0], t_norm[-1]])
        ax2.tick_params(colors=self.colors['text'])

        # ============ Plot (233): Power Spectrum (xp, yp method) ============
        ax3 = fig.add_subplot(2, 3, 3)
        ax3.set_facecolor('white')
        
        # Calculate xp, yp similar to MATLAB cal_omega_fft.m
        nfreq = len(t_norm) // 2
        signal = yr_norm + 1j * yi_norm
        power = np.fft.fft(signal)
        ypow = np.abs(power)
        
        # Build xp and yp arrays (matching MATLAB)
        dt_norm = t_norm[1] - t_norm[0] if len(t_norm) > 1 else dt
        Nmode = len(t_norm)
        
        xp_neg = np.arange(1, nfreq) * 2 * np.pi / (Nmode * dt_norm)
        xp_neg = xp_neg - nfreq * 2 * np.pi / (Nmode * dt_norm)
        xp_pos = np.arange(1, nfreq + 1) * 2 * np.pi / (Nmode * dt_norm)
        xp = np.concatenate([xp_neg, xp_pos])
        
        # ypow: first half (negative freq), second half (positive freq)
        yp_neg = ypow[Nmode-nfreq+1:Nmode]
        yp_pos = ypow[1:nfreq+1]
        yp = np.concatenate([yp_neg, yp_pos])
        
        ax3.plot(xp, yp, linewidth=1.5, color=self.colors['warning'], zorder=3)
        ax3.set_ylabel("Power", fontsize=10, color=self.colors['text'])
        ax3.set_xlabel("ω (Cs/R₀)", fontsize=9, color=self.colors['text'])
        ax3.set_title("(233) Power Spectrum", fontsize=10, fontweight='bold')
        ax3.grid(True, alpha=0.3, linestyle='--', linewidth=0.8, color=self.colors['grid'], zorder=0)
        ax3.tick_params(colors=self.colors['text'])

        # ============ Plot (234): Log Amplitude History ============
        ax4 = fig.add_subplot(2, 3, 4)
        ax4.set_facecolor('white')
        ax4.plot(t, log_amp, linewidth=1.5, color=self.colors['accent'], zorder=3)
        
        # Plot linear fit (in log10 scale)
        ax4.plot(t_fit, fit_line, '--', linewidth=2, color=self.colors['text'], 
                label=f'Fit: γ={gamma:.4f}', zorder=4)
        ax4.plot([t_fit[0], t_fit[-1]], [fit_line[0], fit_line[-1]], 'r*',
                markersize=8, markeredgewidth=1.5, zorder=5)
        
        ax4.set_ylabel("log₁₀|A|", fontsize=10, color=self.colors['text'])
        ax4.set_xlabel(f"Time (R₀/cₛ)", fontsize=9, color=self.colors['text'])
        ax4.set_title("(234) Amplitude History", fontsize=10, fontweight='bold')
        ax4.legend(loc='upper left', fontsize=8, framealpha=1)
        ax4.grid(True, alpha=0.3, linestyle='--', linewidth=0.8, color=self.colors['grid'], zorder=0)
        ax4.set_xlim([t[0], t[-1]])
        ax4.tick_params(colors=self.colors['text'])

        # ============ Plot (235): Omega Simple (peak detection) ============
        ax5 = fig.add_subplot(2, 3, 5)
        ax5.set_facecolor('white')
        
        # Smooth the normalized signals (matching MATLAB smoothdata)
        from scipy.signal import savgol_filter
        if len(yi_norm) >= 5:
            yi_smooth = savgol_filter(yi_norm, min(5, len(yi_norm)), 2)
            yr_smooth = savgol_filter(yr_norm, min(5, len(yr_norm)), 2)
        else:
            yi_smooth = yi_norm
            yr_smooth = yr_norm
        
        # Find local maxima (matching MATLAB auto_simp=4)
        from scipy.signal import argrelextrema
        peaks_idx = argrelextrema(yi_smooth, np.greater)[0]
        
        # Plot normalized signals
        ax5.plot(t_norm, yr_smooth, linewidth=1.5, color=self.colors['primary'], 
                label='Real', zorder=3)
        ax5.plot(t_norm, yi_smooth, linewidth=1.5, color=self.colors['secondary'], 
                label='Imag', zorder=3)
        
        # Mark peaks
        if len(peaks_idx) >= 2:
            ax5.plot(t_norm[peaks_idx], yi_smooth[peaks_idx], 'r*-', markersize=6, 
                    linewidth=1.5, label=f'Peaks: n={len(peaks_idx)}', zorder=4)
            # Calculate omega from peak spacing
            peak_times = t_norm[peaks_idx]
            dt_peaks = np.diff(peak_times)
            omega_simple = 2 * np.pi / np.mean(dt_peaks) if len(dt_peaks) > 0 else 0
        else:
            omega_simple = 0
        
        ax5.set_xlabel(f"Time (R₀/cₛ)", fontsize=9, color=self.colors['text'])
        ax5.set_ylabel("Norm. Amplitude", fontsize=10, color=self.colors['text'])
        ax5.set_title(f"(235) ω = {omega_simple:.4f}", fontsize=10, fontweight='bold')
        ax5.legend(loc='upper left', fontsize=8, framealpha=1)
        ax5.grid(True, alpha=0.3, linestyle='--', linewidth=0.8, color=self.colors['grid'], zorder=0)
        ax5.set_xlim([t_norm[0], t_norm[-1]])
        ax5.tick_params(colors=self.colors['text'])

        # ============ Plot (236): FFT Power Spectrum (fftshift) ============
        ax6 = fig.add_subplot(2, 3, 6)
        ax6.set_facecolor('white')
        
        # FFT with fftshift (matching cal_omega_fft.m auto_fft=4)
        Nmode = len(signal)
        Tmode = dt_norm
        
        # Frequency axis (matching MATLAB)
        freq_idx = np.floor(np.arange(-(Nmode-1)/2, (Nmode-1)/2 + 1))
        t_f1 = 2 * np.pi / Tmode / Nmode * freq_idx
        
        # FFT with fftshift
        yymode_fft = Tmode * np.fft.fftshift(np.fft.fft(signal))
        
        ax6.plot(t_f1, np.abs(yymode_fft), linewidth=1.5, color=self.colors['success'], zorder=3)
        
        # Find and mark dominant frequency
        omegamax_idx = np.argmax(np.abs(yymode_fft))
        omega_fft = t_f1[omegamax_idx]
        
        ax6.axvline(omega_fft, color=self.colors['accent'], linestyle='--', 
                   linewidth=1.5, label=f'ω = {omega_fft:.4f}', zorder=4)
        ax6.axvline(-omega_fft, color=self.colors['accent'], linestyle='--', 
                   linewidth=1, alpha=0.7, zorder=4)
        
        # Set xlim (matching MATLAB: [-5 5]*abs(omega_fft))
        if omega_fft != 0:
            ax6.set_xlim([-5 * abs(omega_fft), 5 * abs(omega_fft)])
        
        ax6.set_xlabel("ω (Cs/R₀)", fontsize=9, color=self.colors['text'])
        ax6.set_ylabel("Amplitude", fontsize=10, color=self.colors['text'])
        ax6.set_title("(236) FFT Spectrum", fontsize=10, fontweight='bold')
        ax6.legend(loc='upper right', fontsize=8, framealpha=1)
        ax6.grid(True, alpha=0.3, linestyle='--', linewidth=0.8, color=self.colors['grid'], zorder=0)
        ax6.tick_params(colors=self.colors['text'])

        plt.tight_layout()
        return fig

    def plot_field_time(
        self,
        field_idx: int,
        quantities: List[int] = None,
        title: str = "",
        figsize: Tuple[int, int] = (10, 8)
    ) -> Figure:
        """
        Plot field time series (2 subplots)

        Parameters
        ----------
        field_idx : int
            Field index (0=phi, 1=a_par, 2=fluidne)
        quantities : list of int
            Which quantities to plot (0-3 based on mfdiag)
        title : str
            Plot title
        """
        fig, axes = plt.subplots(2, 1, figsize=figsize, sharex=True)
        fig.patch.set_facecolor('#0d1117')
        fig.suptitle(title or f"Field {field_idx} Time Evolution", fontsize=14)

        time = self.data.time

        if quantities is None:
            quantities = list(range(self.data.header.mfdiag))

        quantity_names = ['value at origin', 'flux surface avg', 'zonal RMS', 'total RMS']

        for idx, ax in enumerate(axes.flat):
            if idx < len(quantities):
                q = quantities[idx]
                ax.plot(time, self.data.field_time[:, q, field_idx],
                       linewidth=2, color=self.colors['primary'])
                ax.set_ylabel(quantity_names[q] if q < len(quantity_names) else f"Q{q}")
                ax.grid(True, alpha=0.3, linestyle='--')
            ax.set_xlabel("Time (R₀/cₛ)")

        plt.tight_layout()
        return fig

    def plot_particle_data(
        self,
        species_idx: int,
        quantities: List[int] = None,
        figsize: Tuple[int, int] = (10, 8)
    ) -> Figure:
        """
        Plot particle diagnostic data (2 subplots per row)

        Parameters
        ----------
        species_idx : int
            Species index (0=ion, 1=electron, 2=EP)
        quantities : list of int
            Which quantities to plot
        """
        fig, axes = plt.subplots(2, 2, figsize=figsize, sharex=True)
        fig.patch.set_facecolor('#0d1117')

        species_names = ['Ion', 'Electron', 'EP']
        quantity_names = [
            'Density', 'Entropy', 'Momentum', 'δu',
            'Energy', 'δE', 'Particle Flux', 'Momentum Flux',
            'Energy Flux', 'Total Density'
        ]

        time = self.data.time

        if quantities is None:
            quantities = list(range(min(4, self.data.header.mpdiag)))

        for idx, ax in enumerate(axes.flat):
            if idx < len(quantities):
                q = quantities[idx]
                ax.plot(time, self.data.particle_data[:, q, species_idx],
                       linewidth=2, color=self.colors['primary'])
                ax.set_ylabel(quantity_names[q] if q < len(quantity_names) else f"Q{q}")
                ax.grid(True, alpha=0.3, linestyle='--')
            ax.set_xlabel("Time (R₀/cₛ)")

        species_name = species_names[species_idx] if species_idx < len(species_names) else f"Species {species_idx}"
        fig.suptitle(f"{species_name} - Particle Diagnostics")
        plt.tight_layout()
        return fig

    def calculate_growth_rate(
        self,
        field_idx: int = 0,
        mode_idx: int = 0
    ) -> tuple:
        """
        Simple growth rate and frequency calculation

        Returns
        -------
        (gamma, omega) : tuple
            Growth rate and frequency
        """
        from .history_reader import HistoryReader
        
        reader = HistoryReader.__new__(HistoryReader)
        reader.data = self.data
        return reader.get_growth_rate(field_idx=field_idx, mode_idx=mode_idx)
