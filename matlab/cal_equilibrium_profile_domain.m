% calculate some basic parameters 离子与电子相关剖面的梯度标长
% close all; clear; clc;
run setpath;
run read_para.m
KB_J_per_K = 1.38*1e-23;
eV_to_K = 1.16*1e04;
eV_to_J = KB_J_per_K*eV_to_K;
mu0     = 4*pi*1e-7;
%% 温度梯度标长 使用gtc.out中的模拟区域的数据
%psi0-psi1区域的数据来观察
%profile_gtcout1作为整个的文件保存住
% i,  rg/a,  psi/ped,   q,   rg_sp/rg - 1,  dtorpsi/q 
% profile_gtcout2作为整个的文件保存住
% i  r   psipol  psitor  meshte  meshti  meshtf  meshne  meshni meshnf
figure(6)
subplot(231)
Ti_psi_p  =  profile_gtcout2(:,6);
psi_p     =  profile_gtcout2(:,3);
r_hat     =  profile_gtcout2(:,2)/a_minor;
Ti_logp_psi_p = -(diff(log(Ti_psi_p)))./(diff(psi_p));
Ti_p_r = Ti_logp_psi_p.*(diff(psi_p)./diff(r_hat))/a_minor;
plot(psi_p./ped,Ti_psi_p,'-','LineWidth',2);
hold on
plot(r_hat,Ti_psi_p,'--','LineWidth',2);
legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$T_i [eV]$','interpreter','latex','fontsize',16);
title('$T_i$','interpreter','latex','fontsize',16);
grid on
subplot(234)
% Ti_psi_p  =  pdata(:,9);
% psi_p     =  pdata(:,1);
% Ti_logp_psi_p = -(diff(log(Ti_psi_p)))./(diff(psi_p));
yyaxis left
plot(psi_p(1:end-1)./ped,Ti_logp_psi_p,'LineWidth',2);
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$-dln(T_i)/d\psi_p$','interpreter','latex','fontsize',16);
title('$-dln(T_i)/d\psi_p,R_0/L_{Ti}$','interpreter','latex','fontsize',16);
yyaxis right
plot(r_hat(1:end-1),Ti_p_r,'--','LineWidth',2);
legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
ylabel('$R_0/L_{Ti}$','interpreter','latex','fontsize',16);
grid on
%% 离子密度梯度标长
%pdata(:,11)离子密度 12列是一阶导数值
subplot(232)
ni_psi_p  =  profile_gtcout2(:,9)*eden0*1e6;
psi_p     =  profile_gtcout2(:,3);
ni_logp_psi_p = -(diff(log(ni_psi_p)))./(diff(psi_p));
ni_p_r = ni_logp_psi_p.*(diff(psi_p)./diff(r_hat))/a_minor;
plot(psi_p./ped,ni_psi_p,'LineWidth',2);
hold on
plot(r_hat,ni_psi_p,'--','LineWidth',2);
legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
grid on
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$n_i [m^{-3}]$','interpreter','latex','fontsize',16);
title('$n_i$','interpreter','latex','fontsize',16);
subplot(235)
% ni_psi_p  =  pdata(:,11);
% psi_p     =  pdata(:,1);
% ni_logp_psi_p = -(diff(log(ni_psi_p)))./(diff(psi_p));
yyaxis left
plot(psi_p(1:end-1)./ped,ni_logp_psi_p,'LineWidth',2);
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$-dln(n_i)/d\psi_p$','interpreter','latex','fontsize',16);
title('$-dln(n_i)/d\psi_p,R_0/L_{ni}$','interpreter','latex','fontsize',16);
yyaxis right
plot(r_hat(1:end-1),ni_p_r,'--','LineWidth',2);
ylabel('$R_0/L_{ni}$','interpreter','latex','fontsize',16);
legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
grid on
%% 离子eta_i
subplot(233)
eta_i = Ti_logp_psi_p./ni_logp_psi_p;
plot(psi_p(1:end-1),eta_i,'LineWidth',2);
% hold on
% plot(profile_gtcout2(1:end-1,2)*R0/100,eta_i,'--','LineWidth',2);
% legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
grid on
xlabel('$\psi_p$','interpreter','latex','fontsize',16);
ylabel('$\eta_i$','interpreter','latex','fontsize',16);
title('$\eta_i$','interpreter','latex','fontsize',16);
subplot(236)
% eta_i = Ti_logp_psi_p./ni_logp_psi_p;
plot(psi_p(1:end-1)./ped,eta_i,'LineWidth',2);
hold on
plot(r_hat(1:end-1),eta_i,'--','LineWidth',2);
legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
grid on
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$\eta_i$','interpreter','latex','fontsize',16);
title('$\eta_i$','interpreter','latex','fontsize',16);

