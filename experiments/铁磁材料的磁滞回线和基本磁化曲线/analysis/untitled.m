% =========================================================================
% 程序一：基本磁化曲线 B-H 与 磁导率曲线 mu-H 绘制
% =========================================================================
clc; clear; close all;

%% 1. 实验常数定义
N1 = 150;           % 励磁线圈匝数
N2 = 150;           % 探测线圈匝数
L = 0.130;          % 磁路平均长度 (m)
S = 1.24e-4;        % 样品截面积 (m^2)
R1 = 2.5;           % 采样电阻 (Ohm)
R2 = 10e3;          % 积分电阻 (Ohm)
C = 3e-6;           % 积分电容 (F)

% 修正系数：示波器读数 -> 真实电压
probe_factor = 1/10; % 探头衰减修正

%% 2. 输入手写表格数据 (峰峰值 V)
% U_in (V)
U_labels = [0.50, 1.00, 1.20, 1.50, 1.80, 2.00, 2.20, 2.50, 2.80, 3.00, 3.20, 3.53];
% Ux_pp (V)
Ux_pp_raw = [1.0946, 1.9953, 2.3360, 2.8506, 3.4120, 3.7793, 4.1100, 4.6633, 5.3726, 7.4800, 13.232, 31.500];
% Uy_pp (V)
Uy_pp_raw = [0.84322, 1.6248, 1.9338, 2.4024, 2.8858, 3.2117, 3.5080, 3.9864, 4.4565, 4.7770, 5.0645, 5.3221];

%% 3. 数据处理
% 步骤A: 修正探头系数 (/10) 并 转换为峰值 (/2)
Ux_peak = (Ux_pp_raw * probe_factor) / 2;
Uy_peak = (Uy_pp_raw * probe_factor) / 2;

% 步骤B: 计算 H (A/m) 和 B (T)
H = (N1 ./ (L * R1)) .* Ux_peak;
B = ((R2 * C) ./ (N2 * S)) .* Uy_peak;

% 步骤C: 计算磁导率 mu (H/m)
mu_abs = B ./ H;          % 绝对磁导率
mu_0 = 4 * pi * 1e-7;     % 真空磁导率
mu_r = mu_abs ./ mu_0;    % 相对磁导率

%% 4. 绘图 (双Y轴)
figure('Color', 'w', 'Name', '基本磁化曲线与磁导率');

% 左轴: B-H
yyaxis left;
plot(H, B, '-s', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'b');
ylabel('磁感应强度 B (T)', 'FontSize', 12);
xlabel('磁场强度 H (A/m)', 'FontSize', 12);
grid on;

% 右轴: mu-H
yyaxis right;
plot(H, mu_r, '-o', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'r');
ylabel('相对磁导率 \mu_r', 'FontSize', 12);

% 图例与标题
legend('B - H 曲线', '\mu_r - H 曲线', 'Location', 'Best');
title('样品的基本磁化曲线 (B-H) 与 磁导率曲线 (\mu-H)', 'FontSize', 14);

% 打印计算结果表
fprintf('序号\t H(A/m)\t B(T)\t mu_r\n');
for i = 1:length(H)
    fprintf('%d\t %.2f\t %.3f\t %.0f\n', i, H(i), B(i), mu_r(i));
end