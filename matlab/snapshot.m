%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Yuehao Ma, USTC, myh2020@mail.ustc.edu.cn
% GTC Data Processing GUI
% V4.6 for gtc4.6 version myh 20230323 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hua-sheng XIE, IFTS-ZJU, huashengxie@gmail.com, 2011-10-23 01:08
% GTC Data Processing GUI -- Snapshot, http://phoenix.ps.uci.edu/GTC/
% v1.1, 2012-12-04 13:48
% v1.2, 2012-12-10 21:06, fixed a bug in "history.m"
% v1.3, 2014-03-27 09:05 draft, 2014-04-05 10:14 update
%   add fieldm.m, snapmovie.m, tracking.m ... , 
%   also better parameter setup
% v.1.4,2021-11-05 11:00  马越好 调用 cal_plot_snapshot.m更清晰绘制二维contourf图
close all;clear all; clc;

snap_panel=figure('Unit','normalized',...
   'Position',[0.01 0.1 0.5 0.15], ...
   'Resize','on','menubar','none',...
   'numbertitle','off','name','GTC Data Processing GUI -- Snapshot');

snap_str={'ion density','flow','energy','PDF-energy','PDF-pitch';
     'electron density','flow','energy','PDF-energy','PDF-pitch';
           'EP density','flow','energy','PDF-energy','PDF-pitch';
                  'phi-flux','spectrum','poloidal','psi','theta';
                'apara-flux','spectrum','poloidal','psi','theta';
              'fluidne-flux','spectrum','poloidal','psi','theta';
            'mode# range','cutoff','PS file','Exit','Load New File'};

for i=1:7
    for j=1:5
        snap_btm(i,j) = uicontrol(snap_panel,'style','pushbutton','units','normalized','position',...
            [0.02+(i-1)*0.14,0.79-(j-1)*0.19,0.12,0.18],'string',snap_str(i,j));
    end
end

% load equilibruim file data
run setpath;
run read_para.m
getfile_eval_str=['[filename,pathname]=uigetfile([path,''snap*.out''],''Select the snapshot file'');',...
    'path=[pathname,filename];snap_data=load(path);'];
eval(getfile_eval_str);

snap_size = length(snap_data);
nspecies  = snap_data(1);
nfield    = snap_data(2);
nvgrid    = snap_data(3);
mpsi      = snap_data(4)-1;    % snap_data(4)=mpsi+1
mtgrid    = snap_data(5)-1;    % snap_data(5)=mtgrid+1
mtoroidal = snap_data(6);
tmax      = snap_data(7);      % snap_data(7)=1.0/emax_inv

% read profile, pdf, poloidata, fluxdata pdf2d from snapshot file
profile   = zeros(mpsi+1,6,nspecies);
pdf       = zeros(nvgrid,4,nspecies);
pdf2d     = zeros(nvgrid,nvgrid,2,nspecies);
poloidata = zeros(mtgrid+1,mpsi+1,nfield+2);
fluxdata  = zeros(mtgrid+1,mtoroidal,nfield);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% define the field type  to chose the nfield for the fluidne panel
nfield_type = 5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% !javierhn: write the phase space of lambda vs Energy. The values in pdf2d(:,:,2,:) correponds to delta_f**2 distribution
%      write(iosnap,102) pdf2d
% !guillaume: write the phase space of mu vs Energy vs Pphi. The values in pdf3d(:,:,2,:) correponds to delta_f distribution
%      write(iosnap,102) pdf3d_mu
% !guillaume: write the thermal ion / fast ion reactivity radial profile
%      write(iosnap,102) reac
pdf3d_mu  = zeros(nvgrid,2*nvgrid,nvgrid,3,nspecies);
reac      = zeros(mpsi+1,2,nspecies);


ind1=7;
ind2=7+(mpsi+1)*nspecies*6;
ind3=7+(mpsi+1)*6*nspecies+nvgrid*4*nspecies;
ind4=7+(mpsi+1)*6*nspecies+nvgrid*4*nspecies+(mtgrid+1)*(mpsi+1)*(nfield+2);
ind5=7+(mpsi+1)*6*nspecies+nvgrid*4*nspecies+(mtgrid+1)*(mpsi+1)*(nfield+2)+...
       (mtgrid+1)*(mtoroidal)*(nfield);
ind6=ind5+2*(nspecies)*nvgrid*nvgrid;
ind7=ind6+3*(nspecies)*nvgrid*(2*nvgrid)*nvgrid;

