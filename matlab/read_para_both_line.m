function [data1, data2] = read_para_both_line(filename, prefix)
% 打开文件
fid = fopen(filename, 'r');

% 初始化数据
data1 = [];
data2 = [];

% 遍历文件
while ~feof(fid)
    % 读取一行
    line = fgetl(fid);

    % 检查是否以指定前缀开头
    if startsWith(line, prefix)
        % 从等号后面开始截取字符串
        idx = strfind(line, '=');
        if ~isempty(idx)
            value_str = line(idx(1)+1 : end);   % 只用第一个等号
            value_str = strtrim(value_str);     % 去空格
        else
            value_str = '';                     % 或者按需处理
        end
        % 使用正则表达式匹配所有数字
        nums = regexp(value_str, '[+-]?\d+\.?\d*(?:[eE][+-]?\d+)?', 'match');

        % 如果已经找到两个数据，则退出循环
        if length(nums) >= 2
            % 将字符串转换为数值类型，如果转换失败则输出提示信息
            data1_str = nums{1};
            data2_str = nums{2};
            data1 = str2double(data1_str);
            data2 = str2double(data2_str);
            if isnan(data1) || isnan(data2)
                warning('文件中找到的数据不是有效的数值: %s, %s', data1_str, data2_str);
            end
            break;
        end
    end
end

% 关闭文件
fclose(fid);
end
