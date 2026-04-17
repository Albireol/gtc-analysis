% 计算固定住mpsi的对极向做FFT得到峰值最大m
% 这里mpsi可以任取一些位置而不总是diag_flux的位置
% mtgrid=mtheta(diag_flux)
% fluxdata(极向theta,环向toroidal,场)
% poloidata(极向theta,径向mpsi,场)
% allocate(poloidata(0:mtgrid,0:mpsi,nfield+2),fluxdata(0:mtgrid,mtoroidal,nfield),&
% eachflux(mtgrid),allflux(mtgrid,mtoroidal), STAT=mstat)
% call check_allocation(mstat, "poloidata in snapshot.F90")
% poloidata=0.0_lk
% fluxdata=0.0_lk
% field_number field quantities: phi, a_para, fluidne.
% Last two coloumn of poloidal for coordinates
% N is an integer giving the number of elements in a particular dimension
% T is a floating-point number giving the sampling interval
% X = FINDGEN((N - 1)/2) + 1
% is_N_even = (N MOD 2) EQ 0
% if (is_N_even) then $
%   freq = [0.0, X, N/2, -N/2 + X]/(N*T) $
% else $
%   freq = [0.0, X, -(N/2 + 1) + X]/(N*T)
% ! potential data on poloidal plain uses polar coordinates
%      do j=0,mtgrid
%         tdum=pi2*real(j)/real(mtgrid)
%         do i=0,mpsi
%            if(fielddir==1 .or. fielddir==3)then
%              jt=max(0,min(mtheta(i),1+int(modulo(tdum+pi2*qtinv(i),pi2)/deltat(i))))
%              wt=modulo(tdum+pi2*qtinv(i),pi2)/deltat(i)-real(jt-1)
%            else
%              jt=max(0,min(mtheta(i),1+int(tdum/deltat(i))))
%              wt=tdum/deltat(i)-real(jt-1)
%            endif
%            poloidata(j,i,nf)=(wt*dfield(igrid(i)+jt)+(1.0-wt)*dfield(igrid(i)+jt-1)) !/rho0**2
%            if(nf==1)then
%               poloidata(j,i,nf)=poloidata(j,i,nf)/(rho0*rho0)
%            elseif(nf==2)then
% ! apara is renormalized in such a way that it has the same
% ! amplitude as phi in ideal shear Alfven waves
% #ifndef _FRC
%               poloidata(j,i,nf)=poloidata(j,i,nf)/(rho0*sqrt(betae*aion))
% #endif
% ! no need to renormalize fluidne
% ! renormalize non-adiabatic delta_apara in conservative scheme
%            elseif(nf==3 .and. cs_method==1)then
%               poloidata(j,i,nf)=poloidata(j,i,nf)/(rho0*sqrt(betae*aion))
%            endif
%         enddo
%      enddo
%%  直接对数据傅里叶变换 得到二维数组phi(m,psip)
% 这里时间是从第二个时刻开始  先处理数据
field_number = 1;
mpsi_iflux = [1:mpsi-1];
yym_poloidata0 = poloidata(:,:,field_number);
yym_rms = sqrt(sum(yym_poloidata0.^2)/mtgrid);
[yym_rms_max,mpsi_rms_max] = max(yym_rms(2:end-1));
figure(1773)
subplot(212)
plot(profile_gtcout1(mpsi_iflux,2),yym_rms(2:end-1),'Linewidth',2)
legend_str00 = ['$r/a=$',num2str(profile_gtcout1(mpsi_rms_max,2))];
xlabel('$r/a$','interpreter','latex','fontsize',16);
% ylabel('$$\sqrt{\left \langle \delta{\phi}^2 \right \rangle}$$','Interpreter','latex','fontsize',16);
% ylabel('$(a.u.)$','Interpreter','latex','fontsize',16);
title('$\delta\phi_{rms}$','Interpreter','latex','fontsize',16);
grid on
legend(legend_str00,'Interpreter','latex','fontsize',16);
subplot(211)
plot(profile_gtcout1(mpsi_iflux,2),yym_poloidata0(1,2:end-1),'Linewidth',2)
% legend_str00 = ['$fixed \theta$'];
xlabel('$r/a$','interpreter','latex','fontsize',16);
% ylabel('$$\delta{\phi}$$','Interpreter','latex','fontsize',16);
% ylabel('$(a.u.)$','Interpreter','latex','fontsize',16);
title('$\delta\phi(r,\theta=0,\zeta=0)$','Interpreter','latex','fontsize',16);
grid on
% legend(legend_str00,'Interpreter','latex','fontsize',16);
%% 两种傅里叶变换 auto=1是自编,auto=2是idl中操作auto=3是取实部或者虚部
theta_maxmode_m = [];yymode_fft_max = [];
yymode_fft_thetam=[];
% 直接对数据傅里叶变换 横坐标不作设置 Nmode是偶数
if mod(mtgrid,2)==0
    yym_poloidata = yym_poloidata0(2:end,:);
