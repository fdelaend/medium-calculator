## Fonctionnement du calculateur

**Onglet 1 – Solutions & cibles.** Indiquez la concentration de chaque solution intermédiaire, si elle a été préparée dans le milieu WC ou dans l'eau milliQ, et la cible dans les puits.

- **N et P** : la cible est la concentration **totale** dans le puits, y compris ce que contient déjà le WC normal. Choisissez l'unité :
  - **× WC** : un multiple du WC normal. 4 × WC = WC normal plus 3 doses.
  - **mg N/L** ou **mg P/L** : masse de l'élément.
  - **mg/L NaNO₃** ou **mg/L K₂HPO₄** : masse du sel.
  - **µM** ou **mM** : concentration molaire.

  Changer d'unité convertit la valeur. Avec le WC standard, 4 × WC = 56,0 mg N/L = 340 mg/L de NaNO₃ pour N, et 9,29 mg P/L = 52,3 mg/L de K₂HPO₄ pour P.
- La colonne *Le milieu WC normal contient* donne la recette du WC : 1 mL/L d'une solution de NaNO₃ et 1,5 mL/L d'une solution de K₂HPO₄, avec la concentration de ces solutions. Les valeurs par défaut (85,01 g/L NaNO₃, 8,71 g/L K₂HPO₄) sont celles du WC standard ; vérifiez-les avec votre recette. Elles n'interviennent que si l'on combine × WC ou *mL stock/L* avec des unités de masse ou molaires.
- Les solutions intermédiaires de N et P peuvent être données en *mL stock/L* : par exemple, un milieu WC préparé avec 10 mL/L de solution de NaNO₃ au lieu de 1 mL/L. Elles peuvent aussi être données en unités de masse ou molaires.
- **Sel** : la cible est la quantité **ajoutée** au milieu, en mg Cl⁻/L ou en mg/L de NaCl (0,607 g de Cl⁻ par g de NaCl : 300 mg Cl⁻/L = 494,5 mg/L de NaCl).
- **Glyphosate et tylosine** : la cible est la quantité ajoutée. La solution et la cible doivent être exprimées sous la même forme (ici, sel d'isopropylamine et tartrate).

Le tableau de vérification montre la part du volume final occupée par chaque solution intermédiaire quand elle est seule. **Dans un mélange ces parts s'additionnent** : elles doivent rester petites (quelques % chacune). La dernière colonne donne la concentration de solution nécessaire pour atteindre l'objectif fixé.

**Onglet 2 – Un mélange.** Cochez les stresseurs chimiques et indiquez le nombre de puits et le volume par puits. Vous obtenez le volume de chaque solution à pipeter et le volume de milieu WC pour compléter.

**Onglet 3 – Plan d'expérience.** Construit la liste des traitements à partir des 8 stresseurs (toutes les combinaisons, ou un tirage aléatoire de *n* combinaisons par niveau). Les traitements avec les mêmes stresseurs chimiques utilisent le même milieu, car la température, l'ombrage et la récolte ne changent pas le milieu. Vous obtenez une recette par milieu et un fichier Excel pour la paillasse.

## Le calcul

Chaque solution (WC seul et chaque solution intermédiaire) a une concentration connue de chaque composé. Avec f_j la fraction du volume occupée par la solution j :

C_i (puits) = Σ_j f_j · c_ij + f_WC · b_i,   avec f_WC = 1 − Σ_j f_j

Ici b_i est le niveau du WC normal (pour N et P : dose WC × concentration de la solution mère ; 0 pour les autres). Pour les stresseurs du mélange, C_i est égal à la cible et le petit système linéaire est résolu pour les f_j. Volume de la solution j = f_j × volume à préparer.

- **Solution préparée dans le WC** : elle contient les nutriments normaux du WC et ne dilue donc pas le milieu. Par exemple, la solution N à 10 mL/L contient 10 doses de N, dont 1 est la dose du WC.
- **Solution préparée dans l'eau** : elle dilue tous les composants du WC. Si N ou P est un stresseur du même mélange, le calcul compense cette dilution. Pour les autres composants du WC (oligo-éléments, vitamines…), l'application indique la force restante du WC.

## Statuts

- **OK** : le mélange est réalisable.
- **À vérifier** : le mélange est réalisable, mais un volume est sous le seuil de pipetage précis, ou les solutions dans l'eau diluent le WC sous le seuil choisi.
- **Impossible** : les solutions occuperaient ensemble plus de 100 % du volume, ou une solution est plus faible que sa cible. Utilisez des solutions intermédiaires plus concentrées.

Les paramètres peuvent être enregistrés dans un fichier CSV et rechargés (onglet 1).
