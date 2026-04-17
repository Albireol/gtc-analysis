%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Yuehao Ma, USTC, myh2020@mail.ustc.edu.cn
% GTC Data Processing GUI
% V4.6 for gtc4.6 version myh 20230323 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% v1.1, 2012-12-04 13:48
% v1.2, 2012-12-10 21:06, fixed a bug in "history.m"
% v1.3, 2014-03-27 09:05 draft, 2014-04-05 10:14 update
%   add fieldm.m, snapmovie.m, tracking.m ... , 
%   also better parameter setup
%   这里添加profile的梯度计算模块，另外更正原先dT/dpsi--->dT/dr
close all;clear all; clc;

run read_para.m

eq_panel=figure('Unit','normalized',...
   'Position',[0.01 0.1 0.3 0.3], ...
   'Resize','on','menubar','none',...
   'numbertitle','off','name','GTC Data Processing GUI -- Equilibrium');

eq_str={'minor','major','Te','ne','Ti','ni','Tf','nf','Zeff';
        'rotation','E_r','q:psi-r','s:psi-r','g:psi-r','p:psi-r','tor:psi-r','r:psi-tor','rg:psi-r';
        'psi(tor)','psi(rg)','q(psi)','psi-r:rg','spline mesh','b-field','Jacobian','icurrent','zeta2phi';
        'delb','b(theta)','J(theta)','spline error','PS file','window size','isp','Exit','back to plt'};

for i=1:4
    for j=1:9
        eq_btm(i,j) = uicontrol(eq_panel,'style','pushbutton','units','normalized','position',...
            [0.04+(i-1)*0.24,0.89-(j-1)*0.11,0.2,0.1],'string',eq_str(i,j));
    end
end

% load equilibruim file data
run setpath;

% path='C:\Users\hsxie\Desktop\2\';

eq_data=load([path,'equilibrium.out']);

nrplot = eq_data(1); 
lsp1   = eq_data(2); % nrad
nplot  = eq_data(2+(nrplot+1)*lsp1+1);
lsp2   = eq_data(2+(nrplot+1)*lsp1+2);
lst    = eq_data(2+(nrplot+1)*lsp1+3);
isp    = lsp2-1;
% intial the array
pdata = zeros(lsp1,nrplot+1);
spdata= zeros(lsp2,lst,nplot+2);
% read datap, data1d from equilibruim file
for i=1:lsp1      % # of 1D radial plots and radial points
    for j=1:nrplot+1
        % 1: dadial axis using poloidal flux function
        % 2: square-root of normalized toroidal flux function
        % 3: minor radius
        % 4: minor radius
        % 5: Te
        % 6: -d(ln(Te))/dr
        % 7: ne
        % 8: -d(ln(ne))/dr
        % 9: ti
        % 10: -d(ln(ti))/dr
        % 11: ni
        % 12: -d(ln(ni))/dr
        % 13: tf
        % 14: -d(ln(tf))/dr
        % 15: nf
        % 16: -d(ln(nf))/dr
        % 17: zeff
        % 18: toroidal rotation
        % 19: radial electric field
        % 20: q profile
        % 21: d(ln(q))/dpsi
        % 22: gcurrent profile
        % 23: pressure profile
        % 24: minor radius
        % 25: toroidal flux
        % 26: radial grid: rgpsi
        % 27: inverse of spline torpsi: psitor
        % 28: inverse of spline rgpsi: psirg
        % 29: error of spline cos in [0, pi/2]
        % 30: error of spline sin in [0, pi/2]
        ind=2+(j-1)*lsp1+i;
        pdata(i,j)=eq_data(ind);
    end
end

for i=1:lsp2                      % # of 2D contour plots on poloidal plane
    for j=1:lst
        for k=1:nplot+2
            % 1: x  mesh points on (X,Z)
            % 2: z  mesh points on (X,Z)
            % 3: b  b-field
            % 4: J  Jacobian
            % 5: i  icurrent
            % 6: zeta2phi   zeta (magnetic coord.) to phi (cylindrical coord.) 
            % 7: delta current  delta current
            ind=(2+(nrplot+1)*lsp1+3)+((k-1)*lst+(j-1))*lsp2+i;
            spdata(i,j,k)=eq_data(ind);
        end
    end
end
% output the torpsi边界值用于求解rho_t=sqrt(torpsi/torpsi_ped)与实验对比
% gtc网格中使用的是重新划分后的区域psi0-psi1
% 
torpsi_ped =  pdata(lsp1,25);


% callback function for each pushbutton
% col 1:
eq_cb_1=['h=figure(''Name'',''minor_radius'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'plot(pdata(:,1),pdata(:,3),''LineWidth'',2);axis tight;title(''inverse aspec-ratio from profile data'');'];
set(eq_btm(1,1),'callback',eq_cb_1); % 1: minor radius

