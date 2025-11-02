function out = iu_curve(U_V, I_A, opts)
% iu_curve 生成伏安特性曲线并计算 A 类不确定度（默认对饱和电流段）
%
% 用法：
%   out = iu_curve();                           % 使用下方示例数据（与你表格一致）
%   out = iu_curve(U_V, I_A);                   % 传入自定义数据（单位：V 与 A）
%   out = iu_curve(U_V, I_A, struct('lastN',8));% 指定饱和段取最后 N 个点估计 A 类不确定度
%
% 输入：
%   U_V  : 列/行向量，单位 V
%   I_A  : 列/行向量，单位 A（若你以 10^-10 A 记数，请乘 1e-10 后再传入）
%   opts : 可选结构体
%          - lastN (默认 6)  取末尾 lastN 个点估计饱和电流 I_s 的 A 类不确定度
%          - saveDir (默认 'figures') 输出图目录
%
% 输出（结构体 out）：
%   .U, .I                 : 用于作图的数据（列向量）
%   .Is_mean, .Is_s, .Is_uA: 饱和段均值、样本标准差 s、A 类标准不确定度 u_A=s/sqrt(n)
%   .lastN, .idx_sat       : 使用的饱和段点数与索引
%   .figPath               : 图像保存路径
%
% 说明：
%   - A 类不确定度（统计法）按 GB/T 27418：u_A = s/sqrt(n)，s 为样本标准差（n-1 分母）。
%   - 若你有多次重复扫描的 I–U 数据（相同 U 不同 I），可以先对相同 U 汇总取 u_A；本函数的默认做法
%     是针对“饱和区”一段的多点电流值，估计饱和电流的 u_A，更贴合本实验的需要。

% ========================
% 示例数据（与你表格一致）
% ========================
if nargin < 1 || isempty(U_V)
    U_V = [ ...
        -1.49 -1.00 -0.70 -0.40 0.00 0.20 0.30 0.50 0.75 1.50, ...
         2.00  3.00  4.00  5.00 6.00  7.00  8.00  9.00 10.00 11.00, ...
        12.00 14.00 16.00 18.00 20.00 22.00 24.00 26.00 28.00 30.00]';
end
if nargin < 2 || isempty(I_A)
    % 表格单位为 ×1e-10 A，这里换算到 A
    I_1e10 = [ ...
          0   1   3   5   8  13  15  18  22  25, ...
         33  45  53  69  85 103 120 138 156 176, ...
        193 234 272 304 336 370 398 416 430 441]';
    I_A = I_1e10 * 1e-10; % A
end
if nargin < 3 || isempty(opts)
    opts = struct();
end
if ~isfield(opts,'lastN');   opts.lastN   = 6;        end
if ~isfield(opts,'saveDir');  opts.saveDir = 'figures'; end

% 统一为列向量
U_V = U_V(:); I_A = I_A(:);

% 作图
saveDir = fullfile(fileparts(mfilename('fullpath')), opts.saveDir);
if ~exist(saveDir,'dir'); mkdir(saveDir); end

fig = figure('Name','I–U Curve','Color','w');
plot(U_V, I_A*1e10, 'o-r','LineWidth',1.2,'MarkerSize',5,'MarkerFaceColor',[0.2 0.3 1]);
xlabel('U (V)'); ylabel('i (10^{-10} A)'); grid on; box on;
set(gca,'FontName','Times New Roman');
figPath = fullfile(saveDir,'IU_curve.png');
exportgraphics(fig, figPath, 'Resolution', 300);

% 饱和电流段：取末尾 lastN 个点
nAll = numel(I_A);
lastN = min(opts.lastN, nAll);
idx_sat = (nAll-lastN+1):nAll;
Is_vals = I_A(idx_sat);

% A 类不确定度（样本标准差/均方根不确定度）
Is_mean = mean(Is_vals);
if numel(Is_vals) >= 2
    s = std(Is_vals, 1);         % 样本标准差（分母 n-1）在 MATLAB 用第二参数 0；
                                 % 但后续 u_A=s/sqrt(n) 使用 n 个样本，
                                 % 这里选择 std(...,1) + 手动校正更直观：
    s = std(Is_vals, 0);         % 改为 MATLAB 的样本标准差（n-1）
else
    s = 0;
end
uA = s / sqrt(numel(Is_vals));   % A 类标准不确定度

% 输出结构体
out = struct();
out.U = U_V; out.I = I_A;
out.Is_mean = Is_mean; out.Is_s = s; out.Is_uA = uA;
out.lastN = lastN; out.idx_sat = idx_sat;
out.figPath = figPath;

% 控制台摘要
fprintf('\n[I–U 曲线 & A 类不确定度]\n');
fprintf('  点数: %d; 饱和段: 最后 %d 点 (索引 %d..%d)\n', nAll, lastN, idx_sat(1), idx_sat(end));
fprintf('  I_s = %.3f (×10^{-10} A)\n', Is_mean*1e10);
fprintf('  s   = %.3f (×10^{-10} A)\n', s*1e10);
fprintf('  u_A = %.3f (×10^{-10} A)\n', uA*1e10);

end
