function afficher_optimum(q, res, gr)
% AFFICHER_OPTIMUM  Imprime le detail d'une solution optimale.
noms = noms_contraintes();
tf = res.x_best(1) * 1e-3;  c = res.x_best(2) * 1e-3;

fprintf('  Optimum fmincon (%s) : tf = %.4f mm, c = %.4f mm, m = %.5f kg\n', ...
        res.algo, res.x_best(1), res.x_best(2), res.m_best);
fprintf('  Departs convergents : %d / %d, dispersion de masse = %.2e\n', ...
        res.n_ok, res.n_total, res.dispersion_m);
fprintf('  Contraintes actives : %s\n', res.actives_noms);
if nargin > 2 && ~isnan(gr.m_min)
    fprintf('  Grille exhaustive   : tf = %.4f mm, c = %.4f mm, m = %.5f kg\n', ...
            gr.tf_mm, gr.c_mm, gr.m_min);
    fprintf('  Ecart de masse fmincon vs grille : %+.3f %%\n', ...
            100 * (res.m_best - gr.m_min) / gr.m_min);
end

[delta, dfl, dci] = fleche_panneau(tf, c, q);
[~, mp, ma] = masse_panneau(tf, c, q);
s = contraintes_panneau(tf, c, q);
v = verifier_validite(tf, c, q);
fprintf('  Fleche : %.3f mm (flexion %.3f + cisaillement %.3f) / admissible %.3f mm\n', ...
        1e3*delta, 1e3*dfl, 1e3*dci, 1e3*q.delta_max);
fprintf('  Masse : peaux %.4f kg + ame %.4f kg\n', mp, ma);
fprintf('  sigma_f exacte = %.1f MPa, simplifiee = %.1f MPa (admissible/SF = %.1f MPa)\n', ...
        1e-6*s.sigma_f_exacte, 1e-6*s.sigma_f_simple, 1e-6*q.sig_adm/q.SF);
fprintf('  Plissement : sigma_wr = %.1f MPa ; poinconnement : %.3f MPa (limite %.2f MPa)\n', ...
        1e-6*s.sigma_wr, 1e-6*s.sigma_ind, 1e-6*q.sig_crush);
fprintf('  Cisaillement ame : %.3f MPa (limite %.2f MPa)\n', ...
        1e-6*s.tau_c, 1e-6*q.tau_adm);
fprintf('  Marges g_i (0 = sature) : ');
for i = 1:numel(res.g_best)
    fprintf('%s %+.3f ; ', noms{i}, res.g_best(i));
end
fprintf('\n');
fprintf('  Validite : d/tf = %.1f (>= 5,77 : %d) ; rapport ame = %.1f (>= 16 : %d)\n', ...
        v.d_sur_tf, v.crit_peau_mince, v.rapport_ame, v.crit_ame_faible);
end
