% Hua-sheng XIE, IFTS-ZJU, hushengxie@gmail.com, 2012-07-02 16:28
% an auxiliary code for analytical.F90
% calculate some basic parameters
close all; clear; clc;

run setpath;
run read_para.m

r0=83.5;          % major radius, unit=cm
b0=20125.4;       % on-axis magnetic field, unit=gauss
etemp0=2223.0;    % on-axis electron temperature, unit=ev
% eden0=0.1130e14;  % on-axis electron number density, unit=1/cm^3
% eden0=4.0e14;  % on-axis electron number density, unit=1/cm^3
betae0=4.03e-11*etemp0*eden0/(b0*b0);

psiw=0.0375; % psi on wall
% psi=0.01949*psiw:0.001*psiw:0.88*psiw;
psi=0.00*psiw:0.001*psiw:1*psiw;
psi_n=psi./psiw; % normalization psi
xpsin = (length(psi)+1)/2; %  psi/2

q1=0.82;q2=1.1;q3=1.0;

q=q1+q2.*psi_n+q3.*psi_n.^2;

r=sqrt(2.*(q1.*psi_n+(q2.*psi_n.^2)./2.0+(q3.*psi_n.^3)./3.0)*psiw); % r/R0
a=max(r); % minor radius, a/R0
r_n = r./a; % r/a
s=r_n(1:end-1).*(log(q(2:end))-log(q(1:end-1)))./(r_n(2:end)-r_n(1:end-1)); % shear

xrn = find(abs(r_n-0.49764288)<4e-4);  


% r_half = r_n(xrn); % r=0.5*a

% ne1=0.205;ne2=0.30;ne3=0.4015;
ne1=0.205;ne2=0.30;ne3=0.40;

ne=1.0+ne1.*(tanh((ne2-(psi_n))./ne3)-1.0);

% te1=0.415;te2=0.18;te3=0.4105;
te1=0.415;te2=0.18;te3=0.40;

te=1.0+te1.*(tanh((te2-(psi_n))./te3)-1.0);

% r0=83.5;          % major radius, unit=cm
% b0=20125.4;       % on-axis magnetic field, unit=gauss
% etemp0=2223.0;    % on-axis electron temperature, unit=ev
% % eden0=0.1130e14;  % on-axis electron number density, unit=1/cm^3
% eden0=0.9e14;  % on-axis electron number density, unit=1/cm^3

% some parameters
n_mode  = 10;
k_theta = n_mode*q(xrn)/(0.5*a);
A = 1;Z = 1;itemp0 = etemp0; % A is multiples m_p; Z is ion charge number [e]
rho_i   = 1.02*10^2*(A^0.5)/Z*(itemp0^0.5)/b0/r0;  % ion thermal radius, m
L_rho   = a/rho_i  ;
L_finite = k_theta*rho_i   ;                 
L_ne  = -(log(ne(xrn))-log(ne(xrn-1)))./(r_n(xrn)-r_n(xrn-1))/a; % R_0/L_ne
L_Te  = -(log(te(xrn))-log(te(xrn-1)))./(r_n(xrn)-r_n(xrn-1))/a; % R_0/L_Te
eta_e = L_Te/L_ne;
q_half = q(xrn);
s_half = s(xrn);
omega_n = [-0.56,-0.64,-0.71,-0.77,-0.79,-0.81,0.29,-2.35,-2.17,-2.08];
gamma_n = [0.41,0.37,0.33,0.27,0.24,0.20,0.18,0.28,0.61,0.98];
% gamma_n = [0.000388175,0.000391766,0.000414079,0.000381244,0.000377073,0.000340875  ]/rho_i
% omega_n =  [0.000539571,-0.000902218,-0.000863270,-0.000899285,-0.000986082,-0.000899285 ]/rho_i
betae_n = [0.0025:0.0025:0.01,0.011,0.012,0.0130,0.015,0.0175,0.02];
figure(10)
plot(betae_n,gamma_n,'-o','LineWidth',2)
hold on
betae_n1 = [0.01,0.011,0.012,0.012,0.013,0.013,0.014,0.014,0.015,0.0175,0.02];
omega_n1 = [-0.81,-0.84,0.25,-2.60,0.29,-2.75,-2.40,0.39,-2.15,-2.15,-2.03];
gamma_n1 = [0.23,0.162,0.16,0.16,0.1558,0.1558,0.21,0.21,0.59,0.99,1.32];
plot(betae_n1,gamma_n1,'-^','LineWidth',2)
% xlim([0.013,0.02]);
% ylim([0.1,0.4]);
grid on;
xlabel('\beta_e','FontSize',16)
ylabel('\gamma(C_s/R_0)','FontSize',16)
title('\gamma','FontSize',16)
legend('$w/o \quad {\delta} B_{\parallel}$','$with \quad \delta B_{\parallel}$','interpreter','latex','fontsize',16)
figure(11)
plot(betae_n,omega_n,'o','LineWidth',2)
hold on
plot(betae_n1,omega_n1,'^','LineWidth',2)
% xlim([0.013,0.02]);
% ylim([-1,-0.5]);
grid on;
xlabel('\beta_e','FontSize',16)
ylabel('\omega(C_s/R_0)','FontSize',16)
title('\omega','FontSize',16)

