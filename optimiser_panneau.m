function res = optimiser_panneau(p, X0, algo)
% OPTIMISER_PANNEAU  Minimise la masse sous contraintes avec fmincon,
% depuis plusieurs points de depart.
%
%   res = optimiser_panneau(p)            12 departs aleatoires + 4 coins
%   res = optimiser_panneau(p, X0)        X0 : matrice 2 x N [mm]
%   res = optimiser_panneau(p, X0, algo)  algo : 'sqp' ou 'interior-point'
%
% Probleme :   min  m(tf, c)
%              s.c. g_i(tf, c) <= 0   (i = 1..6, voir marges_contraintes)
%                   bornes sur tf et c
% Variables x = [tf ; c] en mm. Toolbox requise : Optimization Toolbox.
if nargin < 2 || isempty(X0),   X0 = generer_departs(p, 12, 1); end
if nargin < 3 || isempty(algo), algo = p.algo; end

lb = [p.tf_bornes_mm(1); p.c_bornes_mm(1)];
ub = [p.tf_bornes_mm(2); p.c_bornes_mm(2)];

% Fonction objectif : masse en kg, appelee avec x en mm
fobj = @(x) masse_panneau(x(1)*1e-3, x(2)*1e-3, p);
% Contraintes non lineaires : [g, geq] = contraintes_nl(x, p)
fcon = @(x) contraintes_nl(x, p);

opts = optimoptions('fmincon', 'Algorithm', algo, 'Display', 'off', ...
    'ConstraintTolerance', 1e-9, 'OptimalityTolerance', 1e-9, ...
    'StepTolerance', 1e-12, 'MaxIterations', 500, ...
    'MaxFunctionEvaluations', 5000);

N = size(X0, 2);
X = nan(2, N);  M = nan(1, N);  flag = nan(1, N);  gmax = nan(1, N);
for k = 1:N
    try
        [xk, fk, ef] = fmincon(fobj, X0(:,k), [], [], [], [], lb, ub, fcon, opts);
        X(:,k) = xk;  M(k) = fk;  flag(k) = ef;
        gmax(k) = max(fcon(xk));       % pire violation de contrainte
    catch ME
        fprintf('\nErreur au depart %d :\n%s\n', ...
            k, getReport(ME, 'extended'));
        flag(k) = -99;
    end
end

% Un depart est retenu s'il est faisable (violation <= 1e-6) et converge
ok = (gmax <= 1e-6) & (flag > 0);
res.X0 = X0;  res.X = X;  res.M = M;  res.flag = flag;  res.gmax = gmax;
res.ok = ok;  res.n_ok = sum(ok);  res.n_total = N;  res.algo = algo;

if any(ok)
    Mok = M;  Mok(~ok) = Inf;
    [res.m_best, kbest] = min(Mok);
    res.x_best = X(:, kbest);
    % Dispersion des solutions faisables : ~0 => meme optimum partout
    res.dispersion_m  = (max(M(ok)) - min(M(ok))) / min(M(ok));
    g = contraintes_nl(res.x_best, p);
    res.g_best = g;
    noms = noms_contraintes();
    actives = find(g > -1e-4);                 % contraintes saturees
    res.actives = actives;
    lib = noms(actives);
    % Bornes saturees (a 1e-4 mm pres) : elles aussi "contraignent" l'optimum
    xb = res.x_best;
    if xb(1) <= lb(1) + 1e-4, lib{end+1} = 'borne tf_min'; end
    if xb(1) >= ub(1) - 1e-4, lib{end+1} = 'borne tf_max'; end
    if xb(2) <= lb(2) + 1e-4, lib{end+1} = 'borne c_min';  end
    if xb(2) >= ub(2) - 1e-4, lib{end+1} = 'borne c_max';  end
    if isempty(lib), lib = {'aucune'}; end
    res.actives_noms = strjoin(lib, ' + ');
else
    res.m_best = NaN;  res.x_best = [NaN; NaN];  res.dispersion_m = NaN;
    res.g_best = nan(6,1);  res.actives = [];  res.actives_noms = 'aucune (infaisable)';
end
end
