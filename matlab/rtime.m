%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Yuehao Ma, USTC, myh2020@mail.ustc.edu.cn
% GTC Data Processing GUI
% V4.6 for gtc4.6 version myh 20230323 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% v1.1, 2012-12-04 13:48
% v1.2, 2012-12-10 21:06, fixed a bug in "history.m"
% v1.3, 2014-03-27 09:05 draft, 2014-04-05 10:14 update
%   add fieldm.m, snapmovie.m, tracking.m ... ,
%   also better parameter setup

close all;clear all; clc;

rtime_panel=figure('Unit','normalized',...
    'Position',[0.01 0.1 0.7 0.08], ...
    'Resize','on','menubar','none',...
    'numbertitle','off','name','GTC Data Processing GUI -- Radial-Time');

rtime_str={'ion flux','energy flux';'electron flux','energy flux';'EP flux','energy flux';'phi00','phi_rms';
    'apara00','apara_rms';'fluidne00','fluidne_rms';'plot range','cutoff';'PS file','Exit'};

for i=1:8
    for j=1:2
        rtime_btm(i,j) = uicontrol(rtime_panel,'style','pushbutton','units','normalized','position',...
            [0.03+(i-1)*0.12,0.54-(j-1)*0.48,0.1,0.4],'string',rtime_str(i,j));
    end
end

% load radial time file data
run setpath;
run read_para.m
tic
% rtime_data=load('D:\cluster\TH-1A\gtc\rsae\2013\31102013\data1d.out');
rtime_data = load([path,'data1d.out']);

ndstep0    = rtime_data(1);
mpsi       = rtime_data(2)-1;  %  rtime_data(2)=mpsi+1  of radial grids: mpsi+1
nspecies   = rtime_data(3);%  of species: ion, electron, EP, impuries
nhybrid    = rtime_data(4); %  whether electron is loaded
mpdata1d   = rtime_data(5);%  of variables per species: particle flux, energy flux, ... mpdata1d=3 in the module.F90
nfield     = rtime_data(6);  %  of fields: phi, a_para, fluidne
mfdata1d   = rtime_data(7);%  of variables per field: phi00, phi_rms, ...
% ndata=(mpsi+1)*(nspecies*mpdata1d+nfield*mfdata1d); %the length of all data with per timestep
ndata      =(mpsi+1)*(mpdata1d)+(mpsi+1)*(mpdata1d)*(nhybrid>0)+...
            (mpsi+1)*(mpdata1d)*(fload>0)+(magnetic>0)*(mpsi+1)*(mpdata1d)+(mpsi+1)*nfield*mfdata1d;
% read data1di, data1de, data1df, field00, fieldrms from radial time file
% data1dfluide,fluxeexb00,fluxebperp00,Qexbadia00 is vaild for gtc.4.6U
% 先构造数组
rtime_data_length       = length(rtime_data);
rtime_data_length_floor = floor(rtime_data_length/ndata);
ndstep                  = rtime_data_length_floor;
% rtime_data_length_floor = ndstep;

data1di      = zeros(ndstep,mpsi+1,mpdata1d);
data1dfluide = zeros(ndstep,mpsi+1,mpdata1d);
data1de      = zeros(ndstep,mpsi+1,mpdata1d);
%for the massless electrons : heat flux is Qexbadia00
%for both electrons : particle flux is fluxeexb00+fluxebperp00

data1df      = zeros(ndstep,mpsi+1,mpdata1d);
field00      = zeros(ndstep,mpsi+1,nfield);
fieldrms     = zeros(ndstep,mpsi+1,nfield);

ind_i      = 7;
ind_ke     = 7+(mpsi+1)*(mpdata1d);
ind_f      = 7+(mpsi+1)*(mpdata1d)+(mpsi+1)*(mpdata1d)*(nhybrid>0);%读取快离子索引
% ind_fe   = ind_f+(mpsi+1)*(mpdata1d)*(fload>0);
ind_fluide = ind_f+(mpsi+1)*(mpdata1d)*(fload>0);

ind_field00  = ind_fluide+(magnetic>0)*(mpsi+1)*(mpdata1d);
ind_fieldrms = ind_field00+(mpsi+1)*nfield;

