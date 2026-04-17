#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GTC Snapshot Data Reader
Based on MATLAB snapshot.m by Hua-sheng XIE & Yuehao Ma
"""

from dataclasses import dataclass, field
from pathlib import Path
import numpy as np
from typing import Optional


@dataclass
class SnapshotHeader:
    """GTC snapshot file header information"""
    nspecies: int       # number of species
    nfield: int         # number of field variables (we use first 3)
    nfield_file: int    # actual nfield in file (might be larger)
    nvgrid: int         # number of velocity grid points
    mpsi: int           # number of psi grid points
    mtgrid: int         # number of theta grid points
    mtoroidal: int      # number of toroidal grid points
    tmax: float         # max energy / emax_inv


@dataclass
class SnapshotData:
    """Container for parsed GTC snapshot data"""
    header: SnapshotHeader
    
    # Profile data: (mpsi+1, 6 quantities, nspecies)
    # quantities: 0=full-f density, 1=delta-f density, 
    #             2=full-f flow, 3=delta-f flow,
    #             4=full-f energy, 5=delta-f energy
    profile: np.ndarray
    
    # PDF data: (nvgrid, 4, nspecies)
    # 0=full-f in energy, 1=delta-f in energy,
    # 2=full-f in pitch, 3=delta-f in pitch
    pdf: np.ndarray
    
    # PDF 2D data: (nvgrid, nvgrid, 2, nspecies)
    # 0=delta_f, 1=delta_f^2
    pdf2d: np.ndarray
    
    # Poloidal data: (mtgrid+1, mpsi+1, nfield+2)
    poloidata: np.ndarray
    
    # Flux surface data: (mtgrid+1, mtoroidal, nfield)
    fluxdata: np.ndarray
    
    # Time array for energy
    energy_axis: np.ndarray
    
    # Pitch angle axis
    pitch_axis: np.ndarray


class SnapshotReader:
    """Reader for GTC snapshot files"""
    
    # Species names
    SPECIES_NAMES = ['ion', 'electron', 'EP']
    
    # Field names
    FIELD_NAMES = ['phi', 'a_par', 'fluidne']
    
    # Profile quantity names
    PROFILE_NAMES = [
        'full-f density', 'delta-f density',
        'full-f flow', 'delta-f flow',
        'full-f energy', 'delta-f energy'
    ]
    
    # PDF quantity names
    PDF_NAMES = [
        'full-f in energy', 'delta-f in energy',
        'full-f in pitch', 'delta-f in pitch'
    ]

    def __init__(self, file_path: str):
        self.file_path = Path(file_path)
        self.data: Optional[SnapshotData] = None

    def read(self) -> SnapshotData:
        """Read and parse snapshot.out file"""
        # Load raw data
        snap_data = np.loadtxt(self.file_path)
        
        # Parse header
        header = self._parse_header(snap_data)
        
        # Parse data arrays
        profile, pdf, pdf2d, poloidata, fluxdata = self._parse_data(snap_data, header)
        
        # Create axis arrays
        energy_axis = np.linspace(1, header.tmax, header.nvgrid)
        pitch_axis = np.arange(1, header.nvgrid + 1)
        
        self.data = SnapshotData(
            header=header,
            profile=profile,
            pdf=pdf,
            pdf2d=pdf2d,
            poloidata=poloidata,
            fluxdata=fluxdata,
            energy_axis=energy_axis,
            pitch_axis=pitch_axis
        )
        
        return self.data

    def _parse_header(self, snap_data: np.ndarray) -> SnapshotHeader:
        """Extract header information from snapshot data"""
        nspecies = int(snap_data[0])
        # nfield from file might include additional fields
        # We only use first 3: phi, a_par, fluidne
        nfield_file = int(snap_data[1])
        nvgrid = int(snap_data[2])
        mpsi = int(snap_data[3]) - 1  # MATLAB uses mpsi+1
        mtgrid = int(snap_data[4]) - 1
        mtoroidal = int(snap_data[5])
        tmax = float(snap_data[6])
        
        # Use only 3 fields for compatibility
        nfield = min(3, nfield_file)
        
        return SnapshotHeader(
            nspecies=nspecies,
            nfield=nfield,
            nfield_file=nfield_file,
            nvgrid=nvgrid,
            mpsi=mpsi,
            mtgrid=mtgrid,
            mtoroidal=mtoroidal,
            tmax=tmax
        )

    def _parse_data(self, snap_data: np.ndarray, header: SnapshotHeader):
        """Parse profile, pdf, poloidata, fluxdata from snapshot"""
        nspecies = header.nspecies
        nfield = header.nfield
        nfield_file = header.nfield_file
        nvgrid = header.nvgrid
        mpsi = header.mpsi
        mtgrid = header.mtgrid
        mtoroidal = header.mtoroidal
        
        # Initialize arrays
        # poloidata needs nfield_file+2 columns (for X, Z coordinates)
        profile = np.zeros((mpsi + 1, 6, nspecies))
        pdf = np.zeros((nvgrid, 4, nspecies))
        pdf2d = np.zeros((nvgrid, nvgrid, 2, nspecies))
        poloidata = np.zeros((mtgrid + 1, mpsi + 1, nfield_file + 2))
        fluxdata = np.zeros((mtgrid + 1, mtoroidal, nfield_file))
        
        # Calculate indices (matching MATLAB)
        ind1 = 7
        ind2 = 7 + (mpsi + 1) * nspecies * 6
        ind3 = 7 + (mpsi + 1) * 6 * nspecies + nvgrid * 4 * nspecies
        ind4 = ind3 + (mtgrid + 1) * (mpsi + 1) * (nfield_file + 2)
        ind5 = ind4 + (mtgrid + 1) * mtoroidal * nfield_file
        
        # Read poloidata (matching MATLAB: poloidata(i,j,k) with i=mtgrid, j=mpsi, k=nfield_file+2)
        # k=0..nfield_file-1: field data
        # k=nfield_file: X coordinate
        # k=nfield_file+1: Z coordinate
        for i in range(mtgrid + 1):
            for j in range(mpsi + 1):
                for k in range(nfield_file + 2):
                    ind = int(ind3 + (j + (k) * (mpsi + 1)) * (mtgrid + 1) + i)
                    poloidata[i, j, k] = snap_data[ind]
        
        # Read fluxdata (matching MATLAB: fluxdata(i,j,k) with i=mtgrid, j=mtoroidal, k=nfield_file)
        for i in range(mtgrid + 1):
            for j in range(mtoroidal):
                for k in range(nfield_file):
                    ind = int(ind4 + (j + (k) * mtoroidal) * (mtgrid + 1) + i)
                    fluxdata[i, j, k] = snap_data[ind]
        
        # Read profile (matching MATLAB: profile(i,j,k) with i=mpsi, j=6, k=nspecies)
        for k in range(nspecies):
            for j in range(6):
                for i in range(mpsi + 1):
                    ind = int(ind1 + (j + (k) * 6) * (mpsi + 1) + i)
                    profile[i, j, k] = snap_data[ind]
        
        # Read pdf (matching MATLAB: pdf(i,j,k) with i=nvgrid, j=4, k=nspecies)
        for k in range(nspecies):
            for j in range(4):
                for i in range(nvgrid):
                    ind = int(ind2 + (j + (k) * 4) * nvgrid + i)
                    pdf[i, j, k] = snap_data[ind]
        
        # Read pdf2d (matching MATLAB: pdf2d(i,ii,j,k))
        for k in range(nspecies):
            for j in range(2):
                for i in range(nvgrid):
                    for ii in range(nvgrid):
                        ind = int(ind5 + (j + (k) * 2) * nvgrid * nvgrid + i * nvgrid + ii)
                        pdf2d[i, ii, j, k] = snap_data[ind]
        
        return profile, pdf, pdf2d, poloidata, fluxdata

    def get_profile_plot(self, species_idx: int = 0, quantity_idx: int = 0, 
                         title: str = "") -> 'Figure':
        """
        Create profile plot (2 subplots: full-f and delta-f)
        
        Parameters
        ----------
        species_idx : int
            Species index (0=ion, 1=electron, 2=EP)
        quantity_idx : int
            Quantity index (0=density, 1=flow, 2=energy)
        """
        import matplotlib.pyplot as plt
        from matplotlib.figure import Figure
        
        if self.data is None:
            raise ValueError("No data loaded. Call read() first.")
        
        fig, axes = plt.subplots(2, 1, figsize=(8, 6))
        fig.patch.set_facecolor('white')
        
        x = np.arange(self.data.header.mpsi + 1)
        
        # Full-f
        full_f_idx = quantity_idx * 2
        axes[0].plot(x, self.data.profile[:, full_f_idx, species_idx], 
                    linewidth=1.5, color='#1f77b4')
        axes[0].set_ylabel("Full-f")
        axes[0].grid(True, alpha=0.3, linestyle='--')
        
        # Delta-f
        delta_f_idx = quantity_idx * 2 + 1
        axes[1].plot(x, self.data.profile[:, delta_f_idx, species_idx], 
                    linewidth=1.5, color='#ff7f0e')
        axes[1].set_ylabel("Delta-f")
        axes[1].set_xlabel("ψ grid")
        axes[1].grid(True, alpha=0.3, linestyle='--')
        
        species_name = self.SPECIES_NAMES[species_idx] if species_idx < len(self.SPECIES_NAMES) else f"Species {species_idx}"
        quantity_name = ['Density', 'Flow', 'Energy'][quantity_idx] if quantity_idx < 3 else f"Q{quantity_idx}"
        
        fig.suptitle(f"{species_name} - {quantity_name}")
        plt.tight_layout()
        return fig

    def get_pdf_plot(self, species_idx: int = 0, energy_idx: int = 0,
                     title: str = "") -> 'Figure':
        """
        Create PDF plot in energy or pitch angle
        
        Parameters
        ----------
        species_idx : int
            Species index (0=ion, 1=electron, 2=EP)
        energy_idx : int
            0=energy, 1=pitch angle
        """
        import matplotlib.pyplot as plt
        from matplotlib.figure import Figure
        
        if self.data is None:
            raise ValueError("No data loaded. Call read() first.")
        
        fig, axes = plt.subplots(2, 1, figsize=(8, 6))
        fig.patch.set_facecolor('white')
        
        if energy_idx == 0:  # Energy
            x = self.data.energy_axis
            xlabel = "Energy"
        else:  # Pitch angle
            x = self.data.pitch_axis
            xlabel = "Pitch angle grid"
        
        # Full-f
        full_f_idx = energy_idx * 2
        axes[0].plot(x, self.data.pdf[:, full_f_idx, species_idx], 
                    linewidth=1.5, color='#1f77b4')
        axes[0].set_ylabel("Full-f")
        axes[0].grid(True, alpha=0.3, linestyle='--')
        
        # Delta-f
        delta_f_idx = energy_idx * 2 + 1
        axes[1].plot(x, self.data.pdf[:, delta_f_idx, species_idx], 
                    linewidth=1.5, color='#ff7f0e')
        axes[1].set_ylabel("Delta-f")
        axes[1].set_xlabel(xlabel)
        axes[1].grid(True, alpha=0.3, linestyle='--')
        
        species_name = self.SPECIES_NAMES[species_idx] if species_idx < len(self.SPECIES_NAMES) else f"Species {species_idx}"
        pdf_type = "Energy" if energy_idx == 0 else "Pitch Angle"
        
        fig.suptitle(f"{species_name} - PDF in {pdf_type}")
        plt.tight_layout()
        return fig

    def get_flux_surface_plot(self, field_idx: int = 0,
                               title: str = "") -> 'Figure':
        """
        Create flux surface contour plot in (θ, ζ) coordinates
        
        Parameters
        ----------
        field_idx : int
            Field index (0=phi, 1=a_par, 2=fluidne)
        """
        import matplotlib.pyplot as plt
        from matplotlib.figure import Figure
        
        if self.data is None:
            raise ValueError("No data loaded. Call read() first.")
        
        fig, ax = plt.subplots(figsize=(10, 6))
        fig.patch.set_facecolor('white')
        
        data = self.data.fluxdata[:, :, field_idx]
        
        # Create meshgrid for theta and zeta
        theta = np.linspace(0, 2 * np.pi, self.data.header.mtgrid + 1)
        zeta = np.linspace(0, 2 * np.pi, self.data.header.mtoroidal)
        Theta, Zeta = np.meshgrid(theta, zeta, indexing='ij')
        
        # Contour plot with interpolation
        cf = ax.contourf(Zeta, Theta, data, levels=100, cmap='jet', extend='both')
        fig.colorbar(cf, ax=ax, label='Amplitude')
        
        ax.set_xlabel("Toroidal angle (ζ)", fontsize=14)
        ax.set_ylabel("Poloidal angle (θ)", fontsize=14)
        ax.set_aspect('auto')
        
        field_name = self.FIELD_NAMES[field_idx] if field_idx < len(self.FIELD_NAMES) else f"Field {field_idx}"
        ax.set_title(f"{field_name} on Flux Surface", fontsize=16)
        
        plt.tight_layout()
        return fig

    def get_spectrum_plots(self, field_idx: int = 0) -> tuple:
        """
        Create comprehensive spectrum analysis plots as separate figures for tabs:
        1. Poloidal Spectrum
        2. Parallel Spectrum
        3. Mode Structure δφ̃_m(r)
        4. Radial Profile (Point Value)
        5. Radial Profile (RMS)
        6. 2D Mode Spectrum
        
        Based on MATLAB cal_snapshot_fft_phi.m
        
        Parameters
        ----------
        field_idx : int
            Field index (0=phi, 1=a_par, 2=fluidne)
        
        Returns
        -------
        tuple : (list of figures, list of titles)
        """
        import matplotlib.pyplot as plt
        from matplotlib.figure import Figure
        
        if self.data is None:
            raise ValueError("No data loaded. Call read() first.")
        
        figures = []
        titles = []
        
        # Get poloidal data: shape (mtgrid+1, mpsi+1, nfield_file+2)
        f = self.data.poloidata[:, :, field_idx]
        
        mtgrid = self.data.header.mtgrid
        mpsi = self.data.header.mpsi
        mtoroidal = self.data.header.mtoroidal
        
        # Use f[1:-1, 1:-1] to skip edge points
        yym_poloidata = f[1:-1, 1:-1]
        
        mmode_theta = yym_poloidata.shape[0]
        n_mpsi = yym_poloidata.shape[1]
        Tmode = 2 * np.pi / mmode_theta
        
        # Perform FFT for each radial position
        yymode_fft_thetam = np.zeros((mmode_theta, n_mpsi))
        for mpsi_idx in range(n_mpsi):
            yym_theta_m = yym_poloidata[:, mpsi_idx]
            yymode_fft_thetam[:, mpsi_idx] = np.real(Tmode * np.fft.fftshift(np.fft.fft(yym_theta_m)))
        
        # Frequency axis
        t_f1 = np.floor(np.arange(-(mmode_theta-1)/2, (mmode_theta-1)/2 + 1))
        
        # Find dominant mode
        yymode_fft_max = np.max(np.abs(yymode_fft_thetam), axis=1)
        m_dominant_idx = np.argmax(yymode_fft_max)
        m_mpsimax = t_f1[m_dominant_idx]
        
        # Create r/a axis
        psi = np.linspace(0, 1, n_mpsi)
        
        # ============ Plot 1: Poloidal Spectrum ============
        fig1 = plt.figure(figsize=(8, 6))
        fig1.patch.set_facecolor('white')
        ax1 = fig1.add_subplot(111)
        ax1.set_facecolor('white')
        
        avg_spectrum = np.mean(np.abs(yymode_fft_thetam), axis=1)
        ax1.plot(t_f1, avg_spectrum, linewidth=1.5, color='#1f77b4')
        ax1.set_xlabel('m (poloidal mode number)', fontsize=12)
        ax1.set_ylabel('Amplitude', fontsize=12)
        ax1.set_title('Poloidal Spectrum (averaged)', fontsize=14, fontweight='bold')
        ax1.grid(True, alpha=0.3, linestyle='--')
        ax1.axvline(m_mpsimax, color='red', linestyle='--', label=f'Dominant: m={int(m_mpsimax)}')
        ax1.legend()
        
        figures.append(fig1)
        titles.append('Poloidal Spectrum')
        
        # ============ Plot 2: Parallel Spectrum ============
        fig2 = plt.figure(figsize=(8, 6))
        fig2.patch.set_facecolor('white')
        ax2 = fig2.add_subplot(111)
        ax2.set_facecolor('white')
        
        f_toroidal = self.data.fluxdata[:, :, field_idx]
        pmode = mtoroidal // 5
        if pmode < 1:
            pmode = 1
        
        y2 = np.zeros(pmode)
        for i in range(mtgrid):
            yy = np.fft.fft(f_toroidal[i, :])
            y2[0] += np.abs(yy[0])**2
            for j in range(1, pmode):
                if j < len(yy) and (mtoroidal + 2 - j) < len(yy):
                    y2[j] += np.abs(yy[j])**2 + np.abs(yy[mtoroidal + 2 - j])**2
        
        y2 = np.sqrt(y2 / mtgrid) / mtoroidal
        x2 = np.arange(pmode)
        
        ax2.plot(x2, y2, linewidth=1.5, color='#ff7f0e')
        ax2.set_xlabel('n (toroidal mode number)', fontsize=12)
        ax2.set_ylabel('Amplitude', fontsize=12)
        ax2.set_title('Parallel Spectrum', fontsize=14, fontweight='bold')
        ax2.grid(True, alpha=0.3, linestyle='--')
        
        figures.append(fig2)
        titles.append('Parallel Spectrum')
        
        # ============ Plot 3: Mode Structure δφ̃_m(r) ============
        fig3 = plt.figure(figsize=(10, 6))
        fig3.patch.set_facecolor('white')
        ax3 = fig3.add_subplot(111)
        ax3.set_facecolor('white')
        
        diag_m = m_mpsimax + np.arange(-3, 4)
        colors = plt.cm.tab10(np.linspace(0, 1, len(diag_m)))
        
        for jj, m_val in enumerate(diag_m):
            m_idx = int(m_val + (mmode_theta - 1) / 2)
            if 0 <= m_idx < mmode_theta:
                ax3.plot(psi, yymode_fft_thetam[m_idx, :], '-', linewidth=2, 
                        color=colors[jj], label=f'm={int(m_val)}')
        
        ax3.set_xlabel('$r/a$', fontsize=14)
        ax3.set_ylabel('Amplitude', fontsize=14)
        ax3.set_title('$\delta\\tilde{\phi}_m(r)$', fontsize=16, fontweight='bold')
        ax3.grid(True, alpha=0.3, linestyle='--')
        ax3.legend(loc='upper right', fontsize=11)
        ax3.set_xlim([0, 1])
        
        figures.append(fig3)
        titles.append('Mode Structure')
        
        # ============ Plot 4: Radial Profile (Point Value) ============
        fig4 = plt.figure(figsize=(8, 6))
        fig4.patch.set_facecolor('white')
        ax4 = fig4.add_subplot(111)
        ax4.set_facecolor('white')
        
        y1_profile = f[0, 1:-1]
        
        ax4.plot(psi, y1_profile, linewidth=1.5, color='#1f77b4')
        ax4.set_xlabel('$r/a$', fontsize=14)
        ax4.set_ylabel('Point Value', fontsize=12)
        ax4.set_title('Point Value at $\\theta=0$', fontsize=14, fontweight='bold')
        ax4.grid(True, alpha=0.3, linestyle='--')
        ax4.set_xlim([0, 1])
        
        figures.append(fig4)
        titles.append('Point Value')
        
        # ============ Plot 5: Radial Profile (RMS) ============
        fig5 = plt.figure(figsize=(8, 6))
        fig5.patch.set_facecolor('white')
        ax5 = fig5.add_subplot(111)
        ax5.set_facecolor('white')
        
        y2_rms = np.sqrt(np.mean(f[1:, 1:-1] * f[1:, 1:-1], axis=0))
        
        ax5.plot(psi, y2_rms, linewidth=1.5, color='#ff7f0e')
        ax5.set_xlabel('$r/a$', fontsize=14)
        ax5.set_ylabel('RMS', fontsize=12)
        ax5.set_title('RMS', fontsize=14, fontweight='bold')
        ax5.grid(True, alpha=0.3, linestyle='--')
        ax5.set_xlim([0, 1])
        
        figures.append(fig5)
        titles.append('RMS')
        
        # ============ Plot 6: 2D Mode Spectrum ============
        fig6 = plt.figure(figsize=(10, 8))
        fig6.patch.set_facecolor('white')
        ax6 = fig6.add_subplot(111)
        ax6.set_facecolor('white')
        
        X, Y = np.meshgrid(psi, t_f1)
        cf = ax6.contourf(X, Y, np.abs(yymode_fft_thetam), levels=50, cmap='jet')
        fig6.colorbar(cf, ax=ax6, label='Amplitude')
        ax6.set_xlabel('$r/a$', fontsize=14)
        ax6.set_ylabel('m', fontsize=14)
        ax6.set_title('Mode Spectrum', fontsize=14, fontweight='bold')
        ax6.grid(True, alpha=0.3, linestyle='--')
        
        figures.append(fig6)
        titles.append('2D Spectrum')
        
        return figures, titles

    def get_poloidal_plot(self, field_idx: int = 0,
                           title: str = "") -> 'Figure':
        """
        Create poloidal contour plot in (X, Z) coordinates
        Based on MATLAB snapshot.m poloidal_eval_str and cal_snapshot_contour.m
        
        Parameters
        ----------
        field_idx : int
            Field index (0=phi, 1=a_par, 2=fluidne)
        """
        import matplotlib.pyplot as plt
        from matplotlib.figure import Figure
        
        if self.data is None:
            raise ValueError("No data loaded. Call read() first.")
        
        fig, ax = plt.subplots(figsize=(8, 8))
        fig.patch.set_facecolor('white')
        
        # poloidata has shape (mtgrid+1, mpsi+1, nfield_file+2)
        # MATLAB: k=nfield_file+1 = X coordinate, k=nfield_file+2 = Z coordinate
        # Python (0-based): k=nfield_file = X coordinate, k=nfield_file+1 = Z coordinate
        X = self.data.poloidata[:, :, self.data.header.nfield_file]  # X/R0
        Z = self.data.poloidata[:, :, self.data.header.nfield_file + 1]  # Z/R0
        field_data = self.data.poloidata[:, :, field_idx]
        
        # Contour plot
        cf = ax.contourf(X, Z, field_data, levels=100, cmap='jet', extend='both')
        fig.colorbar(cf, ax=ax, label='Amplitude')
        
        ax.set_xlabel("$X/R_0$", fontsize=16)
        ax.set_ylabel("$Z/R_0$", fontsize=16)
        ax.set_aspect('equal')
        
        field_name = self.FIELD_NAMES[field_idx] if field_idx < len(self.FIELD_NAMES) else f"Field {field_idx}"
        ax.set_title(f"$\\delta {field_name}$", fontsize=20)
        
        plt.tight_layout()
        return fig

    def get_psi_profile_plot(self, field_idx: int = 0,
                              title: str = "") -> 'Figure':
        """
        Create radial (psi) profile plot
        
        Parameters
        ----------
        field_idx : int
            Field index (0=phi, 1=a_par, 2=fluidne)
        """
        import matplotlib.pyplot as plt
        from matplotlib.figure import Figure
        
        if self.data is None:
            raise ValueError("No data loaded. Call read() first.")
        
        fig, ax = plt.subplots(figsize=(8, 4))
        fig.patch.set_facecolor('white')
        
        # Average over poloidal angle
        data = np.mean(self.data.poloidata[:, :, field_idx], axis=0)
        
        psi = np.linspace(0, 1, self.data.header.mpsi + 1)
        
        field_name = self.FIELD_NAMES[field_idx] if field_idx < len(self.FIELD_NAMES) else f"Field {field_idx}"
        ax.plot(psi, data, linewidth=1.5, color='#1f77b4')
        ax.set_xlabel("r/a")
        ax.set_ylabel("Amplitude")
        ax.set_title(f"{field_name} Radial Profile (Averaged)")
        ax.grid(True, alpha=0.3, linestyle='--')
        ax.set_xlim([0, 1])
        
        plt.tight_layout()
        return fig

    def get_mode_structure_plot(self, field_idx: int = 0,
                                 title: str = "") -> 'Figure':
        """
        Create mode structure plot showing amplitude vs r/a for different m modes
        Based on MATLAB cal_snapshot_fft_phi.m figure(178)
        
        Parameters
        ----------
        field_idx : int
            Field index (0=phi, 1=a_par, 2=fluidne)
        """
        import matplotlib.pyplot as plt
        from matplotlib.figure import Figure
        
        if self.data is None:
            raise ValueError("No data loaded. Call read() first.")
        
        fig, ax = plt.subplots(figsize=(10, 6))
        fig.patch.set_facecolor('white')
        
        # Get poloidal data: shape (mtgrid+1, mpsi+1, nfield_file+2)
        f = self.data.poloidata[:, :, field_idx]
        
        mtgrid = self.data.header.mtgrid
        mpsi = self.data.header.mpsi
        
        # Use f[2:, :] to skip first row if mtgrid is even (matching MATLAB)
        if mtgrid % 2 == 0:
            yym_poloidata = f[2:, :]
        else:
            yym_poloidata = f
        
        mmode_theta = len(yym_poloidata[:, 0])
        Tmode = 2 * np.pi / mmode_theta
        
        # Frequency axis (matching MATLAB auto=4)
        t_f1 = np.floor(np.arange(-(mmode_theta-1)/2, (mmode_theta-1)/2 + 1))
        
        # Perform FFT for each radial position
        yymode_fft_thetam = []
        for mpsi_idx in range(1, mpsi):  # Skip edge points
            yym_theta_m = yym_poloidata[:, mpsi_idx]
            yymode_fft1 = Tmode * np.fft.fftshift(np.fft.fft(yym_theta_m))
            yymode_fft_thetam.append(np.real(yymode_fft1))
        
        yymode_fft_thetam = np.array(yymode_fft_thetam).T  # Shape: (n_modes, n_mpsi)
        
        # Find dominant mode
        mpsi_iflux = np.arange(1, mpsi)
        yymode_fft_max = np.max(np.abs(yymode_fft_thetam), axis=1)
        mpsimax = np.argmax(yymode_fft_max)
        m_mpsimax = t_f1[np.argmax(np.abs(yymode_fft_thetam[:, mpsimax]))]
        
        # Select modes to plot (around dominant mode)
        diag_m = m_mpsimax + np.arange(-3, 4)
        
        colors = plt.cm.tab10(np.linspace(0, 1, len(diag_m)))
        
        # Create r/a axis
        psi = np.linspace(0, 1, mpsi)
        
        for jj, m_val in enumerate(diag_m):
            m_idx = int(m_val + (mmode_theta - 1) / 2)
            if 0 <= m_idx < len(t_f1):
                ax.plot(psi[1:-1], yymode_fft_thetam[m_idx, :], '-', linewidth=2, 
                       color=colors[jj], label=f'{int(abs(m_val))}')
        
        ax.set_xlabel('$r/a$', fontsize=16)
        ax.set_ylabel('Amplitude', fontsize=16)
        ax.set_title('$\delta\\tilde{\\phi}_m(r)$', fontsize=16)
        ax.grid(True, alpha=0.3, linestyle='--')
        ax.legend(loc='upper right', fontsize=12)
        ax.set_xlim([0, 1])
        
        plt.tight_layout()
        return fig

    def get_radial_profile_plot(self, field_idx: int = 0,
                                 diag_flux: int = None,
                                 title: str = "") -> 'Figure':
        """
        Create radial (psi) profile plot with point value and RMS
        Based on MATLAB cut1d1_eval_str
        
        Parameters
        ----------
        field_idx : int
            Field index (0=phi, 1=a_par, 2=fluidne)
        diag_flux : int
            Diagnostic flux surface index (default: mpsi//2)
        """
        import matplotlib.pyplot as plt
        from matplotlib.figure import Figure
        
        if self.data is None:
            raise ValueError("No data loaded. Call read() first.")
        
        fig, axes = plt.subplots(2, 1, figsize=(8, 6))
        fig.patch.set_facecolor('white')
        
        # Use poloidal data: shape (mtgrid+1, mpsi+1, nfield_file+2)
        # MATLAB: f=poloidata(:,:,1), y1=f(1,:), y2=sqrt(sum(f.*f)/mtgrid)
        f = self.data.poloidata[:, :, field_idx]
        
        # Point value at theta=0 (first row in MATLAB = index 0 in Python)
        # MATLAB f(1,:) = Python f[0, :]
        y1_profile = f[0, :]
        
        # RMS over poloidal angle (mtgrid)
        # MATLAB: y2=sum(f.*f); y2=sqrt(y2/mtgrid)
        y2 = np.sqrt(np.mean(f * f, axis=0))
        
        # Create r/a axis (normalized psi)
        psi = np.linspace(0, 1, self.data.header.mpsi + 1)
        
        axes[0].plot(psi, y1_profile, linewidth=1.5, color='#1f77b4')
        axes[0].set_ylabel("Point Value")
        axes[0].set_title("Point Value at θ=0")
        axes[0].grid(True, alpha=0.3, linestyle='--')
        axes[0].set_xlim([0, 1])
        
        axes[1].plot(psi, y2, linewidth=1.5, color='#ff7f0e')
        axes[1].set_xlabel("r/a")
        axes[1].set_ylabel("RMS")
        axes[1].set_title("RMS")
        axes[1].grid(True, alpha=0.3, linestyle='--')
        axes[1].set_xlim([0, 1])
        
        field_name = self.FIELD_NAMES[field_idx] if field_idx < len(self.FIELD_NAMES) else f"Field {field_idx}"
        fig.suptitle(f"{field_name} Radial Profile", fontsize=14, fontweight='bold')
        
        plt.tight_layout()
        return fig

    def get_poloidal_profile_plot(self, field_idx: int = 0,
                                   diag_flux: int = None,
                                   title: str = "") -> 'Figure':
        """
        Create poloidal (theta) profile plot with point value and RMS
        Based on MATLAB cut1d2_eval_str
        
        Parameters
        ----------
        field_idx : int
            Field index (0=phi, 1=a_par, 2=fluidne)
        diag_flux : int
            Diagnostic flux surface index (default: mpsi//2)
        """
        import matplotlib.pyplot as plt
        from matplotlib.figure import Figure
        
        if self.data is None:
            raise ValueError("No data loaded. Call read() first.")
        
        fig, axes = plt.subplots(2, 1, figsize=(8, 6))
        fig.patch.set_facecolor('white')
        
        # Use poloidal data: shape (mtgrid+1, mpsi+1, nfield_file+2)
        # MATLAB: f=poloidata(:,:,1), y1=f(:,diag_flux+1)
        f = self.data.poloidata[:, :, field_idx]
        
        # Use diagnostic flux surface (default: middle)
        if diag_flux is None:
            diag_flux = self.data.header.mpsi // 2
        
        # Point value at diagnostic flux surface
        # MATLAB f(:,diag_flux+1) = Python f[:, diag_flux]
        y1 = f[:, diag_flux]
        
        # RMS over poloidal angle (theta)
        # MATLAB: y2=sum(f'.*f'); y2=sqrt(y2/mpsi)
        y2 = np.sqrt(np.mean(f * f, axis=1))
        
        # Create theta axis
        theta = np.linspace(0, 2 * np.pi, self.data.header.mtgrid + 1)
        
        axes[0].plot(theta, y1, linewidth=1.5, color='#1f77b4')
        axes[0].set_ylabel("Point Value")
        axes[0].set_title(f"Point Value at ψ={diag_flux}")
        axes[0].grid(True, alpha=0.3, linestyle='--')
        
        axes[1].plot(theta, y2, linewidth=1.5, color='#ff7f0e')
        axes[1].set_xlabel("Poloidal angle (θ)")
        axes[1].set_ylabel("RMS")
        axes[1].set_title("RMS")
        axes[1].grid(True, alpha=0.3, linestyle='--')
        
        field_name = self.FIELD_NAMES[field_idx] if field_idx < len(self.FIELD_NAMES) else f"Field {field_idx}"
        fig.suptitle(f"{field_name} Poloidal Profile", fontsize=14, fontweight='bold')
        
        plt.tight_layout()
        return fig
