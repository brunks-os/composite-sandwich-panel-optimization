function v = verifier_validite(tf, c, p)
% VERIFIER_VALIDITE  Controle des hypotheses du modele de poutre sandwich.
%
% crit_peau_mince : d/tf >= 5,77 -> l'inertie propre des peaux
%   (terme Ef*b*tf^3/6) pese moins de 1 % de D.
% crit_ame_faible : 100*Ef*tf*d^2/(Ec*c^3) >= 16 -> l'ame contribue a
%   moins de ~6 % de D, et l'hypothese "peaux = flexion, ame =
%   cisaillement" est valide.
% Un critere non verifie ne rend pas le calcul faux (D contient deja les
% deux termes) mais la formule de contrainte simplifiee et la repartition
% flexion/cisaillement deviennent moins fiables.
d = c + tf;
v.d_sur_tf = d ./ tf;
v.rapport_ame = 100 .* p.Ef .* tf .* d.^2 ./ (p.Ec .* c.^3);
v.crit_peau_mince = v.d_sur_tf >= 5.77;
v.crit_ame_faible = v.rapport_ame >= 16;
end