eq_cb_2=['h=figure(''Name'',''major_radius'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'plot(pdata(:,1),pdata(:,4),''LineWidth'',2);axis tight;title(''major radius from profile data'');'];
set(eq_btm(1,2),'callback',eq_cb_2); % 2: major radius

eq_cb_3=['h=figure(''Name'',''Te'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(pdata(:,24)/pdata(lsp1-1,24),pdata(:,6),''LineWidth'',2);axis tight;title(''-dlnTe/dr'');',...
    'subplot(212);plot(pdata(:,1),pdata(:,5),''LineWidth'',2);axis tight;title(''Te(psi)'');run cal_equilibrium_profile.m'];
set(eq_btm(1,3),'callback',eq_cb_3); % 3: Te

eq_cb_4=['h=figure(''Name'',''ne'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(pdata(:,24)/pdata(lsp1-1,24),pdata(:,8),''LineWidth'',2);axis tight;title(''-dlnne/dr'');',...
    'subplot(212);plot(pdata(:,1),pdata(:,7),''LineWidth'',2);axis tight;title(''ne(psi)'');run cal_equilibrium_profile_domain.m'];
set(eq_btm(1,4),'callback',eq_cb_4); % 4: ne

eq_cb_5=['h=figure(''Name'',''Ti'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(pdata(:,24)/pdata(lsp1-1,24),pdata(:,10),''LineWidth'',2);axis tight;title(''-dlnTi/dr'');',...
    'subplot(212);plot(pdata(:,1),pdata(:,9),''LineWidth'',2);axis tight;title(''Ti(psi)'');'];
set(eq_btm(1,5),'callback',eq_cb_5); % 5: Ti

eq_cb_6=['h=figure(''Name'',''ni'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(pdata(:,24)/pdata(lsp1-1,24),pdata(:,12),''LineWidth'',2);axis tight;title(''-dlnni/dr'');',...
    'subplot(212);plot(pdata(:,1),pdata(:,11),''LineWidth'',2);axis tight;title(''ni(psi)'');'];
set(eq_btm(1,6),'callback',eq_cb_6); % 6: ni

eq_cb_7=['h=figure(''Name'',''Tf'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(pdata(:,24)/pdata(lsp1-1,24),pdata(:,14),''LineWidth'',2);axis tight;title(''-dlnTf/dr'');',...
    'subplot(212);plot(pdata(:,1),pdata(:,13),''LineWidth'',2);axis tight;title(''Tf(psi)'');'];
set(eq_btm(1,7),'callback',eq_cb_7); % 7: Tf

eq_cb_8=['h=figure(''Name'',''nf'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(pdata(:,24)/pdata(lsp1-1,24),pdata(:,16),''LineWidth'',2);axis tight;title(''-dlnnf/dr'');',...
    'subplot(212);plot(pdata(:,1),pdata(:,15),''LineWidth'',2);axis tight;title(''nf(psi)'');'];
set(eq_btm(1,8),'callback',eq_cb_8); % 8: nf

eq_cb_9=['h=figure(''Name'',''Zeff'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'plot(pdata(:,1),pdata(:,17),''LineWidth'',2);axis tight;title(''Zeff'');'];
set(eq_btm(1,9),'callback',eq_cb_9); % 9: Zeff

eq_cb_10=['h=figure(''Name'',''rotation'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'plot(pdata(:,1),pdata(:,18),''LineWidth'',2);axis tight;title(''rotation'');'];
set(eq_btm(2,1),'callback',eq_cb_10); % 10: rotation

eq_cb_11=['h=figure(''Name'',''Er'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'plot(pdata(:,1),pdata(:,19),''LineWidth'',2);axis tight;title(''E_r'');'];
set(eq_btm(2,2),'callback',eq_cb_11); % 11: E_r

eq_cb_12=['h=figure(''Name'',''qpsi_qr'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(pdata(:,1),pdata(:,20),''LineWidth'',2);axis tight;title(''q(psi)'');',...
    'subplot(212);plot(pdata(:,24),pdata(:,20),''LineWidth'',2);axis tight;title(''q(r)'');'];
set(eq_btm(2,3),'callback',eq_cb_12); % 12: q(psi), q(r)

eq_cb_13=['h=figure(''Name'',''shearpsi_sr'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(pdata(:,24)/pdata(lsp1-1,24),pdata(:,1),''LineWidth'',2);axis tight;title(''psi(r)'');',...
    'subplot(212);plot(pdata(:,1),pdata(:,21),''LineWidth'',2);axis tight;title(''dq/dpsi'');'];