else
    yym_poloidata = yym_poloidata0 ;
end
auto = 4;
m_theta = linspace(0,2*pi,length(yym_poloidata(:,1)));
% m_theta_interp = linspace(0,2*pi,length(m_theta)*4);
for mpsi_fft = mpsi_iflux
    yym_theta_m0 = yym_poloidata(:,mpsi_fft+1);
    %插值处理数据 得到2^N的数据
    yym_theta_m  = yym_theta_m0;
    %     yym_theta_m = (interp1(m_theta,yym_theta_m0,m_theta_interp,'spline'))';
    switch auto
        case 1
            mmode_theta  = length(yym_theta_m);
            Tmode  = 2*pi/mmode_theta;         %采样周期
            t_f  = [([0:mmode_theta/2 -mmode_theta/2+1:-1])]';
            t_f1 = [t_f(mmode_theta/2+2:end);t_f(1:mmode_theta/2+1)];
            yymode_fft  = Tmode.*fft(yym_theta_m);
            yymode_fft1 = [yymode_fft(mmode_theta/2+2:end);yymode_fft(1:mmode_theta/2+1)];
            yymode_fft_thetam = [yymode_fft_thetam,abs(yymode_fft1)]; % 取模长
            [yymodemax,thetamax] = max(abs(yymode_fft1));
            theta_maxmode_m = [theta_maxmode_m,t_f1(thetamax)];
            yymode_fft_max = [yymode_fft_max,yymodemax];
        case 2
            t_f1=(0:mtgrid-1)';yymode_fft=t_f1.*0;
            y0=fft(yym_theta_m);
            yymode_fft(1)=yymode_fft(1)+(abs(y0(1)))^2;
            for ii=2:length(t_f1)
                yymode_fft(ii)=yymode_fft(ii)+(abs(y0(ii)))^2+(abs(y0(mtgrid+2-ii)))^2;
            end
            yymode_fft1=sqrt(yymode_fft/mtoroidal)/mtgrid;
            yymode_fft_thetam = [yymode_fft_thetam,abs(yymode_fft1)]; % 取模长
            [yymodemax,thetamax] = max(abs(yymode_fft1));
            theta_maxmode_m = [theta_maxmode_m,t_f1(thetamax)];
            yymode_fft_max = [yymode_fft_max,yymodemax];
        case 3
            mmode_theta  = length(yym_theta_m);
            Tmode  = 2*pi/mmode_theta;         %采样周期
            t_f  = [([0:mmode_theta/2 -mmode_theta/2+1:-1])]';
            t_f1 = [t_f(mmode_theta/2+2:end);t_f(1:mmode_theta/2+1)];
            yymode_fft  = Tmode.*fft(yym_theta_m);
            yymode_fft1 = [yymode_fft(mmode_theta/2+2:end);yymode_fft(1:mmode_theta/2+1)];
            yymode_fft_thetam = [yymode_fft_thetam,real(yymode_fft1)]; % 有平板的ITG取实部
            [yymodemax,thetamax] = max(abs(real(yymode_fft1)));
            %     yymode_fft_thetam=[yymode_fft_thetam,abs(yymode_fft1)];  % CBC的case取模长
            %     yymode_fft_thetam=[yymode_fft_thetam,imag(yymode_fft1)]; % 取虚部
            %     [yymodemax,thetamax] = max(abs(yymode_fft1));
            theta_maxmode_m = [theta_maxmode_m,t_f1(thetamax)];
            yymode_fft_max = [yymode_fft_max,abs(yymodemax)];
        case 4
            mmode_theta  = length(yym_theta_m);
            t_f1 = floor(-(mmode_theta-1)/2:(mmode_theta-1)/2);  % 乃奎斯特频率下标
            Tmode  = 2*pi/mmode_theta;                           % 采样周期
            k_theta = Tmode.*t_f1;
            yymode_fft1=Tmode*fftshift(fft(yym_theta_m));        % 求x的FFT，移到对称位置