ind_total_length =  ind_fieldrms+(mpsi+1)*nfield;

for it=1:rtime_data_length_floor

    for i=1:mpdata1d                             %读取离子的2种输运
        for j=1:mpsi+1
            ind=7+(it-1)*ndata+(i-1)*(mpsi+1)+j; %读取离子的粒子数扩散系数 diagnosis.F90 382 383
            data1di(it,j,i)=rtime_data(ind);     %读取离子的能量扩散系数
        end
    end

    if (nhybrid>0)             %读取动理学电子的输运 绝热电子不存在输运系数
        for i=1:mpdata1d       %diagnosis.F90 386 存在4组 无效的数据一组
            for j=1:mpsi+1
                ind=ind_ke+(it-1)*ndata+(i-1)*(mpsi+1)+j;%这个从离子结束开始index
                data1de(it,j,i)=rtime_data(ind);
            end
        end
    end
    if (fload>0)             %读取快离子输运
        for i=1:mpdata1d     %diagnosis.F90 393 存在4组,无效的数据一组
            for j=1:mpsi+1
                ind=ind_f+(it-1)*ndata+(i-1)*(mpsi+1)+j;%这个从离子结束开始index
                data1df(it,j,i)=rtime_data(ind);
            end
        end
    end

    if (magnetic>0)                     %读取电磁模拟下面 流体电子的输运系数
        for i=1:mpdata1d                %diagnosis.F90 710 存在2组
            for j=1:mpsi+1
                ind=ind_fluide+(it-1)*ndata+(i-1)*(mpsi+1)+j;%这个从离子结束开始index
                data1dfluide(it,j,i)=rtime_data(ind);
            end
        end
    end

    for i=1:nfield
        for j=1:mpsi+1
            ind=ind_field00+(it-1)*ndata+(i-1)*(mpsi+1)+j;
            field00(it,j,i)=rtime_data(ind);
        end
    end

    for i=1:nfield
        for j=1:mpsi+1
            ind=ind_fieldrms+(it-1)*ndata+(i-1)*(mpsi+1)+j;
            fieldrms(it,j,i)=rtime_data(ind);
        end
    end


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%total particle flux of electron should be fluxebperp00+fluxeexb00 
%%%total heat flux of electron should be Qexbadia00+data1de(:,2)
%for the massless electrons : heat flux is Qexbadia00
%for both electrons : particle flux is fluxeexb00+fluxebperp00
fluxeexb00   = data1dfluide(:,:,1);
fluxebperp00 = data1dfluide(:,:,3);
Qexbadia00   = data1dfluide(:,:,2);
data1de(:,:,1) = fluxeexb00 + fluxebperp00;
% data1de(:,:,1) = data1de(:,:,1)+fluxeexb00 + fluxebperp00;
% data1de(:,:,2) = data1de(:,:,2)+Qexbadia00;
data1de(:,:,2) = data1de(:,:,2);

ndstep=it;
nstart=1;
nend=ndstep;
m0=1;
m1=mpsi-1;
cutoff=-1.0;

