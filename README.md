# Optimisation de masse d'un panneau sandwich en flexion 3 points

Minimiser la masse d'un panneau sandwich (2 peaux + âme) chargé en flexion 3 points, sous contraintes de flèche, de résistance et de stabilité locale. Application visée : paroi latérale de cockpit (peaux lin ou carbone, âme Nomex ou balsa).

> **Toutes les données matériaux et le chargement de `parametres.m` sont arbitraires** (ordres de grandeur plausibles, aucune fiche fournisseur). Les chiffres ci-dessous valent pour ces données. Remplacez-les avant toute conclusion réelle.

## Lancer

```matlab
>> main        % ~30 s ; écrit resultats.txt et figures/*.png
```

Toolbox requise : **Optimization Toolbox** (`fmincon`, `optimoptions`). Tout le reste utilise MATLAB de base.

## Structure (une fonction = une idée)

| Fichier | Rôle |
|---|---|
| `parametres.m` | Seul endroit où l'on change une donnée (SI) |
| `assembler_cas.m` | Fusionne une peau et une âme en une structure plate `q` |
| `masse_panneau.m`, `rigidite_flexion.m`, `rigidite_cisaillement.m`, `fleche_panneau.m` | Modèle physique |
| `contraintes_panneau.m` | σ peau, τ âme, plissement, flambement de cellule, poinçonnement |
| `marges_contraintes.m` | Les 6 contraintes normalisées `g = demandé/admissible − 1 ≤ 0` |
| `contraintes_nl.m` | Contraintes non linéaires au format `fmincon` |
| `optimiser_panneau.m`, `generer_departs.m` | `fmincon` multi-départs (SQP ou interior-point) |
| `recherche_grille.m` | Recherche exhaustive (calcul matriciel) |
| `discretiser_solution.m` | Arrondi à des plis entiers et à un pas d'âme |
| `etude_pareto.m`, `etude_sensibilite.m`, `etude_materiaux.m` | Études |
| `tests_coherence.m` | 3 tests contre des solutions connues |
| `tracer_espace_conception.m`, `sauver_figure.m`, `afficher_optimum.m` | Sorties |

Toutes les fonctions physiques utilisent des opérations terme à terme, donc elles acceptent des scalaires (fmincon) et des matrices (grille). Les unités sont SI dans les fonctions physiques ; l'optimiseur manipule `x = [tf; c]` en **mm** pour un bon conditionnement. Pour le portage Python : mêmes noms, mêmes arguments `(tf, c, p)`, `p` devient un dictionnaire, `fmincon` devient `scipy.optimize.minimize(method='SLSQP')` avec `constraints={'type':'ineq','fun': lambda x: -g(x)}`.

## Modèle et formules

Notation : d = c + tf, M = F·L/4, V = F/2.