%             yymode_fft_thetam = [yymode_fft_thetam,abs(yymode_fft1)]; % 取模长
%             [yymodemax,thetamax] = max(abs(yymode_fft1));
            yymode_fft_thetam = [yymode_fft_thetam,real(yymode_fft1)]; % 有ITG取实部
            [yymodemax,thetamax] = max(abs(real(yymode_fft1)));
            theta_maxmode_m = [theta_maxmode_m,t_f1(thetamax)];
            yymode_fft_max = [yymode_fft_max,yymodemax];           
    end
    
end
%% 绘制挑选几个m的phi的径向分布
figure(17)
% subplot(2,2,4)
% 直接对数据傅里叶变换 横坐标不作设置
[yymode_mpsimax,mpsimax] = max(yymode_fft_max);
% m_mpsimax = theta_maxmode_m(mpsimax);     %最大的yymode_fft_max位置处的m
m_mpsimax = theta_maxmode_m(mpsi_rms_max);  %方均根值最大的位置处的m
% diag_m = [m_mpsimax,m_mpsimax+[-3,-2,-1,1,2,3]]; %设置5个点较为合适 
% diag_m = [m_mpsimax,0,2:7 ]; %设置5个点较为合适
%diag_m = mmodes(1:7); %设置5个点较为合适
 diag_m = m_mpsimax+[-3:1:3]; %设置5个点较为合适 曲线区分度明显
for jj = 1:length(diag_m)
    m_theta_index = find(t_f1==diag_m(jj));
    %     plot(mpsi_theta_mode,yymode_fft_max(mpsi_theta_mode),'-.','Linewidth',2)
    plot(mpsi_iflux,yymode_fft_thetam(m_theta_index,:),'-','Linewidth',2)
    hold on
    legend_str{jj} = num2str(abs(diag_m(jj)));
end
xlabel('$mpsi$','Interpreter','latex','fontsize',16);
ylabel('$Amplitude$','Interpreter','latex','fontsize',16);
title('$\delta\widetilde{\phi}_m(\psi_p)$','Interpreter','latex','fontsize',16);
grid on
legend(legend_str)
%% 使用归一化的坐标 绘制上图
figure(177)
% subplot(2,2,2)
% 直接对数据傅里叶变换 横坐标不作设置
for jj = 1:length(diag_m)
    m_theta_index = find(t_f1==diag_m(jj));
    %     plot(mpsi_theta_mode,yymode_fft_max(mpsi_theta_mode),'-.','Linewidth',2)
    plot(profile_gtcout1(mpsi_iflux,3),yymode_fft_thetam(m_theta_index,:),'-','Linewidth',2)
    hold on
    legend_str1{jj} = num2str(abs(diag_m(jj)));
end
xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
ylabel('$Amplitude$','Interpreter','latex','fontsize',16);
title('$\delta\widetilde{\phi}_m(\psi_p)$','Interpreter','latex','fontsize',16);
grid on
legend(legend_str1)
figure(178)
% subplot(2,2,3)
% 直接对数据傅里叶变换 横坐标不作设置
[yymode_mpsimax,mpsimax] = max(yymode_fft_max);
m_mpsimax =theta_maxmode_m(mpsimax);
for jj = 1:length(diag_m)
    m_theta_index = find(t_f1==diag_m(jj));
    %     plot(mpsi_theta_mode,yymode_fft_max(mpsi_theta_mode),'-.','Linewidth',2)
    plot(profile_gtcout1(mpsi_iflux,2),yymode_fft_thetam(m_theta_index,:),'-','Linewidth',2)
    hold on
    legend_str2{jj} = num2str(abs(diag_m(jj)));
