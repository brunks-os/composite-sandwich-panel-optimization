function q = assembler_cas(p0, nom_peau, nom_ame)
% ASSEMBLER_CAS  Fabrique une structure "plate" q pour une combinaison
% peau/ame, a partir des bibliotheques de parametres().
%
% Les fonctions physiques (masse, fleche, contraintes) lisent directement
% q.Ef, q.rho_f, q.Ec, q.Gc, ... sans se soucier de la bibliotheque.
% En Python, ce sera simplement un dictionnaire fusionne.
q = p0;
peau = p0.peaux.(nom_peau);
ame  = p0.ames.(nom_ame);
champs = fieldnames(peau);
for i = 1:numel(champs), q.(champs{i}) = peau.(champs{i}); end
champs = fieldnames(ame);
for i = 1:numel(champs), q.(champs{i}) = ame.(champs{i}); end
% Contrainte de fabrication : une peau a au moins UN pli entier
% (tf >= t_pli). Sans elle, l'optimum pourrait demander une peau plus
% mince qu'un seul pli, irrealisable.
if p0.au_moins_un_pli
    q.tf_bornes_mm(1) = max(p0.tf_bornes_mm(1), q.t_pli * 1e3);
end
q.nom_peau = nom_peau;
q.nom_ame  = nom_ame;
end
