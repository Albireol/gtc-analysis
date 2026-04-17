%%GTC4.6 gtc.out中参数读取
m_p        = 1.67*10^(-27);        % (kg)   proton mass 
KB_J_per_K = 1.380649*1e-23;       % (J/K)  Boltzmann constant 
eV_to_K    = 11604.51812;          % (K/eV) 1.602176634*1e-19 [J/eV] /1.380649*1e-23 [J/K] ;% 1 eV~10000 K
eV_to_J    = KB_J_per_K*eV_to_K;   % (C)    elementary charge
mu0        = 4*pi*1e-7;            % (H/m) or (N/A^2) vacuum magnetic permeability (variously vacuum permeability)
qe         = 1.60e-19;             % (C)    electron charge
m_e        = 9.11e-31;             % (kg)   electron mass
epsion0    = 8.854*1e-12;          % (F/m)
% utime1_  = 1.0/(9580.0*B0);
% utime2   = m_p/(1.60*10^(-19)*B0/10000);
%% 诊断磁轴处的信息
Z_mp = 1;                                       % Z is ion charge number [e]
% ti_axis = ti_axis_norm*te_axis;                 %磁轴处离子温度 ev
% ni_axis = ni_axis_norm*ne_axis;                 %磁轴处离子密度 cm^-3 ne_axis等价于eden0
 ti_axis_norm = 1.0;
 ni_axis_norm = 1.0;
 ne_axis      = eden0;
ti_axis = ti_axis_norm*etemp0;                %磁轴处离子温度 ev
ni_axis = ni_axis_norm*eden0;                 %磁轴处离子密度 cm^-3
te_axis = etemp0;                             %磁轴处电子温度 ev    te_axis等价于etemp0
Debye_length = 7.43*10^2*sqrt(te_axis)/sqrt(ne_axis)/R0;             %Debye length using the R0 normalized
rho_p_axis   = 102.0*sqrt(etemp0)/(B0*R0);      %等价于gtc中的rho0    质子thermal radius
rho_i_axis   = 1.02*10^2*(aion^0.5)/Z_mp*(ti_axis^0.5)/R0/B0;        % R0归一化ion thermal radius
rho_e_axis   = 2.38*(te_axis^0.5)/R0/B0;        %R0归一化 electronon thermal radius

V_i_axis  = 9.79*10^5./(aion^0.5)*ti_axis^(0.5);%ion thermal velocity,cm/s
V_e_axis  = 4.19*10^7*te_axis^(0.5);            %electron thermal velocity,cm/s
C_si_axis = 9.79*10^5./(aion^0.5)*te_axis^(0.5);%ion sound velocity,cm/s   R0/Cs中的Cs
C_sp_axis = 9.79*10^5.*ti_axis^(0.5);           %proton sound velocity,cm/s
V_Ai_axis = 2.18*10^11/(aion*ni_axis)^(0.5)*B0; %v_Ai is ions Alfven speed,cm/s
V_Ap_axis = 2.18*10^11/(ni_axis)^(0.5)*B0;      %v_Ap is proton Alfven speed,cm/s

tstep_unit_axis     = 1*R0/C_si_axis;           %理论计算的  1R0/Cs  R0/Cs中的Cs使用磁轴处计算
tstep_gtc_axis      = tstep_gtc_second/dt0;     %读取gtc中   1R0/Cs  dt0 is gtc.in中输入 1R0/Cs
tstep_alfven_axis   = 1*R0/V_Ai_axis;           %1个阿尔芬时间
omega_alfven_axis   = 1*V_Ai_axis/R0;           %磁轴处计算的阿尔芬频率
frequency_gtc_axis  = 1/tstep_gtc_axis;         %读取gtc中  1Cs/R0对应的 in gtc unit rad/s 
frequency_unit_axis = 1/tstep_unit_axis;        %理论计算的 1Cs/R0对应的 unit rad/s
tstep_ref_ES_EM     = C_si_axis/V_Ai_axis;      %电磁模拟/静电模拟 tstep时间设置R0/Cs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%other time
Cyclotron_frequency = 9.58*10^3*Z_mp/aion*B0;   %回旋频率 rad/s
T_Cyclotron         = 2*pi/Cyclotron_frequency ;%回旋周期 s
Spitzer_resistivity = ( pi*qe^2*sqrt(m_e)/(4*pi*epsion0)^2/(KB_J_per_K*eV_to_K)^(3/2) )*10/(ti_axis)^(3/2);
T_Resistive         = (R0*a_minor/100)^2/Spitzer_resistivity*mu0;          %Resistive diffusion time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if fload>0
    nfi_axis = nfi_axis_norm*ne_axis;
    tfi_axis = tfi_axis_norm*te_axis;
    nfi_iflux = nfi_iflux_ne_axis*ne_axis;    % on-iflux fast ions density, unit=cm^-3
    tfi_iflux = tfi_iflux_te_axis*te_axis;    % on-iflux fast ions tempreture, unit=ev
    Tfi_eqflux  =  profile_gtcout2(eq_flux-1:eq_flux+1,7);
    Nfi_eqflux  =  profile_gtcout2(eq_flux-1:eq_flux+1,10)*eden0*1e6;
    r_eqflux    =  profile_gtcout2(eq_flux-1:eq_flux+1,2)*R0/100;
    Pfi_eqflux  = (Nfi_eqflux.*Tfi_eqflux )*KB_J_per_K*eV_to_K;
    beta_fi_eqflux  = 2*mu0/(B0/10000)^2*Pfi_eqflux;
    dbetadr_fi_eqflux = ( (beta_fi_eqflux(3)-beta_fi_eqflux(2))./(r_eqflux(3)-r_eqflux(2))+...
        (beta_fi_eqflux(2)-beta_fi_eqflux(1))./(r_eqflux(2)-r_eqflux(1)) )*0.5;
    % dbetadr_fi_eqflux= 2*mu0/(B0/(1+epsilon_r_R))^2*dpdr_fi_eqflux;%epsilon_r_R = q_eq_flux(1,2)*a_minor;
    alpha_fi   = -dbetadr_fi_eqflux*q_eq_flux(1,4).^2*R0/100;
