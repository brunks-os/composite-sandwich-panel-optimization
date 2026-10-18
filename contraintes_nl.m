function [g, geq] = contraintes_nl(x, p)
% CONTRAINTES_NL  Fonction de contraintes non lineaires pour fmincon.
%
% Convention fmincon : g(x) <= 0 (inegalites), geq(x) = 0 (egalites).
% Variable d'optimisation : x = [tf ; c] en MILLIMETRES (bon
% conditionnement : les deux variables sont d'ordre 1 a 10, alors qu'en
% metres elles seraient d'ordre 1e-3).
tf = x(1) * 1e-3;     % mm -> m
c  = x(2) * 1e-3;
G  = marges_contraintes(tf, c, p);
g  = [G{:}]';         % vecteur colonne 6 x 1
geq = [];             % aucune contrainte d'egalite
end
