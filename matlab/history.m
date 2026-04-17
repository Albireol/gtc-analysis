% Hua-sheng XIE, IFTS-ZJU, huashengxie@gmail.com, 2011-10-22 11:02
% GTC Data Processing GUI -- History, http://phoenix.ps.uci.edu/GTC/
% v1.1, 2012-12-04 13:48
% v1.2, 2012-12-10 21:06
%   fix v1.1 read data bug, wrong apara and fluide, pointed 
%   out by Xi-shuo WEI
% v1.3, 2014-03-27 09:05 draft, 2014-04-05 10:14 update
%   add fieldm.m, snapmovie.m, tracking.m ... , 
%   also better parameter setup
% v.1.4,2021-10-15 11:00  马越好 更新了代码 计算增长率和频率的部分，以及平衡
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Yuehao Ma, USTC, myh2020@mail.ustc.edu.cn, 2024-01-01 11:02
% GTC Data Processing GUI
% V4.6 for gtc4.6 version myh 20230323 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 原先的频率计算有问题，验证idl中的频率计算结果是对的，其中总步数为偶数
% 在此代码的基础上修改了idl中的源文件，根据合适的时间尺度选择计算增长率nfreq
% 平衡部分有些计算存在问题，加入新的计算如标长等等
clc,clear;close all;
run setpath.m;
run read_para.m
hsty_panel=figure('Unit','normalized',...
   'Position',[0.01 0.05 0.4 0.4], ...
   'Resize','on','menubar','none',...
   'numbertitle','off','name','GTC Data Processing GUI -- History');

hsty_str={'phi','RMS','mode1','mode2','mode3','mode4','mode5','mode6','mode7','mode8';
	'apara','RMS','mode1','mode2','mode3','mode4','mode5','mode6','mode7','mode8';
	'fluidne','RMS','mode1','mode2','mode3','mode4','mode5','mode6','mode7','mode8';
	'ion density','momentum','energy','pmflux','eflux','EP density','momentum',...
    'energy','pmflux','eflux';
	'electron density','momentum','energy','pmflux','eflux','time range',...
    'frequency range','PS file','Exit','back to plt'};

for i=1:5
    for j=1:10
        hsty_btm(i,j) = uicontrol(hsty_panel,'style','pushbutton','units','normalized','position',...
            [0.03+(i-1)*0.19,0.88-(j-1)*0.09,0.18,0.07],'string',hsty_str(i,j));
    end
end

% load history file data
% path='D:\gtc_dat\';
% run read_para;
hsty_data=[];
hsty_data=load([path,'history.out']);
% % # of time steps
% 	1.ndstep =  总步长/每次诊断次数
% % # of species: ion, electron, EP, impuries
% 	2.nspecies = 粒子种类
% % # of quantities per species: density,entropy,momentum,energy, fluxes
% 	3.mpdiag = 每种粒子的属性;	
% % # of field variables: phi, a_par, fluidne
% 	4.nfield = 场变量;
% % # of modes per field: (n,m)
% 	5.modes = 模数;
% % # of quantities per field: rms, single spatial point, zonal components
% 	6.mfdiag = 场的属性;
% % # time step size
% 	7.tstep = 这里弄清楚是dt0*R_0/C_s/rho0*ndiag; times the utime is the sencond
ndstep      = hsty_data(1);
nspecies    = hsty_data(2);
mpdiag      = hsty_data(3);
nfield      = hsty_data(4);
modes       = hsty_data(5);
mfdiag      = hsty_data(6);
tstep_ndiag = hsty_data(7)*utime/tstep_gtc_axis;    % here tstep*ndiag unit is R0/C_s
ndata       = nspecies*mpdiag+nfield*(2*modes+mfdiag);

