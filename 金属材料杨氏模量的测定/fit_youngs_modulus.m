% 金属材料杨氏模量——逐差法与线性拟合法计算与作图
% 数据来源：金属材料杨氏模量的测定3.tex 中“原始数据”两表
% 地区重力加速度（杭州）：
clear; clc;

g = 9.7936;              % m/s^2

% 装置几何参数（多次测量，已按报告中最新数值更新，单位：mm）
D_mm = [1420.5, 1419.8, 1420.0, 1420.2, 1419.5, 1420.0];
b_mm = [  73.50,   73.58,   74.48,   73.62,   74.20,   73.80];
L_mm = [1110.2, 1109.8, 1110.5, 1110.0, 1109.9, 1109.6];
d_mm = [  0.608,   0.612,   0.609,   0.611,   0.610,   0.610];

D = mean(D_mm)/1000;     % m
b = mean(b_mm)/1000;     % m
L = mean(L_mm)/1000;     % m
d = mean(d_mm)/1000;     % m
S = pi*d.^2/4;           % m^2

% 砝码与读数（两次读数，单位：mm）
m = (1:8)';
s1 = [-10.0; -2.0; 2.5; 10.0; 17.1; 22.8; 30.2; 38.0];
s2 = [-10.0; -4.0; 2.7; 10.0; 17.1; 25.1; 31.4; 38.9];
s  = (s1 + s2)/2;        % 平均读数（mm）

%% 逐差法（每 1 kg 的平均读数增量）
% Δs_i = (s_{i+4} - s_i)/4,  i = 1..4
Delta_s = (s(1+4:end) - s(1:end-4))/4;           % mm/kg
Delta_s_bar = mean(Delta_s);                     % mm/kg
k_ds = Delta_s_bar / 1000;                       % m/kg
E_ds = (2*D*g*L) / (b*S*k_ds);                   % Pa

%% 线性拟合法 s = k*m + c
p = polyfit(m, s, 1);              % 单位：mm/kg, mm
k_fit_mm = p(1); c_fit = p(2);
k_fit = k_fit_mm / 1000;           % m/kg

s_pred = polyval(p, m);
SS_res = sum((s - s_pred).^2);
SS_tot = sum((s - mean(s)).^2);
R2 = 1 - SS_res/SS_tot;

E_fit = (2*D*g*L) / (b*S*k_fit);    % Pa