%% 温度梯度标长 使用gtc.out中的模拟区域的数据 保留梯度
% calculate some basic parameters 离子相关剖面的梯度标长
% close all; clear; clc;
% run setpath;
% run read_para.m
%psi0-psi1区域的数据来观察
%profile_gtcout1作为整个的文件保存住
% i,  rg/a,  psi/ped,   q,   rg_sp/rg - 1,  dtorpsi/q 
%profile_gtcout2作为整个的文件保存住
% i  r   psipol  psitor  meshte  meshti  meshne  meshni 
% figure(66)
% subplot(231)
% Ti_p_psi_p = -(diff(Ti_psi_p))./(diff(psi_p));
% Ti_p_r = Ti_p_psi_p.*(diff(psi_p./ped)./diff(r_hat));
% plot(psi_p./ped,Ti_psi_p,'-','LineWidth',2);
% hold on
% plot(r_hat,Ti_psi_p,'--','LineWidth',2);
% legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
% xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
% ylabel('$T_i$','interpreter','latex','fontsize',16);
% title('$T_i$','interpreter','latex','fontsize',16);
% grid on
% subplot(234)
% % Ti_psi_p  =  pdata(:,9);
% % psi_p     =  pdata(:,1);
% % Ti_logp_psi_p = -(diff(log(Ti_psi_p)))./(diff(psi_p));
% plot(psi_p(1:end-1)./ped,Ti_p_psi_p,'LineWidth',2);
% hold on
% plot(r_hat(1:end-1),Ti_p_r,'--','LineWidth',2);
% legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
% xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
% ylabel('$-dT_i/d\psi_p$','interpreter','latex','fontsize',16);
% title('$-dT_i/d\psi_p$','interpreter','latex','fontsize',16);
% grid on
% %% 离子密度梯度标长
% %pdata(:,11)离子密度 12列是一阶导数值
% subplot(232)
% ni_psi_p  =  profile_gtcout2(:,8)*eden0*1e6;
% psi_p     =  profile_gtcout2(:,3);
% ni_p_psi_p = -(diff(ni_psi_p))./(diff(psi_p));
% ni_p_r = ni_p_psi_p.*(diff(psi_p./ped)./diff(r_hat));
% plot(psi_p./ped,ni_psi_p,'LineWidth',2);
% hold on
% plot(r_hat,ni_psi_p,'--','LineWidth',2);
% legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
% grid on
% xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
% ylabel('$n_i$','interpreter','latex','fontsize',16);
% title('$n_i$','interpreter','latex','fontsize',16);
% subplot(235)
% % ni_psi_p  =  pdata(:,11);
% % psi_p     =  pdata(:,1);
% % ni_logp_psi_p = -(diff(log(ni_psi_p)))./(diff(psi_p));
% plot(psi_p(1:end-1)./ped,ni_p_psi_p,'LineWidth',2);
% hold on
% plot(r_hat(1:end-1),ni_p_r,'--','LineWidth',2);
% legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
% grid on
% xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
% ylabel('$-dn_i/d\psi_p$','interpreter','latex','fontsize',16);
% title('$-dn_i/d\psi_p$','interpreter','latex','fontsize',16);
% %% 离子eta_i
% subplot(233)
% plot(psi_p/ped,r_hat,'LineWidth',2);
% % hold on
% % plot(profile_gtcout2(1:end-1,2)*R0/100,eta_i,'--','LineWidth',2);
% % legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
% 
% xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
% ylabel('$\hat{r}(\psi_p)$','interpreter','latex','fontsize',16);
% title('$\hat{r}(\hat{\psi}_p)$','interpreter','latex','fontsize',16);
% grid on
% subplot(236)
% % eta_i = Ti_logp_psi_p./ni_logp_psi_p;
% plot(psi_p(1:end-1)./ped,(diff(r_hat)./diff(psi_p./ped)),'LineWidth',2);
% xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
% ylabel('$d\hat{r}/d\hat{\psi}_p$','interpreter','latex','fontsize',16);
% title('$d\hat{r}/d\hat{\psi}_p$','interpreter','latex','fontsize',16);
% grid on
%% 模拟区域的q剖面信息以及磁剪切s信息
figure(666)
subplot(221)
psi_p1     =  profile_gtcout1(:,3);
r_hat1     =  profile_gtcout1(:,2);
% r_real     =  r_hat1*a_minor*R0/100;
% q_logp_r = -(diff(log(profile_gtcout1(:,4))))./(diff(log(r_real)));
q_logp_psi_p = (diff(log(profile_gtcout1(:,4))))./(diff(log(psi_p1)));
q_logp_r = (diff(log(profile_gtcout1(:,4))))./(diff(log(r_hat1)));
plot(psi_p1,profile_gtcout1(:,4),'LineWidth',2);
grid on
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
% ylabel('$q$','interpreter','latex','fontsize',16);
title('$q$','interpreter','latex','fontsize',16);
subplot(223)
plot(r_hat1,profile_gtcout1(:,4),'LineWidth',2);
grid on
xlabel('$r/a$','interpreter','latex','fontsize',16);
% ylabel('$q$','interpreter','latex','fontsize',16);
title('$q$','interpreter','latex','fontsize',16);
% 磁剪切s信息
subplot(222)
plot(psi_p1(1:end-1),q_logp_psi_p,'LineWidth',2);
grid on
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
% ylabel('$q$','interpreter','latex','fontsize',16);
title('$s$','interpreter','latex','fontsize',16);
subplot(224)
plot(r_hat1(1:end-1),q_logp_r,'LineWidth',2);
grid on
xlabel('$r/a$','interpreter','latex','fontsize',16);
% ylabel('$q$','interpreter','latex','fontsize',16);
title('$s$','interpreter','latex','fontsize',16);
% calculate some basic parameters 电子相关剖面的梯度标长
% close all; clear; clc;
% run setpath;
% run read_para.m
%% 电子温度梯度标长 使用gtc.out中的模拟区域的数据
%psi0-psi1区域的数据来观察
%profile_gtcout1作为整个的文件保存住
% i,  rg/a,  psi/ped,   q,   rg_sp/rg - 1,  dtorpsi/q 
%profile_gtcout2作为整个的文件保存住
% i  r   psipol  psitor  meshte  meshti  meshtf  meshne  meshni meshnf
figure(4)
subplot(231)
Te_psi_p  =  profile_gtcout2(:,5);
psi_p     =  profile_gtcout2(:,3);
r_hat     =  profile_gtcout2(:,2)/a_minor;
Te_logp_psi_p = -(diff(log(Te_psi_p)))./(diff(psi_p));
Te_p_r = Te_logp_psi_p.*(diff(psi_p)./diff(r_hat))/a_minor;
plot(psi_p./ped,Te_psi_p,'-','LineWidth',2);
hold on
plot(r_hat,Te_psi_p,'--','LineWidth',2);
legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$T_e [eV]$','interpreter','latex','fontsize',16);
title('$T_e$','interpreter','latex','fontsize',16);
grid on
subplot(234)
% Te_psi_p  =  pdata(:,9);
% psi_p     =  pdata(:,1);
% Te_logp_psi_p = -(diff(log(Ti_psi_p)))./(diff(psi_p));
yyaxis left
plot(psi_p(1:end-1)./ped,Te_logp_psi_p,'LineWidth',2);
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$-dln(T_e)/d\psi_p$','interpreter','latex','fontsize',16);
title('$-dln(T_e)/d\psi_p,R_0/L_{Te}$','interpreter','latex','fontsize',16);
yyaxis right
plot(r_hat(1:end-1),Te_p_r,'--','LineWidth',2);
legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
ylabel('$R_0/L_{Te}$','interpreter','latex','fontsize',16);
grid on
%% 电子密度梯度标长
%pdata(:,11)离子密度 12列是一阶导数值
subplot(232)
ne_psi_p  =  profile_gtcout2(:,8)*eden0*1e6;
psi_p     =  profile_gtcout2(:,3);
ne_logp_psi_p = -(diff(log(ne_psi_p)))./(diff(psi_p));
ne_p_r = ne_logp_psi_p.*(diff(psi_p)./diff(r_hat))/a_minor;
plot(psi_p./ped,ne_psi_p,'LineWidth',2);
hold on
plot(r_hat,ne_psi_p,'--','LineWidth',2);
legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
grid on
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$n_e [m^{-3}]$','interpreter','latex','fontsize',16);
title('$n_e$','interpreter','latex','fontsize',16);
subplot(235)
% ni_psi_p  =  pdata(:,11);
% psi_p     =  pdata(:,1);
% ni_logp_psi_p = -(diff(log(ni_psi_p)))./(diff(psi_p));
yyaxis left
plot(psi_p(1:end-1)./ped,ne_logp_psi_p,'LineWidth',2);
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$-dln(n_e)/d\psi_p$','interpreter','latex','fontsize',16);
title('$-dln(n_e)/d\psi_p,R_0/L_{ne}$','interpreter','latex','fontsize',16);
yyaxis right
plot(r_hat(1:end-1),ne_p_r,'--','LineWidth',2);
ylabel('$R_0/L_{ne}$','interpreter','latex','fontsize',16);
legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
grid on
%% 电子eta_e
subplot(233)
eta_e = Te_logp_psi_p./ne_logp_psi_p;
plot(psi_p(1:end-1),eta_e,'LineWidth',2);
% hold on
% plot(profile_gtcout2(1:end-1,2)*R0/100,eta_i,'--','LineWidth',2);
% legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
grid on
xlabel('$\psi_p$','interpreter','latex','fontsize',16);
ylabel('$\eta_e$','interpreter','latex','fontsize',16);
title('$\eta_e$','interpreter','latex','fontsize',16);
subplot(236)
% eta_i = Ti_logp_psi_p./ni_logp_psi_p;
plot(psi_p(1:end-1)./ped,eta_e,'LineWidth',2);
hold on
plot(r_hat(1:end-1),eta_e,'--','LineWidth',2);
legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
grid on
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$\eta_e$','interpreter','latex','fontsize',16);
title('$\eta_e$','interpreter','latex','fontsize',16);
%% 快离子温度梯度标长 使用gtc.out中的模拟区域的数据
%psi0-psi1区域的数据来观察
%profile_gtcout1作为整个的文件保存住
% i,  rg/a,  psi/ped,   q,   rg_sp/rg - 1,  dtorpsi/q 
%profile_gtcout2作为整个的文件保存住
% i  r   psipol  psitor  meshte  meshti  meshtf  meshne  meshni meshnf
figure(5)
subplot(231)
Tf_psi_p  =  profile_gtcout2(:,7);
psi_p     =  profile_gtcout2(:,3);
r_hat     =  profile_gtcout2(:,2)/a_minor;
Tf_logp_psi_p = -(diff(log(Tf_psi_p)))./(diff(psi_p));
Tf_p_r = Tf_logp_psi_p.*(diff(psi_p)./diff(r_hat))/a_minor;
plot(psi_p./ped,Tf_psi_p,'-','LineWidth',2);
hold on
plot(r_hat,Tf_psi_p,'--','LineWidth',2);
legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$T_f [eV]$','interpreter','latex','fontsize',16);
title('$T_f$','interpreter','latex','fontsize',16);
grid on
subplot(234)
% Te_psi_p  =  pdata(:,9);
% psi_p     =  pdata(:,1);
% Te_logp_psi_p = -(diff(log(Ti_psi_p)))./(diff(psi_p));
yyaxis left
plot(psi_p(1:end-1)./ped,Tf_logp_psi_p,'LineWidth',2);
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$-dln(T_f)/d\psi_p$','interpreter','latex','fontsize',16);
title('$-dln(T_f)/d\psi_p,R_0/L_{Tf}$','interpreter','latex','fontsize',16);
yyaxis right
plot(r_hat(1:end-1),Tf_p_r,'--','LineWidth',2);
legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
ylabel('$R_0/L_{Tf}$','interpreter','latex','fontsize',16);
grid on
%% 快离子密度梯度标长
%pdata(:,11)离子密度 12列是一阶导数值
subplot(232)
nf_psi_p  =  profile_gtcout2(:,10)*eden0*1e6;
psi_p     =  profile_gtcout2(:,3);
nf_logp_psi_p = -(diff(log(nf_psi_p)))./(diff(psi_p));
nf_p_r = nf_logp_psi_p.*(diff(psi_p)./diff(r_hat))/a_minor;
plot(psi_p./ped,nf_psi_p,'LineWidth',2);
hold on
plot(r_hat,nf_psi_p,'--','LineWidth',2);
legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
grid on
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$n_f [m^{-3}]$','interpreter','latex','fontsize',16);
title('$n_f$','interpreter','latex','fontsize',16);
subplot(235)
% ni_psi_p  =  pdata(:,11);
% psi_p     =  pdata(:,1);
% ni_logp_psi_p = -(diff(log(ni_psi_p)))./(diff(psi_p));
yyaxis left
plot(psi_p(1:end-1)./ped,nf_logp_psi_p,'LineWidth',2);
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$-dln(n_f)/d\psi_p$','interpreter','latex','fontsize',16);
title('$-dln(n_f)/d\psi_p,R_0/L_{nf}$','interpreter','latex','fontsize',16);
yyaxis right
plot(r_hat(1:end-1),nf_p_r,'--','LineWidth',2);
ylabel('$R_0/L_{nf}$','interpreter','latex','fontsize',16);
legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
grid on
%% 快离子eta_e
subplot(233)
eta_f = Tf_logp_psi_p./nf_logp_psi_p;
plot(psi_p(1:end-1),eta_f,'LineWidth',2);
% hold on
% plot(profile_gtcout2(1:end-1,2)*R0/100,eta_i,'--','LineWidth',2);
% legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
grid on
xlabel('$\psi_p$','interpreter','latex','fontsize',16);
ylabel('$\eta_f$','interpreter','latex','fontsize',16);
title('$\eta_f$','interpreter','latex','fontsize',16);
subplot(236)
% eta_i = Ti_logp_psi_p./ni_logp_psi_p;
plot(psi_p(1:end-1)./ped,eta_f,'LineWidth',2);
hold on
plot(r_hat(1:end-1),eta_f,'--','LineWidth',2);
legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
grid on
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$\eta_f$','interpreter','latex','fontsize',16);
title('$\eta_f$','interpreter','latex','fontsize',16);

