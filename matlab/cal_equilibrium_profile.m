% calculate some basic parameters 总的模拟区域相关剖面的梯度标长
% close all; clear; clc;
% run setpath;
% run read_para.m
%pdata中9列是离子温度数值 10列是一阶导数值
%pdata中24列是关于Z=0的中平面上r/R0的数值
% 24: minor radius
% 25: toroidal flux
%% 离子温度梯度标长
figure(5)
subplot(231)
Ti_psi_p  =  pdata(:,9);
psi_p     =  pdata(:,1);
Ti_logp_psi_p = -(diff(log(Ti_psi_p)))./(diff(psi_p));
plot(psi_p(1:end-1),Ti_logp_psi_p,'LineWidth',2);
grid on
xlabel('$\psi_p$','interpreter','latex','fontsize',16);
ylabel('$-dln(T_i)/d\psi_p$','interpreter','latex','fontsize',16);
title('$-dln(T_i)/d\psi_p$','interpreter','latex','fontsize',16);
subplot(234)
% Ti_psi_p  =  pdata(:,9);
% psi_p     =  pdata(:,1);
% Ti_logp_psi_p = -(diff(log(Ti_psi_p)))./(diff(psi_p));
plot(psi_p(1:end-1)./max(psi_p),Ti_logp_psi_p,'LineWidth',2);
grid on
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$-dln(T_i)/d\psi_p$','interpreter','latex','fontsize',16);
title('$-dln(T_i)/d\psi_p$','interpreter','latex','fontsize',16);

%% 离子密度梯度标长
%pdata(:,11)离子密度 12列是一阶导数值
subplot(232)
ni_psi_p  =  pdata(:,11);
psi_p     =  pdata(:,1);
ni_logp_psi_p = -(diff(log(ni_psi_p)))./(diff(psi_p));
plot(psi_p(1:end-1),ni_logp_psi_p,'LineWidth',2);
grid on
xlabel('$\psi_p$','interpreter','latex','fontsize',16);
ylabel('$-dln(n_i)/d\psi_p$','interpreter','latex','fontsize',16);
title('$-dln(n_i)/d\psi_p$','interpreter','latex','fontsize',16);
subplot(235)
% ni_psi_p  =  pdata(:,11);
% psi_p     =  pdata(:,1);
% ni_logp_psi_p = -(diff(log(ni_psi_p)))./(diff(psi_p));
plot(psi_p(1:end-1)./max(psi_p),ni_logp_psi_p,'LineWidth',2);
grid on
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
title('$-dln(n_i)/d\psi_p$','interpreter','latex','fontsize',16);
%% 离子eta_i
subplot(233)
eta_i = Ti_logp_psi_p./ni_logp_psi_p;
plot(psi_p(1:end-1),eta_i,'LineWidth',2);
grid on
xlabel('$\psi_p$','interpreter','latex','fontsize',16);
ylabel('$\eta_i$','interpreter','latex','fontsize',16);
title('$\eta_i$','interpreter','latex','fontsize',16);
subplot(236)
% eta_i = Ti_logp_psi_p./ni_logp_psi_p;
plot(psi_p(1:end-1)./max(psi_p),eta_i,'LineWidth',2);
grid on
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$\eta_i$','interpreter','latex','fontsize',16);
title('$\eta_i$','interpreter','latex','fontsize',16);

%% 温度梯度标长
%pdata中5列是电子温度数值 6列是一阶导数值
%pdata中24列是关于Z=0的中平面上r/R0的数值
%作为校验
figure(6)
subplot(231)
Te_psi_p  =  pdata(:,5);
psi_p     =  pdata(:,1);
Te_logp_psi_p = -(diff(log(Te_psi_p)))./(diff(psi_p));
plot(psi_p(1:end-1),Te_logp_psi_p,'LineWidth',2);
grid on
xlabel('$\psi_p$','interpreter','latex','fontsize',16);
ylabel('$-dln(T_e)/d\psi_p$','interpreter','latex','fontsize',16);
title('$-dln(T_e)/d\psi_p$','interpreter','latex','fontsize',16);
subplot(234)
% Ti_psi_p  =  pdata(:,9);
% psi_p     =  pdata(:,1);
% Ti_logp_psi_p = -(diff(log(Ti_psi_p)))./(diff(psi_p));
plot(psi_p(1:end-1)./max(psi_p),Te_logp_psi_p,'LineWidth',2);
grid on
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$-dln(T_e)/d\psi_p$','interpreter','latex','fontsize',16);
title('$-dln(T_e)/d\psi_p$','interpreter','latex','fontsize',16);

%% 电子密度梯度标长
%pdata(:,7)离子密度 8列是一阶导数值
subplot(232)
ne_psi_p  =  pdata(:,7);
psi_p     =  pdata(:,1);
ne_logp_psi_p = -(diff(log(ne_psi_p)))./(diff(psi_p));
plot(psi_p(1:end-1),ne_logp_psi_p,'LineWidth',2);
grid on
xlabel('$\psi_p$','interpreter','latex','fontsize',16);
ylabel('$-dln(n_e)/d\psi_p$','interpreter','latex','fontsize',16);
title('$-dln(n_e)/d\psi_p$','interpreter','latex','fontsize',16);
subplot(235)
% ni_psi_p  =  pdata(:,11);
% psi_p     =  pdata(:,1);
% ni_logp_psi_p = -(diff(log(ni_psi_p)))./(diff(psi_p));
plot(psi_p(1:end-1)./max(psi_p),ne_logp_psi_p,'LineWidth',2);
grid on
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
title('$-dln(n_e)/d\psi_p$','interpreter','latex','fontsize',16);
%% 电子eta_i
subplot(233)
eta_e = Te_logp_psi_p./ne_logp_psi_p;
plot(psi_p(1:end-1),eta_e,'LineWidth',2);
grid on
xlabel('$\psi_p$','interpreter','latex','fontsize',16);
ylabel('$\eta_e$','interpreter','latex','fontsize',16);
title('$\eta_e$','interpreter','latex','fontsize',16);
subplot(236)
% eta_i = Ti_logp_psi_p./ni_logp_psi_p;
plot(psi_p(1:end-1)./max(psi_p),eta_e,'LineWidth',2);
grid on
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$\eta_e$','interpreter','latex','fontsize',16);
title('$\eta_e$','interpreter','latex','fontsize',16);
%%q
figure(6)