% ntime=ndstep;
ntime=floor(length(hsty_data)/ndata);
xtime=(1:ntime)';
nstart=1; % nstart=1;
nend=ntime;   
% 计算omega的起始时间位置 需要人眼来观察什么时候线性增长 2021 10 14
% nstart_idl = 0;
nfreq=round((nend-nstart)/2);   % nfreq=(nend-nstart)/10; idl history.pro
% nfreq=round((nend-nstart)/10); % 2013-11-01 11:05
% nfreq=round(nend*0.90); % 2013-11-01 11:05
% nstart_gamma=nfreq; % 计算gamma的起始时间位置 修改后可以与后面的计算一致
% read particle and field data from history file
partdata=zeros(ntime,mpdiag,nspecies,'double');
fieldtime=zeros(ntime,mfdiag,nfield,'double');
fieldmode=zeros(ntime,2,modes,nfield,'double');
for it=1:ntime
    for i=1:nspecies
        for j=1:mpdiag
            ind=7+(it-1)*ndata+(i-1)*mpdiag+j; % fix v1.1 read data bug, wrong apara and fluide, pointed out by WEI Xi-shuo
            partdata(it,j,i)=hsty_data(ind);
        end
    end
    for i=1:nfield
        for j=1:mfdiag
            ind=7+nspecies*mpdiag+(it-1)*ndata+(i-1)*mfdiag+j; % fix v1.1 read data bug
            fieldtime(it,j,i)=hsty_data(ind);
        end
    end
    for i=1:nfield
        for j=1:modes
            ind1=7+nspecies*mpdiag+nfield*mfdiag+(it-1)*ndata+(i-1)*2*modes+2*(j-1)+1; % fix v1.1 read data bug
            ind2=ind1+1;
            fieldmode(it,1,j,i)=hsty_data(ind1);
            fieldmode(it,2,j,i)=hsty_data(ind2);
        end
    end
end

fieldmode=fieldmode;

%数据读取完之后将时间数组格点转换到真实时间 R0/Cs
dt=dt0*ndiag;  
nt=length(fieldtime(:,1,1));
t=dt:dt:nt*dt;  
%数据读取完之后将时间数组格点转换到真实时间 R0/Cs,非均匀时间网格
%t = cal_TimeArray(nt, 0.002, ndiag, dt0, 16400);

% callback function for each pushbutton
% col 1:
hsty_cb_1=['h=figure(''Name'',''phi'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(fieldtime(:,1,1),''LineWidth'',2);axis tight;title(''phi(theta=zeta=0)'');',...
    'subplot(212);plot(fieldtime(:,2,1),''LineWidth'',2);axis tight;title(''phip00(iflux_{diag})'');run cal_history_fieldtime.m'];
set(hsty_btm(1,1),'callback',hsty_cb_1); % 1: phi

hsty_cb_2=['h=figure(''Name'',''RMS'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(fieldtime(:,3,1),''LineWidth'',2);axis tight;title(''ZF RMS'');',...
    'subplot(212);plot(fieldtime(:,4,1),''LineWidth'',2);axis tight;title(''phi RMS'');'];
set(hsty_btm(1,2),'callback',hsty_cb_2); % 2: RMS
%关键之处 计算频率和增长率 idl 中
mode_eval_str=['subplot(231);plot(xtime,yr,xtime,yi,''LineWidth'',2);axis tight;',...
    'title(''history of real & imag components'');ylabel([''n='',num2str(nmodes(imode)),'', m='',num2str(mmodes(imode))]);grid on;',...
    'ya=sqrt(yr.^2+yi.^2);subplot(234);plot(xtime,log10(ya),''LineWidth'',2);axis tight;',...
    'title(''amplitude history'');run cal_gamma;gamma0=log(ya(nend)/ya(nstart))/(nend-nstart);',...
    'nstart=1;nend=ntime;xpow=(0:(nend-nstart))'';yr1=yr./exp(gamma0*xpow);yi1=yi./exp(gamma0*xpow);',...
    'disp([''growth rate (IDL version) = '', num2str(gamma0/tstep_ndiag)]);',...
    'subplot(232);plot(xtime,yr1,xtime,yi1,''LineWidth'',2);grid on;',...
    'axis tight;title(''amplitude normalized by growth rate'');',...
    'run cal_omega_simple;run cal_omega_fft;power=fft(yr1+1i*yi1);ypow=abs(power);',...
    'for i=1:nfreq-1 yp(i)=ypow(i+nend-nstart-nfreq+1);xp(i)=(i-nfreq+1)*2*pi/((nend-nstart)*tstep_ndiag); end;',...
    'for i=1:nfreq yp(nfreq-1+i)=ypow(i);xp(nfreq-1+i)=i*2*pi/((nend-nstart)*tstep_ndiag); end;',...
    'subplot(233);plot(xp,yp,''LineWidth'',2);axis tight;ylabel(''power spectral'');title(''phi=exp[-i(omega*t+m*theta-n*zeta)]'');',...
    'grid on'];