% callback function for each pushbutton
% col 1:
rtime_cb_1=['h=figure(''Name'',''thermal_ion_particle_flux'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(data1di(nstart:nend,m0:m1,1)'');shading(''interp'');title(''thermal ion particle flux'');'];
%  'colorbar;' removed. It's pointed out by Guan-qiong WANG that 'colorbar'
%  for 'pcolor' causes crash at his Linux PC. You can add it yourself, or
%  use 'contourf'. 2014-04-02
set(rtime_btm(1,1),'callback',rtime_cb_1); % 1: thermal ion particle flux

rtime_cb_2=['h=figure(''Name'',''ion_energy_flux'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(data1di(nstart:nend,m0:m1,2)'');shading(''interp'');title(''ion energy flux'');'];
set(rtime_btm(1,2),'callback',rtime_cb_2); % 2: ion energy flux

% col 2:
rtime_cb_3=['h=figure(''Name'',''electron_particle_flux'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(data1de(nstart:nend,m0:m1,1)'');shading(''interp'');title(''electron particle flux'');'];
set(rtime_btm(2,1),'callback',rtime_cb_3); % 3: electron particle flux

rtime_cb_4=['h=figure(''Name'',''electron_energy_flux'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(data1de(nstart:nend,m0:m1,2)'');shading(''interp'');title(''electron energy flux'');'];
set(rtime_btm(2,2),'callback',rtime_cb_4); % 4: electron energy flux

% col 3:
rtime_cb_5=['h=figure(''Name'',''EP_particle_flux'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(data1df(nstart:nend,m0:m1,1)'');shading(''interp'');title(''EP particle flux'');'];
set(rtime_btm(3,1),'callback',rtime_cb_5); % 5: EP particle flux

rtime_cb_6=['h=figure(''Name'',''EP_energy_flux'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(data1df(nstart:nend,m0:m1,2)'');shading(''interp'');title(''EP energy flux'');'];
set(rtime_btm(3,2),'callback',rtime_cb_6); % 6: EP energy flux

% col 4:
rtime_cb_7=['h=figure(''Name'',''zonal_flow'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(field00(nstart:nend,m0:m1,1)'');shading(''interp'');title(''zonal flow'');run cal_rtime_7_zonalflow.m'];
set(rtime_btm(4,1),'callback',rtime_cb_7); % 7: zonal flow

rtime_cb_8=['h=figure(''Name'',''phi_rms'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(fieldrms(nstart:nend,m0:m1,1)'');shading(''interp'');title(''phi\_rms'');'];
set(rtime_btm(4,2),'callback',rtime_cb_8); % 8: phi_rms

% col 5:
rtime_cb_9=['h=figure(''Name'',''zonal_current'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(field00(nstart:nend,m0:m1,2)'');shading(''interp'');title(''zonal current'');'];
set(rtime_btm(5,1),'callback',rtime_cb_9); % 9: zonal current

rtime_cb_10=['h=figure(''Name'',''apara_rms'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(fieldrms(nstart:nend,m0:m1,2)'');shading(''interp'');title(''apara\_rms'');'];
set(rtime_btm(5,2),'callback',rtime_cb_10); % 10: apara_rms

% col 6:
rtime_cb_11=['h=figure(''Name'',''zonal_fluidne'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(field00(nstart:nend,m0:m1,3)'');shading(''interp'');title(''zonal fluidne'');'];
set(rtime_btm(6,1),'callback',rtime_cb_11); % 11: zonal fluidne

rtime_cb_12=['h=figure(''Name'',''fluidne_rms'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(fieldrms(nstart:nend,m0:m1,3)'');shading(''interp'');title(''fluidne\_rms'');'];
set(rtime_btm(6,2),'callback',rtime_cb_12); % 12: fluidne_rms

rtime_cb_13=['disp([''old time ranges (nstart, nend)= '',num2str(nstart),'', '',num2str(nend)]);',...
    'disp([''old radial grid ranges (m0, m1)= '',num2str(m0),'', '',num2str(m1)]);',...
    'disp([''max time= '',num2str(ndstep),'', max grid= '',num2str(mpsi)]);',...
    'nstart=input([''new time ranges? nstart= '']);nend=input([''         nend= '']);',...
    'm0=input([''new grid ranges? m0= '']);m1=input([''         m1= '']);'];
set(rtime_btm(7,1),'callback',rtime_cb_13);  % 13: plot ranges

rtime_cb_14=['disp([''old cutoff= '',num2str(cutoff)]);cutoff=input([''new cutoff=? '']);'];
set(rtime_btm(7,2),'callback',rtime_cb_14);  % 14: cutoff in contour plot
set(rtime_btm(7,2),'enable','off'); % not use in this version

% rtime_cb_15=['filename=[''rtime_'',get(h,''Name''),''_'',datestr(now,30),''.ps''];print(h,''-dpsc'',filename);'];
% set(rtime_btm(8,1),'callback',rtime_cb_15);  % 15: PS file
rtime_cb_15=['filename=[path,''rtime_'',get(h,''Name''),''_'',datestr(now,30),''.png''];print(h,''-dpng'',filename);'];
set(rtime_btm(8,1),'callback',rtime_cb_15);  % 15: PNG file

rtime_cb_16='close all;clc;';
set(rtime_btm(8,2),'callback',rtime_cb_16);  % 16: exit


toc