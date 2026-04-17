% cal_history_fieldtime.m
clc,clear;close all
run history.m
%% phi
figure(11)
subplot(211)
yyaxis left
plot(t,fieldtime(:,4,1),'-','Linewidth',2); 
ylabel('$e\delta\phi/T_e$','Interpreter','latex','fontsize',16);
yyaxis right
plot(t,fieldtime(:,3,1),'-','Linewidth',2); 
xlabel('$t[R_0/C_s]$','Interpreter','latex','fontsize',16);
ylabel('$e\phi^{\prime}_{00}/T_e$','Interpreter','latex','fontsize',16);
title('$\delta\phi_{rms} \; and \,zonal\,flow$','Interpreter','latex','fontsize',16);
grid on
% ylabel('$(a.u.)$','Interpreter','latex','fontsize',16);
legend('$\delta\phi_{rms}$',...
       '$(\phi_{Zonal}^{\prime})_{rms}$',...    
       'Interpreter','latex','fontsize',16);
title('$\delta \phi_{rms}\;and\;zonal\,flow$','Interpreter','latex','fontsize',16);
grid on
subplot(212)
yyaxis left
semilogy(t,fieldtime(:,4,1),'-','Linewidth',2); 
ylabel('$e\delta\phi/T_e$','Interpreter','latex','fontsize',16);
yyaxis right
semilogy(t,fieldtime(:,3,1),'-','Linewidth',2); 
xlabel('$t[R_0/C_s]$','Interpreter','latex','fontsize',16);
ylabel('$e\phi^{\prime}_{00}/T_e$','Interpreter','latex','fontsize',16);
% ylabel('$$\sqrt{\frac{\int d\theta dr\delta{\phi}^2(r,\theta,\zeta=0)}{\int d\theta dr}}$$','Interpreter','latex','fontsize',16);
legend('$\delta\phi_{rms}$',...
       '$(\phi_{Zonal}^{\prime})_{rms}$',...    
       'Interpreter','latex','fontsize',16);
grid on
figure(12)
subplot(211)
plot(t,fieldtime(:,4,1),'-','Linewidth',2); 
xlabel('$t[R_0/C_s]$','Interpreter','latex','fontsize',16);
ylabel('$e\delta\phi/T_e$','Interpreter','latex','fontsize',16);title('$\delta\phi_{rms} \; and \,zonal\,flow$','Interpreter','latex','fontsize',16);
grid on
% ylabel('$(a.u.)$','Interpreter','latex','fontsize',16);
title('$\delta \phi_{rms}$','Interpreter','latex','fontsize',16);
grid on
subplot(212)
semilogy(t,fieldtime(:,4,1),'-','Linewidth',2); 
ylabel('$e\delta\phi/T_e$','Interpreter','latex','fontsize',16);
xlabel('$t[R_0/C_s]$','Interpreter','latex','fontsize',16);
ylabel('$e\delta\phi/T_e$','Interpreter','latex','fontsize',16);title('$\delta\phi_{rms} \; and \,zonal\,flow$','Interpreter','latex','fontsize',16);
grid on
% ylabel('$(a.u.)$','Interpreter','latex','fontsize',16);
title('$\delta \phi_{rms}$','Interpreter','latex','fontsize',16);
grid on
%% 计算gamma增长率
% cal_gamma, unit=R_0/c_s, used by history.m 
% plot at panel subplot(222) for mode 1-8
% 其中要选择合适的时间范围来计算gamma
% ndiag=1; dt0=0.005;
ya_fieldtime = fieldtime(:,3,1);
dt=dt0*ndiag;  
% dt=dt0;  
nt=length(ya_fieldtime);
% yy=log10(ya);
yy_fieldtime=log(ya_fieldtime);
t=dt:dt:nt*dt;
%计算线性增长部分设置两个测量参数 与频率采用区间统一
% modify here to set time step range
cut0 = 0.60;
cut1 = 1.00;
ind0=floor(cut0*nt); ind2=floor(cut1*nt);
N  = length(t(ind0:ind2));
if mod(N,2)==0
    ind1 = ind0;
else
    ind1 = ind0+1;
end

gamma_poly = polyfit(t(ind1:ind2),yy_fieldtime(ind1:ind2),1);
yy_poly = polyval(gamma_poly,t(ind1:ind2));
% gamma = (yy(ind2)-yy(ind1))/(t(ind2)-t(ind1));
gamma = gamma_poly(1);
gamma_mode = gamma_poly(1)
figure(13)
plot(t,yy_fieldtime,t(ind1:ind2),yy_poly,'r--','Linewidth',2); 
hold on
plot([t(ind1),t(ind2)],[yy_poly(1),yy_poly(end)],'r*','Linewidth',2); 
xlim([0,max(t)]);
% xlabel('t'); ylabel('log(|\phi|)');
xlabel('$t[R_0/C_s]$','Interpreter','latex','fontsize',16);
ylabel('$ln(|\delta\phi|)$','Interpreter','latex','fontsize',16);
grid on; 
yyaxis right
ylim([min(log10(ya_fieldtime)),max(log10(ya_fieldtime))])
% set(gca,'YTick',min(log10(ya)):max(log10(ya)));
% ylabel('$log_{10}(|\delta\phi|)$','Interpreter','latex','fontsize',16);
% xlim([0,max(t)]);
% title(['\gamma=',num2str(gamma)]);
    title(['$\gamma=$',num2str(gamma)],'Interpreter','latex','fontsize',16);
% qiflux = 1.00;rgiflux=0.17826;  %代码出现错误 gtc.out的版本不同
% eload = 1;

 % cal k_theta*rho_i, only for eload=1 myh
 
%  if((iload==1)&&exist('diag_flux','var')&&exist('q_diag_flux','var'))
%     kthetarhoi=nmodes(imode)*q_diag_flux(1,4)/(q_diag_flux(1,2)*a_minor)*rho_i;
%     ylabel(['k_{\theta}\rho_i=',num2str(kthetarhoi)]);
%  end



 
% if((eload==1)&&exist('qiflux','var')&&exist('rgiflux','var'))
%     kthetarhoi=nmodes(imode)*qiflux/rgiflux*rho0;
%     ylabel(['k_{\theta}\rho_i=',num2str(kthetarhoi)]);
% end



% subplot(222)
% plot(t,fieldtime(:,2,1),'-','Linewidth',2); 
% xlabel('$t(R_0/C_s)$','Interpreter','latex','fontsize',16);
% % ylabel('$(a.u.)$','Interpreter','latex','fontsize',16);
% title('$\phi_{Zonal}^{\prime}(r=diag)$','Interpreter','latex','fontsize',16);
% grid on
% subplot(224)
% semilogy(t,fieldtime(:,3,1),'-','Linewidth',2); 
% xlabel('$t(R_0/C_s)$','Interpreter','latex','fontsize',16);
% % ylabel('$(a.u.)$','Interpreter','latex','fontsize',16);
% title('$(\phi_{Zonal}^{\prime})_{rms}$','Interpreter','latex','fontsize',16);
% grid on