end
% if fload==0
%     nfi_axis = nfi_axis_norm;
%     tfi_axis = tfi_axis_norm;
%     nfi_axis_norm = nfi_axis/ne_axis;   
%     tfi_axis_norm = tfi_axis/te_axis;
% end

%% 诊断磁面处eq_flux处的信息
epsilon_r_R = q_eq_flux(1,2)*a_minor;
% te_axis = etemp0/te_iflux_te_axis;         %iload=1解析位形的例如CBC下这样设置，其余正常
% ne_axis = eden0;                           %iload=1 去除inorm的归一化的影响
ti_iflux = ti_iflux_te_axis*te_axis;         % on-iflux ion temperature, unit=ev
te_iflux = te_iflux_te_axis*te_axis;         % on-iflux electron temperature, unit=ev
ne_iflux = ne_iflux_ne_axis*ne_axis;         % on-iflux ion density, unit=cm^-3
ni_iflux = ne_iflux;                         % on-iflux electron density, unit=cm^-3

rho_i   = 1.02*10^2*(aion^0.5)/Z_mp*(ti_iflux^0.5)/R0/B0;   % R0归一化 ion thermal radius
rho_e   = 2.38*(te_iflux^0.5)/R0/B0;                        % R0归一化 electronon thermal radius
V_i_iflux  = 9.79*10^5./(aion^0.5)*ti_iflux^(0.5);          %ion thermal velocity,cm/s
C_si_iflux = 9.79*10^5./(aion^0.5)*te_iflux^(0.5);          %ion sound velocity,cm/s       R0/Cs中的Cs 使用eq_flux处的温度
C_sp_iflux = 9.79*10^5.*te_iflux^(0.5);                     %proton sound velocity,cm/s    etemp_iflux=etemp0
V_e_iflux  = 4.19*10^7*te_iflux^(0.5);                      %electron thermal velocity,cm/s
% V_Ai_iflux = 2.18*10^11/(aion*ni_iflux)^(0.5)*( B0/(1+epsilon_r_R) );    %v_A is ions Alfven speed,cm/s
% V_Ap_iflux = 2.18*10^11/(ni_iflux)^(0.5)*( B0/(1+epsilon_r_R) );         %v_Ap is proton Alfven speed,cm/s
V_Ai_iflux = 2.18*10^11/(aion*ni_iflux)^(0.5)*( B0 );       %v_A is ions Alfven speed,cm/s
V_Ap_iflux = 2.18*10^11/(ni_iflux)^(0.5)*( B0 );            %v_Ap is proton Alfven speed,cm/s
omega_alfven_iflux   = V_Ai_iflux/R0;                       %诊断位置处的阿尔芬频率
tstep_unit_iflux     = 1*R0/C_si_iflux;                     % 1R0/Cs使用eq_flux处的温度  R0/Cs中的Cs
% tstep_ref_iflux   = C_si_iflux/V_Ai_iflux;                %电磁模拟/静电模拟 tstep时间设置R0/Cs

