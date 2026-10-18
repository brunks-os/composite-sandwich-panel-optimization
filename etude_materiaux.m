function out = etude_materiaux(p, nom_fig)
% ETUDE_MATERIAUX  Compare les combinaisons peau/ame de p.combos.
%
% Pour chacune : optimum continu (fmincon multi-departs), puis solution
% FABRICABLE (nombre entier de plis, ame au pas du catalogue).
combos = p.combos;
n = size(combos, 1);
m_cont = nan(1, n);  m_disc = nan(1, n);  parts = nan(n, 2);
etiq = cell(1, n);

fprintf('  %-16s %-8s %-8s %-9s %-9s %-6s %-9s %s\n', 'Combinaison', 'tf [mm]', 'c [mm]', ...
        'm cont.', 'm fabr.', 'plis', 'tf/c fabr.', 'contraintes actives');
for i = 1:n
    q = assembler_cas(p, combos{i, 1}, combos{i, 2});
    r = optimiser_panneau(q, generer_departs(q, 8, 4));
    etiq{i} = sprintf('%s / %s', combos{i, 1}, combos{i, 2});
    if isnan(r.m_best)
        fprintf('  %-16s infaisable\n', etiq{i});  continue;
    end
    d = discretiser_solution(r.x_best, q);
    m_cont(i) = r.m_best;  m_disc(i) = d.m;
    [~, mp, ma] = masse_panneau(d.tf_mm*1e-3, d.c_mm*1e-3, q);
    parts(i, :) = [mp, ma];
    fprintf('  %-16s %-8.3f %-8.2f %-9.4f %-9.4f %-6d %.2f/%-5.0f %s (faisable : %d)\n', ...
            etiq{i}, r.x_best(1), r.x_best(2), r.m_best, d.m, d.n_plis, ...
            d.tf_mm, d.c_mm, r.actives_noms, d.ok);
end
out.etiquettes = etiq;  out.m_cont = m_cont;  out.m_disc = m_disc;  out.parts = parts;

if nargin >= 2
    fig = figure('Visible', 'off', 'Position', [100 100 800 550]);
    bar(parts, 'stacked');
    set(gca, 'XTickLabel', etiq);
    grid on;
    ylabel('Masse du panneau fabricable [kg]');
    xlabel('Combinaison peau / ame');
    title('Comparaison de materiaux (masse minimale, solution arrondie)');
    legend({'Peaux (2)', 'Ame'}, 'Location', 'northeast');
    for i = 1:n
        if ~isnan(m_disc(i))
            text(i, m_disc(i), sprintf('%.3f kg', m_disc(i)), ...
                 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        end
    end
    sauver_figure(fig, nom_fig);
end
end