set(eq_btm(2,4),'callback',eq_cb_13); % 13: shear(psi), s(r)

eq_cb_14=['h=figure(''Name'',''current_gpsi_gr'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(pdata(:,1),pdata(:,22),''LineWidth'',2);axis tight;title(''g(psi)'');',...
    'subplot(212);plot(pdata(:,24),pdata(:,22),''LineWidth'',2);axis tight;title(''g(r)'');'];
set(eq_btm(2,5),'callback',eq_cb_14); % 14: current g(psi) & g(r)

eq_cb_15=['h=figure(''Name'',''pressure_ppsi_pr'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(pdata(:,1),pdata(:,23),''LineWidth'',2);axis tight;title(''P(psi)'');',...
    'subplot(212);plot(pdata(:,24),pdata(:,23),''LineWidth'',2);axis tight;title(''P(r)'');'];
set(eq_btm(2,6),'callback',eq_cb_15); % 15: pressure p(psi) & p(r)

eq_cb_16=['h=figure(''Name'',''toroidal_flux_psi_r'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(pdata(:,1),pdata(:,25),''LineWidth'',2);axis tight;title(''toroidal flux(psi)'');',...
    'subplot(212);plot(pdata(:,24),pdata(:,25),''LineWidth'',2);axis tight;title(''toroidal flux(r)'');'];
set(eq_btm(2,7),'callback',eq_cb_16); % 16: toroidal flux (psi) & (r)

eq_cb_17=['h=figure(''Name'',''rpsi_rtorpsi'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(pdata(:,1),pdata(:,24),''LineWidth'',2);axis tight;title(''r(psi)'');',...
    'subplot(212);plot(pdata(:,25),pdata(:,24),''LineWidth'',2);axis tight;title(''r(toroidal flux)'');'];
set(eq_btm(2,8),'callback',eq_cb_17); % 17: r(psi) & r(torpsi)

eq_cb_18=['h=figure(''Name'',''radial_grid'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(pdata(:,1),pdata(:,26),''LineWidth'',2);axis tight;title(''radial grid rg(psi)'');',...
    'subplot(212);plot(pdata(:,24),pdata(:,26),''LineWidth'',2);axis tight;title(''radial grid rg(r)'');'];
set(eq_btm(2,9),'callback',eq_cb_18); % 18: radial grid 第一列是psi 第24列是r 第26列是rg

eq_cb_19=['h=figure(''Name'',''toroidal_flux_and_its_inverse'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'plot(pdata(:,1),pdata(:,25),pdata(:,27),pdata(1,25)+(pdata(lsp1,25)-pdata(1,25))*(0:(lsp1-1))/(lsp1-1),''LineWidth'',2);',...
    'axis tight;title(''toroidal flux tor(psi) & psi(tor)'');'];
set(eq_btm(3,1),'callback',eq_cb_19); % 19: toroidal flux and its inverse

eq_cb_20=['h=figure(''Name'',''radial_grid_and_its_inverse'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'plot(pdata(:,1),pdata(:,26),pdata(:,28),pdata(1,26)+(pdata(lsp1,26)-pdata(1,26))*(0:(lsp1-1))/(lsp1-1),''LineWidth'',2);',...
    'axis tight;title(''radial grip rg(psi) & psi(rg)'');'];
set(eq_btm(3,2),'callback',eq_cb_20); % 20: radial grid and its inverse

% 21 ...
eq_cb_21=['h=figure(''Name'',''qpsi'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(pdata(:,1),pdata(:,25),''LineWidth'',2);axis tight;title(''q(psi) from spdata & dtorpsi/dpsi'');',...
    'subplot(212);plot(pdata(:,24),pdata(:,25),''LineWidth'',2);axis tight;title(''toroidal flux(r)'');'];
set(eq_btm(3,3),'callback',eq_cb_21); % 21: q(psi)

eq_cb_22=['h=figure(''Name'',''psirg_rrg'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(pdata(1,26)+(pdata(lsp1,26)-pdata(1,26))*(0:(lsp1-1))/(lsp1-1),pdata(:,28),''LineWidth'',2);axis tight;title(''radial grid psi(rg)'');',...
    'subplot(212);plot(pdata(1,26)+(pdata(lsp1,26)-pdata(1,26))*(0:(lsp1-1))/(lsp1-1),pdata(:,28),''LineWidth'',2);axis tight;title(''radial grid r(rg)'');'];
set(eq_btm(3,4),'callback',eq_cb_22); % 22: psi(rg) & r(rg) 