hsty_cb_3=['h=figure(''Name'',''Mode1_phi'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,1,1);',...
    'imode=1;yi=fieldmode(:,2,imode,1);eval(mode_eval_str);'];
set(hsty_btm(1,3),'callback',hsty_cb_3); % 3: mode=1

hsty_cb_4=['h=figure(''Name'',''Mode2_phi'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,2,1);',...
    'imode=2;yi=fieldmode(:,2,imode,1);eval(mode_eval_str);'];
set(hsty_btm(1,4),'callback',hsty_cb_4); % 4: mode=2

hsty_cb_5=['h=figure(''Name'',''Mode3_phi'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,3,1);',...
    'imode=3;yi=fieldmode(:,2,imode,1);eval(mode_eval_str);'];
set(hsty_btm(1,5),'callback',hsty_cb_5); % 5: mode=3

hsty_cb_6=['h=figure(''Name'',''Mode4_phi'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,4,1);',...
    'imode=4;yi=fieldmode(:,2,imode,1);eval(mode_eval_str);'];
set(hsty_btm(1,6),'callback',hsty_cb_6); % 6: mode=4

hsty_cb_7=['h=figure(''Name'',''Mode5_phi'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,5,1);',...
    'imode=5;yi=fieldmode(:,2,imode,1);eval(mode_eval_str);'];
set(hsty_btm(1,7),'callback',hsty_cb_7); % 7: mode=5

hsty_cb_8=['h=figure(''Name'',''Mode6_phi'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,6,1);',...
    'imode=6;yi=fieldmode(:,2,imode,1);eval(mode_eval_str);'];
set(hsty_btm(1,8),'callback',hsty_cb_8); % 8: mode=6

hsty_cb_9=['h=figure(''Name'',''Mode7_phi'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,7,1);',...
    'imode=7;yi=fieldmode(:,2,imode,1);eval(mode_eval_str);'];
set(hsty_btm(1,9),'callback',hsty_cb_9); % 9: mode=7

hsty_cb_10=['h=figure(''Name'',''Mode8_phi'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,8,1);',...
    'imode=8;yi=fieldmode(:,2,imode,1);eval(mode_eval_str);'];
set(hsty_btm(1,10),'callback',hsty_cb_10); % 10: mode=8

% col 2:
hsty_cb_11=['h=figure(''Name'',''a_par'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(fieldtime(:,1,2),''LineWidth'',2);axis tight;title(''a_{par}(theta=zeta=0)'');',...
    'subplot(212);plot(fieldtime(:,2,2),''LineWidth'',2);axis tight;title(''a_{par00}(iflux_{diag})'');'];
set(hsty_btm(2,1),'callback',hsty_cb_11); % 11: a_par

hsty_cb_12=['h=figure(''Name'',''zonal_a_par'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(fieldtime(:,3,2),''LineWidth'',2);axis tight;title(''ZF RMS'');',...
    'subplot(212);plot(fieldtime(:,4,2),''LineWidth'',2);axis tight;title(''a_{par} RMS'');'];
set(hsty_btm(2,2),'callback',hsty_cb_12); % 12: zonal a_par

hsty_cb_13=['h=figure(''Name'',''Mode1_Apara'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,1,2);',...
    'imode=1;yi=fieldmode(:,2,imode,2);eval(mode_eval_str);'];
set(hsty_btm(2,3),'callback',hsty_cb_13); % 13: mode=1

hsty_cb_14=['h=figure(''Name'',''Mode2_Apara'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,2,2);',...
    'imode=2;yi=fieldmode(:,2,imode,2);eval(mode_eval_str);'];