%% 温度梯度标长 使用gtc.out中的模拟区域的数据 保留梯度
% calculate some basic parameter 电子相关剖面的梯度标长
% close all; clear; clc;
% run setpath;
% run read_para.m
%psi0-psi1区域的数据来观察
%profile_gtcout1作为整个的文件保存住
% i,  rg/a,  psi/ped,   q,   rg_sp/rg - 1,  dtorpsi/q 
%profile_gtcout2作为整个的文件保存住
% i  r   psipol  psitor  meshte  meshti  meshne  meshni 
% figure(44)
% subplot(231)
% Te_psi_p  =  profile_gtcout2(:,5);
% psi_p     =  profile_gtcout2(:,3);
% r_hat     =  profile_gtcout2(:,2)/a_minor;
% Te_p_psi_p = -(diff(Te_psi_p))./(diff(psi_p));
% Te_p_r = Te_p_psi_p.*(diff(psi_p./ped)./diff(r_hat));
% plot(psi_p./ped,Te_psi_p,'-','LineWidth',2);
% hold on
% plot(r_hat,Te_psi_p,'--','LineWidth',2);
% legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
% xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
% ylabel('$T_e$','interpreter','latex','fontsize',16);
% title('$T_e$','interpreter','latex','fontsize',16);
% grid on
% subplot(234)
% % Ti_psi_p  =  pdata(:,9);
% % psi_p     =  pdata(:,1);
% % Ti_logp_psi_p = -(diff(log(Ti_psi_p)))./(diff(psi_p));
% plot(psi_p(1:end-1)./ped,Te_p_psi_p,'LineWidth',2);
% hold on
% plot(r_hat(1:end-1),Te_p_r,'--','LineWidth',2);
% legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
% xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
% ylabel('$-dT_e/d\psi_p$','interpreter','latex','fontsize',16);
% title('$-dT_e/d\psi_p$','interpreter','latex','fontsize',16);
% grid on
% %% 电子密度梯度标长
% %pdata(:,11)电子密度 12列是一阶导数值
% subplot(232)
% ne_psi_p  =  profile_gtcout2(:,7)*eden0*1e6;
% psi_p     =  profile_gtcout2(:,3);
% ne_p_psi_p = -(diff(ne_psi_p))./(diff(psi_p));
% ne_p_r = ne_p_psi_p.*(diff(psi_p./ped)./diff(r_hat));
% plot(psi_p./ped,ne_psi_p,'LineWidth',2);
% hold on
% plot(r_hat,ne_psi_p,'--','LineWidth',2);
% legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
% grid on
% xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
% ylabel('$n_e$','interpreter','latex','fontsize',16);
% title('$n_e$','interpreter','latex','fontsize',16);
% subplot(235)
% % ni_psi_p  =  pdata(:,11);
% % psi_p     =  pdata(:,1);
% % ni_logp_psi_p = -(diff(log(ni_psi_p)))./(diff(psi_p));
% plot(psi_p(1:end-1)./ped,ne_p_psi_p,'LineWidth',2);
% hold on
% plot(r_hat(1:end-1),ne_p_r,'--','LineWidth',2);
% legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
% grid on
% xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
% ylabel('$-dn_e/d\psi_p$','interpreter','latex','fontsize',16);
% title('$-dn_e/d\psi_p$','interpreter','latex','fontsize',16);
% %% 电子eta_i
% subplot(233)
% plot(psi_p/ped,r_hat,'LineWidth',2);
% % hold on
% % plot(profile_gtcout2(1:end-1,2)*R0/100,eta_i,'--','LineWidth',2);
% % legend('$\hat{\psi}_p$','$r/a$','interpreter','latex','fontsize',16);
% 
% xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
% ylabel('$\hat{r}(\psi_p)$','interpreter','latex','fontsize',16);
% title('$\hat{r}(\hat{\psi}_p)$','interpreter','latex','fontsize',16);
% grid on
% subplot(236)
% % eta_i = Ti_logp_psi_p./ni_logp_psi_p;
% plot(psi_p(1:end-1)./ped,(diff(r_hat)./diff(psi_p./ped)),'LineWidth',2);
% xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
% ylabel('$d\hat{r}/d\hat{\psi}_p$','interpreter','latex','fontsize',16);
% title('$d\hat{r}/d\hat{\psi}_p$','interpreter','latex','fontsize',16);
% grid on
%% 压强剖面
figure(36)
Pe_psi_p = (ne_psi_p.*Te_psi_p)*KB_J_per_K*eV_to_K;
Pi_psi_p = (ni_psi_p.*Ti_psi_p)*KB_J_per_K*eV_to_K;
Pf_psi_p = (nf_psi_p.*Tf_psi_p)*KB_J_per_K*eV_to_K;
P_total_psip = Pi_psi_p+Pe_psi_p+Pf_psi_p;
psi_p     =  profile_gtcout2(:,3);
r_hat     =  profile_gtcout2(:,2)/a_minor;
plot(psi_p./ped,Pe_psi_p,'-','linewidth',2);
hold on
plot(psi_p./ped,Pi_psi_p,'-','linewidth',2);
hold on
plot(psi_p./ped,Pf_psi_p,'-','linewidth',2);
hold on
plot(psi_p./ped,P_total_psip,'-','linewidth',2);
grid on
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$P(Pa)$','interpreter','latex','fontsize',16);
title('$P$','interpreter','latex','fontsize',16);
legend('$P_e$','$P_i$','$P_f$','$P_{total}$','interpreter','latex','fontsize',16)
figure(37)
plot(r_hat,Pe_psi_p,'-','linewidth',2);
hold on
plot(r_hat,Pi_psi_p,'-','linewidth',2);
hold on
plot(r_hat,Pf_psi_p,'-','linewidth',2);
hold on
plot(r_hat,P_total_psip,'-','linewidth',2);
grid on
xlabel('$\rho$','interpreter','latex','fontsize',16);
ylabel('$P(Pa)$','interpreter','latex','fontsize',16);
title('$P$','interpreter','latex','fontsize',16);
legend('$P_e$','$P_i$','$P_f$','$P_{total}$','interpreter','latex','fontsize',16)
%比压
figure(38)
beta_total  = (P_total_psip)./((B0/10000).^2/(2*mu0));
betap_total = diff(beta_total)./diff(r_hat);
yyaxis left
plot(r_hat,beta_total,'-','linewidth',2);
ylabel('$\beta$','interpreter','latex','fontsize',16);
yyaxis right
plot(r_hat(2:end),betap_total,'-','linewidth',2);
grid on
xlabel('$\rho$','interpreter','latex','fontsize',16);
ylabel('$d\beta/d\rho$','interpreter','latex','fontsize',16);
title('$\beta,d\beta/d\rho$','interpreter','latex','fontsize',16);


