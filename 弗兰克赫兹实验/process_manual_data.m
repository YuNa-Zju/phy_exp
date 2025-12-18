% 弗兰克-赫兹实验手动测量数据处理脚本

% 1. 录入数据
U = 0:100; % 电压 0-100V
I = [ ...
    0.0, 0.0, 0.0, 1.0, 3.0, 5.0, 14.0, 27.0, 36.0, ... % 0-8
    39.0, 44.0, 46.0, 48.0, 49.0, 51.0, 52.0, 52.0, 52.0, ... % 9-17
    51.0, 47.0, 41.0, 38.0, 38.0, 39.0, 43.0, 55.0, 61.0, ... % 18-26
    67.0, 71.0, 73.0, 62.0, 48.0, 38.0, 47.0, 62.0, 73.0, ... % 27-35
    81.0, 88.0, 91.0, 91.0, 89.0, 83.0, 69.0, 50.0, 49.0, ... % 36-44
    64.0, 80.0, 93.0, 102.0, 108.0, 111.0, 111.0, 108.0, 100.0, ... % 45-53
    84.0, 68.0, 67.0, 81.0, 85.0, 110.0, 119.0, 128.0, 132.0, ... % 54-62
    135.0, 133.0, 125.0, 112.0, 97.0, 93.0, 100.0, 113.0, 125.0, ... % 63-71
    138.0, 149.0, 158.0, 163.0, 165.0, 162.0, 154.0, 143.0, 137.0, ... % 72-80
    138.0, 146.0, 156.0, 168.0, 180.0, 191.0, 202.0, 208.0, 211.0, ... % 81-89
    209.0, 207.0, 201.0, 198.0, 199.0, 205.0, 213.0, 227.0, 240.0, ... % 90-98
    253.0, 264.0 ... % 99-100
];

% 2. 寻找峰值 (手动指定大致范围或自动查找)
% 这里使用简单的局部最大值查找，并处理平台峰
peak_locs = [];
peak_vals = [];

for i = 2:length(I)-1
    is_peak = false;
    current_loc = U(i);
    
    if I(i) > I(i-1) && I(i) > I(i+1)
        is_peak = true;
    elseif I(i) > I(i-1) && I(i) == I(i+1)
        % 平台起始，检查平台结束
        j = i + 1;
        while j < length(I) && I(j) == I(i)
            j = j + 1;
        end
        if j <= length(I) && I(j) < I(i)
            % 是峰值平台
            is_peak = true;
            current_loc = (U(i) + U(j-1)) / 2; % 取平台中心
        end
    end
    
    if is_peak
        % 简单的过滤：峰值必须大于一定阈值，且距离上一个峰值有一定距离
        if isempty(peak_locs) || (current_loc - peak_locs(end) > 8)
             peak_locs = [peak_locs, current_loc];
             peak_vals = [peak_vals, I(i)];
        end
    end
end

% 确保只取前7个峰（如果有更多）或者所有找到的峰
if length(peak_locs) > 7
    peak_locs = peak_locs(1:7);
    peak_vals = peak_vals(1:7);
end

% 3. 绘制 I-U 曲线并标记峰值
figure('Position', [100, 100, 1000, 600]);
plot(U, I, 'b.-', 'LineWidth', 1, 'DisplayName', '实验曲线');
hold on;
plot(peak_locs, peak_vals, 'ro', 'MarkerSize', 8, 'LineWidth', 1.5, 'DisplayName', '峰值点');
grid on;
xlabel('加速电压 U_{G2K} (V)', 'FontSize', 12);
ylabel('阳极电流 I_A (\times 10^{-9} A)', 'FontSize', 12);
title('弗兰克-赫兹实验 I_A - U_{G2K} 曲线 (手动测量)', 'FontSize', 14);
legend('Location', 'northwest');

% 标注峰值电压
for k = 1:length(peak_locs)
    text(peak_locs(k), peak_vals(k)+5, sprintf('%.1fV', peak_locs(k)), 'HorizontalAlignment', 'center', 'FontSize', 10);
end

if ~exist('figures', 'dir')
    mkdir('figures');
end
saveas(gcf, 'figures/manual_curve.png');

% 4. 线性拟合计算 U0
n = 1:length(peak_locs); % 峰值序号
[p, S] = polyfit(n, peak_locs, 1);
slope = p(1);      % 斜率，即 U0
intercept = p(2);  % 截距
y_fit = polyval(p, n);

% 5. 计算不确定度 (A类)
% 残差平方和 SSE
SSE = sum((peak_locs - y_fit).^2);
% 自由度 (数据点数 - 参数个数)
dof = length(n) - 2;
% 剩余标准差 (RMSE)
sigma = sqrt(SSE / dof);
% 自变量 n 的离差平方和 Sxx
Sxx = sum((n - mean(n)).^2);
% 斜率的标准不确定度 u_A
u_A = sigma / sqrt(Sxx);

% 相关系数 r
r_matrix = corrcoef(n, peak_locs);
r = r_matrix(1, 2);

% 输出结果
fprintf('================ 手动测量拟合结果 ================\n');
fprintf('检测到的峰值电压: %s\n', sprintf('%.1f ', peak_locs));
fprintf('斜率 (U0): %.4f V\n', slope);
fprintf('截距:      %.4f V\n', intercept);
fprintf('相关系数 r: %.4f\n', r);
fprintf('拟合方程:   U = %.4f * n + %.4f\n', slope, intercept);
fprintf('--------------------------------------------------\n');
fprintf('斜率的A类不确定度 u_A: %.4f V\n', u_A);
fprintf('==================================================\n');

% 6. 绘制拟合图
figure('Position', [150, 150, 800, 600]);
plot(n, peak_locs, 'ro', 'MarkerSize', 8, 'LineWidth', 1.5, 'DisplayName', '峰值数据');
hold on;
x_fit_line = linspace(0.5, length(n)+0.5, 100);
y_fit_line = polyval(p, x_fit_line);
plot(x_fit_line, y_fit_line, 'b-', 'LineWidth', 1.5, 'DisplayName', sprintf('线性拟合 (U_0=%.2f V)', slope));

grid on;
xlabel('峰值序号 n', 'FontSize', 12);
ylabel('峰值电压 U (V)', 'FontSize', 12);
title(sprintf('手动测量数据峰值拟合 (U_0 = %.2f \\pm %.2f V)', slope, u_A), 'FontSize', 14);
legend('Location', 'northwest', 'FontSize', 12);
set(gca, 'FontSize', 12);

% 保存拟合图
saveas(gcf, 'figures/manual_fit.png');
fprintf('图片已保存至 figures/manual_curve.png 和 figures/manual_fit.png\n');
