%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Yuehao Ma, USTC, myh2020@mail.ustc.edu.cn
% GTC Data Processing GUI
% V4.6 for gtc4.6 version myh 20230323 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;clear; clc;
% load equilibruim file data
run setpath;
run read_para.m
%% 绘制相空间的pdf3d图像 deltaf
% brochard, pdf3d_mu 诊断gtc
% snapshoot.m中使用数据已经读取 但是gtc4.3之前的版本中不存在pdf2d
% particles sorted into bins in energy, and pitch
% 相空间 lambda=mu*B0/E  !so the maximum lambda=1/0.8=1.25
[filename,pathname]=uigetfile([path,'snap*.out'],'Select the myhsnapshot file');
path=[pathname,filename];
fid = fopen(path,'r');
if fid < 0 % error opening the file
    error('Could not open the snapshot file ');
end

%% scalar parameters
nspecies  = fscanf(fid, '%f',1);
nfield    = fscanf(fid, '%f',1);
nvgrid    = fscanf(fid, '%f',1);
mpsi      = fscanf(fid, '%f',1)-1; % snap_data(4)=mpsi+1
mtgrid    = fscanf(fid, '%f',1)-1; % snap_data(5)=mtgrid+1
mtoroidal = fscanf(fid, '%f',1);
tmax      = fscanf(fid, '%f',1);   % snap_data(7)=1.0/emax_inv
%% set parameters
emax_inv    = 1/tmax;
lambmax_inv = 0.8;
if length(Pphi_min)>2
    Pphi_min_ions = Pphi_min(2);       %Minimal Pphi to set for ions
    Pphi_max_ions = Pphi_max(2);       %Maximal Pphi to set for ions
    Pphi_min_fast = Pphi_min(2);       %Minimal Pphi to set for EP
    Pphi_max_fast = Pphi_max(2);       %Maximal Pphi to set for EP

    mu_max_ions   = mu_max(2);
    mu_min_ions   = mu_min(2);
    mu_max_fast   = mu_max(2);
    mu_min_fast   = mu_min(2);
else
    Pphi_min_ions = Pphi_min;       %Minimal Pphi to set for ions
    Pphi_max_ions = Pphi_max;       %Maximal Pphi to set for ions
    Pphi_min_fast = Pphi_min;       %Minimal Pphi to set for EP
    Pphi_max_fast = Pphi_max;       %Maximal Pphi to set for EP

    mu_max_ions   = mu_max;
    mu_min_ions   = mu_min;
    mu_max_fast   = mu_max;
    mu_min_fast   = mu_min;

end




%% read in grid data
% read profile, pdf, poloidata, fluxdata pdf2d from snapshot file
profile     = zeros(mpsi+1,6,nspecies);
pdf         = zeros(nvgrid,4,nspecies);
reac        = zeros(mpsi+1,2,nspecies);
poloidata   = zeros(mtgrid+1,mpsi+1,nfield+2);
fluxdata    = zeros(mtgrid+1,mtoroidal,nfield);
pdf2d       = zeros(nvgrid,nvgrid,2,nspecies);
pdf2d_fullf = zeros(nvgrid,nvgrid,nspecies);
pdf2d_df    = zeros(nvgrid,nvgrid,nspecies);

pdf3d       = zeros(nvgrid,2*nvgrid,nvgrid,3,nspecies);
pdf3d_fullf = zeros(nvgrid,2*nvgrid,nvgrid,nspecies);
pdf3d_df    = zeros(nvgrid,2*nvgrid,nvgrid,nspecies);
pdf3d_pitch = zeros(nvgrid,2*nvgrid,nvgrid,nspecies);


for i = 1:nspecies
    profile(:,:,i) = fscanf(fid, '%f', [mpsi+1 6]);
end

for i = 1:nspecies
    pdf(:,:,i) = fscanf(fid, '%f', [nvgrid 4]);
end

