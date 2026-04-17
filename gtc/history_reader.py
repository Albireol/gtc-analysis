#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GTC History Data Reader
Based on MATLAB history.m by Hua-sheng XIE & Yuehao Ma

Data structure in history.out:
    [header (7 values), data...]
    
Header:
    1. ndstep    - # of time steps
    2. nspecies  - # of species (ion, electron, EP, impurities)
    3. mpdiag    - # of quantities per species
    4. nfield    - # of field variables (phi, a_par, fluidne)
    5. modes     - # of modes per field
    6. mfdiag    - # of quantities per field
    7. tstep     - time step size

Data layout:
    [particle_data, field_time_data, field_mode_data]
"""

from dataclasses import dataclass
from pathlib import Path
import numpy as np
from typing import Optional, Tuple


@dataclass
class HistoryHeader:
    """GTC history file header information"""
    ndstep: int           # number of time steps
    nspecies: int         # number of species
    mpdiag: int           # quantities per species
    nfield: int           # number of field variables
    modes: int            # modes per field
    mfdiag: int           # quantities per field
    tstep: float          # time step size
    ndata: int            # total data per time step
    ntime: int            # actual number of time steps


@dataclass
class HistoryData:
    """Container for parsed GTC history data"""
    header: HistoryHeader
    
    # Particle data: (time, quantity, species)
    particle_data: np.ndarray  # shape: (ntime, mpdiag, nspecies)
    
    # Field time series: (time, quantity, field)
    field_time: np.ndarray     # shape: (ntime, mfdiag, nfield)
    
    # Field mode data: (time, component, mode, field)
    field_mode: np.ndarray     # shape: (ntime, 2, modes, nfield)
                               # component 0=real, 1=imag
    
    # Time array in simulation units (R0/Cs)
    time: np.ndarray           # shape: (ntime,)


class HistoryReader:
    """Reader for GTC history.out files"""
    
    # Field variable names (standard GTC ordering)
    FIELD_NAMES = ['phi', 'a_par', 'fluidne']
    
    # Species names (standard GTC ordering)
    SPECIES_NAMES = ['ion', 'electron', 'EP']
    
    # Particle diagnostic names
    PARTICLE_DIAG_NAMES = [
        'density', 'entropy', 'momentum', 'delta_u',
        'energy', 'delta_E', 'particle_flux', 'momentum_flux',
        'energy_flux', 'total_density'
    ]
    
    # Field time diagnostic names
    FIELD_TIME_DIAG_NAMES = [
        'value_at_origin', 'flux_surface_avg',
        'zonal_rms', 'total_rms'
    ]
    
    def __init__(self, file_path: str):
        self.file_path = Path(file_path)
        self.data: Optional[HistoryData] = None
    
    def read(self, time_scale: Optional[float] = None) -> HistoryData:
        """
        Read and parse history.out file

        Parameters
        ----------
        time_scale : float, optional
            Time step (dt) in R0/Cs units.
            If None, uses tstep from header (tstep*ndiag).

        Returns
        -------
        HistoryData
            Parsed history data container
        """
        # Load raw data
        raw_data = np.loadtxt(self.file_path)

        # Parse header
        header = self._parse_header(raw_data)

        # Parse data arrays
        particle_data, field_time, field_mode = self._parse_data(raw_data, header)

        # Create time array: t = dt, 2*dt, 3*dt, ..., ntime*dt
        # Note: header.tstep from history.out is NOT dt!
        # We need to get dt from gtc.out (dt0 * ndiag).
        # Default: dt=1 (in simulation units R0/Cs)
        dt = 1.0

        if time_scale is not None:
            dt = time_scale

        # Time array starts from dt, not 0 (matching MATLAB: t=dt:dt:nt*dt)
        time = np.arange(1, header.ntime + 1) * dt

        self.data = HistoryData(
            header=header,
            particle_data=particle_data,
            field_time=field_time,
            field_mode=field_mode,
            time=time
        )

        return self.data
    
    def _parse_header(self, raw_data: np.ndarray) -> HistoryHeader:
        """Extract and parse header information"""
        ndstep = int(raw_data[0])
        nspecies = int(raw_data[1])
        mpdiag = int(raw_data[2])
        nfield = int(raw_data[3])
        modes = int(raw_data[4])
        mfdiag = int(raw_data[5])
        tstep = float(raw_data[6])
        
        # Calculate data size per time step
        ndata = nspecies * mpdiag + nfield * (2 * modes + mfdiag)
        
        # Calculate actual number of time steps
        ntime = int(len(raw_data) / ndata)
        
        return HistoryHeader(
            ndstep=ndstep,
            nspecies=nspecies,
            mpdiag=mpdiag,
            nfield=nfield,
            modes=modes,
            mfdiag=mfdiag,
            tstep=tstep,
            ndata=ndata,
            ntime=ntime
        )
    
    def _parse_data(
        self, raw_data: np.ndarray, header: HistoryHeader
    ) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
        """
        Parse particle and field data from raw array
        
        Data layout in file:
            [header, particle_data, field_time_data, field_mode_data]
        """
        ntime = header.ntime
        nspecies = header.nspecies
        mpdiag = header.mpdiag
        nfield = header.nfield
        modes = header.modes
        mfdiag = header.mfdiag
        ndata = header.ndata
        
        # Initialize arrays
        particle_data = np.zeros((ntime, mpdiag, nspecies))
        field_time = np.zeros((ntime, mfdiag, nfield))
        field_mode = np.zeros((ntime, 2, modes, nfield))
        
        # Skip header (first 7 values)
        data_start = 7
        
        for it in range(ntime):
            offset = data_start + it * ndata
            
            # Particle data
            for i in range(nspecies):
                for j in range(mpdiag):
                    idx = offset + i * mpdiag + j
                    particle_data[it, j, i] = raw_data[idx]
            
            # Field time data
            field_offset = offset + nspecies * mpdiag
            for i in range(nfield):
                for j in range(mfdiag):
                    idx = field_offset + i * mfdiag + j
                    field_time[it, j, i] = raw_data[idx]
            
            # Field mode data
            mode_offset = field_offset + nfield * mfdiag
            for i in range(nfield):
                for j in range(modes):
                    idx_real = mode_offset + i * (2 * modes) + 2 * j
                    idx_imag = idx_real + 1
                    field_mode[it, 0, j, i] = raw_data[idx_real]
                    field_mode[it, 1, j, i] = raw_data[idx_imag]
        
        return particle_data, field_time, field_mode
    
    def get_growth_rate(
        self,
        field_idx: int = 0,
        mode_idx: int = 0,
        nstart: int = 0,
        nend: Optional[int] = None
    ) -> Tuple[float, float]:
        """
        Calculate growth rate and frequency for a specific mode
        
        Parameters
        ----------
        field_idx : int
            Field index (0=phi, 1=a_par, 2=fluidne)
        mode_idx : int
            Mode index (0-based)
        nstart : int
            Start time index for growth rate calculation
        nend : int, optional
            End time index (default: all data)

        Returns
        -------
        (gamma, omega, info) : Tuple[float, float, dict]
            Growth rate, frequency, and diagnostic info
        """
        if self.data is None:
            raise ValueError("No data loaded. Call read() first.")

        # Get mode data
        yr = self.data.field_mode[:, 0, mode_idx, field_idx]
        yi = self.data.field_mode[:, 1, mode_idx, field_idx]
        amplitude = np.sqrt(yr**2 + yi**2)
        amplitude = np.clip(amplitude, 1e-20, None)

        nt = len(amplitude)
        time = self.data.time
        
        # Get time step (dt in R0/Cs units)
        # time array should be: dt, 2*dt, 3*dt, ..., nt*dt
        if len(time) > 1:
            dt = time[1] - time[0]
        else:
            dt = 1.0
        
        # Auto-detect linear region (based on cal_gamma.m)
        # MATLAB uses fixed cut0=0.05, cut1=0.95
        ind0, ind2, r2_best = self._detect_linear_region(amplitude, time, dt)
        
        # Ensure minimum interval (as in MATLAB)
        if (ind2 - ind0) < 5:
            ind0 = 0
            ind2 = nt - 1

        # Adjust for even number of points (as in MATLAB cal_gamma.m)
        # MATLAB: N = length(t(ind0:ind2)) - inclusive end
        N = ind2 - ind0 + 1  # MATLAB length (inclusive)
        ind1 = ind0
        if N % 2 == 1:  # odd length
            ind1 = ind0 + 1
            N = ind2 - ind1 + 1

        # Fit growth rate using TIME (matching cal_gamma.m)
        # MATLAB: gamma_poly = polyfit(t(ind1:ind2), yy(ind1:ind2), 1)
        # Python: use [ind1:ind2+1] for inclusive end
        t_fit = time[ind1:ind2+1]
        yy = np.log(amplitude[ind1:ind2+1])

        # Check for valid data
        gamma_poly = [0.0, 0.0]  # Default
        if not np.all(np.isfinite(yy)) or len(yy) < 2 or len(t_fit) < 2:
            gamma = 0.0
        else:
            # Check for constant time
            if np.max(t_fit) - np.min(t_fit) < 1e-10:
                gamma = 0.0
            else:
                try:
                    gamma_poly = np.polyfit(t_fit, yy, 1)
                    gamma = gamma_poly[0] if np.isfinite(gamma_poly[0]) else 0.0
                except (np.linalg.LinAlgError, ValueError):
                    gamma = 0.0

        # Normalize by growth rate for FFT (matching cal_omega_fft.m auto_fft=4)
        # Use time range from ind1 to ind2 (inclusive)
        t_norm = time[ind1:ind2+1]
        yr_norm = yr[ind1:ind2+1] / np.exp(gamma * t_norm)
        yi_norm = yi[ind1:ind2+1] / np.exp(gamma * t_norm)

        # FFT for frequency (matching cal_omega_fft.m auto_fft=4)
        signal = yr_norm + 1j * yi_norm
        Nmode = len(signal)
        Tmode = t_norm[1] - t_norm[0] if len(t_norm) > 1 else dt  # 采样周期
        
        # Frequency axis (matching MATLAB)
        # t_f1 = [2*pi/Tmode/Nmode*floor(-(Nmode-1)/2:(Nmode-1)/2)]'
        freq_idx = np.floor(np.arange(-(Nmode-1)/2, (Nmode-1)/2 + 1))
        t_f1 = 2 * np.pi / Tmode / Nmode * freq_idx
        
        # FFT with fftshift (matching MATLAB)
        yymode_fft = Tmode * np.fft.fftshift(np.fft.fft(signal))
        
        # Find dominant frequency
        omegamax_idx = np.argmax(np.abs(yymode_fft))
        omega = t_f1[omegamax_idx]

        info = {
            'ind0': ind0,
            'ind1': ind1,
            'ind2': ind2,
            'r2_best': r2_best,
            'gamma_poly': gamma_poly,
            'omega_fft': omega,
            'N': N
        }

        return gamma, omega, info

    def _detect_linear_region(
        self,
        amplitude: np.ndarray,
        time: np.ndarray,
        dt: float = 1.0,
        threshold_r2: float = 0.99,
        m_segments: int = 50
    ) -> Tuple[int, int, float]:
        """
        Detect linear growth region using piecewise fitting
        Based on MATLAB cal_gamma.m by Yuehao Ma

        MATLAB code uses FIXED cut0=0.05, cut1=0.95
        
        MATLAB indexing (1-based):
            ind0 = max(1, floor(cut0 * nt))
            ind2 = min(nt, floor(cut1 * nt))
        
        Python indexing (0-based):
            ind0 = max(0, floor(cut0 * nt) - 1) = floor(cut0 * nt) - 1  (for cut0=0.05, nt>20)
            ind2 = min(nt-1, floor(cut1 * nt) - 1)

        Parameters
        ----------
        amplitude : np.ndarray
            Mode amplitude vs time
        time : np.ndarray
            Time array in R0/Cs units
        dt : float
            Time step in R0/Cs units
        threshold_r2 : float
            R² threshold for linear region (not used in fixed mode)
        m_segments : int
            Number of segments for piecewise fitting (not used in fixed mode)

        Returns
        -------
        (cut0_idx, cut1_idx, r2_best) : Tuple[int, int, float]
            Start index, end index, best R² value (r2_best=1.0 for fixed mode)
        """
        nt = len(amplitude)

        # MATLAB cal_gamma.m uses FIXED values:
        cut0 = 0.05
        cut1 = 0.95

        # Convert MATLAB 1-based indices to Python 0-based indices
        # MATLAB: ind0 = max(1, floor(cut0 * nt))
        # Python: ind0 = ind0_matlab - 1
        ind0_matlab = max(1, int(cut0 * nt))
        ind2_matlab = min(nt, int(cut1 * nt))
        
        # Convert to 0-based indexing
        ind0 = ind0_matlab - 1
        ind2 = ind2_matlab - 1

        return ind0, ind2, 1.0
    
    def get_field_names(self) -> list:
        """Get list of field variable names"""
        return self.FIELD_NAMES[:self.data.header.nfield] if self.data else self.FIELD_NAMES
    
    def get_species_names(self) -> list:
        """Get list of species names"""
        return self.SPECIES_NAMES[:self.data.header.nspecies] if self.data else self.SPECIES_NAMES
