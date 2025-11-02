% UA-NU linear fit with covariance propagation to h, W, and nu0
% Method: ordinary least squares on U = m*nu + b
% Uncertainties: use parameter covariance matrix from polyfit's S output
% Then propagate to derived quantities including covariance term
% Units:
%   nu: Hz, U: V, m: V*s, b: V, h: J*s, W: J, nu0: Hz
% Result matches the approach shown in the reference screenshot.

clear; clc;

% ---------------------------
% 1) Raw data (from report)
% ---------------------------
% Wavelengths (nm) and stopping voltages U_a (V)
lambda_nm = [365, 405, 436, 546, 577];
Ua_V      = [-1.689, -1.343, -1.134, -0.595, -0.480];

% Physical constants
c = 299792458;                 % m/s
qe = 1.602176634e-19;          % C

% Convert to frequency (Hz)
nu_Hz = c ./ (lambda_nm*1e-9);

% ---------------------------
% 2) Linear regression U = m*nu + b
% ---------------------------
[p, S] = polyfit(nu_Hz, Ua_V, 1);      % p = [m, b]
m = p(1);
b = p(2);

% Fitted values and residuals
Ua_fit = polyval(p, nu_Hz);
res = Ua_V - Ua_fit;

% R^2
SS_res = sum(res.^2);
SS_tot = sum((Ua_V - mean(Ua_V)).^2);
R2 = 1 - SS_res/SS_tot;

% ---------------------------
% 3) Parameter covariance matrix
% ---------------------------
% From polyfit documentation:
% Cov = (S.normr^2 / S.df) * inv(S.R) * inv(S.R)'
Cov = (S.normr^2 / S.df) * (inv(S.R) * inv(S.R)');

var_m = Cov(1,1);  u_m = sqrt(var_m);
var_b = Cov(2,2);  u_b = sqrt(var_b);
cov_mb = Cov(1,2);

% ---------------------------
% 4) Derived quantities and uncertainties
% ---------------------------
% h = e*m, W = -e*b
h  = qe * m;
u_h = qe * u_m;            % linear factor
W  = -qe * b;
u_W = qe * u_b;            % linear factor

% nu0 = -b/m, with covariance-aware propagation
% partial derivatives
% dnu0/db = -1/m;   dnu0/dm = b/m^2
p_b = -1/m;
p_m =  b/(m^2);
var_nu0 = p_b^2*var_b + p_m^2*var_m + 2*p_b*p_m*cov_mb;
nu0 = -b/m;
u_nu0 = sqrt(var_nu0);

% Optional: red-limit wavelength and its uncertainty
lambda0 = c / nu0;
u_lambda0 = (c / (nu0^2)) * u_nu0;

% ---------------------------
% 5) Pretty print
% ---------------------------
fmt = @(x) sprintf('%.6e', x);

fprintf('Fit model: U = m*nu + b\n');
fprintf('m = %s V*s\n', fmt(m));
fprintf('b = %s V\n',   fmt(b));
fprintf('R^2 = %.6f\n\n', R2);

fprintf('u(m) = %s V*s\n', fmt(u_m));
fprintf('u(b) = %s V\n',   fmt(u_b));
fprintf('cov(m,b) = %s V^2*s\n\n', fmt(cov_mb));

fprintf('h = e*m = %s J*s\n', fmt(h));
fprintf('u(h) = e*u(m) = %s J*s\n', fmt(u_h));

fprintf('W = -e*b = %s J\n', fmt(W));
fprintf('u(W) = e*u(b) = %s J\n\n', fmt(u_W));

fprintf('nu0 = -b/m = %s Hz\n', fmt(nu0));
fprintf('u(nu0) = %s Hz\n', fmt(u_nu0));
fprintf('lambda0 = c/nu0 = %s m\n', fmt(lambda0));
fprintf('u(lambda0) = %s m\n', fmt(u_lambda0));

% ---------------------------
% 6) Plot
% ---------------------------
figure('Color','w');
scatter(nu_Hz, Ua_V, 60, 'k', 'filled'); hold on;
nu_dense = linspace(min(nu_Hz), max(nu_Hz), 200);
Ua_dense = polyval(p, nu_dense);
plot(nu_dense, Ua_dense, 'b-', 'LineWidth', 1.5);
grid on; box on;
xlabel('\nu (Hz)'); ylabel('U_a (V)');
title('Stopping voltage vs frequency: U = m\cdot\nu + b');
legend('Data','OLS fit','Location','best');

% Save figure next to the report figures folder if available
try
    outDir = fullfile(fileparts(mfilename('fullpath')), 'figures');
    if ~exist(outDir, 'dir'); mkdir(outDir); end
    saveas(gcf, fullfile(outDir, 'Ua_nu_fit.png'));
catch ME
    warning('Could not save figure: %s', ME.message);
end