end
xlabel('$r/a$','interpreter','latex','fontsize',16);
ylabel('$Amplitude$','Interpreter','latex','fontsize',16);
title('$\delta\widetilde{\phi}_m(r)$','Interpreter','latex','fontsize',16);
grid on
legend(legend_str2)
%% 多个径向位置mpsi叠加在一张图上
% subplot(2,2,1)
figure(179)
mpsi_diag = [eq_flux,diag_flux,mpsi_rms_max,mpsimax];
for jj = 1:length(mpsi_diag)
    mpsi_fft  = mpsi_diag(jj);
    yym_theta0 = yym_poloidata(:,mpsi_fft+1);
    mmode_theta  = length(yym_theta0);
    Tmode  = 2*pi/mmode_theta;         %采样周期
    t_f  = [([0:mmode_theta/2 -mmode_theta/2+1:-1])]';
    t_f2 = [t_f(mmode_theta/2+2:end);t_f(1:mmode_theta/2+1)];
    yymode_fft  = Tmode.*fft(yym_theta0);
%     yymode_fft  = yymode_fft_thetam(:,mpsi_fft);
    yymode_fft1 = [yymode_fft(mmode_theta/2+2:end);yymode_fft(1:mmode_theta/2+1)];
    [yymodemax,thetamax0] = max(abs(real(yymode_fft1)));
    theta_mode0 = abs(t_f2(thetamax0));
    plot(t_f2,abs(yymode_fft1),'-','Linewidth',2)
    legend_str0{jj} = ['$mpsi=$',num2str(mpsi_fft),',$r/a=$',num2str(profile_gtcout1(mpsi_fft,2)),',$m=$',num2str(theta_mode0)];
    hold on
