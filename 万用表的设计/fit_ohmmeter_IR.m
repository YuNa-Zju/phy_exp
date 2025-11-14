% Fit ohmmeter I-R relationship from Experiment 3
% Model derivation:
%  Circuit total series resistance when measuring Rx is R_total = R0 + Rx,
%  where R0 = R_g' + R' is the fixed internal resistance of the ohmmeter
%  (meter internal + protection + rheostat etc.). With source emf E,
%  the current is
%     I = E / (R0 + Rx).
%  If we work in mA and Ohm, we can rewrite
%     I_mA = K / (R0 + Rx),  with K (mA·Ohm) = 1000*E (A·Ohm).
%  Linearization for fitting:
%     1/I = (1/K) * Rx + (R0/K)  (a straight line in Rx).
%  We fit the line Y = s*Rx + c, then K = 1/s, R0 = c/s.
%
% Data copied from the report table.

clear; clc; close all;

% Rx in Ohm, Ix in mA
Rx = [0, 100, 200, 300, 400, 500, 600, 700, 1000, 2000, 3000, 5000];
Ix_mA = [1.00, 0.73, 0.58, 0.47, 0.40, 0.35, 0.31, 0.27, 0.21, 0.16, 0.07, 0.04];

% Measured Ix is galvanometer current. Total loop current equals m*Ix,
% but we will fit using Ix only and carry m explicitly.
m = 5;  % e.g., 1 mA head -> 5 mA range

% Exclude zero-current points from fits (cannot invert)
mask_valid = Ix_mA > 0;
Rx_fit = Rx(mask_valid);
Ix_fit = Ix_mA(mask_valid);

% --- Linearized fit: 1/Ix vs R ---
Y = 1 ./ Ix_fit; % 1/mA
X = Rx_fit;      % Ohm
[p, S] = polyfit(X, Y, 1);   % Y = s*X + c
s = p(1); c = p(2);
% Parameter estimates (Ix = (K/m)/(R0+R))
% slope s = m/K  =>  K = m/s ;  intercept c = s*R0 => R0 = c/s
K = m / s;          % mA*Ohm
R0 = c / s;         % Ohm

% Goodness of fit
Yhat = polyval(p, X);
res = Y - Yhat;
SS_res = sum(res.^2);
SS_tot = sum((Y - mean(Y)).^2);
R2_lin = 1 - SS_res/SS_tot;

% --- Alternative linear fit as requested: R (dep) vs 1/I (indep) ---
X_alt = 1 ./ Ix_fit;   % 1/mA (independent variable)
Y_alt = Rx_fit;        % Ohm   (dependent variable)
[p_alt, ~] = polyfit(X_alt, Y_alt, 1); % Y_alt = K_alt * X_alt + b_alt
K_alt = p_alt(1);      % slope -> K (mA*Ohm)
b_alt = p_alt(2);      % intercept -> -R0 (so R0 = -b_alt)
R0_alt = -b_alt;
Y_alt_hat = polyval(p_alt, X_alt);
R2_alt = 1 - sum((Y_alt - Y_alt_hat).^2) / sum((Y_alt - mean(Y_alt)).^2);

% Derived checks
I0_pred = K / R0;   % mA at Rx=0
Rx_half = R0;       % at I = I0/2, Rx should equal R0

% --- Nonlinear confirmation fit (Ix-only model) ---
% Ix = (K/m)/(R0 + R) = Keff/(R0 + R)
model = @(b, x) b(1) ./ (b(2) + x);      % b(1)=Keff=K/m, b(2)=R0
% initial from linearized
b0 = [K/m, R0];
opts = statset('nlinfit');
try
    [bhat, R, J, CovB, mse] = nlinfit(Rx_fit, Ix_fit, model, b0, opts);
    K_nl  = m * bhat(1); R0_nl = bhat(2);
catch
    K_nl = NaN; R0_nl = NaN;
end

% --- Print results ---
fmt = @(x) sprintf('%.6f', x);
fprintf('Linearized fit (1/Ix vs R): R^2 = %.6f\n', R2_lin);
fprintf('K = %s mA*Ohm\n', fmt(K));
fprintf('R0 = %s Ohm\n', fmt(R0));
fprintf('Prediction: I_meas at Rx=0 -> %.6f mA (total I=m*Ix)\n', (K/R0)/m);
fprintf('Prediction: Rx at half-scale (total I=I0/2) -> %s Ohm\n', fmt(Rx_half));
if ~isnan(K_nl)
    fprintf('Nonlinear confirm (Ix model): K = %s, R0 = %s\n', fmt(K_nl), fmt(R0_nl));
end

% Print alternative fit results
fprintf('\nAlt fit (R vs 1/Ix): R^2 = %.6f\n', R2_alt);
fprintf('Slope = K/m = %s mA*Ohm\n', fmt(K_alt));
fprintf('=> K = m*(K/m) = %s mA*Ohm\n', fmt(m*K_alt));
fprintf('R0_alt (= -intercept) = %s Ohm\n', fmt(R0_alt));

% --- Plots ---
outDir = fullfile(fileparts(mfilename('fullpath')), 'figures');
if ~exist(outDir, 'dir'); mkdir(outDir); end

% 1) Ix vs R with fitted curve
figure('Color','w');
plot(Rx, Ix_mA, 'ko', 'MarkerFaceColor', [0.2 0.2 0.2]); hold on;
Rx_dense = linspace(min(Rx), max(Rx), 400);
Ix_fit_dense = (K/m) ./ (R0 + Rx_dense);
plot(Rx_dense, Ix_fit_dense, 'b-', 'LineWidth', 1.6);
box on; grid on;
xlabel('R_x (\Omega)'); ylabel('I_x (mA)');
title(sprintf('Ohmmeter model: I_x = (K/m)/(R_0 + R_x),  m=%d', m));
legend('Data','Fit','Location','northeast');
saveas(gcf, fullfile(outDir, 'ohmmeter_I_vs_R_fit.png'));

% 2) Linearization plot 1/Ix vs R
figure('Color','w');
plot(X, Y, 'o', 'MarkerSize', 6, 'MarkerFaceColor', [0.2 0.45 0.9]); hold on;
X_dense = linspace(min(X), max(X), 400);
Y_dense = polyval(p, X_dense);
plot(X_dense, Y_dense, 'r-', 'LineWidth', 1.5);
box on; grid on;
xlabel('R_x (\Omega)'); ylabel('1/I_x (1/mA)');
title('Linearization: 1/I_x = (m/K)R_x + (m/K)R_0');
legend('Data','Linear fit','Location','northwest');
saveas(gcf, fullfile(outDir, 'ohmmeter_linearization.png'));

% 3) Alternative plot: R vs 1/I with fitted line
figure('Color','w');
plot(X_alt, Y_alt, 'o', 'MarkerSize', 6, 'MarkerFaceColor', [0.1 0.6 0.3]); hold on;
X_alt_dense = linspace(min(X_alt), max(X_alt), 400);
Y_alt_dense = polyval(p_alt, X_alt_dense);
plot(X_alt_dense, Y_alt_dense, 'm-', 'LineWidth', 1.5);
box on; grid on;
xlabel('1/I_x (1/mA)'); ylabel('R_x (\Omega)');
title(sprintf('R vs 1/I_x: R_x = (K/m)\cdot(1/I_x) - R_0,  m=%d', m));
legend('Data','Fit','Location','northwest');
saveas(gcf, fullfile(outDir, 'ohmmeter_R_vs_invI_linear.png'));

fprintf('Saved figures to %s\n', outDir);