- Rigidité de flexion : D = Ef·b·tf·d²/2 + Ef·b·tf³/6 + Ec·b·c³/12 (exacte ; avec Ef = Ec elle redonne E·b·h³/12).
- Flèche : δ = F·L³/(48·D) + F·L/(4·S), avec S = Gc·b·d²/c.
- Contrainte de peau : σf = M·Ef·(c/2 + tf)/D. Cette forme est cohérente avec D. La formule demandée M/(b·tf·d) reste disponible (`p.sigma_exacte = false`) et donne 35,0 au lieu de 35,4 MPa sur le cas de référence.
- Cisaillement d'âme : τc = F/(2·b·d).
- Masse : m = b·L·(2·ρf·tf + ρc·c).
- Plissement des peaux : σwr = 0,43·(Ef·Ez·Gc)^(1/3), avec **Ez le module de l'âme à travers l'épaisseur**, distinct de Ec (module dans le plan, utilisé dans D).
- Flambement de cellule (nid d'abeille) : σdimp = 2·Ef/(1 − ν²)·(tf/s)².
- Poinçonnement : peau en poutre sur fondation élastique, pression maximale F·β/(2·b), β = (3·Ez/(Ef·c·tf³))^(1/4).
- Contraintes : δ ≤ δmax ; σf·SF ≤ min(σadm, σwr, σdimp) ; τc ≤ τadm ; pression de poinçonnement ≤ résistance en compression de l'âme.
- Bornes : tf ≥ 1 pli entier (`p.au_moins_un_pli`), 0,2–5 mm ; c de 3 à 50 mm.

## Résultats (données arbitraires de `parametres.m`)

Cas de référence : b = 200 mm, L = 600 mm, F = 600 N, δmax = 6 mm (L/100), SF = 2, peaux lin, âme Nomex.

| Résultat | Valeur |
|---|---|
| Optimum continu | tf = 0,400 mm (borne 1 pli), c = 31,70 mm, m = 0,3026 kg |
| Contraintes saturées | flèche + borne tf_min |
| Robustesse | 16 départs sur 16 convergent vers le même point (dispersion de masse 3·10⁻⁸) |
| Grille 600 × 600 | m = 0,3027 kg ; écart fmincon/grille −0,03 % |
| Flèche | 5,45 mm de flexion + 0,55 mm de cisaillement |
| Marges | σf 35,4 MPa pour 40 MPa admissibles ; poinçonnement 0,53 pour 2,0 MPa ; τ 0,047 pour 0,6 MPa |
| Solution fabricable | 1 pli de 0,40 mm, c = 32 mm, m = 0,3043 kg (+0,6 %) |

Pareto (lin/Nomex) : la masse passe de 0,677 kg à δmax = 1 mm à 0,448 kg à 2 mm, 0,384 kg à 3 mm, 0,303 kg à 6 mm, 0,280 kg à 8 mm, puis sature à **0,2786 kg** dès δmax ≥ 9 mm. Au-delà de 9 mm, la rupture de la peau remplace la flèche comme contrainte active (tf = 0,464 mm, c = 24,2 mm).

Sensibilité (élasticité d ln m / d ln x autour du cas de référence) : charge F +0,32 ; module de peau Ef −0,29 ; masse volumique d'âme ρc +0,60. Une hausse de 10 % de ρc coûte donc environ 6 % de masse.

Comparaison de matériaux (δmax = 6 mm, solutions fabricables) :

| Peau / âme | m continu | m fabricable | Plis × t_pli, c |
|---|---|---|---|
| lin / Nomex | 0,3026 kg | 0,3043 kg | 1 × 0,40 mm, 32 mm |
| lin / balsa | 0,6115 kg | 0,6540 kg | 2 × 0,40 mm, 23 mm |
| carbone / Nomex | 0,2016 kg | 0,2052 kg | 1 × 0,25 mm, 20 mm |

Tests de cohérence (tous passent) :

- **T1, poutre homogène.** Avec Ec = Ef et Gc → ∞, D égale E·b·h³/12 à 10⁻¹⁶ près et δ égale F·L³/(4·E·b·h³) ; l'écart décroît en 1/Gc (10⁻² à Gc = 10¹⁰, 10⁻¹⁰ à 10¹⁸).
- **T2, optimum analytique.** Avec flèche seule, Ec = 0 et Gc → ∞, la solution fermée est c* = (8·ρf·D_req/(ρc·Ef·b))^(1/3), tf* = 2·D_req/(Ef·b·c*²). Analytique : tf = 0,1647 mm, c = 19,76 mm, m = 0,1778 kg. fmincon : 0,1665 mm, 19,48 mm, 0,1768 kg (écarts 1,1 %, 1,4 %, 0,6 %, de l'ordre de tf/c = 0,8 %, le terme de peau mince étant négligé dans la formule fermée).
- **T3, fmincon contre grille** : 0,03 %.

## Comment ces résultats ont été vérifiés

MATLAB n'était pas disponible dans mon environnement. Le code a été exécuté sous **GNU Octave 8.4** avec un substitut de `fmincon` bâti sur `sqp` (non livré). Les chiffres ont ensuite été recoupés par un calcul Python indépendant (SciPy SLSQP, réécrit à part) : masses de référence, Pareto, trois matériaux et trois élasticités concordent à 4–5 chiffres. Deux conséquences : `fmincon` réel n'a pas tourné (attendez-vous à des écarts de l'ordre de 10⁻⁴ sur tf et c), et la comparaison SQP / interior-point de `resultats_reference_octave.txt` est sans valeur puisque les deux utilisent le même solveur. Les PNG fournis sont des rendus Octave ; ceux de MATLAB seront esthétiquement différents.

## Limites du modèle

1. **Poutre 1D, charge ponctuelle.** Une paroi est une plaque, souvent chargée par une pression répartie (formules différentes : δ = 5qL⁴/(384D) + qL²/(8S)). Les conditions aux limites réelles ne sont ni des appuis simples ni une portée unique.
2. **Peaux isotropes.** Un stratifié lin ou carbone est orthotrope ; Ef dépend de l'orientation des plis, de Vf et du procédé. Le lin a un comportement non linéaire et sensible à l'humidité.
3. **σadm de peau unique.** Il faut le minimum traction/compression dans le sens L, après abattements (fatigue, humidité, température).
4. **Poinçonnement par fondation élastique de Winkler**, charge ponctuelle supposée. Modèle le moins fiable du lot : à valider en priorité.
5. **Plissement et flambement de cellule** : formules classiques avec coefficient 0,43 ; sensibles aux défauts de collage et au sandwich non plan.
6. **Modes de ruine absents** : écrasement/flambement global, décollement peau-âme, flambement par cisaillement de l'âme (crimping), fluage de l'âme, impact.
7. **Poids** : masse de résine ou de colle non comptée, ρf supposé uniforme.
8. **Données arbitraires.** Aucune valeur n'est issue d'une fiche ou d'un essai.
9. **Variables discrètes** : l'arrondi à des plis entiers est fait après coup. Un vrai optimum discret demande une énumération (peu de combinaisons possibles : la grille s'y prête).

## Pour valider

1. Remplacer `parametres.m` par les valeurs de fiches (ou d'essais de caractérisation) et refaire tourner `main`.
2. Modèle éléments finis Abaqus (coque sandwich ou solide pour l'âme) sur le point optimum fabricable : comparer flèche, contrainte de peau et pression sous le point de charge. Un écart de l'ordre de 5 à 10 % est un repère courant pour accepter un modèle analytique (à fixer avec votre encadrant).
3. Essais de flexion 3 points sur 3 éprouvettes du point optimum (ASTM C393, flexion de sandwich) avec mesure de la flèche et identification du mode de ruine.
4. Si le mode de ruine mesuré diffère du mode saturé prédit, ajouter la contrainte correspondante dans `marges_contraintes.m` : une seule fonction à modifier.
