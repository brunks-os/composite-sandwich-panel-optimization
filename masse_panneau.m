function [m, m_peaux, m_ame] = masse_panneau(tf, c, p)
% MASSE_PANNEAU  Masse du panneau sandwich [kg].
%   m = b*L*(2*rho_f*tf + rho_c*c)
%
% Entrees (SI) : tf [m] epaisseur d'UNE peau, c [m] epaisseur d'ame.
% Les operations sont terme a terme (.*) : tf et c peuvent etre des
% matrices (utile pour la recherche sur grille).
% Hypotheses : deux peaux identiques, pas de resine/colle en surplus,
% rho_f est la masse volumique du stratifie (fibres + resine).
m_peaux = p.b .* p.L .* (2 .* p.rho_f .* tf);
m_ame   = p.b .* p.L .* (p.rho_c .* c);
m       = m_peaux + m_ame;
end
