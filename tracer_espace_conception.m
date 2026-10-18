function tracer_espace_conception(q, gr, res, nom_fig)
% TRACER_ESPACE_CONCEPTION  Carte de la masse dans le plan (tf, c) avec les
% frontieres de chaque contrainte (g = 0) et les optima trouves.
%
% Region coloree = domaine faisable (toutes contraintes respectees),
% region grise = domaine infaisable. L'optimum se place sur la frontiere
% faisable, la ou la masse (couleur) est la plus faible.
fig = figure('Visible', 'off', 'Position', [100 100 900 650]);
tf_v = gr.TF_mm(1, :);  c_v = gr.C_mm(:, 1);

% Image en couleurs vraies (RGB) construite a la main : zone faisable
% coloree selon la masse, zone infaisable en gris. Plus robuste qu'un
% imagesc avec NaN (rendu identique sur toutes les versions).
if exist('parula', 'file'), cmap = parula(256); else, cmap = jet(256); end
m_lo = res.m_best;  m_hi = 3 * res.m_best;        % echelle : de m_opt a 3 m_opt
idx  = round(1 + 255 * (gr.M - m_lo) / (m_hi - m_lo));
idx  = min(max(idx, 1), 256);
RGB  = reshape(cmap(idx(:), :), [size(gr.M), 3]);
for k = 1:3
    plan = RGB(:, :, k);
    plan(~gr.ok) = 0.85;                          % gris clair : infaisable
    RGB(:, :, k) = plan;
end
set(gca, 'Color', [0.85 0.85 0.85]);  hold on;
image(tf_v, c_v, RGB);
set(gca, 'YDir', 'normal');
colormap(cmap);  caxis([m_lo m_hi]);
cb = colorbar;
ylabel(cb, 'Masse [kg] (saturee a 3 x m_{opt})');

noms = noms_contraintes();
coul = [0.85 0.1 0.1; 0.1 0.45 0.85; 0.1 0.65 0.2; 0.6 0.3 0.8; 0.95 0.55 0.0; 0.0 0.0 0.0];
leg = {};  hl = [];
for k = 1:6
    Gk = gr.G{k};
    if max(Gk(:)) - min(Gk(:)) < 1e-12 || max(Gk(:)) < 0 || min(Gk(:)) > 0
        continue;                           % contrainte constante ou jamais saturee
    end
    contour(gr.TF_mm, gr.C_mm, Gk, [0 0], 'LineColor', coul(k, :), 'LineWidth', 2);
    hl(end+1) = plot(NaN, NaN, '-', 'Color', coul(k, :), 'LineWidth', 2);
    leg{end+1} = [noms{k} ' (g = 0)'];
end
hl(end+1) = plot(res.x_best(1), res.x_best(2), 'kp', 'MarkerSize', 14, ...
                 'MarkerFaceColor', 'w', 'LineWidth', 1.5);
leg{end+1} = 'Optimum fmincon';
hl(end+1) = plot(gr.tf_mm, gr.c_mm, 'kx', 'MarkerSize', 10, 'LineWidth', 2);
leg{end+1} = 'Optimum grille';
xlabel('Epaisseur d''une peau t_f [mm]');
ylabel('Epaisseur d''ame c [mm]');
title(sprintf('Espace de conception (%s / %s) : faisable colore, infaisable gris', ...
              q.nom_peau, q.nom_ame));
lg = legend(hl, leg, 'Location', 'northeast');
set(lg, 'Color', [1 1 1]);                 % fond blanc : lisible sur la carte
xlim([min(tf_v) - 0.03*(max(tf_v)-min(tf_v)), max(tf_v)]);
ylim([min(c_v) max(c_v)]);
sauver_figure(fig, nom_fig);
end
