% MAIN  Script principal : reproduit TOUS les resultats du projet.
%
% Optimisation de masse d'un panneau sandwich en flexion 3 points
% (peaux + ame) sous contraintes de fleche, de resistance et de
% stabilite locale. Toolbox requise : Optimization Toolbox (fmincon).
% Lancer :  >> main      Duree : quelques dizaines de secondes.
% Sorties : texte dans resultats.txt, figures PNG dans ./figures/.
clear; clc; close all;
dossier = fileparts(mfilename('fullpath'));
if isempty(dossier), dossier = pwd; end
addpath(dossier);
if ~exist(fullfile(dossier, 'figures'), 'dir'), mkdir(fullfile(dossier, 'figures')); end
if exist(fullfile(dossier, 'resultats.txt'), 'file'), delete(fullfile(dossier, 'resultats.txt')); end
diary(fullfile(dossier, 'resultats.txt'));  diary on;

% ======================= 0. DONNEES ===========================================
p = parametres();
q = assembler_cas(p, p.peau_ref, p.ame_ref);
fprintf('=== 0. CAS DE REFERENCE : peaux %s, ame %s ===\n', q.nom_peau, q.nom_ame);
fprintf('  b = %.0f mm, L = %.0f mm, F = %.0f N, delta_max = %.1f mm (L/%.0f), SF peau = %.1f\n', ...
        1e3*q.b, 1e3*q.L, q.F, 1e3*q.delta_max, q.L/q.delta_max, q.SF);
fprintf('  Peau : Ef = %.1f GPa, rho_f = %.0f kg/m3, sig_adm = %.0f MPa\n', ...
        1e-9*q.Ef, q.rho_f, 1e-6*q.sig_adm);
fprintf('  Ame  : Gc = %.0f MPa, Ez = %.0f MPa, rho_c = %.0f kg/m3, tau_adm = %.2f MPa\n', ...
        1e-6*q.Gc, 1e-6*q.Ez, q.rho_c, 1e-6*q.tau_adm);
fprintf('  (valeurs ILLUSTRATIVES : voir parametres.m)\n\n');

% ======================= 1. OPTIMISATION multi-departs ===========================
fprintf('=== 1. OPTIMISATION fmincon, 16 departs (12 aleatoires + 4 coins) ===\n');
X0 = generer_departs(q, 12, 1);
res_sqp = optimiser_panneau(q, X0, 'sqp');
res_ip  = optimiser_panneau(q, X0, 'interior-point');
fprintf('  %-4s %-16s %-16s %-10s %-6s\n', 'k', 'depart [mm]', 'arrivee SQP [mm]', 'm [kg]', 'flag');
for k = 1:size(X0, 2)
    fprintf('  %-4d (%5.2f,%6.2f)   (%6.3f,%7.3f)   %-10.5f %-6d\n', k, ...
            X0(1,k), X0(2,k), res_sqp.X(1,k), res_sqp.X(2,k), res_sqp.M(k), res_sqp.flag(k));
end
fprintf('\n  --- SQP ---\n');
gr = recherche_grille(q, 600, 600);
afficher_optimum(q, res_sqp, gr);
fprintf('\n  --- Interior-point ---\n');
afficher_optimum(q, res_ip, gr);
fprintf('\n  Ecart de masse SQP vs interior-point : %.2e (relatif)\n', ...
        abs(res_sqp.m_best - res_ip.m_best) / res_sqp.m_best);

% ======================= 2. SOLUTION FABRICABLE ===========================
fprintf('\n=== 2. SOLUTION FABRICABLE (plis entiers, ame au pas du catalogue) ===\n');
d = discretiser_solution(res_sqp.x_best, q);
fprintf('  %d plis x %.2f mm = tf %.2f mm ; c = %.0f mm ; m = %.4f kg (surcout %+.1f %%) ; faisable : %d\n', ...
        d.n_plis, 1e3*q.t_pli, d.tf_mm, d.c_mm, d.m, 100*d.surcout, d.ok);

% ======================= 3. ESPACE DE CONCEPTION (figure) =====================
tracer_espace_conception(q, gr, res_sqp, 'fig1_espace_conception');

% ======================= 4. PARETO =============================================
fprintf('\n=== 4. FRONT DE PARETO masse / fleche admissible ===\n');
deltas_mm = [1 1.5 2 3 4 5 6 7 8 9 10 12];
par = etude_pareto(q, deltas_mm, gr, 'fig2_pareto');

% ======================= 5. SENSIBILITE ====================================
fprintf('\n=== 5. SENSIBILITE de la masse optimale (cas de reference) ===\n');
sen = etude_sensibilite(q, 'fig3_sensibilite');

% ======================= 6. MATERIAUX ====================================
fprintf('\n=== 6. COMPARAISON DE MATERIAUX ===\n');
mat = etude_materiaux(p, 'fig4_materiaux');

% ======================= 7. TESTS DE COHERENCE =============================
fprintf('\n=== 7. TESTS DE COHERENCE ===\n');
ok = tests_coherence(p);
if ok, fprintf('  => TOUS LES TESTS PASSENT\n'); else, fprintf('  => AU MOINS UN TEST ECHOUE\n'); end

fprintf('\nTermine. Figures dans %s\n', fullfile(dossier, 'figures'));
diary off;
