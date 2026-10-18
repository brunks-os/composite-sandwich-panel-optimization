function D = rigidite_flexion(tf, c, p)
% RIGIDITE_FLEXION  Rigidite en flexion D = E*I equivalente [N.m^2].
%
%   D = Ef*b*tf*d^2/2 + Ef*b*tf^3/6 + Ec*b*c^3/12,   d = c + tf
%
% Origine des trois termes (theoreme de Huygens) :
%  1) deux peaux a distance d/2 de l'axe neutre : 2*Ef*b*tf*(d/2)^2
%  2) inertie propre des deux peaux : 2*Ef*b*tf^3/12
%  3) contribution de l'ame : Ec*b*c^3/12 (Ec = module dans le plan)
d = c + tf;
D = p.Ef .* p.b .* tf .* d.^2 ./ 2 ...
  + p.Ef .* p.b .* tf.^3 ./ 6 ...
  + p.Ec .* p.b .* c.^3 ./ 12;
end
