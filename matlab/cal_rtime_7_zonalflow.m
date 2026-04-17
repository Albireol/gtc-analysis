%% zonal flow
% 三维mesh图
run setpath;
run read_para.m
figure(7)
dt=dt0*ndiag;  
t=(nstart:nend)*dt;
% profile_gtcout1(m0:m1,2)
[Y_rtime,X_rtime] = meshgrid(profile_gtcout1(m0:m1,2),t);
mesh(X_rtime,Y_rtime,field00(nstart:nend,m0:m1,1));
colorbar;
% set(h,'linecolor','none');
set(gca,'fontsize',16,'linewidth',1.5);
grid on
xlabel('$t[R_0/C_s]$','interpreter','latex','fontsize',16)
ylabel('$r/a$','interpreter','latex','fontsize',16)
title('$zonal\,flow$','interpreter','latex','fontsize',16)
%% 二维contour图
figure(77)
[C,h]=contourf(X_rtime,Y_rtime,field00(nstart:nend,m0:m1,1),100);
hold on;colormap('jet')
set(h,'linecolor','none');
% set(gca,'dataaspectratio',[1,1,1]);
colorbar;
set(gca,'fontsize',16,'linewidth',2);
xlabel('$t[R_0/C_s]$','interpreter','latex','fontsize',16)
ylabel('$r/a$','interpreter','latex','fontsize',16)
title('$zonal\,flow$','interpreter','latex','fontsize',16)
% hold on
% plot(x(:,diag_flux),y(:,diag_flux),'--k','linewidth',1);
% hold on
% plot(x(:,q_min_flux),y(:,q_min_flux),'-.k','linewidth',1);
% plot(x(:,diag_flux),y(:,diag_flux),'--k','linewidth',1);
% title('$\phi$','interpreter','latex','fontsize',20)
% title('$\delta A_{||}$','interpreter','latex','fontsize',20)
%% 一维径向zonal 结构
%%00分量
%%%nfield00 1 phip00(i)/(rho0),
nfield_type   = 1;
title_toal    = {'$\delta \phi_{00}p$ '};
title_label   = title_toal{nfield_type};
%title_label   = '$\delta n_{e00}/n_{e0}$ ';
num_images = 5;
ntemp0     = floor(linspace(0.50,1.00,num_images)*nend);
for i = 1:num_images
    ntemp1 = ntemp0(i);
    figure(900+i)
    plot(profile_gtcout1(m0:m1,2),field00(ntemp1,m0:m1,nfield_type),'Linewidth',2)
    grid on
    xlabel('$r/a$','interpreter','latex','fontsize',16)
%     ylabel([title_label,'$[m^2/s]$'],'interpreter','latex','fontsize',16)
    ylabel(title_label,'interpreter','latex','fontsize',16)
    title(['$t=\;$', num2str(t(ntemp1)), '$R_0/C_s$'], 'interpreter', 'latex', 'fontsize', 16)
    % % title([title_label, '$, \,t=$', num2str(t(ntemp1)), '$R_0/C_s$'], 'interpreter', 'latex', 'fontsize', 16)
end
%% 一维随时间变化
figure(1000)
% profile_gtcout1(m0:m1,2)
mtemp2 = 40;
plot(t,field00(nstart:nend,mtemp2,nfield_type),'Linewidth',2)
grid on
xlabel('$t[R_0/C_s]$','interpreter','latex','fontsize',16)
ylabel(title_label,'interpreter','latex','fontsize',16)
title(['$r/a=\;$', num2str(profile_gtcout1(mtemp2,2))], 'interpreter', 'latex', 'fontsize', 16)

%% 一维随时间变化,径向平均
figure(2000)
%sqrt(sum(data1di(nstart:nend,:,nspecies_chi))/(mpsi))
plot(t,sqrt(sum(field00(nstart:nend,:,nfield_type).^2,2)/(mpsi)),'Linewidth',2)
grid on
xlabel('$t[R_0/C_s]$','interpreter','latex','fontsize',16)
ylabel(title_label,'interpreter','latex','fontsize',16)
% % title([title_label, '$, \,t=$', num2str(t(ntemp1)), '$R_0/C_s$'], 'interpreter', 'latex', 'fontsize', 16)



