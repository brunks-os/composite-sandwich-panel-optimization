function ok_global = tests_coherence(p)
% TESTS_COHERENCE  Verifie le code contre des solutions connues.
%
% T1 : poutre homogene. Si l'ame est faite du meme materiau que les
%      peaux (Ec = Ef = E) et ne se cisaille pas (Gc -> infini), la poutre
%      sandwich EST une poutre pleine d'epaisseur h = c + 2*tf :
%          D = E*b*h^3/12  et  delta = F*L^3/(4*E*b*h^3).
%      (Ec -> infini seul ne suffit pas : D -> infini et delta -> 0.)
% T2 : optimum analytique. Avec une ame sans rigidite (Ec = 0), sans
%      cisaillement (Gc -> infini), peaux minces (D ~ Ef*b*tf*c^2/2) et
%      la seule contrainte de fleche, le probleme a une solution fermee :
%          D_req = F*L^3/(48*delta_max)
%          c*  = (8*rho_f*D_req/(rho_c*Ef*b))^(1/3)
%          tf* = 2*D_req/(Ef*b*c*^2)
%      (on annule dm/dc avec tf = 2*D_req/(Ef*b*c^2) injecte dans m).
q0 = assembler_cas(p, 'carbone', 'nomex');
ok_global = true;

% ---------------- T1 : limite poutre homogene -----------------------------
fprintf('  T1 - Limite poutre homogene (Ec = Ef, Gc -> infini)\n');
q = q0;  E = q.Ef;  q.Ec = E;
tf = 3e-3;  c = 20e-3;  h = c + 2*tf;
D_ref = E * q.b * h^3 / 12;
d_ref = q.F * q.L^3 / (4 * E * q.b * h^3);
fprintf('     %-12s %-14s %-14s\n', 'Gc [Pa]', 'delta [mm]', 'ecart relatif');
for Gc = [1e8, 1e10, 1e12, 1e15, 1e18]
    q.Gc = Gc;
    dl = fleche_panneau(tf, c, q);
    fprintf('     %-12.0e %-14.6f %-14.2e\n', Gc, 1e3*dl, abs(dl - d_ref)/d_ref);
end
err_D = abs(rigidite_flexion(tf, c, q) - D_ref) / D_ref;
err_d = abs(dl - d_ref) / d_ref;
t1 = (err_D < 1e-10) && (err_d < 1e-8);
fprintf('     Ecart sur D : %.1e ; ecart sur delta (Gc = 1e18) : %.1e  -> %s\n', ...
        err_D, err_d, ifelse_txt(t1));
ok_global = ok_global && t1;

% ---------------- T2 : optimum analytique ---------------------------------
fprintf('  T2 - Optimum analytique (fleche seule, Ec = 0, Gc -> infini, peaux minces)\n');
q = q0;
q.Ef = 70e9;  q.rho_f = 1500;  q.rho_c = 50;
q.Ec = 0;  q.Gc = 1e15;
q.sig_adm = 1e15;  q.tau_adm = 1e15;  q.sig_crush = 1e15;  q.s_cell = NaN;
q.Ez = 1e12;                              % desactive les autres contraintes
q.tf_bornes_mm = [0.01 5];  q.c_bornes_mm = [1 200];
D_req   = q.F * q.L^3 / (48 * q.delta_max);
c_an    = (8 * q.rho_f * D_req / (q.rho_c * q.Ef * q.b))^(1/3);
tf_an   = 2 * D_req / (q.Ef * q.b * c_an^2);
m_an    = masse_panneau(tf_an, c_an, q);
r = optimiser_panneau(q, generer_departs(q, 10, 5));
e_tf = abs(r.x_best(1)*1e-3 - tf_an) / tf_an;
e_c  = abs(r.x_best(2)*1e-3 - c_an)  / c_an;
e_m  = abs(r.m_best - m_an) / m_an;
fprintf('     Analytique : tf = %.4f mm, c = %.3f mm, m = %.5f kg (tf/c = %.1f %%)\n', ...
        1e3*tf_an, 1e3*c_an, m_an, 100*tf_an/c_an);
fprintf('     fmincon    : tf = %.4f mm, c = %.3f mm, m = %.5f kg\n', ...
        r.x_best(1), r.x_best(2), r.m_best);
fprintf('     Ecarts relatifs : tf %.2f %%, c %.2f %%, m %.2f %% (attendu ~ tf/c, terme de peau mince neglige)\n', ...
        100*e_tf, 100*e_c, 100*e_m);
t2 = (e_c < 0.03) && (e_m < 0.01) && (e_tf < 0.05);
fprintf('     -> %s\n', ifelse_txt(t2));
ok_global = ok_global && t2;

% ---------------- T3 : fmincon vs grille sur le cas de reference ------------
fprintf('  T3 - fmincon contre grille (cas de reference)\n');
q = assembler_cas(p, p.peau_ref, p.ame_ref);
r  = optimiser_panneau(q);
gr = recherche_grille(q, 600, 600);
e  = abs(r.m_best - gr.m_min) / gr.m_min;
t3 = (e < 5e-3) && (r.m_best <= gr.m_min * (1 + 1e-6));
fprintf('     fmincon %.5f kg, grille %.5f kg, ecart %.3f %% -> %s\n', ...
        r.m_best, gr.m_min, 100*e, ifelse_txt(t3));
ok_global = ok_global && t3;
end

function t = ifelse_txt(ok)
% Petite fonction locale : texte PASS / ECHEC
if ok, t = 'PASS'; else, t = 'ECHEC'; end
end