for i = 1:nfield+2 %extra +1 to read apara field
    poloidata(:,:,i) = fscanf(fid, '%f', [mtgrid+1 mpsi+1]);
end

for i = 1:nfield
    fluxdata(:,:,i) = fscanf(fid, '%f', [mtgrid+1 mtoroidal]);
end

for i = 1:nspecies % 2D (E,lambda) diagram
    pdf2d_fullf(:,:,i) = fscanf(fid, '%f', [nvgrid nvgrid]);
    pdf2d_df(:,:,i)    = fscanf(fid, '%f', [nvgrid nvgrid]);
end

for i = 1:nspecies % 3D (mu,lambda, Pphi) diagram
    for j=1:nvgrid
        pdf3d_fullf(:,:,j,i) = fscanf(fid, '%f', [nvgrid 2*nvgrid]);
    end
    for j=1:nvgrid
        pdf3d_df(:,:,j,i)    = fscanf(fid, '%f', [nvgrid 2*nvgrid]);
    end
    for j=1:nvgrid % Use to dissociate trapped from passing particles
        pdf3d_pitch(:,:,j,i) = fscanf(fid, '%f', [nvgrid 2*nvgrid]);
    end
end

for i = 1:nspecies % Thermonuclear fusion reactivity
    reac(:,:,i) = fscanf(fid, '%f', [mpsi+1 2]);
end

pdf2d(:,:,1,:) = pdf2d_fullf;
pdf2d(:,:,2,:) = pdf2d_df;

pdf3d(:,:,:,1,:) = pdf3d_fullf;
pdf3d(:,:,:,2,:) = pdf3d_df;
pdf3d(:,:,:,3,:) = pdf3d_pitch;

% close read snapshot file.
fclose(fid);
%%

lambdabin      = (1:nvgrid)./nvgrid/lambmax_inv;
lambdabin_3d   = (1:nvgrid*2)/(2*nvgrid)/lambmax_inv;
energybin      = (1:nvgrid)/nvgrid/emax_inv;
Pphi_grid_ions = -(Pphi_min_ions+(1:nvgrid)/nvgrid*(Pphi_max_ions-Pphi_min_ions))/psiw;
Pphi_grid_fast = -(Pphi_min_fast+(1:nvgrid)/nvgrid*(Pphi_max_fast-Pphi_min_fast))/psiw;

mubin_ions          = (1:nvgrid)/nvgrid*mu_max_ions;
mubin_ions          = mubin_ions.*(qe^2*(B0/1e4)*(R0/1e2).^2/m_p).*((B0/1e4)./(ti_axis*qe));

mubin_fast          = (1:nvgrid)/nvgrid*mu_max_fast;
mubin_fast          = mubin_fast.*(qe^2*(B0/1e4)*(R0/1e2).^2/m_p).*((B0/1e4)./(tfi_axis*qe));


%% plot the pdf3d
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%find the maximum energy slice and lambda using the pdf2d
pdf2d_df_max(:,:) = pdf2d_df(:,:,2);
[lambda0_EP,energy_EP]=find(pdf2d_df_max==max(max(pdf2d_df_max)));
mu_EP00 = lambdabin(lambda0_EP)*energybin(energy_EP);
mu_EP0       = find( abs(mubin_fast-mu_EP00)<=0.1 );
lambda_EP0   = find( abs(lambdabin_3d-lambdabin(lambda0_EP))<=1e-5 );


% %%%find the maximum muB0 slice
pdf3d_df_EP_maxmu0 = zeros(length(mubin_fast),1);
for i = 1:length(mubin_fast)
    EP_temp(:,:) = pdf3d_df(i,:,1:end-2,2).^2;
    pdf3d_df_EP_maxmu0(i)   = max(EP_temp(:));
end
[pdf3d_df_EP_maxmu,mu_EP_max]= max(pdf3d_df_EP_maxmu0);
mu_EP1 = mu_EP_max;

