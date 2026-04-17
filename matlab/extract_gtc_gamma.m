function gamma_phys = extract_gtc_gamma(data_path, mode_idx, field_idx)
    % 输入: 文件夹路径, 模数索引(如3), 场索引(phi=1)
    
    % 1. 环境准备 (需确保 read_para.m 和 setpath.m 在搜索路径中)

    
    % 2. 加载 history.out
    hsty_data = load([data_path, 'history.out']);
    
    % 3. 解析头文件与维度 (GTC 4.6 标准)
    ndstep      = hsty_data(1);
    nspecies    = hsty_data(2);
    mpdiag      = hsty_data(3);
    nfield      = hsty_data(4);
    modes       = hsty_data(5);
    mfdiag      = hsty_data(6);
    ndata       = nspecies*mpdiag + nfield*(2*modes + mfdiag);
    ntime       = floor(length(hsty_data)/ndata);
    
    % dt 计算 (物理单位 R0/Cs)
    dt = dt0 * ndiag; 
    t = dt:dt:ntime*dt;
    
    % 4. 提取目标数据 (Real & Imag -> Amplitude)
    yr = zeros(ntime, 1);
    yi = zeros(ntime, 1);
    for it = 1:ntime
        base_ind = 7 + nspecies*mpdiag + nfield*mfdiag + (it-1)*ndata;
        ind1 = base_ind + (field_idx-1)*2*modes + 2*(mode_idx-1) + 1;
        yr(it) = hsty_data(ind1);
        yi(it) = hsty_data(ind1+1);
    end
    ya = sqrt(yr.^2 + yi.^2);
    yy = log(ya); % 使用自然对数便于拟合直接得到 gamma

    % 5. 【核心：Albireo 自动化线性段选取逻辑】
    M = 50;  
    threshold_R2 = 0.99;  
    segment_length = floor(ntime / M);
    cut0 = NaN; cut1 = NaN; Rc = 0;

    for i = 1:M
        start_idx = (i - 1) * segment_length + 1;
        end_idx = min(i * segment_length, ntime);
        fit_range = start_idx:end_idx;
        
        % 对每一段进行线性拟合评估
        gamma_poly = polyfit(t(fit_range), yy(fit_range), 1);
        yy_predicted = polyval(gamma_poly, t(fit_range));
        
        % 计算 R^2
        ss_residual = sum((yy(fit_range) - yy_predicted(:)).^2);
        ss_total = sum((yy(fit_range) - mean(yy(fit_range))).^2);
        R2 = 1 - (ss_residual / ss_total);
        
        if R2 > threshold_R2
            if isnan(cut0) || (Rc < R2 && ~isnan(cut1))
                cut0 = t(start_idx)/t(end); 
                cut1 = NaN;
            end
        else
            if ~isnan(cut0) && isnan(cut1)
                cut1 = t(start_idx)/t(end);
            end
        end
    end
    if isnan(cut1), cut1 = 1; end
    if isnan(cut0), cut0 = 0; end % 防御性设置

    % 6. 执行最终线性拟合
    ind0 = max(1, floor(cut0 * ntime)); 
    ind2 = floor(cut1 * ntime);
    
    % 保证点数为偶数 (兼容后续 FFT)
    N_points = length(t(ind0:ind2));
    if mod(N_points, 2) == 0, ind1 = ind0; else, ind1 = ind0 + 1; end
    
    final_fit_range = ind1:ind2;
    gamma_final_poly = polyfit(t(final_fit_range), yy(final_fit_range), 1);
    
    % 返回结果 (即为物理单位的增长率 gamma)
    gamma_phys = gamma_final_poly(1);
    
    % 打印反馈信息，方便调试
    fprintf('  -> 自动化选取区间: [%.2f, %.2f] R0/Cs, R^2判断完成.\n', t(ind1), t(ind2));
end