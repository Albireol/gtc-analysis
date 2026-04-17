A=read_prodata;
B=read_spdata;
r_n = A.r / max(A.r);
k=1.38*10^-23;
eV2K=11604.525;
Pe=A.Te.*A.ne*10^6*k*eV2K;
Pi=A.Ti.*A.ni*10^6*k*eV2K;
Pf=A.Tf.*A.nf*10^6*k*eV2K;
Pa=A.Ta.*A.na*10^6*k*eV2K;
P_total=Pe+Pi+Pa+Pf;
p_sp = B.ppsi(1, :);      
r_sp=B.rpsi(1, :);
r_n_sp = r_sp/max(r_sp); 
mu0     = 4*pi*1e-7;
q=B.qpsi(1, :);
%b=B.baxis;



B_raw = squeeze(B.bsp(1, :, 1));
B_on_P_grid = interp1(r_n_sp,B_raw,r_n);
b=B_on_P_grid;


beta_e=Pe./((b.^2)/(2*mu0));
beta_i=Pi./((b.^2)/(2*mu0));
beta_f=Pf./((b.^2)/(2*mu0));
beta_a=Pa./((b.^2)/(2*mu0));
beta_total=P_total./((b.^2)/(2*mu0));

figure;
% 密度剖面 (ne, ni, nf)
subplot(2, 4, 1);
plot(r_n, A.ne*10^6, 'k-', 'LineWidth', 1.5);
xlabel('r/a');ylabel('n_e [m^{-3}]'); title('Electron Density'); grid on;

subplot(2, 4, 2);
plot(r_n, A.ni*10^6, 'b-', 'LineWidth', 1.5);
xlabel('r/a');ylabel('n_i [m^{-3}]'); title('Ion Density'); grid on;

subplot(2, 4, 3);
plot(r_n, A.nf*10^6, 'r-', 'LineWidth', 1.5);
xlabel('r/a');ylabel('n_f [m^{-3}]'); title('Fast Ion Density'); grid on;

subplot(2, 4, 4);
plot(r_n, A.na*10^6, 'r-', 'LineWidth', 1.5);
xlabel('r/a');ylabel('n_\alpha [m^{-3}]'); title('Alpha Particle Density'); grid on;
% 温度剖面 (Te, Ti, Tf)
subplot(2, 4, 5);
plot(r_n, A.Te, 'k-', 'LineWidth', 1.5);
xlabel('r/a'); ylabel('T_e [eV]'); title('Electron Temperature'); grid on;

subplot(2, 4, 6);
plot(r_n, A.Ti, 'b-', 'LineWidth', 1.5);
xlabel('r/a'); ylabel('T_i [eV]'); title('Ion Temperature'); grid on;

subplot(2, 4, 7);
plot(r_n, A.Tf, 'r-', 'LineWidth', 1.5);
xlabel('r/a'); ylabel('T_f [eV]'); title('Fast Ion Temperature'); grid on;

subplot(2, 4, 8);
plot(r_n, A.Ta, 'r-', 'LineWidth', 1.5);
xlabel('r/a'); ylabel('T_\alpha [eV]'); title('Alpha Particle Temperature'); grid on;

figure;
subplot(2, 3, 1);
plot(r_n, Pe, 'k-', 'LineWidth', 1.5);
xlabel('r/a');ylabel('Pe'); title('Electron Pressure'); grid on;
subplot(2, 3, 2);
plot(r_n, Pi, 'k-', 'LineWidth', 1.5);
xlabel('r/a');ylabel('Pi'); title('Ion Pressure'); grid on;
subplot(2, 3, 3);
plot(r_n, Pf, 'k-', 'LineWidth', 1.5);
xlabel('r/a');ylabel('Pf'); title('Fast Ion Pressure'); grid on;
subplot(2, 3, 4);
plot(r_n, Pa, 'k-', 'LineWidth', 1.5);
xlabel('r/a');ylabel('Pa'); title('Alpha Particle Pressure'); grid on;
subplot(2, 3, 5);
plot(r_n, P_total, 'k-', 'LineWidth', 1.5);
xlabel('r/a');ylabel('Ptotal'); title('Total Pressure'); grid on;
subplot(2, 3, 6);
plot(r_n, Pa/P_total, 'k-', 'LineWidth', 1.5);
xlabel('r/a');ylabel('Pa/Pt'); title('Pa/Pt'); grid on;
% 创建画布，设置白色背景
figure('Color', 'w', 'Name', 'Pressure Profiles High Contrast');

% ==========================================
% 主坐标轴 (左侧)：绘制各项压强
% ==========================================
yyaxis left
hold on;

