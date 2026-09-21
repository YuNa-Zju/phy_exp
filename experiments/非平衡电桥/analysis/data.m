% data.m - 最小二乘拟合 Rt vs t 并计算 alpha
% 使用说明：编辑 t 和 Rt 两个向量（列向量或行向量），然后运行脚本。

% --- 用户需修改的数据（示例） ---
% 温度 t (°C)
t = [30 35 40 45 50 55 60 65]';
% 对应电阻 Rt (Ω)
Rt = [56.43 57.44 58.52 59.54 60.61 61.72 62.72 63.81]';
% 若需要从文件读取，可改用: data = load('yourfile.txt'); t = data(:,1); Rt = data(:,2);

% 绘图与线性拟合 R = a + b*t
X = [ones(size(t)) t];
[b,~,resid,~,stats] = regress(Rt,X); % b = [a; slope]
a = b(1);
b_slope = b(2);

% 计算参数协方差（使用普通最小二乘估计）
N = length(t);
s2 = sum(resid.^2)/(N-2); % 残差方差估计
Covb = s2 * inv(X'*X); % 协方差矩阵
se_a = sqrt(Covb(1,1));
se_b = sqrt(Covb(2,2));

% 计算 alpha: Rt = R0(1 + alpha*t) => 若拟合 Rt = a + b t，则 R0 = a (当参考温度为 0°C)
% alpha = b / a
alpha = b_slope / a;
% 用不确定度传播求 alpha 的不确定度
% 对 alpha = b/a, 偏导数: dalpha/db = 1/a, dalpha/da = -b/a^2
ualpha = sqrt( (1/a)^2 * se_b^2 + (-b_slope/(a^2))^2 * se_a^2 + 2*(-b_slope/(a^2))*(1/a)*Covb(1,2) );

% 输出结果
fprintf('拟合结果: R(t) = %.5f + %.7f t (Ω)\n', a, b_slope);
fprintf('参数标准不确定度: se_a = %.5e, se_b = %.5e\n', se_a, se_b);
fprintf('由拟合得到 alpha = %.6e (单位 1/°C), 不确定度 u(alpha) = %.6e\n', alpha, ualpha);
fprintf('决定系数 R^2 = %.5f\n', stats(1));

% 绘图：散点、拟合直线、95% 置信区间
figure('Color','w','Position',[100 100 700 500]);
plot(t,Rt,'ko','MarkerFaceColor','k','DisplayName','实验数据'); hold on;
tt = linspace(min(t),max(t),200)';
Yfit = a + b_slope*tt;
plot(tt, Yfit,'r-','LineWidth',1.5,'DisplayName','线性拟合');

% 计算95%置信带（预测标准误差）
% sigma_pred^2 = s2*(1 + x0'*(X'X)^{-1}*x0)  对于拟合曲线点，去掉 1 项得到拟合带标准误差
invXTX = inv(X'*X);
X0 = [ones(size(tt)) tt];
se_fit = zeros(size(tt));
for i=1:length(tt)
	x0 = X0(i,:)';
	se_fit(i) = sqrt(s2 * (x0' * invXTX * x0));
end
ci = 1.96 * se_fit; % 95% 置信带
fill([tt; flipud(tt)], [Yfit+ci; flipud(Yfit-ci)], [1 0.8 0.8], 'EdgeColor','none', 'FaceAlpha',0.6,'DisplayName','95% 置信带');

xlabel('温度 t / ^\circC','FontSize',12);
ylabel('R_t / \Omega','FontSize',12);
legend('Location','best');
grid on;

% 在图上注释拟合参数及 alpha 结果
txt = sprintf('R(t)=%.4f + %.5e t\nR^2=%.4f\nalpha=%.6e ± %.6e (1/°C)', a, b_slope, stats(1), alpha, ualpha);
annotation('textbox',[0.15,0.65,0.3,0.2],'String',txt,'FitBoxToText','on','BackgroundColor','w','Interpreter','none');

% 保存图像
plotDir = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'figures', 'plots');
if ~exist(plotDir, 'dir'), mkdir(plotDir); end
saveas(gcf,fullfile(plotDir, 'Rt_vs_t_fit.png'));
