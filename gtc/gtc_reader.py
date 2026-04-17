#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GTC Output File Reader
Replaces MATLAB: read_para.m, read_para1.m, read_para2.m, read_para3_parameters.m
"""

import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional, Dict, Any


@dataclass
class GTCParameters:
    """Container for GTC simulation parameters"""
    
    # Basic run parameters
    mstep: int = 0
    msnap: int = 0
    ndiag: int = 0
    tstep: float = 0.0
    dt0: float = 0.0  # Same as tstep
    
    # Grid parameters
    mpsi: int = 0
    mthetamax: int = 0
    mtoroidal: int = 0
    psi0: float = 0.0
    psi1: float = 0.0
    
    # Physics parameters
    magnetic: int = 0
    nhybrid: int = 0
    eq_flux: int = 0
    diag_flux: int = 0
    
    # Species loading
    iload: int = 0
    eload: int = 0
    fload: int = 0
    feload: int = 0
    
    # Geometry
    r0: float = 0.0  # Major radius (cm)
    b0: float = 0.0  # On-axis B field (Gauss)
    etemp0: float = 0.0  # Electron temp (eV)
    eden0: float = 0.0  # Electron density (cm^-3)
    rho0: float = 0.0
    
    # Derived units
    utime: float = 0.0  # Time unit conversion
    ulength: float = 0.0  # Length unit
    betae: float = 0.0
    
    # Equilibrium
    psi_iflux: float = 0.0
    ped: float = 0.0  # Poloidal flux at separatrix
    a_minor: float = 0.0  # Minor radius
    
    # Mode numbers
    n_modes: list = field(default_factory=list)
    m_modes: list = field(default_factory=list)
    
    # Additional diagnostics
    q_diag_flux: list = field(default_factory=list)
    te_axis: float = 0.0
    ti_axis_norm: float = 0.0
    ne_axis: float = 0.0
    
    # File paths
    data_path: Path = field(default_factory=Path)
    
    # Computed
    @property
    def tstep_ndiag(self) -> float:
        """Time step * ndiag in simulation units"""
        return self.dt0 * self.ndiag
    
    @property
    def frequency_gtc_axis(self) -> float:
        """Frequency conversion factor to physical units"""
        if self.utime > 0:
            return 1.0 / self.utime
        return 1.0
    
    @property
    def frequency_unit_axis(self) -> float:
        """Alternative frequency conversion"""
        return self.frequency_gtc_axis


class GTCOutputReader:
    """
    Reader for GTC output files (gtc.out, gtc0.out)
    Replaces MATLAB read_para.m family of functions
    """
    
    def __init__(self, data_path: str):
        self.data_path = Path(data_path)
        self.params = GTCParameters(data_path=self.data_path)
    
    def read(self, use_gtc0: bool = False) -> GTCParameters:
        """
        Read GTC output file and extract parameters
        
        Parameters
        ----------
        use_gtc0 : bool
            If True, read gtc0.out instead of gtc.out
        """
        # Determine which file to read
        if use_gtc0:
            gtc_file = self.data_path / "gtc0.out"
        else:
            gtc_file = self.data_path / "gtc.out"
            if not gtc_file.exists():
                gtc_file = self.data_path / "gtc0.out"
        
        if not gtc_file.exists():
            raise FileNotFoundError(f"No gtc.out or gtc0.out found in {self.data_path}")
        
        with open(gtc_file, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                self._parse_line(line)

        # Set dt0 = tstep (matching MATLAB convention)
        self.params.dt0 = self.params.tstep

        # Read additional parameters from other files
        self._read_equilibrium()
        
        return self.params
    
    def _parse_line(self, line: str):
        """Parse a single line from gtc.out"""
        line = line.replace(',', '').strip()
        
        # Helper to extract value after '='
        def extract(pattern, attr):
            match = re.search(pattern, line, re.IGNORECASE)
            if match:
                try:
                    value = line.split('=')[1].strip()
                    # Handle array values
                    if ' ' in value:
                        setattr(self.params, attr, [float(x) for x in value.split()])
                    else:
                        setattr(self.params, attr, float(value))
                    return True
                except (IndexError, ValueError):
                    pass
            return False
        
        # Basic run parameters (case-sensitive for TSTEP to avoid matching "tstep=" later in file)
        extract(r'MSTEP\s*=', 'mstep')
        extract(r'MSNAP\s*=', 'msnap')
        extract(r'NDIAG\s*=', 'ndiag')
        # Use case-sensitive match for TSTEP (uppercase only) to avoid matching "tstep=" on line 191
        if re.search(r'^\s*TSTEP\s*=', line, re.MULTILINE):
            try:
                value = line.split('=')[1].strip()
                self.params.tstep = float(value)
            except (IndexError, ValueError):
                pass
        extract(r'NHYBRID\s*=', 'nhybrid')
        
        # Grid parameters
        extract(r'MPSI\s*=', 'mpsi')
        extract(r'MTHETAMAX\s*=', 'mthetamax')
        extract(r'MTOROIDAL\s*=', 'mtoroidal')
        extract(r'PSI0\s*=', 'psi0')
        extract(r'PSI1\s*=', 'psi1')
        
        # Physics flags
        extract(r'MAGNETIC\s*=', 'magnetic')
        extract(r'FEM\s*=', 'fem')
        extract(r'IZONAL\s*=?', 'izonal')
        
        # Species loading
        extract(r'ILOAD\s*=?', 'iload')
        extract(r'ELOAD\s*=?', 'eload')
        extract(r'FLOAD\s*=?', 'fload')
        extract(r'FELOAD\s*=?', 'feload')
        
        # Geometry and physical units
        extract(r'R0\s*=', 'r0')
        extract(r'B0\s*=', 'b0')
        extract(r'ETEMP0\s*=', 'etemp0')
        extract(r'EDEN0\s*=', 'eden0')
        extract(r'RHO0\s*=', 'rho0')
        extract(r'BETAE\s*=', 'betae')
        extract(r'UTIME\s*=', 'utime')
        extract(r'ULENGTH\s*=', 'ulength')
        
        # Flux surfaces
        extract(r'EQ_FLUX\s*=', 'eq_flux')
        extract(r'DIAG_FLUX\s*=', 'diag_flux')
        extract(r'PSI_IFLUX\s*=', 'psi_iflux')
        extract(r'PED\s*=', 'ped')
        extract(r'A_MINOR\s*=', 'a_minor')
        
        # Diagnostic values
        extract(r'ON-AXIS ELECTRON DENSITY', 'ne_axis')
        extract(r'ON-AXIS ELECTRON TEMPERATURE', 'te_axis')
        extract(r'ION TEMPERATURE.*NORM TO ETEMP0', 'ti_axis_norm')
        
        # Mode numbers (for gtc4.3+ format)
        if 'N_MODES' in line.upper():
            try:
                parts = line.split('=')[1].strip().split()
                self.params.n_modes = [int(x) for x in parts]
            except:
                pass
        
        if 'M_MODES' in line.upper():
            try:
                parts = line.split('=')[1].strip().split()
                self.params.m_modes = [int(x) for x in parts]
            except:
                pass
    
    def _read_equilibrium(self):
        """Read additional equilibrium parameters"""
        # This would read from equilibrium files if needed
        # For now, just set defaults
        pass


def read_gtc_parameters(data_path: str, use_gtc0: bool = False) -> GTCParameters:
    """
    Convenience function to read GTC parameters
    
    Parameters
    ----------
    data_path : str
        Path to directory containing gtc.out
    use_gtc0 : bool
        Read gtc0.out instead
    
    Returns
    -------
    GTCParameters
        Parsed parameters container
    """
    reader = GTCOutputReader(data_path)
    return reader.read(use_gtc0)