set(hsty_btm(2,4),'callback',hsty_cb_14); % 14: mode=2

hsty_cb_15=['h=figure(''Name'',''Mode3_Apara'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,3,2);',...
    'imode=3;yi=fieldmode(:,2,imode,2);eval(mode_eval_str);'];
set(hsty_btm(2,5),'callback',hsty_cb_15); % 15: mode=3

hsty_cb_16=['h=figure(''Name'',''Mode4_Apara'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,4,2);',...
    'imode=4;yi=fieldmode(:,2,imode,2);eval(mode_eval_str);'];
set(hsty_btm(2,6),'callback',hsty_cb_16); % 16: mode=4

hsty_cb_17=['h=figure(''Name'',''Mode5_Apara'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,5,2);',...
    'imode=5;yi=fieldmode(:,2,imode,2);eval(mode_eval_str);'];
set(hsty_btm(2,7),'callback',hsty_cb_17); % 17: mode=5

hsty_cb_18=['h=figure(''Name'',''Mode6_Apara'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,6,2);',...
    'imode=6;yi=fieldmode(:,2,imode,2);eval(mode_eval_str);'];
set(hsty_btm(2,8),'callback',hsty_cb_18); % 18: mode=6

hsty_cb_19=['h=figure(''Name'',''Mode7_Apara'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,7,2);',...
    'imode=7;yi=fieldmode(:,2,imode,2);eval(mode_eval_str);'];
set(hsty_btm(2,9),'callback',hsty_cb_19); % 19: mode=7

hsty_cb_20=['h=figure(''Name'',''Mode8_Apara'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,8,2);',...
    'imode=8;yi=fieldmode(:,2,imode,2);eval(mode_eval_str);'];
set(hsty_btm(2,10),'callback',hsty_cb_20); % 20: mode=8

% col 3:
hsty_cb_21=['h=figure(''Name'',''fluidne'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(fieldtime(:,1,3),''LineWidth'',2);axis tight;title(''fluidne(theta=zeta=0)'');',...
    'subplot(212);plot(fieldtime(:,2,3),''LineWidth'',2);axis tight;title(''fluidne_{00}(iflux_{diag})'');'];
set(hsty_btm(3,1),'callback',hsty_cb_21); % 21: fluidne

hsty_cb_22=['h=figure(''Name'',''zonal_fluidne'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(fieldtime(:,3,3),''LineWidth'',2);axis tight;title(''ZF RMS'');',...
    'subplot(212);plot(fieldtime(:,4,3),''LineWidth'',2);axis tight;title(''fluidne RMS'');'];
set(hsty_btm(3,2),'callback',hsty_cb_22); % 22: zonal fluidne

hsty_cb_23=['h=figure(''Name'',''Mode1_fluidne'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,1,3);',...
    'imode=1;yi=fieldmode(:,2,imode,3);eval(mode_eval_str);'];
set(hsty_btm(3,3),'callback',hsty_cb_23); % 23: mode=1

hsty_cb_24=['h=figure(''Name'',''Mode2_fluidne'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,2,3);',...
    'imode=2;yi=fieldmode(:,2,imode,3);eval(mode_eval_str);'];
set(hsty_btm(3,4),'callback',hsty_cb_24); % 24: mode=2

hsty_cb_25=['h=figure(''Name'',''Mode3_fluidne'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,3,3);',...
    'imode=3;yi=fieldmode(:,2,imode,3);eval(mode_eval_str);'];
set(hsty_btm(3,5),'callback',hsty_cb_25); % 25: mode=3

hsty_cb_26=['h=figure(''Name'',''Mode4_fluidne'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,4,3);',...
    'imode=4;yi=fieldmode(:,2,imode,3);eval(mode_eval_str);'];
set(hsty_btm(3,6),'callback',hsty_cb_26); % 26: mode=4

hsty_cb_27=['h=figure(''Name'',''Mode5_fluidne'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,5,3);',...
    'imode=5;yi=fieldmode(:,2,imode,3);eval(mode_eval_str);'];