%% 诊断磁面处eq_flux处的信息 抗磁漂移频率等参数
%psi0-psi1区域的数据来观察
%profile_gtcout1作为整个的文件保存住 横坐标不一样，插值处理
% i,  rg/a,  psi/ped,   q,   rg_sp/rg - 1,  dtorpsi/q
% profile_gtcout2作为整个的文件保存住
% i  r   psipol  psitor  meshte  meshti  meshtf  meshne  meshni meshnf
Ti_eqflux  =  profile_gtcout2(eq_flux-1:eq_flux+1,6);
Te_eqflux  =  profile_gtcout2(eq_flux-1:eq_flux+1,5);
Ni_eqflux  =  profile_gtcout2(eq_flux-1:eq_flux+1,9)*eden0*1e6;
r_eqflux   =  profile_gtcout2(eq_flux-1:eq_flux+1,2)*R0/100;
Ne_eqflux  =  profile_gtcout2(eq_flux-1:eq_flux+1,8)*eden0*1e6;
Pe_eqflux  = (Ne_eqflux.*Te_eqflux )*KB_J_per_K*eV_to_K;
Pi_eqflux  = (Ni_eqflux.*Ti_eqflux )*KB_J_per_K*eV_to_K;
P_eqflux   = Pe_eqflux + Pi_eqflux ;
% P_eqflux   = Pe_eqflux+Pi_eqflux+Pfi_eqflux;
beta_ie_eqflux    = 2*mu0/(B0/10000)^2*P_eqflux;
beta_e_eqflux     = 2*mu0/(B0/10000)^2*Pe_eqflux;
dpdr_ie_eqflux    = ( (P_eqflux(3)-P_eqflux(2))./(r_eqflux(3)-r_eqflux(2))+...
                    (P_eqflux(2)-P_eqflux(1))./(r_eqflux(2)-r_eqflux(1)) )*0.5;

dnedr_eqflux    = ( (Ne_eqflux(3)-Ne_eqflux(2))./(r_eqflux(3)-r_eqflux(2))+...
                    (Ne_eqflux(2)-Ne_eqflux(1))./(r_eqflux(2)-r_eqflux(1)) )*0.5;
dnidr_eqflux    = ( (Ni_eqflux(3)-Ni_eqflux(2))./(r_eqflux(3)-r_eqflux(2))+...
                    (Ni_eqflux(2)-Ni_eqflux(1))./(r_eqflux(2)-r_eqflux(1)) )*0.5;

dbetadr_ie_eqflux = ( (beta_ie_eqflux(3)-beta_ie_eqflux(2))./(r_eqflux(3)-r_eqflux(2))+...
                    (beta_ie_eqflux(2)-beta_ie_eqflux(1))./(r_eqflux(2)-r_eqflux(1)) )*0.5;

alpha_ie          = -dbetadr_ie_eqflux*q_eq_flux(1,4).^2*R0/100;

%%%% 抗磁漂移频率 -k_theta*(1/(q*B0))*dlog(n_s)/dr*T_s, below should be times toroidal number
% here utime is time unit in gtc, that is the inverse proton cyclotron frequency unit 1/(rad/s)
omega_Dia_dpdr    = -q_eq_flux(1,4)/r_eqflux(2)*utime/m_p/(Ni_eqflux(2))*dpdr_ie_eqflux;                               %units rad/s
omega_Dia_dnedr   = -q_eq_flux(1,4)/r_eqflux(2)*utime/m_p/(Ne_eqflux(2))*Te_eqflux(2)*dnedr_eqflux*KB_J_per_K*eV_to_K; %units rad/s
omega_Dia_dnidr   = -q_eq_flux(1,4)/r_eqflux(2)*utime/m_p/(Ni_eqflux(2))*Ti_eqflux(2)*dnidr_eqflux*KB_J_per_K*eV_to_K; %units rad/s

omega_Dia_dpdr_unit_axis  = omega_Dia_dpdr*tstep_unit_axis;         % units Cs/R0
omega_Dia_dnedr_unit_axis = omega_Dia_dnedr*tstep_unit_axis;        % units Cs/R0
omega_Dia_dnidr_unit_axis = omega_Dia_dnidr*tstep_unit_axis;        % units Cs/R0

%% 输运系数中的归一化单位问题 SI
normal_chi       = (R0/100)*(R0/100)/utime;      
% convert_to_SI = rho0_norm*rho0_norm*normal_chi;
chi_to_SI        = rho0*rho0*normal_chi;         % (m^2/s)
chi_to_Bohm      = te_axis/(B0/10000);           %Bohm unit
%chi_to_Bohm      = KB_J_per_K*te_axis*eV_to_K/(qe*B0/10000);       %Bohm unit
chi_to_gyroBohm   = rho0/a_minor*chi_to_Bohm;    %gyro-Bohm unit
% chi_to_gyroBohm1  = rho0/(1/9)*chi_to_Bohm;    %gyro-Bohm unit
