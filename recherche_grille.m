function gr = recherche_grille(p, n_tf, n_c)
% RECHERCHE_GRILLE  Recherche exhaustive sur grille (tf, c).
%
% On evalue masse et contraintes en TOUS les points d'une grille
% n_c x n_tf (calcul matriciel, sans boucle), on elimine les points qui
% violent une contrainte et on garde le minimum de masse. Ne depend
% d'aucun optimiseur : sert de verite de reference. Precision limitee par
% le pas de grille (le minimum de grille est >= au vrai minimum).
if nargin < 2, n_tf = 500; end
if nargin < 3, n_c  = 500; end

tf_mm = linspace(p.tf_bornes_mm(1), p.tf_bornes_mm(2), n_tf);
c_mm  = linspace(p.c_bornes_mm(1),  p.c_bornes_mm(2),  n_c);
[TF, C] = meshgrid(tf_mm * 1e-3, c_mm * 1e-3);  % TF varie en colonnes, C en lignes

M     = masse_panneau(TF, C, p);
G     = marges_contraintes(TF, C, p);
delta = fleche_panneau(TF, C, p);

ok_autres = true(size(TF));                    % contraintes 2..6
for k = 2:6, ok_autres = ok_autres & (G{k} <= 0); end
ok = ok_autres & (G{1} <= 0);                  % + contrainte de fleche

Mf = M;  Mf(~ok) = Inf;
[mmin, idx] = min(Mf(:));

gr.TF_mm = TF * 1e3;  gr.C_mm = C * 1e3;
gr.M = M;  gr.G = G;  gr.delta = delta;
gr.ok = ok;  gr.ok_autres = ok_autres;
if isinf(mmin)
    gr.m_min = NaN;  gr.tf_mm = NaN;  gr.c_mm = NaN;
else
    gr.m_min = mmin;
    gr.tf_mm = TF(idx) * 1e3;
    gr.c_mm  = C(idx)  * 1e3;
end
end
