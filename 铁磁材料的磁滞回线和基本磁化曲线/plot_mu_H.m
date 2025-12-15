% plot_mu_H.m
% 功能：根据已知的 H 和 μ 数据绘制 μ-H 曲线
% 使用说明：
%   1. 将本文件放在与数据同一文件夹下；
%   2. 修改下方 H 和 mu 数组为你自己算出来的值；
%   3. 在 MATLAB 中切换到本文件所在目录，执行：plot_mu_H

clear; clc; close all;

%% 在这里填入你自己的数据 ======================================
% 示例数据，仅用于演示，请替换为你自己的 H、mu 数组
% 要求：H 和 mu 长度相同，按测量顺序一一对应
%% 在这里填入你自己的数据（来自表  \ref{tab:magnetization_curve_data}）
H  = [22.26, 44.11, 52.38, 64.66, 77.63, 86.63, 96.14, 123.55, 192.32, 287.76];           % A/m
mu = [2.90, 2.97, 2.94, 2.97, 2.96, 2.93, 2.92, 2.62, 1.87, 1.32] * 1e-3;                 % 10^{-3} H/m → H/m
% ===============================================================

if numel(H) ~= numel(mu)
    error('H 和 mu 的长度不一致，请检查数据！');
end

%% 绘制 μ-H 曲线
figure;
set(gcf, 'Position', [200, 150, 800, 550]);

plot(H, mu, 'rs-', 'LineWidth', 1.8, ...
     'MarkerSize', 6, 'MarkerFaceColor', 'r');
grid on;

xlabel('H (A/m)',         'FontSize', 12, 'FontName', '宋体');
ylabel('\mu (H/m)',       'FontSize', 12, 'FontName', '宋体');
title('\mu-H 磁导率曲线', 'FontSize', 14, 'FontName', '宋体');

set(gca, 'FontSize', 11, 'FontName', '宋体');
box on;

% 标出最大 μ 点（可选）
[mu_max, idx_max] = max(mu);
hold on;
plot(H(idx_max), mu_max, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k');
text(H(idx_max), mu_max, ...
     sprintf('  \\mu_{max}=%.4g H/m,  H=%.2f A/m', mu_max, H(idx_max)), ...
     'FontSize', 10, 'FontName', '宋体', 'Color', 'k');

% 可选：保存图片到当前文件夹
% print(gcf, 'mu_H_curve.png', '-dpng', '-r300');
