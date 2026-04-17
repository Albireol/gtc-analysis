%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Yuehao Ma, USTC, myh2020@mail.ustc.edu.cn
% GTC Data Processing GUI
% V4.6 for gtc4.6 version myh 20230323
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 将非线性模拟数据可视化
%%%%数据读取处理
clc,clear;close all
run history.m
nfield_type      = 1 ;                                    % 1 phi; 2 Apara; 3 fluidne
Trans.t          = t';                                    %时间
Trans.phi_rms    = fieldtime(:,4,nfield_type);            %扰动电势 Volume-averaged RMS
Trans.phip00_rms = fieldtime(:,3,nfield_type);            %扰动电势00分量方均根 zonal
Trans.D_i        = [];
Trans.chi_i      = [];
Trans.D_e        = [];
Trans.chi_e      = [];
Trans.D_f        = [];
Trans.chi_f      = [];
if ( ndims(partdata)==3 )
    if iload>0
        Trans.D_i        = partdata(:,7,1)*chi_to_SI;            %离子扩散系数
        Trans.chi_i      = partdata(:,9,1)*chi_to_SI;            %离子热导率
    end
    if nhybrid>0
        Trans.D_e        = partdata(:,7,2)*chi_to_SI;            %电子扩散系数
        Trans.chi_e      = partdata(:,9,2)*chi_to_SI;            %电子热导率
    end
    if fload>0
        if nhybrid>0
            Trans.D_f        = partdata(:,7,3)*chi_to_SI;            %快粒子扩散系数
            Trans.chi_f      = partdata(:,9,3)*chi_to_SI;            %快粒子热导率
        else
            Trans.D_f        = partdata(:,7,2)*chi_to_SI;            %快粒子扩散系数
            Trans.chi_f      = partdata(:,9,2)*chi_to_SI;            %快粒子热导率
        end
    end
else
    Trans.D_i        = partdata(:,7)*chi_to_SI;                  %离子扩散系数
    Trans.chi_i      = partdata(:,9)*chi_to_SI;                  %离子热导率
    Trans.D_e        = zeros(size(partdata(:,7)));               %电子扩散系数
    Trans.chi_e      = zeros(size(partdata(:,9)));               %电子热导率
end

%% 剔除异常数值
% 找到负数及其位置
if ( ndims(partdata)==3 )
    Trans.negative_indices = union(find(Trans.D_i < 0),find(Trans.chi_e < 0));
else
    Trans.negative_indices = find(Trans.D_i < 0);
