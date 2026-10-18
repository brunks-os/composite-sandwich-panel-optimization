function p = parametres()
% PARAMETRES  Jeu de donnees unique du projet (unites SI : m, N, Pa, kg).
%
% ATTENTION : TOUTES LES VALEURS CI-DESSOUS SONT ILLUSTRATIVES (ARBITRAIRES).
% Elles ont des ordres de grandeur plausibles pour des composites lin/carbone
% et des ames Nomex/balsa, mais ne proviennent d'aucune fiche fournisseur.
% Avant toute utilisation reelle (ou tout chiffre cite en entretien),
% remplacer par les valeurs de vos fiches materiaux / essais.
%
% Toutes les autres fonctions recoivent cette structure (ou une copie
% modifiee) : c'est le SEUL endroit ou l'on change une donnee.

% ---------------- Geometrie et chargement (cas de reference) ------------
p.b         = 0.20;        % largeur de la bande de panneau etudiee [m]
p.L         = 0.60;        % portee entre appuis (distance entre couples) [m]
p.F         = 600;         % charge centrale [N]
p.delta_max = p.L/100;     % fleche admissible [m] (ici L/100 = 6 mm)

% ---------------- Securite -----------------------------------------------
p.SF     = 2.0;   % coefficient de securite sur les contraintes de PEAU
p.SF_ame = 1.0;   % coefficient sur les contraintes d'AME (tau_adm et
                  % sig_crush sont supposes deja des valeurs admissibles)

% ---------------- Variables de conception : bornes -----------------------
p.tf_bornes_mm = [0.2  5];   % epaisseur d'UNE peau [mm]
p.c_bornes_mm  = [3   50];   % epaisseur d'ame [mm]
p.c_pas_mm     = 1;          % pas d'epaisseur d'ame disponible [mm]

% ---------------- Parametres de modele -----------------------------------
p.k_wr         = 0.43;   % coefficient de plissement (0,5 theorique ;
                         % 0,43 avec defauts, plus prudent)
p.sigma_exacte = true;   % true : sigma_f = M*Ef*(c/2+tf)/D (coherent avec D)
                         % false : sigma_f = M/(b*tf*(c+tf)) (peaux minces)
p.algo         = 'sqp';  % 'sqp' ou 'interior-point'
p.au_moins_un_pli = true; % true : tf >= epaisseur d'un pli (assembler_cas)

% ---------------- Bibliotheque de peaux -----------------------------------
% Ef : module dans la direction de L ; rho_f : masse volumique du STRATIFIE
% sig_adm : min(traction, compression) ; t_pli : epaisseur d'un pli cuit
p.peaux.lin     = struct('Ef',12e9, 'rho_f',1250, 'sig_adm',80e6, ...
                         'nu',0.30, 't_pli',0.40e-3);
p.peaux.carbone = struct('Ef',55e9, 'rho_f',1500, 'sig_adm',350e6, ...
                         'nu',0.30, 't_pli',0.25e-3);

% ---------------- Bibliotheque d'ames --------------------------------------
% Ec : module DANS LE PLAN du panneau (sens de L), tres faible pour un
%      nid d'abeille, intervient dans D
% Ez : module a travers l'epaisseur (plissement, poinconnement)
% Gc : module de cisaillement ; tau_adm : cisaillement admissible
% sig_crush : resistance en compression a travers l'epaisseur
% s_cell : taille de cellule (NaN si pas de cellules : balsa)
p.ames.nomex = struct('Ec',2e6,  'Ez',130e6, 'Gc',25e6,  'tau_adm',0.6e6, ...
                      'rho_c',48,  'sig_crush',2.0e6,  's_cell',3.2e-3);
p.ames.balsa = struct('Ec',100e6,'Ez',4.0e9, 'Gc',110e6, 'tau_adm',2.5e6, ...
                      'rho_c',150, 'sig_crush',10e6,   's_cell',NaN);

% ---------------- Combinaisons comparees dans etude_materiaux -------------
p.combos = {'lin','nomex'; 'lin','balsa'; 'carbone','nomex'};

% Cas de reference utilise par defaut
p.peau_ref = 'lin';
p.ame_ref  = 'nomex';
end
