# English / French text. Add a key here and use tr(key, lang) in the server
# or i18n(key) in the UI (the UI text is swapped in the browser, so switching
# language never resets the inputs).

TXT <- list(
  app_title         = c(en = "Stressor medium calculator", fr = "Calculateur de milieux stressés"),
  tab_stocks        = c(en = "1 · Stocks & targets", fr = "1 · Solutions & cibles"),
  tab_single        = c(en = "2 · One mixture", fr = "2 · Un mélange"),
  tab_plan          = c(en = "3 · Experiment plan", fr = "3 · Plan d'expérience"),
  tab_help          = c(en = "Help", fr = "Aide"),

  # stressor names
  st_N       = c(en = "Nitrogen (NaNO₃)", fr = "Azote (NaNO₃)"),
  st_P       = c(en = "Phosphorus (K₂HPO₄)", fr = "Phosphore (K₂HPO₄)"),
  st_NaCl    = c(en = "Salt (NaCl → Cl⁻)", fr = "Sel (NaCl → Cl⁻)"),
  st_Gly     = c(en = "Glyphosate (isopropylamine salt)", fr = "Glyphosate (sel d'isopropylamine)"),
  st_Tyl     = c(en = "Tylosin tartrate", fr = "Tartrate de tylosine"),
  st_Temp    = c(en = "Temperature (+5 °C)", fr = "Température (+5 °C)"),
  st_Shade   = c(en = "Shading", fr = "Ombrage"),
  st_Harvest = c(en = "Biomass harvest (−50 %)", fr = "Récolte de biomasse (−50 %)"),
  st_WC      = c(en = "WC medium (top up)", fr = "Milieu WC (compléter)"),

  # stocks tab
  stocks_intro = c(
    en = "Enter the intermediate solutions you have and the concentration you want in the wells. Every concentration can be entered in the unit you prefer; changing a unit converts the number.",
    fr = "Indiquez vos solutions interm\u00e9diaires et la concentration voulue dans les puits. Chaque concentration peut \u00eatre saisie dans l'unit\u00e9 de votre choix ; changer d'unit\u00e9 convertit la valeur."),
  h_stressor    = c(en = "Stressor", fr = "Stresseur"),
  h_wc_dose     = c(en = "Normal WC medium contains", fr = "Le milieu WC normal contient"),
  wc_of         = c(en = "mL/L of a", fr = "mL/L d'une solution \u00e0"),
  wc_stock_txt  = c(en = "g/L stock", fr = "g/L"),
  total_in_well = c(en = "total (WC included)", fr = "au total (WC compris)"),
  np_note       = c(
    en = "N and P: the target is the total concentration in the well, including what normal WC already contains. \u00d7 WC = multiple of normal WC (4 \u00d7 WC = normal WC plus 3 extra doses). mL stock/L = mL of the WC stock solution per litre. The stock concentrations (85.01 g/L NaNO\u2083 and 8.71 g/L K\u2082HPO\u2084, standard WC) only matter when \u00d7 WC or mL stock/L is mixed with mass or molar units; check them against your recipe. Salt, glyphosate and tylosin: the target is the amount added.",
    fr = "N et P : la cible est la concentration totale dans le puits, y compris ce que contient d\u00e9j\u00e0 le WC normal. \u00d7 WC = multiple du WC normal (4 \u00d7 WC = WC normal plus 3 doses). mL stock/L = mL de solution m\u00e8re WC par litre. Les concentrations des solutions m\u00e8res (85,01 g/L NaNO\u2083 et 8,71 g/L K\u2082HPO\u2084, WC standard) n'interviennent que si l'on combine \u00d7 WC ou mL stock/L avec des unit\u00e9s de masse ou molaires ; v\u00e9rifiez-les avec votre recette. Sel, glyphosate et tylosine : la cible est la quantit\u00e9 ajout\u00e9e."),
  h_stock       = c(en = "Intermediate solution", fr = "Solution intermédiaire"),
  h_solvent     = c(en = "Prepared in", fr = "Préparée dans"),
  h_target      = c(en = "Target in wells", fr = "Cible dans les puits"),
  solv_WC       = c(en = "WC medium", fr = "Milieu WC"),
  solv_water    = c(en = "MilliQ water", fr = "Eau milliQ"),
  added         = c(en = "added", fr = "ajouté"),
  h_checks      = c(en = "Check of the intermediate solutions", fr = "Vérification des solutions intermédiaires"),
  checks_intro  = c(
    en = "Share of the final volume each intermediate solution takes when it is the only stressor. In a mixture these shares add up, so they must stay small.",
    fr = "Part du volume final occupée par chaque solution intermédiaire quand elle est seule. Dans un mélange ces parts s'additionnent : elles doivent rester petites."),
  max_frac      = c(en = "Aim: each addition at most (% of volume)", fr = "Objectif : chaque ajout au plus (% du volume)"),
  min_pip       = c(en = "Smallest volume you pipette accurately (µL)", fr = "Plus petit volume pipeté précisément (µL)"),
  min_wc        = c(en = "Warn when WC strength drops below (%)", fr = "Avertir si la force du WC descend sous (%)"),
  general       = c(en = "General settings", fr = "Paramètres généraux"),
  c_target      = c(en = "Target (compound)", fr = "Cible (composé)"),
  c_stock       = c(en = "Stock", fr = "Solution"),
  c_frac        = c(en = "% of volume (alone)", fr = "% du volume (seul)"),
  c_suggest     = c(en = "Stock needed for the aim", fr = "Concentration nécessaire pour l'objectif"),
  c_verdict     = c(en = "Verdict", fr = "Verdict"),
  v_ok          = c(en = "OK", fr = "OK"),
  v_high        = c(en = "Too dilute", fr = "Trop diluée"),
  v_weak        = c(en = "Weaker than target!", fr = "Plus faible que la cible !"),
  save_settings = c(en = "Save settings", fr = "Enregistrer les paramètres"),
  load_settings = c(en = "Load settings", fr = "Charger des paramètres"),
  reset         = c(en = "Reset to defaults", fr = "Valeurs par défaut"),

  # single mixture tab
  choose_st     = c(en = "Chemical stressors in this mixture", fr = "Stresseurs chimiques dans ce mélange"),
  n_wells       = c(en = "Number of wells", fr = "Nombre de puits"),
  well_vol      = c(en = "Volume per well (mL)", fr = "Volume par puits (mL)"),
  margin        = c(en = "Extra volume (%)", fr = "Volume supplémentaire (%)"),
  total_vol     = c(en = "Volume to prepare", fr = "Volume à préparer"),
  recipe        = c(en = "Recipe", fr = "Recette"),
  c_solution    = c(en = "Solution", fr = "Solution"),
  c_volume      = c(en = "Volume to add", fr = "Volume à ajouter"),
  c_share       = c(en = "% of volume", fr = "% du volume"),
  c_final       = c(en = "Final concentration", fr = "Concentration finale"),
  c_wanted      = c(en = "Target", fr = "Cible"),
  total         = c(en = "Total", fr = "Total"),
  order_hint    = c(
    en = "Pipette the WC medium first, then the intermediate solutions, then mix.",
    fr = "Pipeter d'abord le milieu WC, puis les solutions intermédiaires, puis mélanger."),

  # status messages
  s_ok          = c(en = "This mixture can be made.", fr = "Ce mélange est réalisable."),
  s_warning     = c(en = "This mixture can be made, but check the remarks below.", fr = "Ce mélange est réalisable, mais voyez les remarques ci-dessous."),
  s_infeasible  = c(en = "This mixture cannot be made with these intermediate solutions.", fr = "Ce mélange est impossible avec ces solutions intermédiaires."),
  s_wc_only     = c(en = "No chemical stressor selected: plain WC medium (control).", fr = "Aucun stresseur chimique : milieu WC seul (contrôle)."),
  i_over_volume = c(en = "The intermediate solutions together would need %s of the final volume. Use more concentrated intermediate solutions (see tab 1).",
                    fr = "Les solutions intermédiaires occuperaient ensemble %s du volume final. Utilisez des solutions plus concentrées (voir onglet 1)."),
  i_weak_stock  = c(en = "The intermediate solution of %s is not more concentrated than the target.",
                    fr = "La solution intermédiaire de %s n'est pas plus concentrée que la cible."),
  i_singular    = c(en = "The system cannot be solved (an intermediate solution equals the normal WC level).",
                    fr = "Le calcul est impossible (une solution intermédiaire est au niveau du WC normal)."),
  i_small_volume = c(en = "Volume below %s µL for %s: prepare a larger volume or dilute that intermediate solution.",
                     fr = "Volume inférieur à %s µL pour %s : préparez un plus grand volume ou diluez cette solution."),
  i_wc_diluted  = c(en = "The water-based solutions dilute the WC medium to %s of its normal strength (all WC ingredients, incl. trace elements and vitamins).",
                    fr = "Les solutions dans l'eau diluent le milieu WC à %s de sa force normale (tous les composants, y compris oligo-éléments et vitamines)."),
  i_nutrient_off = c(en = "%s is not a stressor here but ends up at %s of its normal WC level.",
                     fr = "%s n'est pas un stresseur ici mais se retrouve à %s de son niveau WC normal."),

  # short remarks for the pipetting sheet
  is_over_volume  = c(en = "Needs %s of the volume", fr = "N\u00e9cessite %s du volume"),
  is_weak_stock   = c(en = "Stock weaker than target: %s", fr = "Solution plus faible que la cible : %s"),
  is_singular     = c(en = "Cannot be solved", fr = "Calcul impossible"),
  is_small_volume = c(en = "< %s \u00b5L: %s", fr = "< %s \u00b5L : %s"),
  is_wc_diluted   = c(en = "WC at %s strength", fr = "WC \u00e0 %s"),
  is_nutrient_off = c(en = "%s at %s of WC level", fr = "%s \u00e0 %s du niveau WC"),

  # plan tab
  plan_intro    = c(
    en = "Build the list of treatments from the 8 stressors. Physical stressors (temperature, shading, harvest) do not change the medium, so treatments that share the same chemical stressors share one medium.",
    fr = "Construisez la liste des traitements à partir des 8 stresseurs. Les stresseurs physiques (température, ombrage, récolte) ne changent pas le milieu : les traitements avec les mêmes stresseurs chimiques partagent un même milieu."),
  levels        = c(en = "Numbers of stressors per treatment", fr = "Nombres de stresseurs par traitement"),
  per_level     = c(en = "Combinations per level (0 = all)", fr = "Combinaisons par niveau (0 = toutes)"),
  seed          = c(en = "Random seed", fr = "Graine aléatoire"),
  control       = c(en = "Include control (no stressor)", fr = "Inclure un contrôle (sans stresseur)"),
  replicates    = c(en = "Replicate wells per treatment", fr = "Puits réplicats par traitement"),
  pool          = c(en = "Stressors to draw from", fr = "Stresseurs utilisés"),
  h_treatments  = c(en = "Treatments", fr = "Traitements"),
  h_media       = c(en = "Media to prepare", fr = "Milieux à préparer"),
  h_recipes     = c(en = "Pipetting sheet", fr = "Fiche de pipetage"),
  download_xlsx = c(en = "Download Excel", fr = "Télécharger Excel"),
  c_treatment   = c(en = "Treatment", fr = "Traitement"),
  c_n           = c(en = "No. stressors", fr = "Nb stresseurs"),
  c_stressors   = c(en = "Stressors", fr = "Stresseurs"),
  c_medium      = c(en = "Medium", fr = "Milieu"),
  c_chem        = c(en = "Chemical stressors", fr = "Stresseurs chimiques"),
  c_ntreat      = c(en = "Treatments", fr = "Traitements"),
  c_wells       = c(en = "Wells", fr = "Puits"),
  c_vol_mL      = c(en = "Volume (mL)", fr = "Volume (mL)"),
  c_status      = c(en = "Status", fr = "Statut"),
  c_remarks     = c(en = "Remarks", fr = "Remarques"),
  st_ok         = c(en = "OK", fr = "OK"),
  st_warning    = c(en = "Check", fr = "À vérifier"),
  st_infeasible = c(en = "Impossible", fr = "Impossible"),
  summary_plan  = c(en = "%d treatments, %d wells (%s plates of 6), %d media, %d impossible.",
                    fr = "%d traitements, %d puits (%s plaques de 6), %d milieux, %d impossibles."),
  none          = c(en = "none", fr = "aucun"),

  help_md = c(en = "help_en", fr = "help_fr")
)

tr <- function(key, lang = "en") {
  x <- TXT[[key]]
  if (is.null(x)) return(key)
  unname(x[[lang]])
}

st_name <- function(id, lang = "en") vapply(id, function(i) tr(paste0("st_", i), lang), "")

# all strings of one language, for the browser-side swap
dict_for <- function(lang) lapply(TXT, function(x) unname(x[[lang]]))