end
Trans.t1 = t';
% 删除负数及其对应的横坐标
Trans.t1(Trans.negative_indices)    = [];
Trans.D_i(Trans.negative_indices)   = [];
Trans.D_e(Trans.negative_indices)   = [];
Trans.chi_i(Trans.negative_indices) = [];
Trans.chi_e(Trans.negative_indices) = [];
%% 非线性模拟输运系数等绘制捕获电子 zonal flow
% clc,clear,close all
figure(22)
subplot(211)
plot(Trans.t,Trans.phi_rms,'-','Linewidth',2);
% semilogy(Trans2.t,Trans2.phip00_rms,Trans3.t,Trans3.phip00_rms,'--','Linewidth',2);
xlabel('$t[R_0/C_s]$','Interpreter','latex','fontsize',16);
ylabel('$e\delta\phi/T_e$','Interpreter','latex','fontsize',16);
title('$\delta\phi_{rms}$','Interpreter','latex','fontsize',16);
% title('$zonal\,flow$','Interpreter','latex','fontsize',16);
% legend('zonal','w/o zonal ','interpreter','latex','fontsize',16)
% legend('TE on zonal','w/o TE on zonal ','interpreter','latex','fontsize',16)
grid on
subplot(212)
semilogy(Trans.t,Trans.phi_rms,'-','Linewidth',2);
xlabel('$t[R_0/C_s]$','Interpreter','latex','fontsize',16);
ylabel('$e\delta\phi/T_e$','Interpreter','latex','fontsize',16);
grid on
figure(23)
subplot(211)
plot(Trans.t,Trans.phip00_rms,'-','Linewidth',2);
% semilogy(Trans2.t,Trans2.phip00_rms,Trans3.t,Trans3.phip00_rms,'--','Linewidth',2);
xlabel('$t[R_0/C_s]$','Interpreter','latex','fontsize',16);
ylabel('$\partial \phi_{00}/\partial \psi$','Interpreter','latex','fontsize',16);
title('$zonal\;flow$','Interpreter','latex','fontsize',16);
% title('$zonal\,flow$','Interpreter','latex','fontsize',16);
% legend('zonal','w/o zonal ','interpreter','latex','fontsize',16)
% legend('TE on zonal','w/o TE on zonal ','interpreter','latex','fontsize',16)
grid on
subplot(212)
semilogy(Trans.t,Trans.phip00_rms,'-','Linewidth',2);
xlabel('$t[R_0/C_s]$','Interpreter','latex','fontsize',16);
ylabel('$\partial \phi_{00}/\partial \psi$','Interpreter','latex','fontsize',16);
% legend('zonal','w/o zonal ','interpreter','latex','fontsize',16)
% title('$zonal\,flow$','Interpreter','latex','fontsize',16);
% legend('TE on zonal','w/o TE on zonal ','interpreter','latex','fontsize',16)
grid on
figure(24)
% plot(Trans.t1,Trans.D_i/( sum(profile_gtcout3(:,9))/length(profile_gtcout3(:,9)) ),'-','Linewidth',2);
plot(Trans.t1,Trans.D_i,'-','Linewidth',2);
hold on
plot(Trans.t1,Trans.D_e,'--','Linewidth',2);
hold off
% hold on
% plot(Trans3.t,Trans3.D_i*chi_to_SI,'--',Trans3.t,Trans3.D_e*chi_to_SI,'--','Linewidth',2);
% hold on
% plot(Trans4.t,Trans4.D_i*chi_to_SI,':','Linewidth',2);
% hold on
% plot(Trans4.t,Trans4.D_e*chi_to_SI,':','Linewidth',2);
xlabel('$t[R_0/C_s]$','Interpreter','latex','fontsize',20);
ylabel('$$D \; [m^2/s]$$','Interpreter','latex','fontsize',20);
title('$D_i,D_e$','Interpreter','latex','fontsize',20);
legend('$D_i$','$D_e$','interpreter','latex','fontsize',12)
% legend('$D_i(zonal)$','$D_e(zonal)$','$D_i(w/o,zonal)$','$D_e(w/o,zonal)$',...
%    '$D_i(w/o,TE\, on \,zonal)$','$D_e(w/o,TE\, on \,zonal)$','interpreter','latex','fontsize',12)
% legend('$D_i(TE\, on\, zonal)$','$D_i(w/o,TE\, on \,zonal)$','$D_e(TE\, on\, zonal)$','$D_e(w/o,TE\, on \,zonal)$','interpreter','latex','fontsize',16)
grid on
figure(25)
plot(Trans.t1,Trans.chi_i,'-','Linewidth',2); %Trans.chi_i/( sum(profile_gtcout3(:,9))/length(profile_gtcout3(:,9)) )
hold on
plot(Trans.t1,Trans.chi_e,'--','Linewidth',2);
hold off
% hold on
% plot(Trans3.t,Trans3.chi_i*chi_to_SI,'--',Trans3.t,Trans3.chi_e*chi_to_SI,'--','Linewidth',2);
% hold on
% plot(Trans4.t,Trans4.chi_i*chi_to_SI,':','Linewidth',2);
% hold on
% plot(Trans4.t,Trans4.chi_e*chi_to_SI,':','Linewidth',2);
xlabel('$t[R_0/C_s]$','Interpreter','latex','fontsize',20);
ylabel('$$\chi \; [m^2/s]$$','Interpreter','latex','fontsize',20);
title('$\chi_i,\chi_e$','Interpreter','latex','fontsize',20);
legend('$\chi_i$','$\chi_e$', 'interpreter','latex','fontsize',12)
% legend('$\chi_i(zonal)$','$\chi_e(zonal)$','$\chi_i(w/o,zonal)$','$\chi_e(w/o,,zonal)$',...
%    '$\chi_i(w/o,TE\, on\, zonal)$','$\chi_e(w/o,TE\, on\, zonal)$', 'interpreter','latex','fontsize',12)
% legend('$\chi_i(TE\,on\, zonal)$','$\chi_i(w/o,TE\, on\, zonal)$','$\chi_e(TE\, on \,zonal)$','$\chi_e(w/o,TE\, on\, zonal)$','interpreter','latex','fontsize',16)
grid on
