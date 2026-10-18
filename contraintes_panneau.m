function s = contraintes_panneau(tf, c, p)
% CONTRAINTES_PANNEAU  Contraintes et resistances limites du sandwich [Pa].
%
% Sorties (champs de la structure s) :
%   sigma_f        contrainte normale max dans la peau (selon p.sigma_exacte)
%   sigma_f_exacte M*Ef*(c/2+tf)/D      (coherente avec la rigidite D)
%   sigma_f_simple M/(b*tf*(c+tf))      (peaux minces, couple d'efforts)
%   tau_c          cisaillement moyen dans l'ame : (F/2)/(b*d)
%   sigma_wr       contrainte critique de plissement des peaux
%   sigma_dimp     contrainte critique de flambement intracellulaire
%   sigma_ind      pression max sous la charge (poinconnement de l'ame)
d = c + tf;
M = p.F .* p.L ./ 4;                    % moment max au centre [N.m]
D = rigidite_flexion(tf, c, p);

s.sigma_f_exacte = M .* p.Ef .* (c./2 + tf) ./ D;
s.sigma_f_simple = M ./ (p.b .* tf .* d);
if p.sigma_exacte
    s.sigma_f = s.sigma_f_exacte;
else
    s.sigma_f = s.sigma_f_simple;
end

s.tau_c = p.F ./ (2 .* p.b .* d);       % effort tranchant V = F/2

% Plissement (Hoff-Mautner) : sigma_wr = k*(Ef*Ez*Gc)^(1/3), independant
% de tf et c. Ez = module de l'ame a travers l'epaisseur.
s.sigma_wr = p.k_wr .* (p.Ef .* p.Ez .* p.Gc).^(1/3) .* ones(size(tf + c));

% Flambement intracellulaire (nid d'abeille uniquement) :
% sigma = 2*Ef/(1-nu^2)*(tf/s)^2
if isnan(p.s_cell)
    s.sigma_dimp = Inf(size(tf + c));
else
    s.sigma_dimp = 2 .* p.Ef ./ (1 - p.nu^2) .* (tf ./ p.s_cell).^2 ...
                   .* ones(size(tf + c));
end

% Poinconnement : peau = poutre sur fondation elastique (l'ame, raideur
% k = Ez*b/c par unite de longueur). Sous une charge ponctuelle, la
% pression max vaut F*beta/(2*b), avec beta = (k/(4*Ef*I))^(1/4),
% I = b*tf^3/12, soit beta = (3*Ez/(Ef*c*tf^3))^(1/4).
beta = (3 .* p.Ez ./ (p.Ef .* c .* tf.^3)).^(1/4);
s.sigma_ind = p.F .* beta ./ (2 .* p.b);
end
