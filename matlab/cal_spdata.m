A=read_spdata
B=read_prodata
%%q剖面
% 提取数据
r=A.rpsi(1, :);
r_n = r/max(r); % 归一化半径
q = A.qpsi(1, :);          % 安全因子
p = A.ppsi(1, :);          % 压强
dq_dpsi = gradient(q, A.psi);
s_profile = (A.psi ./ q) .* dq_dpsi;
% 绘图
figure;
plot(r_n, q, 'LineWidth', 2);
xlabel('r/a');
ylabel('Safety Factor q');
yyaxis right
plot(r_n, s_profile, 'r', 'LineWidth', 2); hold on;
ylabel('Magnetic Shear s');
title('Equilibrium Profiles&Magnet Shear');