legend('$w/o \quad {\delta} B_{\parallel}$','$with \quad \delta B_{\parallel}$','interpreter','latex','fontsize',16)

R=1+r;
% betae0=4.03e-11*etemp0*eden0/(b0*b0);
bb=(1./R).*sqrt(1+(r./(q.*R)).^2); % normalized B, right?
% betae=betae0.*te.*ne./(bb.*bb);   % Q: how to give the B^2 field?
betae=betae0.*te.*ne;   % Q: how to give the B^2 field?
[0.02,0.0175,0.015,0.014,0.013,0.012,0.011,0.010,0.0075,0.0050,0.0025]*b0^2*10^11/4.03/etemp0

% tau_A/tau_cs0, tau_cs0 is GTC unit, tau_A(r)=q(r)*R/v_A(r) is local Alfven time
% taua_o_taucs0=q.*R.*sqrt(betae./2.0);
taua_o_taucs0=q.*sqrt(betae./2.0);

hf=figure('unit','normalized','Position',[0.1 0.2 0.7 0.7],...
            'Name','Equilibrium profile',... % 'menubar','none',...
            'NumberTitle','off');
set(gcf,'DefaultAxesFontSize',14);

subplot(341);plot(psi_n,q,'--g',r_n,q,'r','LineWidth',2);xlim([0,1]);ylim([0,4]);grid on;
title(['q=/',num2str(q1),',',num2str(q2),',',num2str(q3),'/']);
% legend('(psi)','(r)',-2)
legend('(psi)','(r)')
legend('boxoff');

subplot(342);plot(psi_n,ne,'--g',r_n,ne,'r','LineWidth',2);xlim([0,1]);grid minor;
title(['ne=/',num2str(ne1),',',num2str(ne2),',',num2str(ne3),'/']);

subplot(343);plot(psi_n,te,'--g',r_n,te,'r','LineWidth',2);xlim([0,1]);grid on;
title(['Te=/',num2str(te1),',',num2str(te2),',',num2str(te3),'/']);

subplot(344);plot(psi_n,betae,'--g',r_n,betae,'r','LineWidth',2);xlim([0,1]);grid minor;
title(['\beta_e=',num2str(betae0)]);  % betae(1) \neq betae0 !!

subplot(345);
plot(psi_n(1:end-1),(log(q(2:end))-log(q(1:end-1)))./(psi_n(2:end)-psi_n(1:end-1)),...
    '--g',r_n(1:end-1),(log(q(2:end))-log(q(1:end-1)))./(r_n(2:end)-r_n(1:end-1)),'r','LineWidth',2);
xlim([0,1]);title('dln(q)');grid minor;

subplot(346);
plot(psi_n(1:end-1),-(log(ne(2:end))-log(ne(1:end-1)))./(psi_n(2:end)-psi_n(1:end-1)),...
    '--g',r_n(1:end-1),-(log(ne(2:end))-log(ne(1:end-1)))./(r_n(2:end)-r_n(1:end-1)),'r','LineWidth',2);
xlim([0,1]);title('-dln(ne)');grid minor;box on;

subplot(347);
plot(psi_n(1:end-1),-(log(te(2:end))-log(te(1:end-1)))./(psi_n(2:end)-psi_n(1:end-1)),...
    '--g',r_n(1:end-1),-(log(te(2:end))-log(te(1:end-1)))./(r_n(2:end)-r_n(1:end-1)),'r','LineWidth',2);
xlim([0,1]);title('-dln(Te)');grid on;

subplot(348);plot(psi_n,taua_o_taucs0,'--g',r_n,taua_o_taucs0,'r','LineWidth',2);xlim([0,1]);grid minor;
title('\tau_A/\tau_{cs0}');

subplot(349);plot(psi_n,r,'--g','LineWidth',2);
grid on;xlim([0,1]);title(['r(psi), a/R0=',num2str(a)]);

subplot(3,4,10);  % s=(r/q)*(dq/dr)
s=r_n(1:end-1).*(log(q(2:end))-log(q(1:end-1)))./(r_n(2:end)-r_n(1:end-1));
plot(psi_n(1:end-1),s,'--g',r_n(1:end-1),s,'r','LineWidth',2);
xlim([0,1]);title('shear');grid minor;

subplot(3,4,11);  % alpha=-q^2*R*(dbeta/dr), Q: how to give R?
alpha=-q(1:end-1).^2.*(R(1:end-1).*2).*(betae(2:end)-betae(1:end-1))./(r(2:end)-r(1:end-1));
plot(psi_n(1:end-1),alpha,'--g',r_n(1:end-1),alpha,'r','LineWidth',2);
xlim([0,1]);title('\alpha');grid minor;

subplot(3,4,12);  % alpha=-q^2*R*(dbeta/dr), Q: how to give R?
plot(r_n(1:end-1),-(log(ne(2:end))-log(ne(1:end-1)))./(r_n(2:end)-r_n(1:end-1))/a,...
    '-g',r_n(1:end-1),-(log(te(2:end))-log(te(1:end-1)))./(r_n(2:end)-r_n(1:end-1))/a,'r','LineWidth',2);
xlim([0,1]);title('\kappa(r)');legend('R_0/L_{ne}','R_0/L_{Te}');grid minor;box on;

% print(hf,'-dpng',[path,'analytical_equilibrium_profile.png']);

