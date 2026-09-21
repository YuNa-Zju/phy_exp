% ua_invlambda_k_uncertainty.m
% 实验一数据：对 U 与 1/λ 做线性拟合，计算斜率对应的 k=h/e 的标准偏差与不确定度
% 说明：表格中 U_a 记录为负值（反向电压），物理上采用其绝对值作为截止电压

clear; clc;

% 常数
c = 299792458;                 % 光速 (m/s)
e = 1.602176634e-19;           % 元电荷 (C)，此脚本只用到 k=h/e，不直接用 e

% 数据（来自 tex 表格）
% λ (nm) 与 U_a (V)；表内为负值，取绝对值作为拟合因变量
lambda_nm = [365, 405, 436, 546, 577];
Ua_V      = [-1.689, -1.343, -1.134, -0.595, -0.480];

% 构造自变量 x=1/λ (m^-1)，因变量 y=|U_a| (V)
lambda_m = lambda_nm * 1e-9;
x = 1 ./ lambda_m;          % m^-1
y = abs(Ua_V);               % V

% 线性拟合 y = a*x + b（带截距）
[p, S] = polyfit(x, y, 1);    % p(1)=a, p(2)=b

a = p(1); b = p(2);
% 拟合优度 R^2
yfit = polyval(p, x);
R2 = 1 - sum((y - yfit).^2) / sum((y - mean(y)).^2);

% 系数协方差与标准误差（标准偏差）
% cov(p) = (S.normr^2 / S.df) * inv(R)'*inv(R)
V  = (S.normr^2 / S.df) * (inv(S.R) * inv(S.R)');
se_a = sqrt(V(1,1));          % 斜率 a 的标准误差（标准偏差）

% 将斜率 a（单位 V·m）换算为 k=h/e（单位 V·s），k = a/c
k_hat = a / c;                % V·s
se_k  = se_a / c;             % 标准偏差（标准不确定度）

% 95% 置信区间（扩展不确定度）：t_{0.975, df} * se
alpha = 0.05;
df = S.df;                    % 自由度 n-2
try
    t975 = tinv(1 - alpha/2, df);
catch
    % 若无统计工具箱，可用近似值（df=3 时约 3.182）
    if df == 3
        t975 = 3.182;
    else
        % 简单近似：t ≈ 2（df 不大时偏小，谨慎使用）
        t975 = 2.0;
    end
end
U95_k = t975 * se_k;          % 扩展不确定度（约 95% 置信）

% 打印结果
fprintf("[U–(1/λ) 线性拟合]\n");
fprintf("  a = %.6e V·m\n", a);
fprintf("  b = %.6f V\n", b);
fprintf("  R^2 = %.6f\n\n", R2);

fprintf("[k = h/e]\n");
fprintf("  k_hat = a/c = %.6e V·s\n", k_hat);
fprintf("  se(k) = %.6e V·s  (标准偏差/标准不确定度)\n", se_k);
fprintf("  U95(k) = t(0.975, df=%d)*se = %.6e V·s\n", df, U95_k);

% 可选：若需要 h 的估计与不确定度（h = k*e）
% h_hat = k_hat * e;
% se_h  = se_k  * e;
% U95_h = U95_k * e;
% fprintf("\n[h = k·e]\n  h_hat = %.6e J·s\n  se(h) = %.6e J·s\n  U95(h) = %.6e J·s\n", h_hat, se_h, U95_h);
