%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Yuehao Ma, USTC, myh2020@mail.ustc.edu.cn
% GTC Data Processing GUI
% V4.6 for gtc4.6 version myh 20230323 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 绘制相空间的pdf2d图像 deltaf^2
% snapshoot.m中使用数据已经读取 但是gtc4.3之前的版本中不存在pdf2d
% particles sorted into bins in energy, and pitch
% 相空间 lambda=mu*B0/E  !so the maximum lambda=1/0.8=1.25
%% 离子 full f delta f
emax_inv=1/tmax;
% emax_inv=1/16;
lambmax_inv=0.8;
% run setpath;
% run read_para.m
figure(5)
[X_lambamax,Y_energymax] = meshgrid((1:nvgrid)/nvgrid/lambmax_inv,(1:nvgrid)/nvgrid/emax_inv);
mesh(X_lambamax,Y_energymax,pdf2d(:,:,2,1));
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
[C,h]=contourf(X_lambamax,Y_energymax,pdf2d(:,:,2,1),100);
mymap = jet;
mymap(1:2,:) =ones(2,3);
hold on;colormap(mymap)
set(h,'linecolor','none');
% set(gca,'dataaspectratio',[1,1,1]);
colorbar;
ylim([0.2 10])
set(gca,'fontsize',16,'linewidth',2);
xlabel('$\lambda$','interpreter','latex','fontsize',16)
ylabel('$E/T_{i0}$','interpreter','latex','fontsize',16)
title('$\delta f^{2}_{i}$','interpreter','latex','fontsize',16)

%% 电子 full f delta f
if( nhybrid >0)
    figure(9)
    % [Y_lambamax,X_energymax] = meshgrid((1:nvgrid)/nvgrid/lambmax_inv,(1:nvgrid)/nvgrid/emax_inv);
    mesh(X_lambamax,Y_energymax,pdf2d(:,:,2,2));
    colorbar;
    % set(h,'linecolor','none');
    set(gca,'fontsize',16,'linewidth',1.5);
    grid on
    xlabel('$\lambda$','interpreter','latex','fontsize',16)
    ylabel('$E/T_{e0}$','interpreter','latex','fontsize',16)
    title('$\delta f^{2}_{e}$','interpreter','latex','fontsize',16)
    %%二维contour图
    figure(99)
    [C,h]=contourf(X_lambamax,Y_energymax,pdf2d(:,:,2,2),100);
    % hold on;colormap('jet');
%     mymap = jet;mymap(1:4,:) =ones(4,3);
    hold on;colormap(mymap);
    set(h,'linecolor','none');
    % set(gca,'dataaspectratio',[1,1,1]);
    colorbar;
    set(gca,'fontsize',16,'linewidth',2);
    xlabel('$\lambda$','interpreter','latex','fontsize',16)
    ylabel('$E/T_{i0}$','interpreter','latex','fontsize',16)
    title('$\delta f^{2}_{e}$','interpreter','latex','fontsize',16)
end
%% 快离子 full f delta f
if( (nhybrid==0 && nspecies==2) ||  nspecies>=3)
    nspecies_fion = sign(nspecies-2)+2;
    figure(13)
    mesh(X_lambamax,Y_energymax,pdf2d(:,:,2,nspecies_fion));
    colorbar;
    % set(h,'linecolor','none');
    set(gca,'fontsize',16,'linewidth',1.5);
    grid on
    xlabel('$\lambda$','interpreter','latex','fontsize',16)
    ylabel('$E/T_{f0}$','interpreter','latex','fontsize',16)
    title('$\delta f^{2}_{fi}$','interpreter','latex','fontsize',16)
    %%二维contour图
    figure(133)
    [C,h]=contourf(X_lambamax,Y_energymax,pdf2d(:,:,2,nspecies_fion),100);
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