eq_cb_23=['h=figure(''Name'',''poloidal_mesh'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'lsp=lsp2;datax=spdata(:,:,1);dataz=spdata(:,:,2);lp=lsp-1;for i=1:lp+1 x=datax(i,:);y=dataz(i,:);',...
    'x(lst+1)=x(1);y(lst+1)=y(1);plot(x,y);hold on; end; for j=1:lst x=datax(1:lp+1,j);y=dataz(1:lp+1,j);plot(x,y);hold on; end;',...
    'axis tight;title(''poloidal mesh'');axis equal;xlabel(''R'');ylabel(''Z'');'];
set(eq_btm(3,5),'callback',eq_cb_23); % 23: poloidal mesh

eq_cb_24=['h=figure(''Name'',''bfield'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(spdata(:,:,1),spdata(:,:,2),spdata(:,:,3));shading(''interp'');axis tight;axis equal;title(''b-field'');colormap(hsv);'];
set(eq_btm(3,6),'callback',eq_cb_24); % 24: b-field

eq_cb_25=['h=figure(''Name'',''Jacobian'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(spdata(:,:,1),spdata(:,:,2),spdata(:,:,4));shading(''interp'');axis tight;axis equal;title(''Jacobian'');colormap(hsv);'];
set(eq_btm(3,7),'callback',eq_cb_25); % 25: Jacobian

eq_cb_26=['h=figure(''Name'',''icurrent'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(spdata(:,:,1),spdata(:,:,2),spdata(:,:,5));shading(''interp'');axis tight;axis equal;title(''icurrent'');colormap(hsv);'];
set(eq_btm(3,8),'callback',eq_cb_26); % 26: icurrent

eq_cb_27=['h=figure(''Name'',''zeta2phi'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(spdata(:,:,1),spdata(:,:,2),spdata(:,:,6));shading(''interp'');axis tight;axis equal;title(''zeta2phi'');colormap(hsv);'];
set(eq_btm(3,9),'callback',eq_cb_27); % 27: zeta2phi

eq_cb_28=['h=figure(''Name'',''delb'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(spdata(:,:,1),spdata(:,:,2),spdata(:,:,7));shading(''interp'');axis tight;axis equal;title(''delb'');'];
set(eq_btm(4,1),'callback',eq_cb_28); % 28: delb

eq_cb_29=['h=figure(''Name'',''bfield_theta'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'tdata=2.0*pi*(0:lst)/lst;y1(1:lst)=spdata(isp+1,:,3);y1(lst+1)=y1(1);',...
    'plot(tdata,y1,''LineWidth'',2);axis tight;title(''b-field (theta) at psi=isp'');'];
set(eq_btm(4,2),'callback',eq_cb_29); % 29: b-field (theta)

eq_cb_30=['h=figure(''Name'',''Jacobian'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'tdata=2.0*pi*(0:lst)/lst;y1(1:lst)=3.8*spdata(isp,:,4);y1(lst+1)=y1(1);',...
    'y2(1:lst)=(pdata(isp+1,22)*pdata(isp+1,20)+spdata(isp+1,:,5))./(spdata(isp+1,:,3).*spdata(isp+1,:,3));y2(lst+1)=y2(1);',...
    'plot(tdata,y1,tdata,y2,''LineWidth'',2);axis tight;title(''Jacobian spdata & (gq+I)/B^2 at psi=isp'');'];
set(eq_btm(4,3),'callback',eq_cb_30); % 30: Jacobian

eq_cb_31=['h=figure(''Name'',''error_of_spline_cos_and_sin'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'x=1:lsp1;plot(x,pdata(:,29),x,pdata(:,30),''LineWidth'',2);axis tight;title(''error of spline cos and sin'');'];
set(eq_btm(4,4),'callback',eq_cb_31); % 31: error of spline cos and sin

% eq_cb_32=['filename=[''eq_'',get(h,''Name''),''_'',datestr(now,30),''.ps''];print(h,''-dpsc'',filename);'];
% set(eq_btm(4,5),'callback',eq_cb_32);  % 32: PS file
eq_cb_32=['filename=[path,''eq_'',get(h,''Name''),''_'',datestr(now,30),''.png''];print(h,''-dpng'',filename);'];
set(eq_btm(4,5),'callback',eq_cb_32);  % 32: PS file

set(eq_btm(4,6),'enable','off');  % 33: change window size

eq_cb_34=['disp([''current isp= '',num2str(isp)]);isp=input([''new isp=? (max='',num2str(lsp2-1),'') '']);'];
set(eq_btm(4,7),'callback',eq_cb_34);  % 34: change isp

eq_cb_35='close all;clc;';
set(eq_btm(4,8),'callback',eq_cb_35);  % 35: exit

set(eq_btm(4,9),'callback','close all;clc;plt;');  % 36: back to plt.m



