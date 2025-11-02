function out = ua_invlambda_fit(lambda_nm, Ua_V, invertSign)
% ua_invlambda_fit 以 x = 1/λ 与 U 做最简线性拟合，并由斜率计算 h
% 模型：U = a*(1/λ) + b，其中 a = hc/e => h = a*e/c
% 单位：λ 用 nm 输入，内部换算为 m；U 用 V
%
% 用法：
%   out = ua_invlambda_fit();                       % 用示例数据（与你表格一致）
%   out = ua_invlambda_fit(lambda_nm, Ua_V);        % 自带符号自动处理
%   out = ua_invlambda_fit(lambda_nm, Ua_V, true);  % 明确取反（若测得为负）

% 物理常数
c  = 299792458;            % m/s
qe = 1.602176634e-19;      % C

% 默认数据（来自文中示例表）
if nargin < 1 || isempty(lambda_nm)
    lambda_nm = [365 405 436 546 577];
end
if nargin < 2 || isempty(Ua_V)
    Ua_V = [-1.689 -1.343 -1.134 -0.595 -0.480];
end
if nargin < 3 || isempty(invertSign)
    invertSign = 'auto';
end

lambda_nm = lambda_nm(:); Ua_V = Ua_V(:);

% 处理电压符号：截止电压常用正值，这里若平均为负则整体取反
switch string(invertSign)
    case "true"
        U = -Ua_V;
    case "false"
        U = Ua_V;
    otherwise % auto
        U = Ua_V;
        if mean(Ua_V,'omitnan') < 0, U = -Ua_V; end
end

% 自变量：x = 1/λ（m^-1）
lambda_m = lambda_nm * 1e-9;
x = 1 ./ lambda_m;

% 线性拟合（最简）
p = polyfit(x, U, 1);     % U ≈ a*x + b
A = p(1); B = p(2);
Uhat = polyval(p, x);

% R^2（最简）
SSE = sum( (U - Uhat).^2 );
SST = sum( (U - mean(U)).^2 );
R2  = 1 - SSE / SST;

% 由斜率求 h：a = hc/e
h_est = A * qe / c;       % J·s

% 简洁输出
fprintf('\n[U vs 1/λ 线性拟合]\n');
fprintf('  模型: U = a*(1/λ) + b\n');
fprintf('  a = %.6e V·m,  b = %.6f V\n', A, B);
fprintf('  R^2 = %.6f\n');
fprintf('  h = a*e/c = %.6e J·s\n', h_est);

% 绘图
saveDir = fullfile(fileparts(mfilename('fullpath')), 'figures');
if ~exist(saveDir,'dir'), mkdir(saveDir); end
fig = figure('Name','U vs 1/lambda','Color','w');
scatter(x, U, 36, 'b', 'filled'); hold on;
xx = linspace(min(x), max(x), 200);
plot(xx, A*xx + B, 'r-', 'LineWidth', 1.5);
xlabel('1/\lambda (m^{-1})'); ylabel('U_a (V)'); grid on; box on;
legend('数据', sprintf('U = a*(1/\lambda)+b\n a=%.3e V·m, b=%.3f V', A, B), 'Location','best');
exportgraphics(fig, fullfile(saveDir,'Ua_invLambda_fit.png'), 'Resolution', 300);

% 组织返回
out = struct('a',A,'b',B,'R2',R2,'h',h_est,'x',x,'U',U);

end
