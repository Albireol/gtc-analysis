% cal_omega, unit=C_s/R_0, run this when use history.m
% plot at panel subplot(223) for mode 1-8
% 修正之后的频率需要omegamode/rho_i
% 对应源代码中omegamode/rho0此时单位是 unit=R_0/c_s

subplot(236);
% auto_fft=4;     % 1直接对数据傅里叶变换 2线性增长阶段对数据进行傅里叶变换
if(auto_fft==1) % this may wrong when signal periodicity is not well
    %这里时间是从第二个时刻开始 Nmode是偶数
    if mod(length(t),2)==0
        yymode = yr+1i*yi;
        ttmode = t;
    else
        %         yymode = [0;yr+1i*yi];
        %         ttmode = [0,t];
        yymode = yr(1:end-1)+1i*yi(1:end-1);
        ttmode = t(1,1:end-1);
    end
    amode  = ttmode(1);
    % amode  = 0
    bmode  = ttmode(end);
    Nmode  = length(ttmode);
    Tmode  = (bmode-amode)/Nmode;         %采样周期
    t_f  = [2*pi/Tmode/Nmode*([0:Nmode/2 -Nmode/2+1:-1])]';
    t_f1 = [t_f(Nmode/2+2:end);t_f(1:Nmode/2+1)];
    yymode_fft  = Tmode*exp(-1i.*t_f*amode).*fft(yymode);
    yymode_fft1 = [yymode_fft(Nmode/2+2:end);yymode_fft(1:Nmode/2+1)];
    [yymodemax,omegamax] = max(yymode_fft1);
    omega_fft       = t_f1(omegamax);
    omega_mode_fft  = omega_fft*frequency_gtc_axis
    stem(t_f1,abs(yymode_fft1),'-','Linewidth',2)
    xlim([-5 5]*abs(omega_fft));
    xlabel('$\omega$','Interpreter','latex','fontsize',16);
    ylabel('amplitude','Interpreter','latex','fontsize',16);
    title(['$\omega=$',num2str(omega_fft)],'Interpreter','latex','fontsize',16);
    grid on
elseif(auto_fft==2)

    it0 = ind1;it1 = ind2; %来自计算gamma的文件

    yti=yi(it0:it1)./exp(gamma*(t(it0:it1))');
    ytr=yr(it0:it1)./exp(gamma*(t(it0:it1))');

    yymode = ytr+1i*yti;
    ttmode = t(it0:it1);
    amode  = ttmode(1);
    % amode  = 0
    bmode  = ttmode(end);
    Nmode  = length(ttmode);              %必须是偶数
    Tmode  = (bmode-amode)/Nmode;         %采样周期
    t_f  = [2*pi/Tmode/Nmode*([0:Nmode/2 -Nmode/2+1:-1])]';
    t_f1 = [t_f(Nmode/2+2:end);t_f(1:Nmode/2+1)];
    yymode_fft  = Tmode*exp(-1i.*t_f*amode).*fft(yymode);
    yymode_fft1 = [yymode_fft(Nmode/2+2:end);yymode_fft(1:Nmode/2+1)];
    [yymodemax,omegamax] = max(yymode_fft1);
    omega_fft       = t_f1(omegamax);
    omega_mode_fft  = omega_fft*frequency_gtc_axis
    stem(t_f1,abs(yymode_fft1),'-','Linewidth',2)
    xlim([-5 5]*abs(omega_fft));
    xlabel('$\omega$','Interpreter','latex','fontsize',16);
    ylabel('amplitude','Interpreter','latex','fontsize',16);
    title(['$\omega=$',num2str(omega_fft)],'Interpreter','latex','fontsize',16);
    grid on
elseif(auto_fft==3)
    yymode = yr+1i*yi;
    ttmode = t;
    amode  = ttmode(1);
    % amode  = 0
    bmode  = ttmode(end);
    Nmode  = length(ttmode);
    Tmode  = ttmode(2)-ttmode(1);                   %采样周期
    %     Tmode  = (bmode-amode)/Nmode;             %采样周期
    t_f1 = [2*pi/Tmode/Nmode*floor(-(Nmode-1)/2:(Nmode-1)/2)]';  % 乃奎斯特频率下标
    %     t_f2 = t_f1*Tmode/tstep_ndiag/rho0;
    yymode_fft1  = Tmode*exp(-1i.*t_f1*amode).*fftshift(fft(yymode));
    [yymodemax,omegamax] = max(abs(yymode_fft1));
    omega_fft       = t_f1(omegamax);
    omega_mode_fft  = omega_fft*frequency_gtc_axis
    stem(t_f1,abs(yymode_fft1),'-','Linewidth',2)
    if omega_fft~=0
        xlim([-5 5]*abs(omega_fft));
    end
    xlabel('$\omega$','Interpreter','latex','fontsize',16);
    ylabel('amplitude','Interpreter','latex','fontsize',16);
    title(['$\omega=$',num2str(omega_fft)],'Interpreter','latex','fontsize',16);
    grid on

elseif(auto_fft==4)

    it0 = ind1;it1 = ind2; %来自计算gamma的文件
    yti=yi(it0:it1)./exp(gamma*(t(it0:it1))');
    ytr=yr(it0:it1)./exp(gamma*(t(it0:it1))');

    yymode = ytr+1i*yti;
    ttmode = t(it0:it1);
    amode  = ttmode(1);

    % amode  = 0
    bmode  = ttmode(end);
    Nmode  = length(ttmode);
    Tmode  = ttmode(2)-ttmode(1);             %采样周期
    t_f1   = [2*pi/Tmode/Nmode*floor(-(Nmode-1)/2:(Nmode-1)/2)]';  % 乃奎斯特频率下标
    yymode_fft1  = Tmode*exp(-1i.*t_f1*amode).*fftshift(fft(yymode));
    %     yymode_fft1  = Tmode*fftshift(fft(yymode));
    %     [yymodemax,omegamax] = max(abs(yymode_fft1));
    [yymodemax,omegamax] = max(abs(yymode_fft1));
    omega_fft      = t_f1(omegamax);
    omega_mode_fft = omega_fft*frequency_gtc_axis
    stem(t_f1,abs(yymode_fft1),'-','Linewidth',2)
    if omega_fft~=0
        xlim([-5 5]*abs(omega_fft));
    end
    xlabel('$\omega$','Interpreter','latex','fontsize',16);
    ylabel('amplitude','Interpreter','latex','fontsize',16);
    title(['$\omega=$',num2str(omega_fft)],'Interpreter','latex','fontsize',16);
    grid on

else

    disp('Wrong in omega_fft')

end




