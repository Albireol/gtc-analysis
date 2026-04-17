#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GTC Analysis Context Manager
Replaces MATLAB's global workspace approach with a proper context object
"""

from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional, Dict, Any
import numpy as np

from .gtc_reader import GTCParameters
from .history_reader import HistoryData


@dataclass
class GTCContext:
    """
    Context object that holds all GTC analysis data and parameters
    Replaces MATLAB's global variable workspace
    """
    
    # Data path
    data_path: Path = field(default_factory=Path)
    
    # Parameters from gtc.out
    params: Optional[GTCParameters] = None
    
    # History data
    history_data: Optional[HistoryData] = None
    
    # Snapshot data (to be added)
    snapshot_data: Optional[Dict[str, Any]] = None
    
    # Computed diagnostic quantities
    diag_flux: Optional[np.ndarray] = None
    q_diag_flux: Optional[np.ndarray] = None
    rho_i: float = 0.0
    
    # Frequency conversion factors
    @property
    def frequency_gtc_axis(self) -> float:
        """Convert simulation frequency to physical units (rad/s)"""
        if self.params and self.params.utime > 0:
            return 1.0 / self.params.utime
        return 1.0
    
    @property
    def frequency_unit_axis(self) -> float:
        """Alternative frequency conversion"""
        return self.frequency_gtc_axis
    
    @property
    def tstep_ndiag(self) -> float:
        """Time step in simulation units (R0/Cs)"""
        if self.params:
            return self.params.tstep_ndiag
        return 1.0
    
    @property
    def dt(self) -> float:
        """Diagnostic time step"""
        if self.params:
            return self.params.dt0 * self.params.ndiag
        return 0.0
    
    def load_all(self, use_gtc0: bool = False):
        """
        Load all available data from the data directory
        
        Parameters
        ----------
        use_gtc0 : bool
            Read gtc0.out instead of gtc.out
        """
        from .gtc_reader import read_gtc_parameters
        from .history_reader import HistoryReader
        
        # Read parameters
        self.params = read_gtc_parameters(str(self.data_path), use_gtc0)
        
        # Read history data if available
        history_file = self.data_path / "history.out"
        if history_file.exists():
            reader = HistoryReader(str(history_file))
            self.history_data = reader.read(time_scale=self.tstep_ndiag)
        
        # Read diag_flux from gtc.out if available
        if self.params and self.params.diag_flux > 0:
            self._compute_diag_quantities()
    
    def _compute_diag_quantities(self):
        """Compute diagnostic surface quantities"""
        if not self.params:
            return
        
        # These would be computed from equilibrium data
        # For now, just placeholders
        diag_flux = int(self.params.diag_flux)
        mpsi = self.params.mpsi
        
        # q profile at diagnostic surface (placeholder)
        if self.params.mpsi > 0:
            psi_norm = diag_flux / mpsi
            # Simple parabolic q profile (placeholder)
            q0 = 1.0
            q_edge = 4.0
            self.q_diag_flux = [q0 + (q_edge - q0) * psi_norm]
        
        # Ion Larmor radius (placeholder)
        if self.params.rho0 > 0:
            self.rho_i = self.params.rho0 * 0.01  # Typical value
    
    def get_mode_info(self, mode_idx: int) -> Dict[str, Any]:
        """
        Get information about a specific mode
        
        Parameters
        ----------
        mode_idx : int
            Mode index (0-based)
        
        Returns
        -------
        dict
            Mode information (n, m, k_theta*rho_i, etc.)
        """
        info = {
            'n_mode': 0,
            'm_mode': 0,
            'k_theta_rho_i': 0.0
        }
        
        if not self.params:
            return info
        
        # Get mode numbers
        if mode_idx < len(self.params.n_modes):
            info['n_mode'] = int(self.params.n_modes[mode_idx])
        if mode_idx < len(self.params.m_modes):
            info['m_mode'] = int(self.params.m_modes[mode_idx])
        
        # Calculate k_theta*rho_i
        if self.q_diag_flux and self.rho_i > 0 and info['n_mode'] > 0:
            q = self.q_diag_flux[0]
            a_minor = self.params.a_minor if self.params.a_minor > 0 else 1.0
            info['k_theta_rho_i'] = info['n_mode'] * q / a_minor * self.rho_i
        
        return info


def create_context(data_path: str) -> GTCContext:
    """
    Create and load GTC analysis context
    
    Parameters
    ----------
    data_path : str
        Path to GTC data directory
    
    Returns
    -------
    GTCContext
        Loaded context object
    """
    ctx = GTCContext(data_path=Path(data_path))
    ctx.load_all()
    return ctx
