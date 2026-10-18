function [delta, delta_flex, delta_cis] = fleche_panneau(tf, c, p)
% FLECHE_PANNEAU  Fleche au centre en flexion 3 points [m].
%
%   delta = F*L^3/(48*D)  +  F*L/(4*S)
%           \__ flexion __/  \_ cisaillement de l'ame _/
%
% Le deuxieme terme est celui de la poutre de Timoshenko : il peut
% representer 20 a 50 % de la fleche totale pour une ame souple.
D = rigidite_flexion(tf, c, p);
S = rigidite_cisaillement(tf, c, p);
delta_flex = p.F .* p.L.^3 ./ (48 .* D);
delta_cis  = p.F .* p.L ./ (4 .* S);
delta      = delta_flex + delta_cis;
end
