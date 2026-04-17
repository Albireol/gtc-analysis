%% phi for n and m numbers at the diag_flux
clc,clear;close all
run history.m
imode_target_n = 25;                  % target n modes
imode_target_m = 25;                  % target m modes
nfield_type    = 1;                   % 1 phi; 2 Apara; 3 fluidne
% 保存图像在当前路径
save_images    = 1;
imode_matching = find(nmodes == imode_target_n & mmodes == imode_target_m);% 创建匹配索引
imode          = imode_matching(1);   % 出现重复值取第一个数据

yr     = fieldmode(:,1,imode,nfield_type);
yi     = fieldmode(:,2,imode,nfield_type);
% 打开一个新的图形窗口，并为其命名
fig = figure('Name', 'history for single n and m','NumberTitle','off','DefaultAxesFontSize',14);
%set(gcf, 'Color', 'w'); % 设置图形窗口背景颜色为白色
set(gcf, 'WindowState', 'maximized'); % 将图窗最大化
subplot(231)
plot(xtime,yr,'LineWidth',2);
hold on
plot(xtime,yi,'LineWidth',2);
hold off
title('history of real & imag components','fontsize',16);
legend('real component','imag component','Location', 'Best');
ylabel(['n=',num2str(nmodes(imode)), ',m=',num2str(mmodes(imode))]);
grid on
ya=sqrt(yr.^2+yi.^2);
subplot(234)
plot(xtime,log10(ya),'LineWidth',2)
title('amplitude history','fontsize',16);
run cal_gamma.m;
gamma0=log(ya(nend)/ya(nstart))/(nend-nstart);
nstart=1; % nstart=1;
nend=ntime;
xpow=(0:(nend-nstart))';
yr1=yr./exp(gamma0*xpow);
yi1=yi./exp(gamma0*xpow);
disp(['growth rate (IDL version) = ', num2str(gamma0/tstep_ndiag)]);
grid on; 
gca.GridAlpha = 0.3; % 确保网格线不透明
subplot(232);
plot(xtime,yr1,'LineWidth',2);
hold on
plot(xtime,yi1,'LineWidth',2);
hold off
grid on
title('amplitude normalized by growth rate','fontsize',16);
run cal_omega_simple.m;
run cal_omega_fft.m;
power=fft(yr1+1i*yi1);
ypow=abs(power);
xp = zeros(1,nfreq);
yp = zeros(1,nfreq);
for i=1:nfreq-1
    yp(i)=ypow(i+nend-nstart-nfreq+1);
    xp(i)=(i-nfreq+1)*2*pi/((nend-nstart)*tstep_ndiag);
end
for i=1:nfreq
    yp(nfreq-1+i)=ypow(i);
    xp(nfreq-1+i)=i*2*pi/((nend-nstart)*tstep_ndiag);
end
subplot(233);
plot(xp,yp,'LineWidth',2);
axis tight;
ylabel('power spectral');
title('phi=exp[-i(omega*t+m*theta-n*zeta)]','fontsize',16);
grid on

%% save the figure

if save_images == 1
    % 获取当前的图形对象
    h = gcf;
    % 为文件名添加前缀
    filename_prefix = 'history_single_nm';
    % 保存图像文件，文件名包括前缀和标签
    filename = [path, filename_prefix, num2str(nmodes(imode)),num2str(mmodes(imode)), '.fig'];
    saveas(h, filename);
end