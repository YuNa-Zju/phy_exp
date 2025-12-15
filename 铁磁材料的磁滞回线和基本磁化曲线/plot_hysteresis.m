% 磁滞回线和基本磁化曲线绘图程序
% 作者：姚舜瑜
% 日期：2025年11月11日

clear; clc; close all;

%% 基本磁化曲线数据
U_basic = [0.5, 1.0, 1.2, 1.5, 1.8, 2.0, 2.2, 2.5, 2.8, 3.0];
Ux_basic = [48.23, 95.58, 113.5, 140.1, 168.2, 187.7, 208.3, 267.7, 416.7, 623.5];
H_basic = [22.26, 44.11, 52.38, 64.66, 77.63, 86.63, 96.14, 123.55, 192.32, 287.76];
B_basic = [66.8, 130.9, 154.3, 192.0, 229.8, 253.9, 280.6, 323.1, 358.9, 380.0];

%% 磁滞回线数据
% 重新整理原始数据，确保按正确的物理顺序排列
% 磁滞回线应该是一个连续的闭合曲线

% 第一组数据：从正饱和到负矫顽力
H1 = [287.76, 245.55, 212.31, 173.99, 144.92, 114.20, 98.45, 83.00, 62.60, 36.35, ...
      14.79, 0.00, -21.13, -45.07, -65.42, -84.83, -98.87, -109.70];
B1 = [380.0, 371.0, 363.7, 352.7, 345.5, 336.5, 329.2, 320.2, 309.2, 292.9, ...
      278.4, 260.2, 233.1, 196.8, 158.7, 98.8, 55.3, 0.0];

% 第二组数据：继续到负饱和（注意去掉重复点和错误跳跃）
H2 = [-132.35, -146.80, -161.53, -182.66, -202.27, -238.00, -288.53];
B2 = [-178.7, -255.0, -296.6, -322.1, -342.1, -358.4, -376.5];

% 第三组数据：从负饱和到正矫顽力
H3 = [-246.83, -212.58, -168.20, -81.01, -51.15, -18.72, 0.00, 21.96, ...
      44.72, 72.72, 94.99, 103.34, 110.50];
B3 = [-369.2, -360.2, -345.6, -314.8, -298.5, -276.8, -256.8, -231.3, ...
      -196.9, -138.9, -69.9, -39.1, 0.0];

% 第四组数据：从正矫顽力回到正饱和
H4 = [122.38, 139.31, 151.18, 176.62, 205.54, 233.63];
B4 = [73.4, 204.0, 267.4, 316.4, 343.7, 359.9];

% 合并所有部分，去掉重复的端点
H_hysteresis = [H1, H2, H3, H4];
B_hysteresis = [B1, B2, B3, B4];

%% 计算磁滞回线面积
% 使用多边形面积公式（Shoelace公式）计算闭合曲线面积
% 确保数据点形成闭合回路
H_closed = [H_hysteresis, H_hysteresis(1)]; % 闭合回路
B_closed = [B_hysteresis, B_hysteresis(1)];

% 计算面积（使用梯形积分法）
area_hysteresis = 0;
for i = 1:length(H_closed)-1
    area_hysteresis = area_hysteresis + (H_closed(i+1) - H_closed(i)) * (B_closed(i+1) + B_closed(i)) / 2;
end
area_hysteresis = abs(area_hysteresis); % 取绝对值

% 单位转换：从 (A/m)×(mT) 转为 J/m³
% 1 mT = 1×10⁻³ T，所以面积单位是 (A/m)×(mT) = 1×10⁻³ J/m³
area_energy_loss = area_hysteresis * 1e-3; % J/m³

%% 寻找特殊值
% 饱和磁感应强度 Bs 和对应的饱和磁场强度 Hs
[Bs_pos, idx_Bs_pos] = max(B_hysteresis);
Hs_pos = H_hysteresis(idx_Bs_pos);
[Bs_neg, idx_Bs_neg] = min(B_hysteresis);
Hs_neg = H_hysteresis(idx_Bs_neg);

% 剩磁 Br（H=0时的B值）
% 寻找H最接近0的点
[~, idx_H0_pos] = min(abs(H_hysteresis - 0));
Br_pos = B_hysteresis(idx_H0_pos);

% 寻找另一个方向的剩磁
H_temp = H_hysteresis;
H_temp(idx_H0_pos) = inf; % 排除已找到的点
[~, idx_H0_neg] = min(abs(H_temp - 0));
Br_neg = B_hysteresis(idx_H0_neg);

% 矫顽力 Hc（B=0时的H值）
% 寻找B最接近0的点
[~, idx_B0_pos] = min(abs(B_hysteresis - 0));
Hc_pos = H_hysteresis(idx_B0_pos);