set(hsty_btm(3,7),'callback',hsty_cb_27); % 27: mode=5

hsty_cb_28=['h=figure(''Name'',''Mode6_fluidne'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,6,3);',...
    'imode=6;yi=fieldmode(:,2,imode,3);eval(mode_eval_str);'];
set(hsty_btm(3,8),'callback',hsty_cb_28); % 28: mode=6

hsty_cb_29=['h=figure(''Name'',''Mode7_fluidne'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,7,3);',...
    'imode=7;yi=fieldmode(:,2,imode,3);eval(mode_eval_str);'];
set(hsty_btm(3,9),'callback',hsty_cb_29); % 29: mode=7

hsty_cb_30=['h=figure(''Name'',''Mode8_fluidne'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);yr=fieldmode(:,1,8,3);',...
    'imode=8;yi=fieldmode(:,2,imode,3);eval(mode_eval_str);'];
set(hsty_btm(3,10),'callback',hsty_cb_30); % 30: mode=8

% col 4:
hsty_cb_31=['h=figure(''Name'',''ion_density_entropy'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(partdata(:,1,1),''LineWidth'',2);axis tight;title(''density \delta{f}'');',...
    'subplot(212);plot(partdata(:,2,1),''LineWidth'',2);axis tight;title(''entropy \delta{f^2}'');'];
set(hsty_btm(4,1),'callback',hsty_cb_31); % 31: ion density & entropy

hsty_cb_32=['h=figure(''Name'',''momentum'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(partdata(:,3,1),''LineWidth'',2);axis tight;title(''paralle flow u'');',...
    'subplot(212);plot(partdata(:,4,1),''LineWidth'',2);axis tight;title(''\delta{u}'');'];
set(hsty_btm(4,2),'callback',hsty_cb_32); % 32: momentum

hsty_cb_33=['h=figure(''Name'',''energy'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(partdata(:,5,1),''LineWidth'',2);axis tight;title(''energy E-1.5'');',...
    'subplot(212);plot(partdata(:,6,1),''LineWidth'',2);axis tight;title(''entropy \delta{E}'');'];
set(hsty_btm(4,3),'callback',hsty_cb_33); % 33: energy

hsty_cb_34=['h=figure(''Name'',''particle_momentum_flux'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(partdata(:,7,1),''LineWidth'',2);axis tight;title(''particle flux'');',...
    'subplot(212);plot(partdata(:,8,1),''LineWidth'',2);axis tight;title(''momentum flux'');'];
set(hsty_btm(4,4),'callback',hsty_cb_34); % 34: particle & momentum flux

hsty_cb_35=['h=figure(''Name'',''energy_flux'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(partdata(:,9,1),''LineWidth'',2);axis tight;title(''energy flux'');',...
    'subplot(212);plot(partdata(:,10,1),''LineWidth'',2);axis tight;title(''total density'');'];
set(hsty_btm(4,5),'callback',hsty_cb_35); % 35: energy flux

hsty_cb_36=['h=figure(''Name'',''EP_density_entropy'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(partdata(:,1,3),''LineWidth'',2);axis tight;title(''density \delta{f}'');',...
    'subplot(212);plot(partdata(:,2,3),''LineWidth'',2);axis tight;title(''entropy \delta{f^2}'');'];
set(hsty_btm(4,6),'callback',hsty_cb_36); % 36: EP density & entropy

hsty_cb_37=['h=figure(''Name'',''momentum'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(partdata(:,3,3),''LineWidth'',2);axis tight;title(''paralle flow u'');',...
    'subplot(212);plot(partdata(:,4,3),''LineWidth'',2);axis tight;title(''\delta{u}'');'];
set(hsty_btm(4,7),'callback',hsty_cb_37); % 37: momentum

hsty_cb_38=['h=figure(''Name'',''energy'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(partdata(:,5,3),''LineWidth'',2);axis tight;title(''energy E-1.5'');',...
    'subplot(212);plot(partdata(:,6,3),''LineWidth'',2);axis tight;title(''\delta{E}'');'];
set(hsty_btm(4,8),'callback',hsty_cb_38); % 38: energy

