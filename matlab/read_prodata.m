function A=read_prodata(path,file)
%read in profile.dat
run setpath.m
file='profile.dat';
filename = [path,file];
data = importdata(filename,' ',1);

A.psi = data.data(:,1);
A.x = data.data(:,2);
A.r = data.data(:,3);
A.R = data.data(:,4);
A.Rr = data.data(:,5);
A.Te = data.data(:,6);
A.ne = data.data(:,7);
A.Ti = data.data(:,8);
A.Zeff = data.data(:,9);
A.omega_tor = data.data(:,10);
A.Er = data.data(:,11);
A.ni = data.data(:,12);
A.nimp = data.data(:,13);
A.nf = data.data(:,14);
A.Tf = data.data(:,15);
A.na = data.data(:,16);
A.Ta = data.data(:,17);
end