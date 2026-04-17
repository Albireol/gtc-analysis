%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Yuehao Ma, USTC, myh2020@mail.ustc.edu.cn
% GTC Data Processing GUI
% V4.6 for gtc4.6 version myh 20230323 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cal_gamma, unit=R_0/c_s, used by history.m 
% plot at panel subplot(222) for mode 1-8
% 更新利用逐段拟合自动寻找线性区间 25.12.12 A.L.

% ndiag=1; dt0=0.005;

dt=dt0*ndiag;  
% dt=dt0;  
nt=length(ya);
% yy=log10(ya);
yy=log(ya);
t=dt:dt:nt*dt;
%计算线性增长部分设置两个测量参数 与频率采用区间统一
% modify here to set time step range
M = 50;  % 可以根据需要调整
threshold_R2 = 0.99;  % 设置拟合的 R^2 阈值
Rc = 0;
% 计算每一份的长度
segment_length = floor(nt / M);
cut0 = NaN; cut1 = NaN;

for i = 1:M
    % 每一段的索引
    start_idx = (i - 1) * segment_length + 1;
    end_idx = min(i * segment_length, nt);  % 防止最后一段越界

    % 对每一段进行线性拟合
    fit_range = start_idx:end_idx;
    gamma_poly = polyfit(t(fit_range), yy(fit_range), 1);
    yy_predicted = polyval(gamma_poly, t(fit_range));
    yy_predicted = yy_predicted(:);
    % 计算 R^2 值
    ss_residual = sum((yy(fit_range) - yy_predicted).^2);  % 残差平方和
    ss_total = sum((yy(fit_range) - mean(yy(fit_range))).^2);  % 总平方和
    R2 = 1 - (ss_residual / ss_total);  % 计算 R^2 值

    % 判断是否线性
    if R2 > threshold_R2
        if isnan(cut0) || Rc<R2 && ~isnan(cut1)
            cut0 = t(start_idx)/t(length(t)); % 记录第一个符合条件的左端点
            cut1 = NaN;
        end
    else
        if ~isnan(cut0) && isnan(cut1)
            cut1 = t(start_idx)/t(length(t));  % 记录第一个不符合条件的左端点
        end
    end
end
    if isnan(cut1)
       cut1 = 1;
    end
% modify the fft and omega simple
auto_fft  = 3;      % 1 or 3直接对数据傅里叶变换 2 or 4 线性增长阶段对数据进行傅里叶变换
auto_simp = 4;      % 找峰值，auto=1是谢华生的代码求解，auto=2使用包健的代码求解
% auto=3使用MATLAB自带找极值的函数进行寻找 找实部
% auto=4使用MATLAB自带找极值的函数进行寻找 找虚部
% auto=5使用MATLAB自带找极值的函数进行寻找 find real part and imag part
% 在循环结束后添加
if isnan(cut0)
    warning('未找到符合阈值的线性区间，自动回退至全段分析');
    cut0 = 0.05; % 默认避开初始扰动
end
if isnan(cut1) || cut1 <= cut0
    cut1 = 0.95; % 默认取到末尾
end
cut0 = 0.05;
cut1 = 0.95;
ind0 = max(1, floor(cut0 * nt)); 
ind2 = min(nt, floor(cut1 * nt));

% 确保区间长度足够进行拟合
if (ind2 - ind0) < 5
    ind0 = 1; ind2 = nt;
end
N    = length(t(ind0:ind2));
if mod(N,2)==0
    ind1 = ind0;
else
    ind1 = ind0+1;
    N    = length(t(ind1:ind2));
end

gamma_poly = polyfit(t(ind1:ind2),yy(ind1:ind2),1);
yy_poly = polyval(gamma_poly,t(ind1:ind2));
% gamma = (yy(ind2)-yy(ind1))/(t(ind2)-t(ind1));
gamma           = gamma_poly(1);
gamma_mode      = gamma_poly(1)
gamma_mode_gtc  = gamma_poly(1)*frequency_gtc_axis
gamma_mode_freq = gamma_poly(1)*frequency_unit_axis
plot(t,yy,t(ind1:ind2),yy_poly,'r--','Linewidth',2); 
hold on
plot([t(ind1),t(ind2)],[yy_poly(1),yy_poly(end)],'r*','Linewidth',2); 
xlim([0,max(t)]);
% xlabel('t'); ylabel('log(|\phi|)');
xlabel('$t[R_0/C_s]$','Interpreter','latex','fontsize',16);
ylabel('$\ln(|\delta\phi|)$','Interpreter','latex','fontsize',16);
hold off
yyaxis right
ylim([min(log10(ya)),max(log10(ya))])
% set(gca,'YTick',min(log10(ya)):max(log10(ya)));
% ylabel('$log_{10}(|\delta\phi|)$','Interpreter','latex','fontsize',16);
% xlim([0,max(t)]);
% title(['\gamma=',num2str(gamma)]);
if(exist('diag_flux','var')&&exist('q_diag_flux','var')&&exist('rho_i','var'))
    kthetarhoi=nmodes(imode)*q_diag_flux(1,4)/(q_diag_flux(1,2)*a_minor)*rho_i;
    title(['$k_{\theta}\rho_i=$',num2str(kthetarhoi),' $\gamma=$',num2str(gamma)],'Interpreter','latex','fontsize',16);
else
    title(['$\gamma=$',num2str(gamma)],'Interpreter','latex','fontsize',16);
end

%% updata the nstart and the nend for the history.out calculate the gamma0
% 计算omega的起始时间位置,需要人眼来观察什么时候线性增长,或者使用图像识别 2021 10 14
nstart = ind1;   
nend   = ind2;

