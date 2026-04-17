%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Yuehao Ma, USTC, myh2020@mail.ustc.edu.cn, 2024-01-01 11:02
% GTC Data Processing GUI
% V4.6 for gtc4.6 version myh 20230323 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hua-sheng XIE, IFTS-ZJU, huashengxie@gmail.com, 2014-03-27 09:12
% GTC Data Processing GUI, v1.3
% tracking.m, particle orbit, update from Yi ZHEN's version
% draft
% 2014-04-05 10:14 bugs fixed, this version only reads ions

close all; clc;
% clear all; % cannot clear all variable R0 npe 
run setpath;
%run read_para;

% if npe is not read correctly, pls modify 'read_para.m' (aroud line 14),
% or, set it here
% npe=128; % number of PE
% open data files
for i=1:npe
%     filename=[path,num2str(i-1)];
    filename=[path,'trackp_dir/TRACKP.',num2str(i-1,'%5.5d')];
    fid(i)=fopen(filename,'r');
end

% load data
% load and arange data for first istep to settle the number of particles
k=0;
for i=1:npe
    istep=fgetl(fid(i)); % get istep
    np=fgetl(fid(i)); % get np
    np=str2num(np);
    for j=1:np
        k=k+1;
        data=fgetl(fid(i));
        data1=str2num(data);
        data=fgetl(fid(i));
        data2=str2num(data);
        
        X=data1(1)*R0;
        Z=data1(2)*R0;
        zeta=data1(3);
        
        %caculate (x,y,z) 
        xion(k,1)=X*cos(zeta);
        yion(k,1)=X*sin(zeta);
        zion(k,1)=Z;
        
        tag(1,k)=data2(2);
        tag(2,k)=data2(3);
    end

end

for i=1:npe
    istep=fgetl(fid(i)); % get istep
    while istep~=-1
        istep=str2num(istep)/ndiag;
        np=fgetl(fid(i)); % get np
        np=str2num(np);
        for j=1:np
            data=fgetl(fid(i));
            data1=str2num(data);
            data=fgetl(fid(i));
            data2=str2num(data);
            
            X=data1(1)*R0;
            Z=data1(2)*R0;
            zeta=data1(3);
            
            % locate the particle
            k=1;
            while (data2(2)~=tag(1,k))||(data2(3)~=tag(2,k)) % <--
                k=k+1;
            end

            % caculate (x,y,z)
            xion(k,istep)=X*cos(zeta);
            yion(k,istep)=X*sin(zeta);
            zion(k,istep)=Z;
        end
        istep=fgetl(fid(i)); % get next istep
    end
end

%%
close all;

[ipp,itt]=size(xion);
ip=floor(ipp/5)+1;
ts=1+floor(0.2*itt); td=floor(0.9*itt);

for jp=1:9 % 3D
    subplot(3,3,jp);
    plot3(xion(jp+ip,ts:td),yion(jp+ip,ts:td),zion(jp+ip,ts:td),'LineWidth',2);
    axis equal;
end
filename=[path,'tracking_3d_',datestr(now,30),'.png'];
print(gcf,'-dpng',filename);

figure; % 2D
for jp=1:9
    subplot(3,3,jp);
    plot(sqrt(xion(jp+ip,ts:td).^2+yion(jp+ip,ts:td).^2),zion(jp+ip,ts:td),'LineWidth',2); 
    axis equal;
end
filename=[path,'tracking_2d_',datestr(now,30),'.png'];
print(gcf,'-dpng',filename);

fclose('all');

