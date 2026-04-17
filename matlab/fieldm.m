% Hua-sheng XIE, IFTS-ZJU, huashengxie@gmail.com, 2014-03-27 19:52
% GTC snapshot to movie, v1.3, 2014-04-05 10:14 update
% fieldm.m, cal 1D Fourier modes

close all; clear all; clc;

addrfline=1; % add a circle for r=riflux

run setpath;
run read_para;
getfile_eval_str=['[filename,pathname]=uigetfile([path,''*.out''],''Select the snapshot file'');',...
    'path1=[pathname,filename];snap_data=load(path1);'];
eval(getfile_eval_str);

nspecies=snap_data(1);
nfield=snap_data(2);
nvgrid=snap_data(3);
mpsi=snap_data(4)-1; % snap_data(4)=mpsi+1
mtgrid=snap_data(5)-1; % snap_data(5)=mtgrid+1
mtoroidal=snap_data(6);
tmax=snap_data(7); % snap_data(7)=1.0/emax_inv

% read profile, pdf, poloidata, fluxdata data1d from snapshot file
ind1=7;
ind2=7+(mpsi+1)*nspecies*6;
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
end

ind3=7+(mpsi+1)*6*nspecies+nvgrid*4*nspecies;
ind4=7+(mpsi+1)*6*nspecies+nvgrid*4*nspecies+(mtgrid+1)*(mpsi+1)*(nfield+2);
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

mmode=round(mtgrid/5);
pmode=round(mtoroidal/5);
cutoff=-1.0;

%% ================================== phi_m ==========================================

r_data=load([path,'gtc_rg.out']);
rg=r_data(:,2);
rr=rg/a_minor;

h=figure('Name','profile_of_field_m','NumberTitle','off','DefaultAxesFontSize',14);
   
xx=poloidata(:,:,nfield+1);
yy=poloidata(:,:,nfield+2);
for ifld=1:3
    f=poloidata(:,:,ifld);
    
    subplot(2,3,ifld);        
    pcolor(xx,yy,f); axis equal; axis tight; shading('interp');
    
    if((addrfline==1)&&exist('iflux','var'))
%         thetmp=0:pi/20:2*pi;
%         xtmp=1+rgiflux*cos(thetmp); % need modified to non-circle
%         ytmp=rgiflux*sin(thetmp);  % using X(:,iflux),Z(:,iflux)
        xtmp=xx(:,iflux); ytmp=yy(:,iflux);
        hold on;
        plot(xtmp,ytmp,'r--','Linewidth',2);
    end
    
    title(['filed=',num2str(ifld)]);

    subplot(2,3,3+ifld);
    
    phim=[];
    for ipsi=1:(mpsi+1)
        x=(0:mtgrid).*2*pi/mtgrid;
        y=f(:,ipsi);

    %     subplot(211);plot(x,y,'LineWidth',2);
    %     axis tight;
    %     title('point value');

        Lx=length(x); % number of sampling
        dfs=2*pi/(x(end)-x(1));
        fs=0:dfs:dfs*(Lx-1);

        dy_ft=fft(real(y))/Lx*2; % *2 ?? need check
        ifs=1:floor(mtgrid/2);

    %     phim(ifs,ipsi)=imag(dy_ft(ifs));
        phim(ifs,ipsi)=abs(dy_ft(ifs));

    %     subplot(212);
    %     plot(fs(ifs),imag(dy_ft(ifs)),'LineWidth',2);
    %     axis tight;

    end

    %
    % r=1:(mpsi+1);
    % plot(r,phim(7,:),r,phim(8,:),r,phim(9,:),r,phim(10,:),'LineWidth',2); 

    ir=2:mpsi;
    for im=ifs
       plot(rr,phim(im,ir),'b','LineWidth',2); hold on;
    end

    % plot(rr,phim(7,ir),rr,phim(8,ir),rr,phim(9,ir),rr,phim(10,ir),'LineWidth',2); 
    % 
    % axis tight;
    % legend('m=6','m=7','m=8','m=9'); legend('boxoff'); % m=ind-1

    
end
%%
filename=[path1,'snap_',get(h,'Name'),'_',datestr(now,30),'.png'];
print(h,'-dpng',filename);
    
    