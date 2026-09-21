% alpha_fit.m
% 线性拟合温度系数 α 的完整脚本（最小二乘法）
% 模型：R(T) = R0 * (1 + α * (T - T0))，默认 T0 = 0 ℃，因此 R = R0 + (α R0) * T
% 输出：
%   - R0（Ω）、α（℃^{-1}）
%   - 回归指标：R^2、调整 R^2、残差标准差 s、自由度 ν
%   - α 的标准不确定度 u(α)（由参数协方差传播）与 95% 置信区间
% 图像：
%   - 拟合图：figures/plots/alpha_fit.png
%   - 残差图：figures/plots/alpha_residuals.png

% === 原始数据（来自文档表格） ===
T  = [35 38 41 44 47 50 53 56 59 62]';          % 摄氏温度 (°C)
Rr = [0.04856 0.04895 0.04946 0.05004 0.05060 ...
      0.05124 0.05175 0.05231 0.05286 0.05341]'; % 表中读数 (Ω)，比率臂 M=0.1

% === 比率臂还原真实电阻 ===
M = 0.1;                 % 比率臂（0.1 档）
R = M * Rr;              % 真实电阻 (Ω)

% === 参考温度 ===
T0 = 0;                  % 参考温度（°C），与文档 R = R0 (1 + α t) 一致
 t = T - T0;             %#ok<NASGU> % 这里 t==T，仅保持符号一致性

% === 线性拟合：R = R0 + (α R0) * T ===
mdl = fitlm(T, R, 'linear');   % 截距 + 斜率
b0 = mdl.Coefficients.Estimate(1); % 截距 ≈ R0
b1 = mdl.Coefficients.Estimate(2); % 斜率 ≈ α R0
R0 = b0;
alpha = b1 / b0;               % α = 斜率 / 截距

% 回归指标
rsq     = mdl.Rsquared.Ordinary;
rsq_adj = mdl.Rsquared.Adjusted;
s       = mdl.RMSE;            % 残差标准差（单位：Ω）
nu      = mdl.DFE;             % 自由度 n-2

% 参数协方差与 α 的不确定度（解析传播）
try
    C = mdl.CoefficientCovariance;           % 2x2 协方差矩阵
catch
    % 兼容性兜底：用 SE 和样本相关计算近似协方差（不推荐，仅防断档）
    se = mdl.Coefficients.SE;
    % 近似协方差（忽略协方差项），仅为兜底
    C = diag(se.^2);
end
var_b0   = C(1,1);
var_b1   = C(2,2);
cov_b0b1 = C(1,2);
u_alpha  = sqrt( var_b1/b0^2 + (alpha^2)*var_b0/b0^2 - 2*alpha*cov_b0b1/b0^2 );

% 95% 置信区间（t 分布）
try
    tval = tinv(0.975, nu);
catch
    tval = 1.96; % 兜底：近似 95%
end
ci = [alpha - tval*u_alpha, alpha + tval*u_alpha];

% === 输出结果 ===
fprintf('--- 线性拟合结果 ---\n');
fprintf('R0  = %.6e  Ω\n', R0);
fprintf('α    = %.6e  1/°C\n', alpha);
fprintf('u(α) = %.6e  1/°C\n', u_alpha);
fprintf('α (95%% CI, t, ν=%d) = [%.6e, %.6e]  1/°C\n', nu, ci(1), ci(2));
fprintf('R^2 = %.6f,  R^2_adj = %.6f,  s = %.6e Ω\n', rsq, rsq_adj, s);

% === 绘图并保存 ===
plotDir = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'figures', 'plots');
if ~exist(plotDir, 'dir'), mkdir(plotDir); end
Tf = linspace(min(T)-1, max(T)+1, 200)';
Rf = predict(mdl, Tf);
figure('Color','w'); hold on; grid on; box on;
scatter(T, R*1e3, 45, 'o', 'MarkerFaceColor',[0.2 0.6 1], 'MarkerEdgeColor','k');
plot(Tf, Rf*1e3, 'r-', 'LineWidth',1.6);
xlabel('温度 T / ^\circC');
ylabel('电阻 R / m\Omega');
title('R-T 线性拟合求温度系数 \alpha');
legend('实验数据','线性拟合','Location','northwest');
% 保存拟合图（两个文件名，便于 LaTeX 引用）
try
    exportgraphics(gcf, fullfile(plotDir,'alpha_fit.png'), 'Resolution', 300);
catch
    saveas(gcf, fullfile(plotDir,'alpha_fit.png'));
end


% === 可选：两点法验证（相邻点配对平均） ===
alpha_pairs = (R(2:end) - R(1:end-1)) ./ (R(1:end-1) .* (T(2:end) - T(1:end-1)));
alpha_bar = mean(alpha_pairs);
fprintf('两点法（相邻配对）平均 α = %.6e  1/°C\n', alpha_bar);

% === 残差图 ===
res = mdl.Residuals.Raw;
figure('Color','w'); hold on; grid on; box on;
plot(T, res, 'ko-', 'LineWidth',1.2, 'MarkerFaceColor',[0.8 0.8 0.8]);
yline(0,'r--');
xlabel('温度 T / ^\circC');
ylabel('残差 e / \Omega');
title('线性回归残差图');
try
    exportgraphics(gcf, fullfile(plotDir,'alpha_residuals.png'), 'Resolution', 300);
catch
    saveas(gcf, fullfile(plotDir,'alpha_residuals.png'));
end