for i=1:mtgrid+1
    for j=1:mpsi+1
        for k=1:nfield+2
            ind=ind3+((j-1)+(k-1)*(mpsi+1))*(mtgrid+1)+i;
            poloidata(i,j,k)=snap_data(ind);
        end
    end
    for j=1:mtoroidal
        for k=1:nfield
            ind=ind4+((j-1)+(k-1)*mtoroidal)*(mtgrid+1)+i;
            fluxdata(i,j,k)=snap_data(ind);
        end
    end
end



for k=1:nspecies
    for j=1:6
        for i=1:mpsi+1
            ind=ind1+((j-1)+(k-1)*6)*(mpsi+1)+i;
            profile(i,j,k)=snap_data(ind);
        end
    end
    for j=1:4
        for i=1:nvgrid
            ind=ind2+((j-1)+(k-1)*4)*nvgrid+i;
            pdf(i,j,k)=snap_data(ind);
        end
    end
    %绘制pdf2d的图像，gtc4.4以后的功能
    for j=1:2
        for i=1:nvgrid
            for ii=1:nvgrid
                ind=ind5+((j-1)+(k-1)*2)*nvgrid*nvgrid+(i-1)*nvgrid+ii;
                pdf2d(i,ii,j,k)=snap_data(ind);
            end
        end
    end
 
end

if ( snap_size>(ind6+1) )

    for k=1:nspecies
        %绘制pdf3d的图像，gtc4.6的功能 guillaume pdf3d(:,:,2,:) correponds to delta_f distribution
        for j=1:3
            for i=1:nvgrid
                for jj=1:2*nvgrid
                    for ii=1:nvgrid
                        ind=ind6+((((k-1)*3 +(j-1) )*nvgrid +(i-1) )*2*nvgrid +(jj-1) )*nvgrid+ii;
                        pdf3d_mu(ii,jj,i,j,k)=snap_data(ind);
                    end
                end

            end
        end

        for j=1:2
            for i=1:mpsi+1
                ind=ind7+((j-1)+(k-1)*2)*(mpsi+1)+i;
                reac(i,j,k)=snap_data(ind);
            end
        end


    end


end



mmode=round(mtgrid/6);
pmode=round(mtoroidal/5);
cutoff=-1.0;

% callback function for each pushbutton
% col 1:
snap_cb_1=['h=figure(''Name'',''thermal_ion_density'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'x=0:mpsi;subplot(211);plot(x,profile(:,1,1),''LineWidth'',2);axis tight;title(''full-f'');',...
    'subplot(212);plot(x,profile(:,2,1),''LineWidth'',2);axis tight;title(''del-f'');'];
set(snap_btm(1,1),'callback',snap_cb_1); % 1: thermal ion density

snap_cb_2=['h=figure(''Name'',''flow'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'x=0:mpsi;subplot(211);plot(x,profile(:,3,1),''LineWidth'',2);axis tight;title(''full-f'');',...
    'subplot(212);plot(x,profile(:,4,1),''LineWidth'',2);axis tight;title(''del-f'');'];
set(snap_btm(1,2),'callback',snap_cb_2); % 2: flow

snap_cb_3=['h=figure(''Name'',''energy'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'x=0:mpsi;subplot(211);plot(x,profile(:,5,1),''LineWidth'',2);axis tight;title(''full-f'');',...
    'subplot(212);plot(x,profile(:,6,1),''LineWidth'',2);axis tight;title(''del-f'');'];
set(snap_btm(1,3),'callback',snap_cb_3); % 3: energy

snap_cb_4=['h=figure(''Name'',''pdf_in_energy'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'x=tmax*(1:nvgrid)/(nvgrid-1);subplot(211);plot(x,pdf(:,1,1),''LineWidth'',2);axis tight;title(''full-f'');',...
    'subplot(212);plot(x,pdf(:,2,1),''LineWidth'',2);axis tight;title(''del-f'');run cal_snapshot_pdf2d.m'];
set(snap_btm(1,4),'callback',snap_cb_4); % 4: pdf in energy

snap_cb_5=['h=figure(''Name'',''pdf_in_pitch_angle'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'x=1:nvgrid;subplot(211);plot(x,pdf(:,3,1),''LineWidth'',2);axis tight;title(''full-f'');',...
    'subplot(212);plot(x,pdf(:,4,1),''LineWidth'',2);axis tight;title(''del-f'');'];
set(snap_btm(1,5),'callback',snap_cb_5); % 5: pdf in pitch angle

% col 2:
snap_cb_6=['h=figure(''Name'',''electron_density'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'x=0:mpsi;subplot(211);plot(x,profile(:,1,2),''LineWidth'',2);axis tight;title(''full-f'');',...
    'subplot(212);plot(x,profile(:,2,2),''LineWidth'',2);axis tight;title(''del-f'');'];
