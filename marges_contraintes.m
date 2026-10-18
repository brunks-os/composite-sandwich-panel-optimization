function G = marges_contraintes(tf, c, p)
% MARGES_CONTRAINTES  Les 6 contraintes sous forme normalisee g <= 0.
%
% Chaque g est "demande / admissible - 1" : g < 0 = contrainte respectee,
% g = 0 = contrainte saturee (active), g > 0 = violee. La normalisation
% met toutes les contraintes a l'echelle ~1, ce qui aide l'optimiseur.
%
% G est un cell de 6 elements, chacun de la taille de tf + c (scalaire
% pour fmincon, matrice pour la grille). Source unique de verite : la
% fonction non lineaire de fmincon et la grille l'appellent toutes deux.
s     = contraintes_panneau(tf, c, p);
delta = fleche_panneau(tf, c, p);

G = cell(1, 6);
G{1} = delta ./ p.delta_max - 1;                     % fleche
G{2} = s.sigma_f .* p.SF ./ p.sig_adm - 1;           % rupture de la peau
G{3} = s.sigma_f .* p.SF ./ s.sigma_wr - 1;          % plissement
G{4} = s.sigma_f .* p.SF ./ s.sigma_dimp - 1;        % flambement cellule
G{5} = s.tau_c .* p.SF_ame ./ p.tau_adm - 1;         % cisaillement ame
G{6} = s.sigma_ind .* p.SF_ame ./ p.sig_crush - 1;   % poinconnement
end
