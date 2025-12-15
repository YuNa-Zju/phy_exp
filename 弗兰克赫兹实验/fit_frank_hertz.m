% 弗兰克-赫兹实验数据拟合脚本

% 1. 定义数据
n = [1, 2, 3, 4, 5, 6, 7]; % 峰值序号
U = [15.2, 26.6, 38.3, 50.0, 62.5, 75.4, 88.3]; % 峰值电压 (V)

% 2. 线性拟合 (y = p(1)*x + p(2))
[p, S] = polyfit(n, U, 1);
slope = p(1);      % 斜率，即第一激发电势 U0
intercept = p(2);  % 截距
y_fit_val = polyval(p, n); % 拟合值

% 3. 计算不确定度 (A类)
% 残差平方和 SSE
SSE = sum((U - y_fit_val).^2);
% 自由度 (数据点数 - 参数个数)
dof = length(n) - 2;
% 剩余标准差 (RMSE)
sigma = sqrt(SSE / dof);
% 自变量 n 的离差平方和 Sxx
Sxx = sum((n - mean(n)).^2);
% 斜率的标准不确定度 u_A
u_A = sigma / sqrt(Sxx);

% 相关系数 r
r_matrix = corrcoef(n, U);
r = r_matrix(1, 2);

% 输出结果
fprintf('================ 拟合结果 ================\n');
fprintf('斜率 (U0): %.4f V\n', slope);
fprintf('截距:      %.4f V\n', intercept);
fprintf('相关系数 r: %.4f\n', r);
fprintf('拟合方程:   U = %.4f * n + %.4f\n', slope, intercept);
fprintf('------------------------------------------\n');
fprintf('斜率的A类不确定度 u_A: %.4f V\n', u_A);
fprintf('==========================================\n');

% 4. 绘图
figure('Position', [100, 100, 800, 600]); % 设置画布大小
plot(n, U, 'ro', 'MarkerSize', 8, 'LineWidth', 1.5, 'DisplayName', '实验数据'); % 绘制数据点
hold on;

% 绘制拟合直线
x_fit = linspace(0.5, 7.5, 100);
y_fit = polyval(p, x_fit);
plot(x_fit, y_fit, 'b-', 'LineWidth', 1.5, 'DisplayName', sprintf('线性拟合 (U_0=%.2f V)', slope));

% 5. 图形美化
grid on;
xlabel('峰值序号 n', 'FontSize', 12);
ylabel('峰值电压 U_{G2K} (V)', 'FontSize', 12);
title(sprintf('弗兰克-赫兹实验数据拟合 (U_0 = %.2f \\pm %.2f V)', slope, u_A), 'FontSize', 14);
legend('Location', 'northwest', 'FontSize', 12);
set(gca, 'FontSize', 12);

% 6. 保存图片
if ~exist('figures', 'dir')
    mkdir('figures');
end
saveas(gcf, 'figures/自动测量拟合.png');
fprintf('图片已保存至 figures/自动测量拟合.png\n');
