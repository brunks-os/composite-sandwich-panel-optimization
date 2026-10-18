function X0 = generer_departs(p, N, graine)
% GENERER_DEPARTS  Points de depart pour l'optimisation multi-departs [mm].
%
% Renvoie une matrice 2 x (N+4) : les 4 coins du domaine [tf_min,tf_max] x
% [c_min,c_max] (departs deterministes, souvent infaisables, c'est voulu :
% ils testent la robustesse) puis N points tires uniformement au hasard
% (graine fixee pour reproductibilite).
%
% Pourquoi plusieurs departs : fmincon est un optimiseur LOCAL. Si le
% probleme est non convexe, il peut s'arreter sur un minimum local selon
% le point de depart. Si tous les departs convergent vers la meme
% solution, on a une forte presomption d'optimum global (que la recherche
% sur grille confirme ensuite).
lb = [p.tf_bornes_mm(1); p.c_bornes_mm(1)];
ub = [p.tf_bornes_mm(2); p.c_bornes_mm(2)];
rng(graine);
alea  = lb + (ub - lb) .* rand(2, N);
coins = [lb(1) lb(1) ub(1) ub(1); ...
         lb(2) ub(2) lb(2) ub(2)];
X0 = [coins, alea];
end