%%%find the maximum lambda slice
pdf3d_df_EP_maxlambda0 = zeros(length(lambdabin_3d),1);
for i = 1:length(lambdabin_3d)
    EP_temp1(:,:) = pdf3d_df(:,i,1:end-2,2).^2;
    pdf3d_df_EP_maxlambda0(i)   = max(EP_temp1(:));
end
[pdf3d_df_EP_maxlambda,lambda_EP_max]= max(pdf3d_df_EP_maxlambda0);
lambda_EP1 = lambda_EP_max;

mu_GKi       = 7;                               %GKi mu index to set
lambda_GKi   = 100;                             %GKi lambda index to set
mu_EP        = 29;                              %EP  mu index to set
lambda_EP    = 105;                             %EP  lambda index to set
%%
ii=1;
div1_GKi      = [];
div2_GKi      = [];
div1_EP       = [];
div2_EP       = [];
for jj=1:nvgrid-1 % GKi trapped/passing line
    for kk=1:2*nvgrid-1
        if(pdf3d_pitch(mu_GKi,kk,jj,1)*pdf3d_pitch(mu_GKi,kk+1,jj,1)<0)
            div1_GKi(ii,1)=Pphi_grid_ions(jj);
            div1_GKi(ii,2)=lambdabin_3d(kk) + pdf3d_pitch(mu_GKi,kk,jj,1)/...
                (pdf3d_pitch(mu_GKi,kk,jj,1)-pdf3d_pitch(mu_GKi,kk+1,jj,1))*...
                (lambdabin_3d(kk+1)-lambdabin_3d(kk));
            div1_GKi(ii,3)=1e1;
            ii=ii+1;
        end
    end
end
ii=1;
for kk=1:2*nvgrid-1 % GKi pdf envelope
    for jj=1:nvgrid-1
        if(abs(pdf3d_pitch(mu_GKi,kk,jj,1))<1e-10 && abs(pdf3d_pitch(mu_GKi,kk,jj+1,1))>1e-10)
            div2_GKi(ii,1)=Pphi_grid_ions(jj);
            div2_GKi(ii,2)=lambdabin_3d(kk);
            div2_GKi(ii,3)=1e1;
            ii=ii+1;
        end
    end
end
ff=1;
for m=1:nvgrid-1 % EP trapped/passing line
    for k=1:2*nvgrid-1
        if(pdf3d_pitch(mu_EP,k,m,2)*pdf3d_pitch(mu_EP,k+1,m,2)<0)
            div1_EP(ff,1)=Pphi_grid_fast(m);
            div1_EP(ff,2)=lambdabin_3d(k) + pdf3d_pitch(mu_EP,k,m,2)/(pdf3d_pitch(mu_EP,k,m,2)-pdf3d_pitch(mu_EP,k+1,m,2))...
                *(lambdabin_3d(k+1)-lambdabin_3d(k));
            div1_EP(ff,3)=1e4;
            ff=ff+1;
        end
    end
end
ff=1;
for k=1:2*nvgrid-1 % EP pdf envelope
    for m=1:nvgrid-1
        if(abs(pdf3d_pitch(mu_EP,k,m,2))<1e-10 && abs(pdf3d_pitch(mu_EP,k,m+1,2))>1e-10)
            div2_EP(ff,1)=Pphi_grid_fast(m);
            div2_EP(ff,2)=lambdabin_3d(k);
            div2_EP(ff,3)=1e4;
            ff=ff+1;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Energy-------------lambda  pdf2d
