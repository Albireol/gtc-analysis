%% GTC AE Spectrum Analysis (Single Mode FFT with Alfven Normalization)
% 专注于提取单一模的时间演化，并以 \omega/\omega_A 为横坐标绘制功率谱
clc; clear; close all;

% =========================================================================
% 1. 用户自定义参数区 (User Settings)
% =========================================================================
path = './';                  % 数据路径
target_field = 1;             % 分析的物理场: 1=phi, 2=a_par, 3=fluidne
target_mode  = 1;             % 分析的模序号 (对应 history_str 里的 mode1, mode2...)
target_psi_n = 0.5;           % 目标径向位置 (\psi_n)，用于计算局域阿尔芬频率
trim_start_time = true;      % 是否跳过初期的数值演化 (例如 t<5 的非物理振荡)
start_step_ratio = 0.1;       % 如果 trim_start_time=true，跳过前 10% 的时间步

% =========================================================================
% 2. 环境初始化与归一化系数计算 (Initialization & Normalization)
% =========================================================================
run setpath.m;
run read_para.m;              % 必须提供 B0, aion, utime 等
A = read_prodata(path, 'profile.dat');

% 计算全径向的 vA/Cs 比值分布
V_Ai_profile = 2.18*10^11 ./ (aion .* A.ni).^0.5 .* B0; 
C_si_profile = 9.79*10^5 ./ (aion^0.5) .* A.Te.^0.5;
vA_over_Cs_dist = V_Ai_profile ./ C_si_profile;

% 提取目标径向位置的转换系数
[~, mid_idx] = min(abs(A.psi/max(A.psi) - target_psi_n));
local_ratio = vA_over_Cs_dist(mid_idx); 

% =========================================================================
% 3. 读取 history.out (Read History Data)
% =========================================================================
hsty_data = load([path, 'history.out']);

% 读取头部信息
ndstep      = hsty_data(1);
nspecies    = hsty_data(2);
mpdiag      = hsty_data(3);
nfield      = hsty_data(4);
modes       = hsty_data(5);
mfdiag      = hsty_data(6);
tstep_ndiag = hsty_data(7) * utime / tstep_gtc_axis; % 时间步长 (单位: R0/Cs)

ndata = nspecies*mpdiag + nfield*(2*modes + mfdiag);
ntime = floor(length(hsty_data) / ndata);

% 提取目标模的实部和虚部
yr = zeros(ntime, 1);
yi = zeros(ntime, 1);

for it = 1:ntime
    % 计算在 history 数组中的索引偏移
    base_idx = 7 + nspecies*mpdiag + nfield*mfdiag + (it-1)*ndata;
    ind1 = base_idx + (target_field-1)*2*modes + 2*(target_mode-1) + 1;
    ind2 = ind1 + 1;
    
    yr(it) = hsty_data(ind1);
    yi(it) = hsty_data(ind2);
end

% =========================================================================
% 4. 信号处理与 FFT 变换 (Signal Processing & FFT)
% =========================================================================
% 设定时间截断范围 (避开早期的瞬态噪声)
nstart = 1;
if trim_start_time
    nstart = max(1, round(ntime * start_step_ratio));
end
nend = ntime;
nfreq = round((nend - nstart) / 2);

yr_cut = yr(nstart:nend);
yi_cut = yi(nstart:nend);
ya_cut = sqrt(yr_cut.^2 + yi_cut.^2);

% 计算增长率 gamma0 用于消除信号包络的指数变化
gamma0 = log(ya_cut(end) / ya_cut(1)) / (nend - nstart);
xpow = (0:(nend - nstart))';

% 信号 Detrend (归一化幅度)
yr1 = yr_cut ./ exp(gamma0 * xpow);
yi1 = yi_cut ./ exp(gamma0 * xpow);

% 执行 FFT
power = fft(yr1 + 1i * yi1);
ypow = abs(power);

% 重建频率轴并转换为阿尔芬单位 (omega_A)
xp = zeros(1, 2*nfreq - 1);
yp = zeros(1, 2*nfreq - 1);

for i = 1:nfreq-1 
    yp(i) = ypow(i + nend - nstart - nfreq + 1); 
    xp(i) = ((i - nfreq + 1) * 2 * pi / ((nend - nstart) * tstep_ndiag)) / local_ratio; 
end

for i = 1:nfreq 
    yp(nfreq - 1 + i) = ypow(i); 
    xp(nfreq - 1 + i) = (i * 2 * pi / ((nend - nstart) * tstep_ndiag)) / local_ratio; 
end

% --- 新增：自动检测峰值 ---
% 分别在正频率和负频率区域寻找最大峰值 (避开 0 频附近的直流分量)
idx_pos = find(xp > 0.1);
[max_pow_pos, max_i_pos] = max(yp(idx_pos));
omega_peak_pos = xp(idx_pos(max_i_pos));

idx_neg = find(xp < -0.1);
[max_pow_neg, max_i_neg] = max(yp(idx_neg));
omega_peak_neg = xp(idx_neg(max_i_neg));

% 找到全局绝对最大峰值
if max_pow_pos > max_pow_neg
    global_peak_omega = omega_peak_pos;
    global_max_pow = max_pow_pos;
else
    global_peak_omega = omega_peak_neg;
    global_max_pow = max_pow_neg;
end

% =========================================================================
% 5. 绘图 (Plotting)
% =========================================================================
figure('Name', 'AE Power Spectral Analysis', 'Color', 'w', 'Position', [150, 150, 900, 600]);

% 绘制主功率谱
plot(xp, yp, 'b-', 'LineWidth', 1.5); 
hold on;

% 在图上标注检测到的峰值
plot(global_peak_omega, global_max_pow, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
text(global_peak_omega, global_max_pow * 1.05, sprintf('\\omega = %.3f', global_peak_omega), ...
    'Color', 'r', 'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

% 添加理论间隙参考线
xline(0.5, 'r--', 'TAE Gap (~0.5)', 'LineWidth', 1.5, 'LabelVerticalAlignment', 'bottom');
xline(-0.5, 'r--', 'LineWidth', 1.5);
xline(1.0, 'g:', 'EAE Gap (~1.0)', 'LineWidth', 1.5, 'LabelVerticalAlignment', 'bottom');
xline(-1.0, 'g:', 'LineWidth', 1.5);

axis tight;
grid on;
set(gca, 'FontSize', 12, 'LineWidth', 1.2);
xlabel('\omega / (v_A/R_0)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Power Spectral (Arb. Units)', 'FontSize', 14, 'FontWeight', 'bold');

title_str = sprintf('Mode %d FFT | \\psi_n \\approx %.2f | \\gamma = %.4f', target_mode, target_psi_n, gamma0);
title(title_str, 'FontSize', 15);

% 输出终端诊断信息
fprintf('\n=== AE 频率分析结果 ===\n');
fprintf('局域 vA/Cs 转换比例: %.3f\n', local_ratio);
fprintf('阻尼率/增长率 (Gamma): %.6f\n', gamma0);
fprintf('-------------------------\n');
fprintf('负频率主峰位置: %.4f [vA/R0]\n', omega_peak_neg);
fprintf('正频率主峰位置: %.4f [vA/R0]\n', omega_peak_pos);
fprintf('绝对最大峰值处: %.4f [vA/R0]\n', global_peak_omega);