set(snap_btm(2,1),'callback',snap_cb_6); % 6: electron density

snap_cb_7=['h=figure(''Name'',''flow'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'x=0:mpsi;subplot(211);plot(x,profile(:,3,2),''LineWidth'',2);axis tight;title(''full-f'');',...
    'subplot(212);plot(x,profile(:,4,2),''LineWidth'',2);axis tight;title(''del-f'');'];
set(snap_btm(2,2),'callback',snap_cb_7); % 7: flow

snap_cb_8=['h=figure(''Name'',''energy'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'x=0:mpsi;subplot(211);plot(x,profile(:,5,2),''LineWidth'',2);axis tight;title(''full-f'');',...
    'subplot(212);plot(x,profile(:,6,2),''LineWidth'',2);axis tight;title(''del-f'');'];
set(snap_btm(2,3),'callback',snap_cb_8); % 8: energy

snap_cb_9=['h=figure(''Name'',''pdf_in_energy'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'x=tmax*(1:nvgrid)/(nvgrid-1);subplot(211);plot(x,pdf(:,1,2),''LineWidth'',2);axis tight;title(''full-f'');',...
    'subplot(212);plot(x,pdf(:,2,2),''LineWidth'',2);axis tight;title(''del-f'');'];
set(snap_btm(2,4),'callback',snap_cb_9); % 9: pdf in energy

snap_cb_10=['h=figure(''Name'',''pdf_in_pitch_angle'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'x=1:nvgrid;subplot(211);plot(x,pdf(:,3,2),''LineWidth'',2);axis tight;title(''full-f'');',...
    'subplot(212);plot(x,pdf(:,4,2),''LineWidth'',2);axis tight;title(''del-f'');'];
set(snap_btm(2,5),'callback',snap_cb_10); % 10: pdf in pitch angle

% col 3:
snap_cb_11=['h=figure(''Name'',''EP_density'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'x=0:mpsi;subplot(211);plot(x,profile(:,1,3),''LineWidth'',2);axis tight;title(''full-f'');',...
    'subplot(212);plot(x,profile(:,2,3),''LineWidth'',2);axis tight;title(''del-f'');'];
set(snap_btm(3,1),'callback',snap_cb_11); % 11: EP density

snap_cb_12=['h=figure(''Name'',''flow'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'x=0:mpsi;subplot(211);plot(x,profile(:,3,3),''LineWidth'',2);axis tight;title(''full-f'');',...
    'subplot(212);plot(x,profile(:,4,3),''LineWidth'',2);axis tight;title(''del-f'');'];
set(snap_btm(3,2),'callback',snap_cb_12); % 12: flow

snap_cb_13=['h=figure(''Name'',''energy'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'x=0:mpsi;subplot(211);plot(x,profile(:,5,3),''LineWidth'',2);axis tight;title(''full-f'');',...
    'subplot(212);plot(x,profile(:,6,3),''LineWidth'',2);axis tight;title(''del-f'');'];
set(snap_btm(3,3),'callback',snap_cb_13); % 13: energy

snap_cb_14=['h=figure(''Name'',''pdf_in_energy'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'x=tmax*(1:nvgrid)/(nvgrid-1);subplot(211);plot(x,pdf(:,1,3),''LineWidth'',2);axis tight;title(''full-f'');',...
    'subplot(212);plot(x,pdf(:,2,3),''LineWidth'',2);axis tight;title(''del-f'');'];
set(snap_btm(3,4),'callback',snap_cb_14); % 14: pdf in energy

snap_cb_15=['h=figure(''Name'',''pdf_in_pitch_angle'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'x=1:nvgrid;subplot(211);plot(x,pdf(:,3,3),''LineWidth'',2);axis tight;title(''full-f'');',...
    'subplot(212);plot(x,pdf(:,4,3),''LineWidth'',2);axis tight;title(''del-f'');'];
set(snap_btm(3,5),'callback',snap_cb_15); % 15: pdf in pitch angle

