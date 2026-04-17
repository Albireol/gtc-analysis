%% 主自动化对比脚本
clear; clc;
beta_list = [0.4, 0.5, 0.6];
base_dir = 'C:\Users\slab0\OneDrive\Research\examples\'; % 你的数据根目录

results_no_p = zeros(size(beta_list));
results_with_p = zeros(size(beta_list));

for i = 1:length(beta_list)
    b_str = num2str(beta_list(i));
    
    % 1. 计算不带 p 的版本 (phi, mode 3)
    path_no_p = fullfile(base_dir, ['beta', b_str, "\"]);
    if isfolder(path_no_p)
        results_no_p(i) = extract_gtc_gamma(path_no_p, 3, 1)
    end
    
    % 2. 计算带 p 的版本 (phi, mode 3)
    path_with_p = fullfile(base_dir, ['beta', b_str, 'p\']);
    if isfolder(path_with_p)
        results_with_p(i) = extract_gtc_gamma(path_with_p, 3, 1)
    end
end

% 3. 绘图
figure;
plot(beta_list, results_with_p, '-ro', 'DisplayName', 'With \delta B_{||}'); hold on;
plot(beta_list, results_no_p, '-k*', 'DisplayName', 'Without \delta B_{||}');
xlabel('\beta'); ylabel('\gamma (R_0/C_s)');
legend; grid on;