%% 估计斜率不确定度（线性回归标准误差）
n = length(m);
X = [m ones(n,1)];
sigma2 = SS_res/(n-2);
cov = sigma2 * inv(X'*X);
se_k_mm = sqrt(cov(1,1));   % mm/kg 的标准误差
se_k = se_k_mm/1000;        % m/kg

%% 各几何量的标准不确定度（样本标准误差：std/sqrt(N)）
uD = std(D_mm)/sqrt(length(D_mm))/1000; % m
ub = std(b_mm)/sqrt(length(b_mm))/1000; % m
uL = std(L_mm)/sqrt(length(L_mm))/1000; % m
ud = std(d_mm)/sqrt(length(d_mm))/1000; % m

%% 误差传播（相对合成）：对于 E = (2 D g L)/(b S k), S = pi d^2/4
% 相对不确定度组合： (uE/E)^2 = (uD/D)^2 + (uL/L)^2 + (ub/b)^2 + (2*ud/d)^2 + (uk/k)^2
uk = se_k; % m/kg
rel_uE_fit = sqrt( (uD./D).^2 + (uL./L).^2 + (ub./b).^2 + (2*ud./d).^2 + (uk./k_fit).^2 );
uE_fit = E_fit .* rel_uE_fit;

%% 逐差法的不确定度：估计 Delta_s 的标准误差
uDelta_s = std(Delta_s)/sqrt(length(Delta_s)); % mm/kg
uk_ds = uDelta_s/1000; % m/kg
rel_uE_ds = sqrt( (uD./D).^2 + (uL./L).^2 + (ub./b).^2 + (2*ud./d).^2 + (uk_ds./k_ds).^2 );
uE_ds = E_ds .* rel_uE_ds;

%% 敏感性分析：对关键参数 +/-5% 的影响
computeE = @(D_v,b_v,L_v,d_v,k_v) (2*D_v*g*L_v)./(b_v*(pi*d_v.^2/4).*k_v);
params = {'D','d','L','b','k'};
base = struct('D',D,'d',d,'L',L,'b',b,'k',k_fit);
sensitivity = struct();
for i=1:length(params)
	p = params{i};
	val = base.(p);
	up = val*1.05; down = val*0.95;
	% create copies of base
	B_up = base; B_down = base;
	B_up.(p) = up; B_down.(p) = down;
	E_up = computeE(B_up.D, B_up.b, B_up.L, B_up.d, B_up.k);
	E_down = computeE(B_down.D, B_down.b, B_down.L, B_down.d, B_down.k);
	sensitivity.(p).up = E_up;
	sensitivity.(p).down = E_down;
	sensitivity.(p).rel_up_pct = (E_up - E_fit)/E_fit*100;
	sensitivity.(p).rel_down_pct = (E_down - E_fit)/E_fit*100;
end

% 打印敏感性分析结果
fprintf('\n敏感性分析（单项 +5%% / -5%% 对 E 的相对变化）:\n');
for i=1:length(params)
	p = params{i};
	fprintf('  %s : +5%% -> %+5.2f%%, -5%% -> %+5.2f%%\n', p, sensitivity.(p).rel_up_pct, sensitivity.(p).rel_down_pct);
end

%% 输出结果
fprintf('几何量平均: D=%.2f mm, b=%.2f mm, L=%.2f mm, d=%.3f mm\n', mean(D_mm), mean(b_mm), mean(L_mm), mean(d_mm));
fprintf('S=%.3e m^2, g=%.4f m/s^2\n', S, g);
fprintf('逐差法:  \tΔs_bar = %.5f mm/kg,  E = %.3e Pa (%.1f GPa)\n', Delta_s_bar, E_ds, E_ds/1e9);
fprintf('线性拟合: k = %.5f mm/kg, R^2 = %.5f, E = %.3e Pa (%.1f GPa)\n', k_fit_mm, R2, E_fit, E_fit/1e9);
fprintf('\n不确定度估计（线性拟合法）：E = %.3e ± %.3e Pa (%.1f ± %.2f GPa)\n', E_fit, uE_fit, E_fit/1e9, uE_fit/1e9);
fprintf('不确定度估计（逐差法）：E = %.3e ± %.3e Pa (%.1f ± %.2f GPa)\n', E_ds, uE_ds, E_ds/1e9, uE_ds/1e9);

% 打印主要贡献
fprintf('\n相对不确定度分量（%%）： D %.2f, L %.2f, b %.2f, d(×2) %.2f, k %.2f\n', (uD./D)*100, (uL./L)*100, (ub./b)*100, (2*ud./d)*100, (uk./k_fit)*100);

%% 作图
f = figure('Color','w'); hold on; grid on; box on;
scatter(m, s, 60, 'b', 'filled', 'DisplayName','测量平均值');
plot(m, s_pred, 'r-', 'LineWidth', 1.8, 'DisplayName', '线性拟合');
xlabel('砝码质量 m / kg');
ylabel('标尺读数 s / mm');
legend('Location','northwest');

% 注记拟合式与R^2
text(0.6, min(s)+5, sprintf('k = %.4f mm/kg\nR^2 = %.4f', k_fit_mm, R2), 'FontSize', 10, 'BackgroundColor', 'w');

% 保存到 figures
outdir = fullfile(fileparts(mfilename('fullpath')), 'figures');
if ~exist(outdir, 'dir'), mkdir(outdir); end
saveas(f, fullfile(outdir, 'Y_fit.png'));
saveas(f, fullfile(outdir, 'Y_fit.pdf'));

close(f);
