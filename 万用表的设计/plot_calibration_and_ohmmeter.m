% Plots for ammeter/voltmeter calibration and ohmmeter I-R curve
% - Fig1: ΔI vs I_theory (T-shaped axes: x-axis at y=0 in the middle)
% - Fig2: ΔU vs U_theory (T-shaped axes)
% - Fig3: I_x vs R_x (linear)
% - Fig4: I_x vs R_x (semi-log x)
% All numbers copied from the LaTeX tables. Units are shown in labels.

clear; clc; close all;

% ---------------------------
% 1) Ammeter calibration (ΔI vs I_theory)
% ---------------------------
I_theory_mA = [1.00, 2.00, 3.00, 4.00, 4.50];
DeltaI_mA   = [+0.02, +0.03, +0.04, +0.06, +0.05];

figure('Color','w');
plot(I_theory_mA, DeltaI_mA, 'o-', 'LineWidth', 1.5, 'MarkerSize', 7, ...
     'MarkerFaceColor', [0.2 0.45 0.9], 'Color', [0.2 0.45 0.9]);
box on; grid on;
xlabel('I_{theory} (mA)');
ylabel('\Delta I (mA)');
title('\Delta I vs I_{theory}');

% Make T-shaped axes: put x-axis at y=0 (middle), keep y-axis at left
ax = gca; ylim auto;
% Symmetric y-limits around zero for better visual centering
rngY = max(abs(DeltaI_mA));
if rngY == 0, rngY = 1; end
pad = 0.15 * rngY;
ax.YLim = [-rngY - pad, rngY + pad];

% Try to place x-axis at origin (y=0); fall back to drawing a zero-line
try
    ax.XAxisLocation = 'origin';
catch
    % Fallback: draw y=0 reference line manually
    hold on;
    try
        yline(0, '--', 'Color', [0.3 0.3 0.3]);
    catch
        % Older MATLAB: emulate yline
        xl = xlim; plot(xl, [0 0], '--', 'Color', [0.3 0.3 0.3]);
    end
end

% Save
outDir = fullfile(fileparts(mfilename('fullpath')), 'figures');
if ~exist(outDir, 'dir'); mkdir(outDir); end
saveas(gcf, fullfile(outDir, 'DeltaI_vs_I_theory.png'));

% ---------------------------
% 2) Voltmeter calibration (ΔU vs U_theory)
% ---------------------------
U_theory_V = [1.00, 2.00, 3.00, 4.00, 4.50];
DeltaU_V   = [-0.05, -0.05, -0.03, -0.01, -0.01];

figure('Color','w');
plot(U_theory_V, DeltaU_V, 's-', 'LineWidth', 1.5, 'MarkerSize', 7, ...
     'MarkerFaceColor', [0.9 0.5 0.2], 'Color', [0.9 0.5 0.2]);
box on; grid on;
xlabel('U_{theory} (V)');
ylabel('\Delta U (V)');
title('\Delta U vs U_{theory}');

% T-shaped axes again
ax = gca; ylim auto;
rngY = max(abs(DeltaU_V));
if rngY == 0, rngY = 1; end
pad = 0.15 * rngY;
ax.YLim = [-rngY - pad, rngY + pad];
try
    ax.XAxisLocation = 'origin';
catch
    hold on;
    try
        yline(0, '--', 'Color', [0.3 0.3 0.3]);
    catch
        xl = xlim; plot(xl, [0 0], '--', 'Color', [0.3 0.3 0.3]);
    end
end

saveas(gcf, fullfile(outDir, 'DeltaU_vs_U_theory.png'));

% ---------------------------
% 3) Ohmmeter I_x vs R_x
% ---------------------------
Rx_ohm = [0, 100, 200, 300, 400, 500, 600, 700, 1000, 2000, 3000, 5000, 10000, 30000];
Ix_mA  = [1.00, 0.73, 0.58, 0.47, 0.40, 0.35, 0.31, 0.27, 0.21, 0.16, 0.07, 0.04, 0.01, 0.00];

% Linear plot
figure('Color','w');
plot(Rx_ohm, Ix_mA, 'o-', 'LineWidth', 1.5, 'MarkerSize', 6);
box on; grid on;
xlabel('R_x (\Omega)');
ylabel('I_x (mA)');
title('I_x vs R_x ');
saveas(gcf, fullfile(outDir, 'Ix_vs_Rx_linear.png'));

% Semi-log x plot (optional, helpful for wide R range)
figure('Color','w');
semilogx(Rx_ohm(2:end), Ix_mA(2:end), 'd-', 'LineWidth', 1.5, 'MarkerSize', 6); % skip 0 for log scale
box on; grid on;
xlabel('R_x (\Omega)');
ylabel('I_x (mA)');
title(' I_x vs R_x ');
saveas(gcf, fullfile(outDir, 'Ix_vs_Rx_semilogx.png'));

fprintf('Saved figures in: %s\n', outDir);
