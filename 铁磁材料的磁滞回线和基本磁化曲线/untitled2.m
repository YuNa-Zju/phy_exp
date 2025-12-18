% =========================================================================
% 程序二：32点磁滞回线绘制 (Hysteresis Loop)
% =========================================================================
clc; clear; close all;

%% 1. 实验常数定义
N1 = 150; N2 = 150; L = 0.130; S = 1.24e-4; R1 = 2.5; R2 = 10e3; C = 3e-6;
probe_factor = 1/10; % 同样需要除以10

%% 2. 输入32组数据 (原始读数 V)
% 数据已根据图片 "扫描的文稿 25.pdf" 整理
% 格式: [序号, Ux, Uy]
data_raw = [
    1, -2.844, -2.261;
    2, -2.754, -2.148;
    3, -2.665, -1.957;
    4, -2.626, -1.406;
    5, -2.562, -0.9562;
    6, -2.460, -0.4050;
    7, -2.306,  0;       % 矫顽力点附近
    8, -2.216,  0.1462;
    9, -1.998,  0.4950;
    10,-1.652,  0.8437;
    11,-1.217,  1.203;
    12,-0.5125, 1.575;
    13, 0,      1.777;   % 剩磁点附近
    14, 0.6150, 1.946;
    15, 0.7943, 2.002;
    16, 1.409,  2.092;
    17, 1.780,  2.160;
    18, 3.023,  2.250;   % 顶点
    19, 2.729,  1.946;
    20, 2.626,  1.215;
    21, 2.588,  0.9675;
    22, 2.472,  0.4500;
    23, 2.319,  0;       % 矫顽力点 (你读出的 2.319)
    24, 2.075, -0.4050;
    25, 1.755, -0.7987;
    26, 1.217, -1.248;
    27, 0.872, -1.451;
    28, 0,     -1.822;   % 剩磁点 (推测值为0附近)
    29,-0.2434,-1.890;
    30,-0.9096,-2.047;
    31,-1.742, -2.182;
    32,-2.319, -2.250
];
data_raw = [data_raw; data_raw(1,:)];
Ux_raw = data_raw(:, 2);
Uy_raw = data_raw(:, 3);

%% 3. 数据处理
Ux_real = Ux_raw * probe_factor;
Uy_real = Uy_raw * probe_factor;

% 换算为 H 和 B
H_loop = (N1 / (L * R1)) * Ux_real;
B_loop = ((R2 * C) / (N2 * S)) * Uy_real;

%% 4. 平滑插值处理
% --- 【关键修改2：生成平滑曲线】 ---
% 创建插值用的密集坐标轴 (从1到33，插值出500个点)
t = 1:length(H_loop);
t_fine = linspace(1, length(H_loop), 500); 

% 使用 'spline' (样条插值) 让曲线变平滑
H_smooth = interp1(t, H_loop, t_fine, 'spline');
B_smooth = interp1(t, B_loop, t_fine, 'spline');

%% 5. 绘图
figure('Color', 'w', 'Name', '磁滞回线 (平滑版)');
hold on;

% 画平滑曲线 (实线)
plot(H_smooth, B_smooth, 'k-', 'LineWidth', 2); 