% col 4:
snap_cb_16=['h=figure(''Name'',''phi_on_flux_surface'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(fluxdata(:,:,1));shading(''interp'');axis tight;title(''phi on flux surface'');'];
set(snap_btm(4,1),'callback',snap_cb_16); % 16: phi on flux surface

% spectrum function in idl snapshot.pro
spectrum_eval_str=['x1=0:mmode-1;y1=x1.*0;for i=1:mtoroidal yy=f(:,i);yy=fft(yy);',...
    'y1(1)=y1(1)+(abs(yy(1)))^2; for j=2:mmode y1(j)=y1(j)+(abs(yy(j)))^2+(abs(yy(mtgrid+2-j)))^2;',...
    'end; end; y1=sqrt(y1/mtoroidal)/mtgrid;subplot(211);plot(x1,y1,''LineWidth'',2);axis tight;xlabel(''m'');title(''poloidal spectrum'');',...
    'x2=0:pmode-1;y2=x2.*0;for i=1:mtgrid yy=f(i,:);yy=fft(yy);',...
    'y2(1)=y2(1)+(abs(yy(1)))^2; for j=2:pmode y2(j)=y2(j)+(abs(yy(j)))^2+(abs(yy(mtoroidal+2-j)))^2;',...
    'end; end; y2=sqrt(y2/mtgrid)/mtoroidal;subplot(212);plot(x2,y2,''LineWidth'',2);axis tight;title(''parallel spectrum'');'];

snap_cb_17=['h=figure(''Name'',''poloidal_and_parallel_spectra'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'f=fluxdata(:,:,1);eval(spectrum_eval_str);run cal_snapshot_fft_phi.m;'];
set(snap_btm(4,2),'callback',snap_cb_17); % 17: poloidal and parallel spectra

% poloidal function in idl snapshot.pro

poloidal_eval_str=['x=poloidata(:,:,nfield+1);y=poloidata(:,:,nfield+2);',...
    'pcolor(x,y,f);axis equal;axis tight;shading(''interp'');'];

snap_cb_18=['h=figure(''Name'',''phi_on_ploidal_plane'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'f=poloidata(:,:,1);eval(poloidal_eval_str);title(''phi on ploidal plane'');figure(18);run cal_snapshot_contour.m ;title(''$\delta \phi$'',''interpreter'',''latex'',''fontsize'',20);',...
    'figure(188);run cal_snapshot_mesh.m ;title(''$\delta \phi$'',''interpreter'',''latex'',''fontsize'',20)'];
set(snap_btm(4,3),'callback',snap_cb_18); % 18: phi on ploidal plane

% cut1d in idl snapshot.pro for eval 这里y1=f(1,:)是theta=0的时候绘制delta_phi随着psi的变化
cut1d1_eval_str=['x=0:mpsi;y1=f(1,:);y2=sum(f.*f);y2=sqrt(y2/mtgrid);',...
    'subplot(211);plot(x,y1,''LineWidth'',2);axis tight;title(''point value'');',...
    'subplot(212);plot(x,y2,''LineWidth'',2);axis tight;title(''rms'');']; % icut=1, radial profile
% cut1d2_eval_str=['x=0:mtgrid;y1=f(:,mpsi/2);y2=sum(f''.*f'');',...
%         'y2=sqrt(y2/mpsi);subplot(211);plot(x,y1,''LineWidth'',2);axis tight;title(''point value'');',...
%     'subplot(212);plot(x,y2,''LineWidth'',2);axis tight;title(''rms'');']; % icut=2, poloidal profile

% 原始未设置diag_flux以及eq_flux导致使用mpsi/2---->>>>>cut1d2_eval_str
% 这里y1=f(:,diag_flux)是mpsi=diag_flux的时候绘制delta_phi随着theta的变化
cut1d2_eval_str=['x=0:mtgrid;y1=f(:,diag_flux+1);y2=sum(f''.*f'');',...
    'y2=sqrt(y2/mpsi);subplot(211);plot(x,y1,''LineWidth'',2);axis tight;title(''point value'');',...
    'subplot(212);plot(x,y2,''LineWidth'',2);axis tight;title(''rms'');']; % icut=2, poloidal profile

snap_cb_19=['h=figure(''Name'',''radius_profile_of_field_and_rms'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'f=poloidata(:,:,1);eval(cut1d1_eval_str);'];
set(snap_btm(4,4),'callback',snap_cb_19); % 19: radius profile of field and rms

snap_cb_20=['h=figure(''Name'',''poloidal_profile_of_field_and_rms'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'f=poloidata(:,:,1);eval(cut1d2_eval_str);'];
set(snap_btm(4,5),'callback',snap_cb_20); % 20: poloidal profile of field and rms

% col 5:
snap_cb_21=['h=figure(''Name'',''apara_on_flux_surface'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(fluxdata(:,:,2));shading(''interp'');axis tight;title(''a_para on flux surface'');'];
set(snap_btm(5,1),'callback',snap_cb_21); % 21: a_para on flux surface

snap_cb_22=['h=figure(''Name'',''poloidal_and_parallel_spectra'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'f=fluxdata(:,:,2);eval(spectrum_eval_str);run cal_snapshot_fft_Apara.m;'];
set(snap_btm(5,2),'callback',snap_cb_22); % 22: poloidal and parallel spectra

snap_cb_23=['h=figure(''Name'',''apara_on_ploidal_plane'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'f=poloidata(:,:,2);eval(poloidal_eval_str);title(''apara on ploidal plane'');figure(23);run cal_snapshot_contour.m;title(''$\delta A_{||}$'',''interpreter'',''latex'',''fontsize'',20);',...
    'figure(233);run cal_snapshot_mesh.m;title(''$\delta A_{||}$'',''interpreter'',''latex'',''fontsize'',20);'];
set(snap_btm(5,3),'callback',snap_cb_23); % 23: a_para on ploidal plane

snap_cb_24=['h=figure(''Name'',''radius_profile_of_field_and_rms'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'f=poloidata(:,:,2);eval(cut1d1_eval_str);'];
set(snap_btm(5,4),'callback',snap_cb_24); % 24: radius profile of field and rms

snap_cb_25=['h=figure(''Name'',''poloidal_profile_of_field_and_rms'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'f=poloidata(:,:,2);eval(cut1d2_eval_str);'];
set(snap_btm(5,5),'callback',snap_cb_25); % 25: poloidal profile of field and rms

% col 6:
snap_cb_26=['h=figure(''Name'',''fluidne_on_flux_surface'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'pcolor(fluxdata(:,:,nfield_type));shading(''interp'');axis tight;title(''fluidne on flux surface'');'];
set(snap_btm(6,1),'callback',snap_cb_26); % 26: fluidne on flux surface

snap_cb_27=['h=figure(''Name'',''poloidal_and_parallel_spectra'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'f=fluxdata(:,:,nfield_type);eval(spectrum_eval_str);run cal_snapshot_fft_fluidne.m;'];
set(snap_btm(6,2),'callback',snap_cb_27); % 27: poloidal and parallel spectra

snap_cb_28=['h=figure(''Name'',''fluidne_on_ploidal_plane'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'f=poloidata(:,:,nfield_type);eval(poloidal_eval_str);title(''fluidne on ploidal plane'');figure(28);run cal_snapshot_contour.m;title(''fluid ne on ploidal plane'');',...
    'figure(288);run cal_snapshot_mesh.m;title(''fluid ne on ploidal plane'');'];
set(snap_btm(6,3),'callback',snap_cb_28); % 28: fluidne on ploidal plane

snap_cb_29=['h=figure(''Name'',''radius_profile_of_field_and_rms'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'f=poloidata(:,:,nfield_type);eval(cut1d1_eval_str);'];
set(snap_btm(6,4),'callback',snap_cb_29); % 29: radius profile of field and rms

snap_cb_30=['h=figure(''Name'',''poloidal_profile_of_field_and_rms'',''NumberTitle'',''off'',''DefaultAxesFontSize'',14);',...
    'f=poloidata(:,:,nfield_type);eval(cut1d2_eval_str);'];
set(snap_btm(6,5),'callback',snap_cb_30); % 30: poloidal profile of field and rms

% col 7:
snap_cb_31=['disp([''old poloidal and parallel range: m, p= '',num2str(mmode),'', '',num2str(pmode)]);',...
    'disp([''maximal m= '', num2str(mtgrid/2+1),'' maximal p= '', num2str(mtoroidal/2+1)]);',...
    'mmode=input(''new m= ? ''); pmode=input(''new p= ? '');'];
set(snap_btm(7,1),'callback',snap_cb_31);  % 31: change poloidal & parallel mode #

snap_cb_32=['disp([''old cutoff= '',num2str(cutoff)]);cutoff=input([''new cutoff=? '']);'];
set(snap_btm(7,2),'callback',snap_cb_32);  % 32: cutoff in contour plot
set(snap_btm(7,2),'enable','off'); % not use in this version

% snap_cb_33=['filename=[''snap_'',get(h,''Name''),''_'',datestr(now,30),''.ps''];',...
%     'print(h,''-dpsc'',filename);'];
snap_cb_33=['filename=[path,''snap_'',get(h,''Name''),''_'',datestr(now,30),''.png''];',...
    'print(h,''-dpng'',filename);'];
set(snap_btm(7,3),'callback',snap_cb_33);  % 33: PS file

snap_cb_34='close all;clc;';
set(snap_btm(7,4),'callback',snap_cb_34);  % 34: exit

% set(snap_btm(7,3),'enable','off');  % 33: change window size

% snap_cb_35=['eval(getfile_eval_str);'];
snap_cb_35=['run snapshot;'];
set(snap_btm(7,5),'callback',snap_cb_35);  % 35: ui get snapshot file