end
% xlim([0 round(max(t_f1)/5)])
xlim([0 round(max(t_f1))])
xlabel('$m$','Interpreter','latex','fontsize',16);
ylabel('$Amplitude$','Interpreter','latex','fontsize',16);
title(['poloidal spectra ','$ \delta\widetilde{\phi}_m(r)$'],'Interpreter','latex','fontsize',16);
legend(legend_str0,'Interpreter','latex','fontsize',16);
grid on
%% 直接得到一个m随mpsi变化的频谱分解
figure(1770)
subplot(2,2,1)
stem(mpsi_iflux,abs(theta_maxmode_m))
xlabel('$mpsi$','Interpreter','latex','fontsize',16);
ylabel('$m$','Interpreter','latex','fontsize',16);
title(['$m(\delta\widetilde{\phi}_{max},\psi_p)$',' diag flux = ',num2str(diag_flux)],'Interpreter','latex','fontsize',16);
grid on
subplot(2,2,3)
stem(mpsi_iflux,yymode_fft_max)
[yymode_fft1_max,max_iflux] = max(abs(yymode_fft_max));
xlabel('$mpsi$','Interpreter','latex','fontsize',16);
ylabel('$Amplitude$','Interpreter','latex','fontsize',16);
% title(['$ \delta \phi_{m}(\psi_p)$',' max mpsi = ',num2str(mpsi_iflux(max_iflux))],'Interpreter','latex','fontsize',16);
title(['$\delta\widetilde{\phi}_{max}(\psi_p)$',' max mpsi = ',num2str(mpsi_iflux(max_iflux))],'Interpreter','latex','fontsize',16);
grid on
subplot(2,2,2)
plot(mpsi_iflux,profile_gtcout1(mpsi_iflux,3),'-','Linewidth',2)
hold on
plot(mpsi_diag,profile_gtcout1(mpsi_diag,3),'o','Linewidth',1.5)
xlabel('$mpsi$','Interpreter','latex','fontsize',16);
ylabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
grid on
subplot(2,2,4)
plot(mpsi_iflux,profile_gtcout1(mpsi_iflux,2),'-','Linewidth',2)
hold on
plot(mpsi_diag,profile_gtcout1(mpsi_diag,2),'o','Linewidth',1.5)
xlabel('$mpsi$','Interpreter','latex','fontsize',16);
ylabel('$r/a$','interpreter','latex','fontsize',16);
grid on
%% 汇总成为二维的contour图以及三维成像的坐标m,或者ktheta，径向位置r/a
%Z坐标是phi的傅里叶变换后的幅值
% 三维mesh图
% run setpath;
% run read_para.m
% dt=dt0*ndiag;  
% t=(nstart:nend)*dt;
% profile_gtcout1(m0:m1,2)
ktheta_m0 = find(t_f1==0);
ktheta_m1 = ktheta_m0+floor(0.075*length(t_f1));%这里是从m>0的取值，取到的是m数组对应的下标
% ktheta_m1 = length(t_f1);
ktheta_m = t_f1(ktheta_m0:ktheta_m1); %这里是取m数组中的部分值
% ktheta_m = t_f1(ktheta_m0:ktheta_m1)./(q_diag_flux(1,2)*a_minor*R0/100); %实际上是ktheta
Y_ktheta = [];
X_r0 = profile_gtcout1(:,2);
for ii = 1:length(X_r0)
    %ktheta_temp = ktheta_m/(X_r0(ii)*a_minor*R0/100);%实际上是ktheta=m/r 单位是m
    ktheta_temp = ktheta_m/(X_r0(ii)*a_minor*R0/100)*rho_i_axis*R0/100;%实际上是ktheta*rho_i  
    Y_ktheta = [Y_ktheta,ktheta_temp'];
end
%%%另一种方式计算ktheta=m/r=nq/r
% Y_ktheta1 = profile_gtcout1(:,6)./(profile_gtcout1(:,2)*a_minor*R0/100);

figure(1771)
[X_r,Y_ktheta_m] = meshgrid(profile_gtcout1(:,2),ktheta_m);
mesh(X_r,Y_ktheta,yymode_fft_thetam(ktheta_m0:ktheta_m1,:));
colorbar;
% set(h,'linecolor','none');
set(gca,'fontsize',16,'linewidth',1.5);
grid on
xlabel('$r/a$','interpreter','latex','fontsize',16)
% xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
% ylabel('$m$','interpreter','latex','fontsize',16)
%ylabel('$k_\theta [m^{-1}]$','interpreter','latex','fontsize',16)
ylabel('$k_\theta \rho_i$','interpreter','latex','fontsize',16)
title('$\delta\widetilde{\phi}$','Interpreter','latex','fontsize',16);
%% 二维contour图
figure(1772)
[C,h]=contourf(X_r,Y_ktheta,yymode_fft_thetam(ktheta_m0:ktheta_m1,:),100);
hold on;colormap('jet')
set(h,'linecolor','none');
% set(gca,'dataaspectratio',[1,1,1]);
colorbar;
set(gca,'fontsize',16,'linewidth',2);
xlabel('$r/a$','interpreter','latex','fontsize',16)
% xlabel('$\hat{\psi}_p$','interpreter','latex','fontsize',16);
% ylabel('$m$','interpreter','latex','fontsize',16)
% ylabel('$k_\theta [m^{-1}]$','interpreter','latex','fontsize',16)
ylabel('$k_\theta \rho_i$','interpreter','latex','fontsize',16)
title('$\delta\widetilde{\phi}$','Interpreter','latex','fontsize',16);
% hold on
% plot(x(:,diag_flux),y(:,diag_flux),'--k','linewidth',1);
% hold on
% plot(x(:,q_min_flux),y(:,q_min_flux),'-.k','linewidth',1);
% plot(x(:,diag_flux),y(:,diag_flux),'--k','linewidth',1);
% title('$\phi$','interpreter','latex','fontsize',20)
% title('$\delta A_{||}$','interpreter','latex','fontsize',20)





