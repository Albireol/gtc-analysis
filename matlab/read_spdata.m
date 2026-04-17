function A=read_spdata(path,file)
%% read in A.dat
run setpath.m
file='spdata.dat';
filename = fullfile(path,file)
fid = fopen(filename,'r');
tline = fgetl(fid);
tline = fgetl(fid);
np = str2num(tline);
A.lsp = np(1);
A.lst = np(2);
A.lemax = np(3);
A.lrmax = np(4);
tline = fgetl(fid);
np = str2num(tline);
A.psiw = np(1);
A.ped = np(2);

spdim_2d = 9; % spline dimension for 2d array
spdim_1d = 3; % spline dimension for 1d array
num = A.lst*spdim_2d*4+spdim_1d*6;

for i = 1:A.lsp
    data1 = fscanf(fid,'%f',num);
    nindex_tmp = 0;
    for s = 1:spdim_2d
        for j = 1:A.lst
            sj = (s-1)*A.lst+j;
            A.bsp(s,i,j) = data1(sj);  % magnetic field
        end
    end
    nindex_tmp = nindex_tmp+sj;
    for s = 1:spdim_2d
        for j = 1:A.lst
            sj = (s-1)*A.lst+j;
            A.xsp(s,i,j) = data1(sj+nindex_tmp);  % X position
        end
    end
    nindex_tmp = nindex_tmp+sj;
    for s = 1:spdim_2d
        for j = 1:A.lst
            sj = (s-1)*A.lst+j;
            A.zsp(s,i,j) = data1(sj+nindex_tmp);  % Z position
        end
    end
    nindex_tmp = nindex_tmp+sj;
    for s = 1:spdim_2d
        for j = 1:A.lst
            sj = (s-1)*A.lst+j;
            A.gsp(s,i,j) = data1(sj+nindex_tmp);  % jacobian
        end
    end
    nindex_tmp = nindex_tmp+sj;
    
    A.qpsi(1:spdim_1d,i) = data1(1+nindex_tmp:spdim_1d+nindex_tmp);   % safety facotor
    nindex_tmp = nindex_tmp+spdim_1d;
    
    A.gpsi(1:spdim_1d,i) = data1(1+nindex_tmp:spdim_1d+nindex_tmp);   % current
    nindex_tmp = nindex_tmp+spdim_1d;
    
    A.ipsi(1:spdim_1d,i) = data1(1+nindex_tmp:spdim_1d+nindex_tmp);   % current
    nindex_tmp = nindex_tmp+spdim_1d;
    
    A.ppsi(1:spdim_1d,i) = data1(1+nindex_tmp:spdim_1d+nindex_tmp);   % pressure
    nindex_tmp = nindex_tmp+spdim_1d;
    
    A.rpsi(1:spdim_1d,i) = data1(1+nindex_tmp:spdim_1d+nindex_tmp);   % radius at outer-midplane
    nindex_tmp = nindex_tmp+spdim_1d;
    
    A.torpsi(1:spdim_1d,i) = data1(1+nindex_tmp:spdim_1d+nindex_tmp); % toroidal psi
    nindex_tmp = nindex_tmp+spdim_1d;
end

data2 = fscanf(fid,'%f',7);
A.krip = data2(1);
A.nrip = data2(2);
A.rmaj = data2(3);
A.d0   = data2(4);
A.brip = data2(5);
A.wrip = data2(6);
A.xrip = data2(7);

% read nu, phi = zeta_B + nu
num3 = A.lst*spdim_2d;
for i = 1:A.lsp
    data3 = fscanf(fid,'%f',num3);
    for s = 1:spdim_2d
        for j = 1:A.lst
            sj = (s-1)*A.lst+j;
            A.nsp(s,i,j) = data3(sj);
        end
    end
end

% read poloidal flux psi
num4 = A.lsp;
data4 = fscanf(fid,'%f',num4);
for i = 1:A.lsp
    A.psi(i) = data4(i);
end

% read magnetic field information at axis and separatrix
data5 = fscanf(fid,'%f',2);
A.torped = data5(1);
A.baxis = data5(2);

num6 = A.lst*spdim_2d;
for i = 1:A.lsp
    data6 = fscanf(fid,'%f',num6);
    for s = 1:spdim_2d
        for j = 1:A.lst
            sj = (s-1)*A.lst+j;
            A.delsp(s,i,j) = data6(sj);
        end
    end
end

num7 = A.lst*spdim_2d;
for i = 1:A.lsp
    data7 = fscanf(fid,'%f',num7);
    for s = 1:spdim_2d
        for j = 1:A.lst
            sj = (s-1)*A.lst+j;
            A.jsp(s,i,j) = data7(sj);
        end
    end
end

% process the data structure with poloidal periodicity
A.lst = A.lst+1; % orbit code convention is (2pi/lst), here we consider the offset for GTC convention (2pi/(lst-1))
A.bsp(1:9,1:A.lsp,A.lst) = A.bsp(1:9,1:A.lsp,1);
A.xsp(1:9,1:A.lsp,A.lst) = A.xsp(1:9,1:A.lsp,1);
A.zsp(1:9,1:A.lsp,A.lst) = A.zsp(1:9,1:A.lsp,1);
A.gsp(1:9,1:A.lsp,A.lst) = A.gsp(1:9,1:A.lsp,1);
A.nsp(1:9,1:A.lsp,A.lst) = A.nsp(1:9,1:A.lsp,1);
A.delsp(1:9,1:A.lsp,A.lst) = A.delsp(1:9,1:A.lsp,1);
A.jsp(1:9,1:A.lsp,A.lst) = A.jsp(1:9,1:A.lsp,1);

fclose(fid);

