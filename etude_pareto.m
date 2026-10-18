function out = etude_pareto(q, deltas_mm, gr, nom_fig)
% ETUDE_PARETO  Front masse minimale / fleche maximale admissible.
%
% Pour chaque fleche admissible delta_max, on resout le probleme
% d'optimisation (fmincon multi-departs) et on superpose l'enveloppe
% obtenue par la grille. Lecture : a gauche (fleche tres contrainte) la
% rigidite domine ; a droite la masse sature sur un PLATEAU car une
% contrainte de resistance (rupture, plissement...) prend le relais :
% assouplir encore la fleche ne fait plus gagner de masse.
N = numel(deltas_mm);
m_opt = nan(1, N);  m_grille = nan(1, N);  X = nan(2, N);
actives = cell(1, N);
X0 = generer_departs(q, 8, 2);
for i = 1:N
    qi = q;  qi.delta_max = deltas_mm(i) * 1e-3;
    r = optimiser_panneau(qi, X0);
    m_opt(i) = r.m_best;  X(:, i) = r.x_best;  actives{i} = r.actives_noms;
    ok = gr.ok_autres & (gr.delta <= qi.delta_max);   % grille : meme probleme
    if any(ok(:)), m_grille(i) = min(gr.M(ok)); end
end
out.deltas_mm = deltas_mm;  out.m_opt = m_opt;  out.m_grille = m_grille;
out.X = X;  out.actives = actives;

fprintf('  %-10s %-9s %-8s %-8s %-9s %s\n', 'dmax [mm]', 'm [kg]', 'tf [mm]', 'c [mm]', 'grille', 'contraintes actives');
for i = 1:N
    fprintf('  %-10.2f %-9.4f %-8.3f %-8.2f %-9.4f %s\n', deltas_mm(i), ...
            m_opt(i), X(1,i), X(2,i), m_grille(i), actives{i});
end

if nargin >= 4
    fig = figure('Visible', 'off', 'Position', [100 100 800 900]);
    subplot(3, 1, 1);
    plot(deltas_mm, m_grille, 'k-', 'LineWidth', 1.5); hold on;
    plot(deltas_mm, m_opt, 'ro', 'MarkerSize', 6, 'LineWidth', 1.2);
    grid on;
    xlabel('Fleche maximale admissible \delta_{max} [mm]');
    ylabel('Masse minimale [kg]');
    title(sprintf('Front de Pareto masse / fleche (%s / %s)', q.nom_peau, q.nom_ame));
    legend({'Grille exhaustive', 'fmincon (multi-departs)'}, 'Location', 'northeast');
    subplot(3, 1, 2);
    plot(deltas_mm, X(1, :), 'b-o', 'LineWidth', 1.2, 'MarkerSize', 4);
    grid on;
    xlabel('Fleche maximale admissible \delta_{max} [mm]');
    ylabel('Epaisseur de peau t_f [mm]');
    subplot(3, 1, 3);
    plot(deltas_mm, X(2, :), 'm-s', 'LineWidth', 1.2, 'MarkerSize', 4);
    grid on;
    xlabel('Fleche maximale admissible \delta_{max} [mm]');
    ylabel('Epaisseur d''ame c [mm]');
    sauver_figure(fig, nom_fig);
end
end