% 画原始数据点 (圆圈，用来展示真实测量位置)
plot(H_loop, B_loop, 'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'r');

grid on;
xlabel('磁场强度 H (A/m)', 'FontSize', 12);
ylabel('磁感应强度 B (T)', 'FontSize', 12);
title('磁滞回线 (平滑闭合版)', 'FontSize', 14);

% 标出坐标轴原点
xline(0, '--k', 'Alpha', 0.3);
yline(0, '--k', 'Alpha', 0.3);

% 计算并标注 Hc 和 Br (使用原始数据计算更准确)
% 注意：因为加了一行数据，原来的索引可能微调，但直接找接近0的点更稳健
% 这里依然沿用原来的索引逻辑计算
Hc_val = (abs(H_loop(7)) + abs(H_loop(23))) / 2;
Br_val = (abs(B_loop(13)) + abs(B_loop(28))) / 2;

text(min(H_loop), max(B_loop)*0.9, sprintf('  H_c \\approx %.1f A/m', Hc_val), 'FontSize', 12, 'Color', 'b');
text(min(H_loop), max(B_loop)*0.8, sprintf('  B_r \\approx %.3f T', Br_val), 'FontSize', 12, 'Color', 'b');

legend('拟合曲线', '实验测量点', 'Location', 'SouthEast');
%% --- 追加部分：计算并显示 Hc, Br, Bm, (BH)max ---

% 1. 计算 Bm (最大磁感应强度)
Bm_calc = max(abs(B_loop));

% 2. 计算 Hc (矫顽力 - H轴截距)
% 找到 B 从负变正 和 从正变负 的位置进行线性插值
ind1 = find(B_loop(1:end-1).*B_loop(2:end) <= 0); % 零点索引
Hc_intercepts = [];
for k = 1:length(ind1)
    idx = ind1(k);
    % 线性插值公式: x = x1 + (0-y1)/(y2-y1)*(x2-x1)
    h_int = H_loop(idx) + (0 - B_loop(idx)) / (B_loop(idx+1) - B_loop(idx)) * (H_loop(idx+1) - H_loop(idx));
    Hc_intercepts = [Hc_intercepts, abs(h_int)];
end
Hc_calc = mean(Hc_intercepts);

% 3. 计算 Br (剩磁 - B轴截距)
% 找到 H 从负变正 和 从正变负 的位置
ind2 = find(H_loop(1:end-1).*H_loop(2:end) <= 0);
Br_intercepts = [];
for k = 1:length(ind2)
    idx = ind2(k);
    % 线性插值求 B
    b_int = B_loop(idx) + (0 - H_loop(idx)) / (H_loop(idx+1) - H_loop(idx)) * (B_loop(idx+1) - B_loop(idx));
    Br_intercepts = [Br_intercepts, abs(b_int)];
end
Br_calc = mean(Br_intercepts);

% 4. 计算 (BH)max (最大磁能积)
% 只取第二象限 (H<0, B>0) 和 第四象限 (H>0, B<0) 的点
BH_product = [];
for k = 1:length(H_loop)
    if (H_loop(k) < 0 && B_loop(k) > 0) || (H_loop(k) > 0 && B_loop(k) < 0)
        BH_product = [BH_product, abs(H_loop(k) * B_loop(k))];
    end
end
if isempty(BH_product)
    BH_max_calc = 0;
else
    BH_max_calc = max(BH_product);
end

% --- 打印结果到命令窗口 ---
fprintf('\n================ 计算结果 ================\n');
fprintf('Bm (最大磁感应强度):  %.4f T\n', Bm_calc);
fprintf('Hc (矫顽力):          %.2f A/m\n', Hc_calc);
fprintf('Br (剩磁):            %.4f T\n', Br_calc);
fprintf('(BH)max (最大磁能积): %.2f J/m^3\n', BH_max_calc);
Area_loss = 0.5 * abs(sum(H_loop(1:end-1).*B_loop(2:end) - H_loop(2:end).*B_loop(1:end-1)));
fprintf('磁滞回线面积 (磁滞损耗): %.3f J/m^3\n', Area_loss);
fprintf('==========================================\n');

% --- 更新图上的标注 (可选) ---
% 清除旧的 text 对象 (如果需要，手动删掉之前的 text 代码)
% text(min(H_loop), max(B_loop)*0.9, sprintf('  H_c = %.1f A/m', Hc_calc), 'FontSize', 12, 'Color', 'b');
% text(min(H_loop), max(B_loop)*0.8, sprintf('  B_r = %.3f T', Br_calc), 'FontSize', 12, 'Color', 'b');
% text(min(H_loop), max(B_loop)*0.7, sprintf('  B_m = %.3f T', Bm_calc), 'FontSize', 12, 'Color', 'b');
% text(min(H_loop), max(B_loop)*0.6, sprintf('  [BH]_{max} = %.1f', BH_max_calc), 'FontSize', 12, 'Color', 'b');