function out = etude_sensibilite(q, nom_fig)
% ETUDE_SENSIBILITE  Sensibilite de la masse optimale a F, Ef et rho_c.
%
% On multiplie un parametre a la fois par 0,8 ... 1,2, on re-optimise a
% chaque fois et on trace m_opt / m_ref. L'elasticite e = d(ln m)/d(ln x)
% (pente locale en log-log, calculee entre les facteurs 0,9 et 1,1) se lit
% directement : e = 0,5 signifie "+10 % sur le parametre => +5 % de masse".
% Attention : Ef varie seul (sig_adm inchange), on isole l'effet de la
% RIGIDITE de la peau, pas d'un changement de materiau.
champs = {'F', 'Ef', 'rho_c'};
noms   = {'F (charge)', 'E_f (module de peau)', '\rho_c (masse vol. ame)'};
fact   = 0.8:0.1:1.2;
X0 = generer_departs(q, 8, 3);

m = nan(numel(champs), numel(fact));
x = nan(2, numel(champs), numel(fact));
for i = 1:numel(champs)
    for j = 1:numel(fact)
        qi = q;  qi.(champs{i}) = q.(champs{i}) * fact(j);
        r = optimiser_panneau(qi, X0);
        m(i, j) = r.m_best;  x(:, i, j) = r.x_best;
    end
end
j_ref = find(abs(fact - 1) < 1e-9);  j_lo = find(abs(fact - 0.9) < 1e-9);
j_hi  = find(abs(fact - 1.1) < 1e-9);
elast = log(m(:, j_hi) ./ m(:, j_lo)) ./ log(1.1/0.9);

out.champs = champs;  out.fact = fact;  out.m = m;  out.elasticite = elast;
fprintf('  Masse de reference : %.4f kg\n', m(1, j_ref));
for i = 1:numel(champs)
    fprintf('  Elasticite de la masse optimale a %-6s : %+.3f   (m/m_ref : ', champs{i}, elast(i));
    fprintf('%.3f ', m(i, :) / m(i, j_ref));
    fprintf(')\n');
end

if nargin >= 2
    fig = figure('Visible', 'off', 'Position', [100 100 800 550]);
    marqueurs = {'-o', '-s', '-^'};
    hold on;
    for i = 1:numel(champs)
        plot(fact, m(i, :) / m(i, j_ref), marqueurs{i}, 'LineWidth', 1.5, 'MarkerSize', 6);
    end
    grid on;
    xlabel('Facteur multiplicatif applique au parametre [-]');
    ylabel('Masse optimale normalisee m_{opt} / m_{ref} [-]');
    title('Sensibilite de la masse optimale');
    legend(noms, 'Location', 'northwest');
    sauver_figure(fig, nom_fig);
end
end
