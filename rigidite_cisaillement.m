function S = rigidite_cisaillement(tf, c, p)
% RIGIDITE_CISAILLEMENT  Rigidite en cisaillement S = Gc*b*d^2/c [N].
%
% Hypothese : l'ame seule reprend l'effort tranchant, avec un
% cisaillement uniforme sur la hauteur c, et les peaux reprennent la
% flexion (couple d'efforts normaux separes de d = c + tf).
d = c + tf;
S = p.Gc .* p.b .* d.^2 ./ c;
end
