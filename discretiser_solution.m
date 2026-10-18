function d = discretiser_solution(x_mm, p)
% DISCRETISER_SOLUTION  Arrondit l'optimum continu a des valeurs
% fabricables : nombre ENTIER de plis par peau, ame au pas c_pas_mm.
%
% L'arrondi se fait vers le HAUT (tf et c plus grands). Toutes les
% contraintes s'ameliorent quand tf ou c augmentent, donc la solution
% arrondie reste faisable ; le surcout en masse mesure le prix de la
% discretisation. On verifie quand meme le resultat.
t_pli_mm = p.t_pli * 1e3;
d.n_plis = ceil(x_mm(1) / t_pli_mm * (1 - 1e-6));   % tolerance numerique
d.tf_mm  = d.n_plis * t_pli_mm;
d.c_mm   = ceil(x_mm(2) / p.c_pas_mm * (1 - 1e-6)) * p.c_pas_mm;

d.m      = masse_panneau(d.tf_mm*1e-3, d.c_mm*1e-3, p);
m_cont   = masse_panneau(x_mm(1)*1e-3, x_mm(2)*1e-3, p);
d.surcout = (d.m - m_cont) / m_cont;                % surcout relatif
d.g      = contraintes_nl([d.tf_mm; d.c_mm], p);
d.ok     = all(d.g <= 1e-6);
end