hsty_cb_39=['h=figure(''Name'',''particle_momentum_flux'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(partdata(:,7,3),''LineWidth'',2);axis tight;title(''particle flux'');',...
    'subplot(212);plot(partdata(:,8,3),''LineWidth'',2);axis tight;title(''momentum flux'');'];
set(hsty_btm(4,9),'callback',hsty_cb_39); % 39: particle & momentum flux

hsty_cb_40=['h=figure(''Name'',''energy_flux'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(partdata(:,9,3),''LineWidth'',2);axis tight;title(''energy flux'');',...
    'subplot(212);plot(partdata(:,10,3),''LineWidth'',2);axis tight;title(''total density'');'];
set(hsty_btm(4,10),'callback',hsty_cb_40); % 40: energy flux

% col 5:
hsty_cb_41=['h=figure(''Name'',''enectron_density_entropy'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(partdata(:,1,2),''LineWidth'',2);axis tight;title(''density \delta{f}'');',...
    'subplot(212);plot(partdata(:,2,2),''LineWidth'',2);axis tight;title(''entropy \delta{f^2}'');'];
set(hsty_btm(5,1),'callback',hsty_cb_41); % 41: enectron density & entropy

hsty_cb_42=['h=figure(''Name'',''momentum'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(partdata(:,3,2),''LineWidth'',2);axis tight;title(''paralle flow u'');',...
    'subplot(212);plot(partdata(:,4,2),''LineWidth'',2);axis tight;title(''\delta{u}'');'];
set(hsty_btm(5,2),'callback',hsty_cb_42); % 42: momentum

hsty_cb_43=['h=figure(''Name'',''energy'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(partdata(:,5,2),''LineWidth'',2);axis tight;title(''energy E-1.5'');',...
    'subplot(212);plot(partdata(:,6,2),''LineWidth'',2);axis tight;title(''entropy \delta{E}'');'];
set(hsty_btm(5,3),'callback',hsty_cb_43); % 43: energy

hsty_cb_44=['h=figure(''Name'',''particle_momentum_flux'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(partdata(:,7,2),''LineWidth'',2);axis tight;title(''particle flux'');',...
    'subplot(212);plot(partdata(:,8,2),''LineWidth'',2);axis tight;title(''momentum flux'');'];
set(hsty_btm(5,4),'callback',hsty_cb_44); % 44: particle & momentum flux

hsty_cb_45=['h=figure(''Name'',''energy_flux'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'subplot(211);plot(partdata(:,9,2),''LineWidth'',2);axis tight;title(''energy flux'');',...
    'subplot(212);plot(partdata(:,10,2),''LineWidth'',2);axis tight;title(''total density'');'];
set(hsty_btm(5,5),'callback',hsty_cb_45); % 45: energy flux

hsty_cb_46=['disp([''current range= '',num2str(nstart),'', '',num2str(nend),''. maximal nend=1, '', num2str(ntime)]);',...
    'nstart=input(''new range: nstart= ? '');nend=input(''new range: nend= ? '');'];
set(hsty_btm(5,6),'callback',hsty_cb_46);  % 46: time range

hsty_cb_47=['disp([''current nfreq= '',num2str(nfreq)]);nfreq=input(''new nfreq=? '');'];
set(hsty_btm(5,7),'callback',hsty_cb_47);  % 47: frequency range

% hsty_cb_48=['filename=[''hsty_'',get(h,''Name''),''_'',datestr(now,30),''.ps''];print(h,''-dpsc'',filename);'];
% set(hsty_btm(5,8),'callback',hsty_cb_48);  % 48: PS file
hsty_cb_48=['filename=[path,''hsty_'',get(h,''Name''),''_'',datestr(now,30),''.png''];print(h,''-dpng'',filename);'];
set(hsty_btm(5,8),'callback',hsty_cb_48);  % 48: png file

hsty_cb_49='close all;clc;';
set(hsty_btm(5,9),'callback',hsty_cb_49);  % 49: exit

set(hsty_btm(5,10),'callback','close all;clc;plt;');  % 50: back to plt.m


