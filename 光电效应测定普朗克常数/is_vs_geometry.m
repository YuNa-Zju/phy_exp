% is_vs_geometry.m
% 绘制：
%  1) 饱和电流 Is 与孔径平方 φ^2 的关系，并做线性拟合 Is = a*φ^2 + b
%  2) 饱和电流 Is 与光源距离平方 L^2 的关系，并做线性拟合 Is = c*L^2 + d
%
% 说明：
% - 数据单位按报告表格：Is 使用 1e-10 A 计量，φ、L 使用 mm。
% - 为了与表格轴刻度一致，拟合也在该单位体系中进行；因此 a、b、c、d
%   的单位分别为 (1e-10 A)/mm^2 与 (1e-10 A)。
% - 运行后将在当前目录下的 figures/ 中保存两张图片：
%   Is_vs_phi2.png 与 Is_vs_L2.png。
%
% 作者：
% 日期：自动生成

clear; clc; close all;

%% 数据（来自报告表格）
% 固定 L=400 mm, λ=365 nm，改变孔径 φ
phi_mm = [2, 4, 8];
Is_phi_tab = [40, 138, 445];  % 单位：×1e-10 A

% 固定 φ=4 mm, λ=365 nm，改变光源距离 L
L_mm = [400, 380, 370, 350, 330, 300];
Is_L_tab = [138, 154, 163, 187, 215, 266];  % 单位：×1e-10 A

% 自变量取平方
x_phi2 = phi_mm.^2;     % mm^2
x_L2   = L_mm.^2;       % mm^2

y_phi = Is_phi_tab;     % 仍用 10^-10 A 的数值作图/拟合
y_L   = Is_L_tab;

%% 拟合函数（一次多项式） y = a*x + b
[p_phi, S_phi] = polyfit(x_phi2, y_phi, 1);  % p(1)=a, p(2)=b
[p_L,   S_L  ] = polyfit(x_L2,   y_L,   1);

% 拟合值与 R^2
yfit_phi = polyval(p_phi, x_phi2);
yfit_L   = polyval(p_L,   x_L2  );

R2_phi = 1 - sum((y_phi - yfit_phi).^2) / sum((y_phi - mean(y_phi)).^2);
R2_L   = 1 - sum((y_L   - yfit_L  ).^2) / sum((y_L   - mean(y_L  )).^2);

% 系数标准差（由 polyfit 的 S 结构估计）
V_phi = inv(S_phi.R) * inv(S_phi.R)';
sigma2_phi = (S_phi.normr^2) / S_phi.df;
cov_phi = V_phi * sigma2_phi;
se_a_phi = sqrt(cov_phi(1,1));
se_b_phi = sqrt(cov_phi(2,2));

V_L = inv(S_L.R) * inv(S_L.R)';
sigma2_L = (S_L.normr^2) / S_L.df;
cov_L = V_L * sigma2_L;
se_a_L = sqrt(cov_L(1,1));
se_b_L = sqrt(cov_L(2,2));

%% 打印结果
fprintf("I–φ^2 拟合（单位：10^-10 A 与 mm^2）\n");
fprintf("  I = a*φ^2 + b\n");
fprintf("  a = %.6g ± %.2g  (每 mm^2)\n", p_phi(1), se_a_phi);
fprintf("  b = %.6g ± %.2g\n", p_phi(2), se_b_phi);
fprintf("  R^2 = %.5f\n\n", R2_phi);

fprintf("I–L^2 拟合（单位：10^-10 A 与 mm^2）\n");
fprintf("  I = c*L^2 + d\n");
fprintf("  c = %.6g ± %.2g  (每 mm^2)\n", p_L(1), se_a_L);
fprintf("  d = %.6g ± %.2g\n", p_L(2), se_b_L);
fprintf("  R^2 = %.5f\n\n", R2_L);

%% 绘图保存
outdir = fullfile(pwd, 'figures');
if ~exist(outdir, 'dir'); mkdir(outdir); end

% 1) Is vs φ^2
figure('Color','w','Position',[100 100 720 480]);
scatter(x_phi2, y_phi, 80, 'o', 'MarkerFaceColor',[0.2 0.4 0.86], 'MarkerEdgeColor','k'); hold on;
xline = linspace(min(x_phi2)*0.9, max(x_phi2)*1.1, 200);
plot(xline, polyval(p_phi, xline), '-', 'LineWidth', 2, 'Color', [0.85 0.33 0.1]);
grid on; box on;
xlabel('\phi^2 (mm^2)');
ylabel('I_s (\times 10^{-10} A)');
title('饱和电流 I_s 与孔径平方 \phi^2 的线性关系');
legend({'数据','线性拟合'}, 'Location','best');
text(0.02, 0.95, sprintf('I = %.3g\\cdot \phi^2 %+ .3g\nR^2 = %.4f', p_phi(1), p_phi(2), R2_phi), ...
     'Units','normalized','FontSize',11,'BackgroundColor','w','EdgeColor',[0.8 0.8 0.8]);
saveas(gcf, fullfile(outdir, 'Is_vs_phi2.png'));

% 2) Is vs L^2
figure('Color','w','Position',[100 100 720 480]);
scatter(x_L2, y_L, 80, 's', 'MarkerFaceColor',[0.13 0.7 0.67], 'MarkerEdgeColor','k'); hold on;
xline = linspace(min(x_L2)*0.95, max(x_L2)*1.05, 400);
plot(xline, polyval(p_L, xline), '-', 'LineWidth', 2, 'Color', [0.85 0.33 0.1]);
grid on; box on;
xlabel('L^2 (mm^2)');
ylabel('I_s (\times 10^{-10} A)');
title('饱和电流 I_s 与距离平方 L^2 的线性关系');
legend({'数据','线性拟合'}, 'Location','best');
text(0.02, 0.95, sprintf('I = %.3g\\cdot L^2 %+ .3g\nR^2 = %.4f', p_L(1), p_L(2), R2_L), ...
     'Units','normalized','FontSize',11,'BackgroundColor','w','EdgeColor',[0.8 0.8 0.8]);
saveas(gcf, fullfile(outdir, 'Is_vs_L2.png'));

fprintf('已保存图片至：%s\n', outdir);
