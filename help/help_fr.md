## Fonctionnement du calculateur

**Onglet 1 – Solutions & cibles.** Indiquez la concentration de chaque solution intermédiaire, si elle a été préparée dans le milieu WC ou dans l'eau milliQ, et la cible dans les puits.

- **N et P** sont comptés en *mL de solution mère WC par litre*. Le WC normal contient 1 mL/L de solution de NaNO₃ et 1,5 mL/L de solution de K₂HPO₄. Une cible de « 4 doses au total » signifie 4 × la quantité normale, soit 3 doses en plus du milieu.
- **Sel** : la cible est le **Cl⁻ ajouté** (en plus du milieu). Le calculateur la convertit en NaCl avec 35,45/58,44 = 0,607 g de Cl⁻ par g de NaCl : 300 mg/L de Cl⁻ = 494,5 mg/L de NaCl.
- **Glyphosate et tylosine** : la cible est la quantité ajoutée. La solution et la cible doivent être exprimées sous la même forme (ici, sel d'isopropylamine et tartrate).

Le tableau de vérification montre la part du volume final occupée par chaque solution intermédiaire quand elle est seule. **Dans un mélange ces parts s'additionnent** : elles doivent rester petites (quelques % chacune). La dernière colonne donne la concentration de solution nécessaire pour atteindre l'objectif fixé.

**Onglet 2 – Un mélange.** Cochez les stresseurs chimiques et indiquez le nombre de puits et le volume par puits. Vous obtenez le volume de chaque solution à pipeter et le volume de milieu WC pour compléter.

**Onglet 3 – Plan d'expérience.** Construit la liste des traitements à partir des 8 stresseurs (toutes les combinaisons, ou un tirage aléatoire de *n* combinaisons par niveau). Les traitements avec les mêmes stresseurs chimiques utilisent le même milieu, car la température, l'ombrage et la récolte ne changent pas le milieu. Vous obtenez une recette par milieu et un fichier Excel pour la paillasse.

## Le calcul

Chaque solution (WC seul et chaque solution intermédiaire) a une concentration connue de chaque composé. Avec f_j la fraction du volume occupée par la solution j :

C_i (puits) = Σ_j f_j · c_ij + f_WC · b_i,   avec f_WC = 1 − Σ_j f_j

Ici b_i est le niveau du WC normal (1 ou 1,5 mL/L pour N et P, 0 pour les autres). Pour les stresseurs du mélange, C_i est égal à la cible et le petit système linéaire est résolu pour les f_j. Volume de la solution j = f_j × volume à préparer.

- **Solution préparée dans le WC** : elle contient les nutriments normaux du WC et ne dilue donc pas le milieu. Par exemple, la solution N à 10 mL/L contient 10 doses de N, dont 1 est la dose du WC.
- **Solution préparée dans l'eau** : elle dilue tous les composants du WC. Si N ou P est un stresseur du même mélange, le calcul compense cette dilution. Pour les autres composants du WC (oligo-éléments, vitamines…), l'application indique la force restante du WC.

## Statuts

- **OK** : le mélange est réalisable.
- **À vérifier** : le mélange est réalisable, mais un volume est sous le seuil de pipetage précis, ou les solutions dans l'eau diluent le WC sous le seuil choisi.
- **Impossible** : les solutions occuperaient ensemble plus de 100 % du volume, ou une solution est plus faible que sa cible. Utilisez des solutions intermédiaires plus concentrées.

Les paramètres peuvent être enregistrés dans un fichier CSV et rechargés (onglet 1).