% 寻找另一个方向的矫顽力
B_temp = B_hysteresis;
B_temp(idx_B0_pos) = inf; % 排除已找到的点
[~, idx_B0_neg] = min(abs(B_temp - 0));
Hc_neg = H_hysteresis(idx_B0_neg);

%% 绘制基本磁化曲线
figure(1);
set(gcf, 'Position', [100, 100, 800, 600]);
plot(H_basic, B_basic, 'bo-', 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', 'b');
hold on;
grid on;
xlabel('磁场强度 H (A/m)', 'FontSize', 12, 'FontName', '宋体');
ylabel('磁感应强度 B (mT)', 'FontSize', 12, 'FontName', '宋体');
title('铁磁材料基本磁化曲线', 'FontSize', 14, 'FontName', '宋体');

% 标注饱和点
plot(H_basic(end), B_basic(end), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
text(H_basic(end)+10, B_basic(end)+10, sprintf('Bs=%.1f mT\nHs=%.1f A/m', B_basic(end), H_basic(end)), ...
     'FontSize', 10, 'FontName', '宋体', 'Color', 'r');

legend('基本磁化曲线', '饱和点', 'Location', 'southeast', 'FontName', '宋体');
set(gca, 'FontName', '宋体', 'FontSize', 10);

%% 绘制磁滞回线
figure(2);
set(gcf, 'Position', [200, 100, 900, 700]);
plot(H_hysteresis, B_hysteresis, 'b-', 'LineWidth', 1.5);
hold on;
grid on;
xlabel('磁场强度 H (A/m)', 'FontSize', 12, 'FontName', '宋体');
ylabel('磁感应强度 B (mT)', 'FontSize', 12, 'FontName', '宋体');
title('铁磁材料磁滞回线', 'FontSize', 14, 'FontName', '宋体');

% 标注特殊点
% 正向饱和点
plot(Hs_pos, Bs_pos, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
text(Hs_pos+10, Bs_pos+10, sprintf('+Bs=%.1f mT\n+Hs=%.1f A/m', Bs_pos, Hs_pos), ...
     'FontSize', 9, 'FontName', '宋体', 'Color', 'r');

% 负向饱和点
plot(Hs_neg, Bs_neg, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
text(Hs_neg-80, Bs_neg-20, sprintf('-Bs=%.1f mT\n-Hs=%.1f A/m', Bs_neg, Hs_neg), ...
     'FontSize', 9, 'FontName', '宋体', 'Color', 'r');

% 正向剩磁
plot(0, Br_pos, 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
text(20, Br_pos, sprintf('+Br=%.1f mT', Br_pos), ...
     'FontSize', 9, 'FontName', '宋体', 'Color', 'g');

% 负向剩磁
plot(0, Br_neg, 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
text(20, Br_neg, sprintf('-Br=%.1f mT', Br_neg), ...
     'FontSize', 9, 'FontName', '宋体', 'Color', 'g');

% 正向矫顽力
plot(Hc_pos, 0, 'mo', 'MarkerSize', 8, 'MarkerFaceColor', 'm');
text(Hc_pos, 20, sprintf('+Hc=%.1f A/m', Hc_pos), ...
     'FontSize', 9, 'FontName', '宋体', 'Color', 'm');

% 负向矫顽力
plot(Hc_neg, 0, 'mo', 'MarkerSize', 8, 'MarkerFaceColor', 'm');
text(Hc_neg, -30, sprintf('-Hc=%.1f A/m', Hc_neg), ...
     'FontSize', 9, 'FontName', '宋体', 'Color', 'm');

% 添加坐标轴
plot([-350, 350], [0, 0], 'k--', 'LineWidth', 0.5);
plot([0, 0], [-400, 400], 'k--', 'LineWidth', 0.5);

% 标注磁滞回线面积信息
text(-200, 300, sprintf('磁滞回线面积:\n%.1f (A/m)×(mT)\n磁滞损耗:\n%.3f J/m³', ...
     area_hysteresis, area_energy_loss), 'FontSize', 10, 'FontName', '宋体', ...
     'BackgroundColor', 'white', 'EdgeColor', 'black', 'LineWidth', 1);

legend('磁滞回线', '饱和点', '剩磁点', '矫顽力点', 'Location', 'northeast', 'FontName', '宋体');
set(gca, 'FontName', '宋体', 'FontSize', 10);

%% 计算磁导率 μ = B/H
% 真空磁导率 μ₀ = 4π×10⁻⁷ H/m
mu0 = 4*pi*1e-7;

% 计算绝对磁导率和相对磁导率
mu_basic = zeros(size(H_basic));      % 绝对磁导率 (H/m)
mu_r_basic = zeros(size(H_basic));    % 相对磁导率 (无量纲)

for i = 1:length(H_basic)
    if H_basic(i) ~= 0
        % μ = B/H，注意单位转换：B从mT转为T
        mu_basic(i) = (B_basic(i) * 1e-3) / H_basic(i);  % H/m
        mu_r_basic(i) = mu_basic(i) / mu0;                % 相对磁导率
    else
        mu_basic(i) = 0;
        mu_r_basic(i) = 0;
    end
end

%% 输出特殊值
fprintf('\n=== 磁滞回线特殊参数 ===\n');
fprintf('正向饱和磁感应强度 +Bs = %.2f mT\n', Bs_pos);
fprintf('正向饱和磁场强度 +Hs = %.2f A/m\n', Hs_pos);
fprintf('负向饱和磁感应强度 -Bs = %.2f mT\n', Bs_neg);
fprintf('负向饱和磁场强度 -Hs = %.2f A/m\n', Hs_neg);
fprintf('正向剩磁 +Br = %.2f mT\n', Br_pos);
fprintf('负向剩磁 -Br = %.2f mT\n', Br_neg);
fprintf('正向矫顽力 +Hc = %.2f A/m\n', Hc_pos);
fprintf('负向矫顽力 -Hc = %.2f A/m\n', Hc_neg);

% 磁导率信息
[mu_max, idx_mu_max] = max(mu_basic);
[mu_r_max, idx_mu_r_max] = max(mu_r_basic);
fprintf('\n=== 磁导率参数 ===\n');
fprintf('最大磁导率 μ_max = %.6f H/m\n', mu_max);
fprintf('对应磁场强度 H = %.2f A/m\n', H_basic(idx_mu_max));
fprintf('最大相对磁导率 μ_r_max = %.0f\n', mu_r_max);
fprintf('对应磁场强度 H = %.2f A/m\n', H_basic(idx_mu_r_max));

fprintf('\n=== 磁滞回线面积 ===\n');
fprintf('磁滞回线面积 = %.2f (A/m)×(mT)\n', area_hysteresis);
fprintf('磁滞损耗密度 = %.3f J/m³\n', area_energy_loss);
fprintf('面积物理意义：单位体积材料在一个磁化周期中的能量损耗\n');
fprintf('===========================\n\n');

%% 绘制双Y轴磁化曲线图（B-H和μ-H）
figure(3);
set(gcf, 'Position', [300, 100, 900, 600]);

% 创建双Y轴图
yyaxis left
plot(H_basic, B_basic/1000, 'bs-', 'LineWidth', 1.5, 'MarkerSize', 4, 'MarkerFaceColor', 'b');
ylabel('B(T)', 'FontSize', 12, 'Color', 'b');
ylim([0, max(B_basic/1000)*1.1]);
ax = gca;
ax.YColor = 'b';

yyaxis right
plot(H_basic, mu_basic, 'rs-', 'LineWidth', 1.5, 'MarkerSize', 4, 'MarkerFaceColor', 'r');
ylabel('μ(H/m)', 'FontSize', 12, 'Color', 'r');
ylim([0, max(mu_basic)*1.1]);
ax = gca;
ax.YColor = 'r';

% 设置X轴和标题
xlabel('H(A/m)', 'FontSize', 12);
title('(2)绘制双Y轴磁化曲线图', 'FontSize', 14, 'FontName', '宋体');
grid on;

% 添加图例
legend({'B', 'μ'}, 'Location', 'northeast', 'FontSize', 10);

% 设置坐标轴格式
set(gca, 'FontSize', 10);
box on;

%% 绘制单独的相对磁导率曲线
figure(4);
set(gcf, 'Position', [400, 100, 800, 600]);
plot(H_basic, mu_r_basic, 'ro-', 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', 'r');
hold on;
% 标注峰值点
plot(H_basic(idx_mu_r_max), mu_r_max, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
text(H_basic(idx_mu_r_max)+5, mu_r_max+20, sprintf('μ_{r,max}=%.0f\nH=%.1f A/m', mu_r_max, H_basic(idx_mu_r_max)), ...
     'FontSize', 10, 'FontName', '宋体', 'Color', 'k');

xlabel('磁场强度 H (A/m)', 'FontSize', 12, 'FontName', '宋体');
ylabel('相对磁导率 μ_r', 'FontSize', 12, 'FontName', '宋体');
title('铁磁材料相对磁导率曲线 (μ_r-H)', 'FontSize', 14, 'FontName', '宋体');
grid on;
legend('μ_r-H曲线', '最大值点', 'Location', 'northeast', 'FontName', '宋体');
set(gca, 'FontName', '宋体', 'FontSize', 10);

%% 保存图片
print(figure(1), 'figures\基本磁化曲线.png', '-dpng', '-r300');
print(figure(2), 'figures\磁滞回线.png', '-dpng', '-r300');
print(figure(3), 'figures\双Y轴磁化曲线.png', '-dpng', '-r300');
print(figure(4), 'figures\相对磁导率曲线.png', '-dpng', '-r300');

fprintf('图片已保存：基本磁化曲线.png、磁滞回线.png、双Y轴磁化曲线.png、相对磁导率曲线.png、磁导率曲线.png 和 磁滞回线面积.png\n');

% 显示计算的磁导率数据表
fprintf('\n=== 基本磁化曲线数据表（包含磁导率）===\n');
fprintf('编号  %-8s %-8s %-12s %-8s\n', 'H(A/m)', 'B(mT)', 'μ(×10⁻⁶H/m)', 'μr');
fprintf('---  %-8s %-8s %-12s %-8s\n', '-------', '------', '----------', '-----');
for i = 1:length(H_basic)
    fprintf('%2d   %-8.2f %-8.1f %-12.1f %-8.0f\n', i, H_basic(i), B_basic(i), mu_basic(i)*1e6, mu_r_basic(i));
end
fprintf('============================================\n');

% 绘制独立的μ-H曲线图（使用绝对磁导率）
figure(5);
set(gcf, 'Position', [500, 100, 800, 600]);
plot(H_basic, mu_basic*1e6, 'go-', 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', 'g');
hold on;
% 标注峰值点
plot(H_basic(idx_mu_max), mu_max*1e6, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
text(H_basic(idx_mu_max)+5, mu_max*1e6+50, sprintf('μ_{max}=%.1f×10⁻⁶ H/m\nH=%.1f A/m', mu_max*1e6, H_basic(idx_mu_max)), ...
     'FontSize', 10, 'FontName', '宋体', 'Color', 'k');

xlabel('磁场强度 H (A/m)', 'FontSize', 12, 'FontName', '宋体');
ylabel('磁导率 μ (×10⁻⁶ H/m)', 'FontSize', 12, 'FontName', '宋体');
title('铁磁材料磁导率曲线 (μ-H)', 'FontSize', 14, 'FontName', '宋体');
grid on;
legend('μ-H曲线', '最大值点', 'Location', 'northeast', 'FontName', '宋体');
set(gca, 'FontName', '宋体', 'FontSize', 10);

print(figure(5), 'figures\磁导率曲线.png', '-dpng', '-r300');

%% 绘制磁滞回线面积可视化图
figure(6);
set(gcf, 'Position', [600, 100, 800, 600]);

% 绘制磁滞回线并填充面积
fill(H_hysteresis, B_hysteresis, 'cyan', 'FaceAlpha', 0.3, 'EdgeColor', 'b', 'LineWidth', 2);
hold on;
plot(H_hysteresis, B_hysteresis, 'b-', 'LineWidth', 2);

% 标注特殊点
plot(Hs_pos, Bs_pos, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
plot(Hs_neg, Bs_neg, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
plot(0, Br_pos, 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
plot(0, Br_neg, 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
plot(Hc_pos, 0, 'mo', 'MarkerSize', 8, 'MarkerFaceColor', 'm');
plot(Hc_neg, 0, 'mo', 'MarkerSize', 8, 'MarkerFaceColor', 'm');

% 添加坐标轴
plot([-350, 350], [0, 0], 'k--', 'LineWidth', 0.5);
plot([0, 0], [-400, 400], 'k--', 'LineWidth', 0.5);

xlabel('磁场强度 H (A/m)', 'FontSize', 12, 'FontName', '宋体');
ylabel('磁感应强度 B (mT)', 'FontSize', 12, 'FontName', '宋体');
title('磁滞回线面积计算（磁滞损耗）', 'FontSize', 14, 'FontName', '宋体');
grid on;

% 添加面积信息文本框
text(-250, 250, sprintf('磁滞回线面积 = %.1f (A/m)×(mT)\n磁滞损耗密度 = %.3f J/m³\n\n物理意义：\n• 面积越大，磁滞损耗越大\n• 代表材料磁化时的能量消耗\n• 适用于变压器、电机等设计', ...
     area_hysteresis, area_energy_loss), 'FontSize', 9, 'FontName', '宋体', ...
     'BackgroundColor', 'lightyellow', 'EdgeColor', 'black', 'LineWidth', 1);

legend('磁滞回线面积', '磁滞回线', '饱和点', '剩磁点', '矫顽力点', 'Location', 'northeast', 'FontName', '宋体');
set(gca, 'FontName', '宋体', 'FontSize', 10);

print(figure(6), 'figures\磁滞回线面积.png', '-dpng', '-r300');