%% 离子 full f delta f
figure(5)
[X_lambamax,Y_energymax] = meshgrid(lambdabin,energybin);
mesh(X_lambamax,Y_energymax,pdf2d(:,:,2,1)');
colorbar;
% set(h,'linecolor','none');
set(gca,'fontsize',16,'linewidth',1.5);
ylim([0 10])
grid on
xlabel('$\lambda$','interpreter','latex','fontsize',16)
ylabel('$E/T_{i0}$','interpreter','latex','fontsize',16)
title('$\delta f^{2}_{i}$','interpreter','latex','fontsize',16)
%% 二维contour图
figure(55)
[C55,h]=contourf(X_lambamax,Y_energymax,pdf2d(:,:,2,1)',100);
mymap = jet;
mymap(1,:) =ones(1,3);
hold on;colormap(mymap)
set(h,'linecolor','none');
% set(gca,'dataaspectratio',[1,1,1]);
colorbar;
ylim([0.2 10])
set(gca,'fontsize',16,'linewidth',2);
xlabel('$\lambda$','interpreter','latex','fontsize',16)
ylabel('$E/T_{i0}$','interpreter','latex','fontsize',16)
title('$\delta f^{2}_{i}$','interpreter','latex','fontsize',16)

%% 快离子 full f delta f
if( (nhybrid==0 && nspecies==2) ||  nspecies>=3)
    nspecies_fion = sign(nspecies-2)+2;
    figure(56)
    mesh(X_lambamax,Y_energymax,pdf2d(:,:,2,nspecies_fion)');
    colorbar;
    % set(h,'linecolor','none');
    set(gca,'fontsize',16,'linewidth',1.5);
    grid on
    xlabel('$\lambda$','interpreter','latex','fontsize',16)
    ylabel('$E/T_{f0}$','interpreter','latex','fontsize',16)
    title('$\delta f^{2}_{fi}$','interpreter','latex','fontsize',16)
    %%二维contour图
    figure(57)
    [C,h]=contourf(X_lambamax,Y_energymax,pdf2d(:,:,2,nspecies_fion)',100);
    hold on;colormap(mymap)
    set(h,'linecolor','none');
    % set(gca,'dataaspectratio',[1,1,1]);
    colorbar;
    set(gca,'fontsize',16,'linewidth',2);
    ylim([0.2 10])
    xlabel('$\lambda$','interpreter','latex','fontsize',16)
    ylabel('$E/T_{fi0}$','interpreter','latex','fontsize',16)
    title('$\delta f^{2}_{fi}$','interpreter','latex','fontsize',16)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pdf3d_df_ions_mu(:,:)    = pdf3d_df(mu_GKi,:,:,1).^2;               %nspecies_ions = 1; % ions
pdf3d_df_fast_mu(:,:)    = pdf3d_df(mu_EP,:,:,2).^2;                % fast ions
pdf3d_pitch_fast1(:,:)   = abs(pdf3d_pitch(mu_EP,:,:,2));           % fast ions indetify the critical lines of EP's distribution
pdf3d_df_ions_lambda(:,:)  = pdf3d_df(:,lambda_GKi,:,1).^2;         %nspecies_ions = 1; % ions
pdf3d_df_fast_lambda(:,:)  = pdf3d_df(:,lambda_EP,:,2).^2;          % fast ions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% p_zeta------------lambda  pdf3d
%% 三维 mesh图
[X_Pphi1,Y_lambdabin1] = meshgrid(Pphi_grid_ions(1:end-2),lambdabin_3d);
figure(6)
mesh(X_Pphi1,Y_lambdabin1,pdf3d_df_ions_mu(:,1:end-2))
colormap jet
colorbar
shading interp
xlabel('$P_{\zeta}/\psi_{wall}$','interpreter','latex','fontsize',16)
ylabel('$\lambda=\mu B_0/E$','interpreter','latex','fontsize',16)
set(gca,'FontSize',30)
% clim([-max(max(abs(A(1:end-5,1:end-5)))) max(max(abs(A(1:end-5,1:end-5))))])
title(['$\mu B_0=$',num2str(mubin_ions(mu_GKi)),'$T_{i0} \; \delta f^{2}_{i}$'],'interpreter','latex','fontsize',16)



%% 二维contour图
figure(66)
[C66,h]=contourf(X_Pphi1,Y_lambdabin1,pdf3d_df_ions_mu(:,1:end-2),100);
mymap = jet;
mymap(1:3,:) =ones(3,3);
hold on;colormap(mymap)
set(h,'linecolor','none');
% set(gca,'dataaspectratio',[1,1,1]);
colorbar;
% ylim([0.2 10])
set(gca,'fontsize',16,'linewidth',2);
xlabel('$P_{\zeta}/\psi_{wall}$','interpreter','latex','fontsize',16)
ylabel('$\lambda=\mu B_0/E$','interpreter','latex','fontsize',16)
title(['$\mu B_0=$',num2str(mubin_ions(mu_GKi)),'$T_{i0} \; \delta f^{2}_{i}$'],'interpreter','latex','fontsize',16)
% hold on
% plot(div1_GKi(:,1),div1_GKi(:,2),'.','LineWidth',2,'Color',[0 0 0]);
% plot(div2_GKi(:,1),div2_GKi(:,2),'.','LineWidth',2,'Color',[1 0 0]);
%% EP paraticle
[X_Pphi2,Y_lambdabin2] = meshgrid(Pphi_grid_fast(1:end-2),lambdabin_3d);
figure(67)
mesh(X_Pphi2,Y_lambdabin2,pdf3d_df_fast_mu(:,1:end-2))
colormap jet
colorbar
shading interp
set(gca,'fontsize',16,'linewidth',2);
xlabel('$P_{\zeta}/\psi_{wall}$','interpreter','latex','fontsize',16)
ylabel('$\lambda=\mu B_0/E$','interpreter','latex','fontsize',16)
% clim([-max(max(abs(A(1:end-5,1:end-5)))) max(max(abs(A(1:end-5,1:end-5))))])
title(['$\mu B_0=$',num2str(mubin_fast(mu_EP)),'$T_{fi0} \; \delta f^{2}_{fi}$'],'interpreter','latex','fontsize',16)

%% 二维contour图
figure(68)
[C68,h]=contourf(X_Pphi2,Y_lambdabin2,pdf3d_df_fast_mu(:,1:end-2),100);
hold on;colormap(mymap)
set(h,'linecolor','none');
% set(gca,'dataaspectratio',[1,1,1]);
colorbar;
%caxis([0 0.5*max(max(abs(pdf3d_df_fast1(1:end-5,1:end-5))))])
%ylim([0.4 1.20])
set(gca,'fontsize',16,'linewidth',2);
xlabel('$P_{\zeta}/\psi_{wall}$','interpreter','latex','fontsize',16)
ylabel('$\lambda=\mu B_0/E$','interpreter','latex','fontsize',16)
title(['$\mu B_0=$',num2str(mubin_fast(mu_EP)),'$T_{fi0} \; \delta f^{2}_{fi}$'],'interpreter','latex','fontsize',16)
hold on
plot(div1_EP(:,1),div1_EP(:,2),'--m','LineWidth',3);
% plot(div2_EP(:,1),div2_EP(:,2),'.','MarkerSize',4);
C100      = contourc(Pphi_grid_fast,lambdabin_3d,pdf3d_pitch_fast1,[1e-10 1e-10]);
xy_index0 = intersect(find(C100(1, 1:end)<=max(Pphi_grid_fast)), find(C100(2, 1:end)<=max(lambdabin_3d)));
C100      = round( C100(:,xy_index0),5);
C101      = C100(:,find( C100(2,:)>=0.5 ));
[C101x, C101ia, C101ic] = unique(C101(1,:));
C101y      = C101(2,C101ia);
plot(C101x,C101y,'.r','linewidth',2,'MarkerSize',10)
hold on
C102      = C100(:,find( C100(2,:)<= 0.5 ));
[C102x, C102ia, C102ic] = unique(C102(1,:));
C102y      = C102(2,C102ia);
plot(C102x,C102y,'.r','linewidth',2,'MarkerSize',10)
hold off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% energy------------p_zeta
%% 三维 mesh图

[X_mubin1,Y_Pphi1] = meshgrid(mubin_ions,Pphi_grid_ions(1:end-2));
figure(7)
mesh(X_mubin1,Y_Pphi1,pdf3d_df_ions_lambda(:,1:end-2)')
colormap jet
colorbar
shading interp
xlabel('$\mu B_0/T_{i0}$','interpreter','latex','fontsize',16)
ylabel('$P_{\zeta}/\psi_{wall}$','interpreter','latex','fontsize',16)
set(gca,'FontSize',30)
% clim([-max(max(abs(A(1:end-5,1:end-5)))) max(max(abs(A(1:end-5,1:end-5))))])
title(['$\lambda=$',num2str(lambdabin_3d(lambda_GKi)),'$ \; \delta f^{2}_{i}$'],'interpreter','latex','fontsize',16)



%% 二维contour图
figure(77)
[C77,h]=contourf(X_mubin1,Y_Pphi1,pdf3d_df_ions_lambda(:,1:end-2)',100);
mymap = jet;
mymap(1,:) =ones(1,3);
hold on;colormap(mymap)
set(h,'linecolor','none');
% set(gca,'dataaspectratio',[1,1,1]);
colorbar;
% ylim([0.2 10])
set(gca,'fontsize',16,'linewidth',2);
xlabel('$\mu B_0/T_{i0}$','interpreter','latex','fontsize',16)
ylabel('$P_{\zeta}/\psi_{wall}$','interpreter','latex','fontsize',16)
title(['$\lambda=$',num2str(lambdabin_3d(lambda_GKi)),'$ \; \delta f^{2}_{i}$'],'interpreter','latex','fontsize',16)
% hold on
% plot(div1_GKi(:,1),div1_GKi(:,2),'.','LineWidth',2,'Color',[0 0 0]);
% plot(div2_GKi(:,1),div2_GKi(:,2),'.','LineWidth',2,'Color',[1 0 0]);
%% EP paraticle
[X_mubin2,Y_Pphi2] = meshgrid(mubin_fast,Pphi_grid_fast(1:end-2));

figure(78)
mesh(X_mubin2,Y_Pphi2,pdf3d_df_fast_lambda(:,1:end-2)')
colormap jet
colorbar
shading interp
set(gca,'fontsize',16,'linewidth',2);
xlabel('$\mu B_0/T_{fi0}$','interpreter','latex','fontsize',16)
ylabel('$P_{\zeta}/\psi_{wall}$','interpreter','latex','fontsize',16)
% clim([-max(max(abs(A(1:end-5,1:end-5)))) max(max(abs(A(1:end-5,1:end-5))))])
title(['$\lambda=$',num2str(lambdabin_3d(lambda_EP)),'$ \; \delta f^{2}_{fi}$'],'interpreter','latex','fontsize',16)

%% 二维contour图
figure(79)
[C79,h]=contourf(X_mubin2,Y_Pphi2,pdf3d_df_fast_lambda(:,1:end-2)',100);
hold on;colormap(mymap)
set(h,'linecolor','none');
%caxis([-max(max(abs(pdf3d_df_fast2(1:end-5,1:end-5)))) max(max(abs(pdf3d_df_fast2(1:end-5,1:end-5))))])
% set(gca,'dataaspectratio',[1,1,1]);
colorbar;
% ylim([0.2 10])
set(gca,'fontsize',16,'linewidth',2);
xlabel('$\mu B_0/T_{fi0}$','interpreter','latex','fontsize',16)
ylabel('$P_{\zeta}/\psi_{wall}$','interpreter','latex','fontsize',16)
title(['$\lambda=$',num2str(lambdabin_3d(lambda_EP)),'$ \; \delta f^{2}_{fi}$'],'interpreter','latex','fontsize',16)

% hold on
% plot(div1_EP(:,1),div1_EP(:,2),'.','LineWidth',2,'Color',[0 0 0]);
% plot(div2_EP(:,1),div2_EP(:,2),'.','LineWidth',2,'Color',[1 0 0]);