% 绘制总压强 (黑色，最粗，最显眼)
plot(r_n, P_total, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Total Pressure');
% 绘制热粒子组分 (深色调)
plot(r_n, Pe, 'Color', [0 0 0.5], 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', 'Electron (P_e)'); % 深蓝
plot(r_n, Pi, 'Color', [0 0.5 0], 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', 'Thermal Ion (P_i)');   % 深绿

% 绘制快粒子组分 (深色调)
plot(r_n, Pf, 'Color', [0.6 0 0], 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', 'Fast Ion (P_f)');     % 深红
plot(r_n, Pa, 'Color', [0.6 0 0.6], 'LineStyle', '-', 'LineWidth', 1.5, 'Marker', 'none', 'DisplayName', 'Alpha (P_\alpha)');
plot(r_n_sp, p_sp, 'Color', [0.6 0.6 0.0], 'LineStyle', '-', 'LineWidth', 1.5, 'Marker', 'none', 'DisplayName', 'P_total(from spdata)');
% 设置左侧坐标轴标签和范围
xlabel(' r/a', 'FontSize', 12, 'FontWeight', 'bold');
ylabel(' Pressure [Pa]', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
set(gca, 'YColor', 'k'); % 确保左侧轴刻度颜色为黑色

grid on;
box on;

% ==========================================
% 次坐标轴 (右侧)：绘制 Alpha 压强占比
% ==========================================
yyaxis right

% 使用易于区分但仍是实线的颜色绘制占比 (例如：深青色)
frac_color = [0 0.7 0.7]; % 深青色
plot(r_n, Pa./P_total, 'Color', frac_color, 'LineStyle', '-', 'LineWidth', 2, 'DisplayName', 'P_\alpha / P_{total}');

% 设置右侧坐标轴标签
ylabel('Alpha Fraction', 'FontSize', 12, 'FontWeight', 'bold', 'Color', frac_color);
set(gca, 'YColor', frac_color); % 右侧轴刻度颜色与曲线一致，方便对应

legend('Location', 'northeast', 'FontSize', 10, 'FontWeight', 'bold');
title('Pressure Profiles', 'FontSize', 14, 'FontWeight', 'bold');
hold off;



%beta

figure('Color', 'w', 'Name', 'Beta');
hold on;
plot(r_n, beta_total, 'k-', 'LineWidth', 1.5, 'DisplayName', '\beta_{total}');
% 绘制热粒子组分 (深色调)
plot(r_n, beta_e, 'Color', [0 0 0.5], 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', '\beta_e'); % 深蓝
plot(r_n, beta_i, 'Color', [0 0.5 0], 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', '\beta_i');   % 深绿

% 绘制快粒子组分 (深色调)
plot(r_n, beta_f, 'Color', [0.6 0 0], 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', '\beta_f');     % 深红
plot(r_n, beta_a, 'Color', [0.6 0 0.6], 'LineStyle', '-', 'LineWidth', 1.5, 'Marker', 'none', 'DisplayName', '\beta_\alpha');
% 设置左侧坐标轴标签和范围
xlabel(' r/a', 'FontSize', 12, 'FontWeight', 'bold');
ylabel(' \beta', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
set(gca, 'YColor', 'k'); % 确保左侧轴刻度颜色为黑色
grid on;
box on;
legend('Location', 'northeast', 'FontSize', 10, 'FontWeight', 'bold')
title('Beta Profiles', 'FontSize', 14, 'FontWeight', 'bold');
hold off;
%beta_a/beta_total
figure('Color', 'w', 'Name', '\beta compared to q ');
yyaxis left
hold on;
plot(r_n, beta_total, 'k-', 'LineWidth', 1.5, 'DisplayName', '\beta_{total}');
plot(r_n, beta_a, 'Color', [0.6 0 0.6], 'LineStyle', '-', 'LineWidth', 1.5, 'Marker', 'none', 'DisplayName', '\beta_\alpha');
xlabel(' r/a', 'FontSize', 12, 'FontWeight', 'bold');
ylabel(' \beta', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
grid on;
box on;
yyaxis right
frac_color = [0 0.7 0.7];
plot(r_n_sp, q, 'Color', frac_color, 'LineStyle', '-', 'LineWidth', 2, 'DisplayName', 'q');
% 设置右侧坐标轴标签
ylabel('Safety Factor', 'FontSize', 12, 'FontWeight', 'bold', 'Color', frac_color);
set(gca, 'YColor', frac_color); % 右侧轴刻度颜色与曲线一致，方便对应
grid on;
box on;
legend('Location', 'northeast', 'FontSize', 10, 'FontWeight', 'bold');
title('\beta compared to Safety Factor', 'FontSize', 14, 'FontWeight', 'bold');
hold off;



figure;
hold on;
plot(r_n, b, 'Color', [0 0 0.5], 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', 'B_{real}');
plot(r_n, B.baxis./(1+(A.r./A.R)), 'Color', [0 0.5 0], 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', 'B_{theo}');   
xlabel('r/a');
ylabel('T');
grid on;
box on;
set(gca, 'YColor', 'k'); %
legend('Location', 'northeast', 'FontSize', 10, 'FontWeight', 'bold');
hold off;
