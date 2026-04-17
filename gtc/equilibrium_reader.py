#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GTC Profile and Spdata Reader
Based on MATLAB read_prodata.m and read_spdata.m
"""

from dataclasses import dataclass, field
from pathlib import Path
import numpy as np


@dataclass
class ProfileData:
    """Container for profile.dat data"""
    psi: np.ndarray = field(default_factory=lambda: np.array([]))
    x: np.ndarray = field(default_factory=lambda: np.array([]))
    r: np.ndarray = field(default_factory=lambda: np.array([]))
    R: np.ndarray = field(default_factory=lambda: np.array([]))
    Rr: np.ndarray = field(default_factory=lambda: np.array([]))
    Te: np.ndarray = field(default_factory=lambda: np.array([]))
    ne: np.ndarray = field(default_factory=lambda: np.array([]))
    Ti: np.ndarray = field(default_factory=lambda: np.array([]))
    Zeff: np.ndarray = field(default_factory=lambda: np.array([]))
    omega_tor: np.ndarray = field(default_factory=lambda: np.array([]))
    Er: np.ndarray = field(default_factory=lambda: np.array([]))
    ni: np.ndarray = field(default_factory=lambda: np.array([]))
    nimp: np.ndarray = field(default_factory=lambda: np.array([]))
    nf: np.ndarray = field(default_factory=lambda: np.array([]))
    Tf: np.ndarray = field(default_factory=lambda: np.array([]))
    na: np.ndarray = field(default_factory=lambda: np.array([]))
    Ta: np.ndarray = field(default_factory=lambda: np.array([]))


@dataclass
class SpdataData:
    """Container for spdata.dat data"""
    lsp: int = 0
    lst: int = 0
    lemax: int = 0
    lrmax: int = 0
    psiw: float = 0.0
    ped: float = 0.0
    
    # 3D arrays (s, psi, theta)
    bsp: np.ndarray = field(default_factory=lambda: np.array([]))  # magnetic field
    xsp: np.ndarray = field(default_factory=lambda: np.array([]))  # X position
    zsp: np.ndarray = field(default_factory=lambda: np.array([]))  # Z position
    gsp: np.ndarray = field(default_factory=lambda: np.array([]))  # jacobian
    nsp: np.ndarray = field(default_factory=lambda: np.array([]))  # nu
    delsp: np.ndarray = field(default_factory=lambda: np.array([]))
    jsp: np.ndarray = field(default_factory=lambda: np.array([]))
    
    # 1D arrays (s, psi)
    qpsi: np.ndarray = field(default_factory=lambda: np.array([]))   # safety factor
    gpsi: np.ndarray = field(default_factory=lambda: np.array([]))   # current
    ipsi: np.ndarray = field(default_factory=lambda: np.array([]))   # current
    ppsi: np.ndarray = field(default_factory=lambda: np.array([]))   # pressure
    rpsi: np.ndarray = field(default_factory=lambda: np.array([]))   # radius
    torpsi: np.ndarray = field(default_factory=lambda: np.array([])) # toroidal psi
    psi: np.ndarray = field(default_factory=lambda: np.array([]))    # poloidal flux
    
    # Additional parameters
    krip: float = 0.0
    nrip: float = 0.0
    rmaj: float = 0.0
    d0: float = 0.0
    brip: float = 0.0
    wrip: float = 0.0
    xrip: float = 0.0
    torped: float = 0.0
    baxis: float = 0.0


class EquilibriumReader:
    """Reader for GTC equilibrium files (profile.dat and spdata.dat)"""
    
    def __init__(self, data_path: str):
        self.data_path = Path(data_path)
        self.profile_data = None
        self.spdata_data = None
    
    def read_profile(self, filename: str = 'profile.dat') -> ProfileData:
        """
        Read profile.dat file
        Based on MATLAB read_prodata.m
        
        Note: profile.dat may have varying number of columns (15 for standard GTC,
        17+ for runs with alpha and fast ion species). This function handles both.
        It also skips non-numeric comment lines at the end of the file.
        """
        file_path = self.data_path / filename
        
        if not file_path.exists():
            raise FileNotFoundError(f"Profile file not found: {file_path}")
        
        # Read file and filter out non-numeric lines
        with open(file_path, 'r') as f:
            lines = f.readlines()
        
        # Skip header line and collect only numeric data lines
        data_lines = []
        for line in lines[1:]:  # Skip first line (header)
            line = line.strip()
            if not line:
                continue
            # Check if line starts with a number
            try:
                float(line.split()[0])
                data_lines.append(line)
            except (ValueError, IndexError):
                # Skip comment lines like "Poloidal Flux in Webers/rad"
                break
        
        # Parse data using numpy
        data = np.loadtxt(data_lines, usecols=range(15), ndmin=2)
        
        # Initialize na and Ta with zeros (for GTC runs without alpha particles)
        na_data = np.zeros(len(data))
        Ta_data = np.zeros(len(data))
        
        self.profile_data = ProfileData(
            psi=data[:, 0],
            x=data[:, 1],
            r=data[:, 2],
            R=data[:, 3],
            Rr=data[:, 4],
            Te=data[:, 5],
            ne=data[:, 6],
            Ti=data[:, 7],
            Zeff=data[:, 8],
            omega_tor=data[:, 9],
            Er=data[:, 10],
            ni=data[:, 11],
            nimp=data[:, 12],
            nf=data[:, 13],
            Tf=data[:, 14],
            na=na_data,
            Ta=Ta_data
        )
        
        return self.profile_data
    
    def read_spdata(self, filename: str = 'spdata.dat') -> SpdataData:
        """
        Read spdata.dat file
        Based on MATLAB read_spdata.m - exact port
        """
        file_path = self.data_path / filename
        
        if not file_path.exists():
            raise FileNotFoundError(f"Spdata file not found: {file_path}")
        
        with open(file_path, 'r') as f:
            # Skip first line
            f.readline()
            
            # Read lsp, lst, lemax, lrmax
            line = f.readline()
            dims = list(map(int, line.split()))
            lsp, lst, lemax, lrmax = dims[0], dims[1], dims[2], dims[3]
            
            # Read psi dimensions
            line = f.readline()
            psi_dims = list(map(float, line.split()))
            psiw, ped = psi_dims[0], psi_dims[1]
            
            spdim_2d = 9  # spline dimension for 2d array
            spdim_1d = 3  # spline dimension for 1d array
            num = lst * spdim_2d * 4 + spdim_1d * 6
            
            # Initialize arrays (MATLAB uses 1-based indexing, Python uses 0-based)
            # We'll allocate with extra space for the periodicity copy
            bsp = np.zeros((spdim_2d, lsp + 1, lst + 1))
            xsp = np.zeros((spdim_2d, lsp + 1, lst + 1))
            zsp = np.zeros((spdim_2d, lsp + 1, lst + 1))
            gsp = np.zeros((spdim_2d, lsp + 1, lst + 1))
            qpsi = np.zeros((spdim_1d, lsp + 1))
            gpsi = np.zeros((spdim_1d, lsp + 1))
            ipsi = np.zeros((spdim_1d, lsp + 1))
            ppsi = np.zeros((spdim_1d, lsp + 1))
            rpsi = np.zeros((spdim_1d, lsp + 1))
            torpsi = np.zeros((spdim_1d, lsp + 1))
            
            # Read data for each psi surface (MATLAB: i = 1:A.lsp)
            for i in range(1, lsp + 1):
                # Read all data for this surface
                data1 = []
                while len(data1) < num:
                    line = f.readline()
                    if not line:
                        break
                    data1.extend(list(map(float, line.split())))
                data1 = np.array(data1[:num])
                
                # Read bsp (MATLAB: A.bsp(s,i,j) = data1(sj))
                for s in range(1, spdim_2d + 1):
                    for j in range(1, lst + 1):
                        sj = (s - 1) * lst + j
                        bsp[s-1, i-1, j-1] = data1[sj - 1]
                
                # Read xsp
                for s in range(1, spdim_2d + 1):
                    for j in range(1, lst + 1):
                        sj = (s - 1) * lst + j
                        xsp[s-1, i-1, j-1] = data1[sj - 1 + lst * spdim_2d]
                
                # Read zsp
                for s in range(1, spdim_2d + 1):
                    for j in range(1, lst + 1):
                        sj = (s - 1) * lst + j
                        zsp[s-1, i-1, j-1] = data1[sj - 1 + 2 * lst * spdim_2d]
                
                # Read gsp
                for s in range(1, spdim_2d + 1):
                    for j in range(1, lst + 1):
                        sj = (s - 1) * lst + j
                        gsp[s-1, i-1, j-1] = data1[sj - 1 + 3 * lst * spdim_2d]
                
                # Read 1D arrays
                idx = 4 * lst * spdim_2d
                qpsi[:, i-1] = data1[idx:idx + spdim_1d]
                idx += spdim_1d
                
                gpsi[:, i-1] = data1[idx:idx + spdim_1d]
                idx += spdim_1d
                
                ipsi[:, i-1] = data1[idx:idx + spdim_1d]
                idx += spdim_1d
                
                ppsi[:, i-1] = data1[idx:idx + spdim_1d]
                idx += spdim_1d
                
                rpsi[:, i-1] = data1[idx:idx + spdim_1d]
                idx += spdim_1d
                
                torpsi[:, i-1] = data1[idx:idx + spdim_1d]
            
            # Read additional parameters (7 values)
            data2 = []
            while len(data2) < 7:
                line = f.readline()
                if not line:
                    break
                data2.extend(list(map(float, line.split())))
            
            krip, nrip, rmaj, d0, brip, wrip, xrip = data2
            
            # Read nu (MATLAB: A.nsp(s,i,j) = data3(sj))
            num3 = lst * spdim_2d
            nsp = np.zeros((spdim_2d, lsp + 1, lst + 1))
            
            for i in range(1, lsp + 1):
                data3 = []
                while len(data3) < num3:
                    line = f.readline()
                    if not line:
                        break
                    data3.extend(list(map(float, line.split())))
                data3 = np.array(data3[:num3])
                
                for s in range(1, spdim_2d + 1):
                    for j in range(1, lst + 1):
                        sj = (s - 1) * lst + j
                        nsp[s-1, i-1, j-1] = data3[sj - 1]
            
            # Read poloidal flux psi
            data4 = []
            while len(data4) < lsp:
                line = f.readline()
                if not line:
                    break
                data4.extend(list(map(float, line.split())))
            
            psi_arr = np.zeros(lsp + 1)
            for i in range(1, lsp + 1):
                psi_arr[i-1] = data4[i - 1]
            
            # Read torped and baxis
            data5 = []
            while len(data5) < 2:
                line = f.readline()
                if not line:
                    break
                data5.extend(list(map(float, line.split())))
            
            torped, baxis = data5
            
            # Read delsp
            num6 = lst * spdim_2d
            delsp = np.zeros((spdim_2d, lsp + 1, lst + 1))
            
            for i in range(1, lsp + 1):
                data6 = []
                while len(data6) < num6:
                    line = f.readline()
                    if not line:
                        break
                    data6.extend(list(map(float, line.split())))
                data6 = np.array(data6[:num6])
                
                for s in range(1, spdim_2d + 1):
                    for j in range(1, lst + 1):
                        sj = (s - 1) * lst + j
                        delsp[s-1, i-1, j-1] = data6[sj - 1]
            
            # Read jsp
            num7 = lst * spdim_2d
            jsp = np.zeros((spdim_2d, lsp + 1, lst + 1))
            
            for i in range(1, lsp + 1):
                data7 = []
                while len(data7) < num7:
                    line = f.readline()
                    if not line:
                        break
                    data7.extend(list(map(float, line.split())))
                data7 = np.array(data7[:num7])
                
                for s in range(1, spdim_2d + 1):
                    for j in range(1, lst + 1):
                        sj = (s - 1) * lst + j
                        jsp[s-1, i-1, j-1] = data7[sj - 1]
            
            # Process poloidal periodicity (MATLAB: A.lst = A.lst + 1)
            # Copy first column to last column for periodicity
            lst_final = lst + 1
            bsp[:, :, lst] = bsp[:, :, 0]
            xsp[:, :, lst] = xsp[:, :, 0]
            zsp[:, :, lst] = zsp[:, :, 0]
            gsp[:, :, lst] = gsp[:, :, 0]
            nsp[:, :, lst] = nsp[:, :, 0]
            delsp[:, :, lst] = delsp[:, :, 0]
            jsp[:, :, lst] = jsp[:, :, 0]
        
        # Create data container
        self.spdata_data = SpdataData(
            lsp=lsp,
            lst=lst_final,  # Use updated lst
            lemax=lemax,
            lrmax=lrmax,
            psiw=psiw,
            ped=ped,
            bsp=bsp,
            xsp=xsp,
            zsp=zsp,
            gsp=gsp,
            nsp=nsp,
            delsp=delsp,
            jsp=jsp,
            qpsi=qpsi,
            gpsi=gpsi,
            ipsi=ipsi,
            ppsi=ppsi,
            rpsi=rpsi,
            torpsi=torpsi,
            psi=psi_arr,
            krip=krip,
            nrip=nrip,
            rmaj=rmaj,
            d0=d0,
            brip=brip,
            wrip=wrip,
            xrip=xrip,
            torped=torped,
            baxis=baxis
        )
        
        return self.spdata_data
