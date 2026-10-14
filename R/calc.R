# Calculation engine for the stressor-medium calculator.
# Pure functions (no Shiny) so they can be tested on their own.
#
# Concept
# -------
# Every solution that goes into a mixture (plain WC medium and each
# intermediate stock) is described by its concentration of every chemical
# stressor compound. The mixture concentration of compound i is
#
#     C_i = sum_j f_j * c_ij + f_0 * b_i
#
# where f_j is the volume fraction of stock j, f_0 = 1 - sum(f_j) is the
# fraction of plain WC medium, c_ij the concentration of compound i in stock j
# and b_i the concentration of i in plain WC medium (0 for compounds that are
# not WC ingredients). Setting C_i equal to the target for every stressor in
# the mixture gives a small linear system
#
#     sum_j f_j * (c_ij - b_i) = target_i - b_i
#
# which is solved for f. This handles stocks prepared in WC medium (they carry
# the normal WC nutrients) as well as stocks prepared in water (they dilute
# the WC nutrients, which the system compensates for when N or P is part of
# the mixture).

CHEM_IDS <- c("N", "P", "NaCl", "Gly", "Tyl")
PHYS_IDS <- c("Temp", "Shade", "Harvest")
ALL_IDS <- c(CHEM_IDS, PHYS_IDS)

# Molar masses (g/mol) and the element / ion the concentration can be
# expressed as. Glyphosate and tylosin are only handled as mass of the salt.
COMPOUNDS <- data.frame(
  id       = CHEM_IDS,
  formula  = c("NaNO₃", "K₂HPO₄", "NaCl", "", ""),
  mw       = c(84.995, 174.176, 58.443, NA, NA),
  el       = c("N", "P", "Cl⁻", NA, NA),
  el_mass  = c(14.007, 30.974, 35.453, NA, NA),
  stringsAsFactors = FALSE
)

CL_FRACTION_NACL <- 35.453 / 58.443 # mass fraction of Cl- in NaCl

# Units. The internal (base) unit of every compound is mg/L of the compound
# itself (mg/L NaNO3, mg/L K2HPO4, mg/L NaCl, mg/L glyphosate salt, ...).
#   ng/L ug/L mg/L g/L : mass of the compound per litre
#   mgEl/L gEl/L        : mass of the element / ion (mg N/L, mg P/L, mg Cl-/L)
#   uM mM               : molar concentration
#   xWC                 : multiple of the amount in normal WC medium
#   mLstock             : mL of the WC stock solution per litre
TARGET_UNITS <- list(
  N    = c("xWC", "mgEl/L", "mg/L", "uM", "mM"),
  P    = c("xWC", "mgEl/L", "mg/L", "uM", "mM"),
  NaCl = c("mgEl/L", "gEl/L", "mg/L", "g/L", "mM"),
  Gly  = c("ng/L", "ug/L", "mg/L", "g/L"),
  Tyl  = c("ng/L", "ug/L", "mg/L", "g/L")
)
STOCK_UNITS <- list(
  N    = c("mLstock", "mg/L", "g/L", "mgEl/L", "mM"),
  P    = c("mLstock", "mg/L", "g/L", "mgEl/L", "mM"),
  NaCl = c("mg/L", "g/L", "mgEl/L", "gEl/L", "mM"),
  Gly  = c("ng/L", "ug/L", "mg/L", "g/L"),
  Tyl  = c("ng/L", "ug/L", "mg/L", "g/L")
)

unit_label <- function(unit, id) {
  cmp <- COMPOUNDS[COMPOUNDS$id == id, ]
  switch(unit,
    "ug/L"    = "µg/L",
    "mg/L"    = if (nzchar(cmp$formula)) paste("mg/L", cmp$formula) else "mg/L",
    "g/L"     = if (nzchar(cmp$formula)) paste("g/L", cmp$formula) else "g/L",
    "mgEl/L"  = paste0("mg ", cmp$el, "/L"),
    "gEl/L"   = paste0("g ", cmp$el, "/L"),
    "uM"      = "µM",
    "xWC"     = "× WC",
    "mLstock" = "mL stock/L",
    unit)
}

# mg/L of compound corresponding to 1 `unit`, for one settings row `r`
# (r needs wc_dose and wc_stock_gL for the WC-related units).
unit_factor <- function(unit, id, r = NULL) {
  cmp <- COMPOUNDS[COMPOUNDS$id == id, ]
  switch(unit,
    "ng/L"    = 1e-6,
    "ug/L"    = 1e-3,
    "mg/L"    = 1,
    "g/L"     = 1e3,
    "mgEl/L"  = cmp$mw / cmp$el_mass,
    "gEl/L"   = 1e3 * cmp$mw / cmp$el_mass,
    "uM"      = cmp$mw / 1e3,
    "mM"      = cmp$mw,
    "xWC"     = r$wc_dose * r$wc_stock_gL,   # mL/L x g/L = mg/L
    "mLstock" = r$wc_stock_gL,
    stop("Unknown unit: ", unit))
}

to_base <- function(value, unit, id, r = NULL) value * unit_factor(unit, id, r)
from_base <- function(value, unit, id, r = NULL) value / unit_factor(unit, id, r)

# Default settings: values given by Laura Willam (Oct 2026).
#  N and P are WC ingredients ("dose"): normal WC contains wc_dose mL/L of a
#  stock solution of wc_stock_gL g/L (standard WC: 85.01 g/L NaNO3 and
#  8.71 g/L K2HPO4 -- to be checked against the lab recipe). Their target is
#  the TOTAL concentration in the well, normal WC included.
#  For the other stressors ("mass") the target is the amount ADDED.
default_settings <- function() {
  data.frame(
    id            = CHEM_IDS,
    kind          = c("dose", "dose", "mass", "mass", "mass"),
    wc_dose       = c(1, 1.5, 0, 0, 0),
    wc_stock_gL   = c(85.01, 8.71, 0, 0, 0),
    stock_value   = c(10, 10, 1000, 50, 0.5),
    stock_unit    = c("mLstock", "mLstock", "mg/L", "mg/L", "g/L"),
    stock_solvent = c("WC", "WC", "water", "water", "water"),
    target_value  = c(4, 4, 300, 300, 0.2),
    target_unit   = c("xWC", "xWC", "mgEl/L", "ug/L", "mg/L"),
    stringsAsFactors = FALSE
  )
}

# Bring settings saved by an earlier version of the app to the current format.
upgrade_settings <- function(s) {
  d <- default_settings()
  if (!"wc_dose" %in% names(s)) {
    s$wc_dose <- if ("wc_baseline" %in% names(s)) s$wc_baseline else d$wc_dose[match(s$id, d$id)]
    s$target_unit[s$id == "NaCl" & s$target_unit == "mg/L"] <- "mgEl/L" # was Cl-
  }
  if (!"wc_stock_gL" %in% names(s)) s$wc_stock_gL <- d$wc_stock_gL[match(s$id, d$id)]
  fix <- c("x" = "xWC", "mL/L" = "mLstock", "µg/L" = "ug/L")
  for (col in c("stock_unit", "target_unit")) {
    hit <- s[[col]] %in% names(fix)
    s[[col]][hit] <- fix[s[[col]][hit]]
  }
  s
}

# Derived quantities in base units (mg/L of compound).
prepare_settings <- function(s) {
  n <- nrow(s)
  s$baseline <- ifelse(s$kind == "dose", s$wc_dose * s$wc_stock_gL, 0)
  s$stock_base <- vapply(seq_len(n), function(k)
    to_base(s$stock_value[k], s$stock_unit[k], s$id[k], s[k, ]), 0)
  s$target_base <- vapply(seq_len(n), function(k)
    to_base(s$target_value[k], s$target_unit[k], s$id[k], s[k, ]), 0)
  # targets of non-WC compounds are amounts added on top of the medium
  s$target_base <- ifelse(s$kind == "dose", s$target_base, s$baseline + s$target_base)
  s
}

# Concentration of every compound (rows) in every stock (columns).
composition_matrix <- function(p) {
  n <- nrow(p)
  m <- matrix(0, n, n, dimnames = list(p$id, p$id))
  for (j in seq_len(n)) {
    if (p$stock_solvent[j] == "WC") m[, j] <- p$baseline
    m[j, j] <- p$stock_base[j]
  }
  m
}

# ---- single mixture ------------------------------------------------------

#' Solve one mixture.
#' @param settings data.frame like default_settings()
#' @param included chemical stressor ids in the mixture
#' @param volume_mL final volume to prepare
#' @param min_pipette_uL smallest volume considered accurately pipettable
#' @param min_wc_strength warn when the WC ingredients fall below this fraction
#' @return list with status ("ok", "warning", "infeasible"), a recipe table,
#'   the final concentrations and a list of issue codes.
solve_mixture <- function(settings, included, volume_mL,
                          min_pipette_uL = 2, min_wc_strength = 0.95) {
  p <- prepare_settings(settings)
  included <- intersect(CHEM_IDS, included)
  comp <- composition_matrix(p)
  b <- setNames(p$baseline, p$id)
  target <- setNames(p$target_base, p$id)
  issues <- list()

  f <- setNames(numeric(0), character(0))
  if (length(included) > 0) {
    A <- comp[included, included, drop = FALSE] - b[included]
    rhs <- target[included] - b[included]
    f <- tryCatch(solve(A, rhs), error = function(e) NULL)
    if (is.null(f)) {
      return(list(status = "infeasible",
                  issues = list(list(code = "singular", ids = included)),
                  recipe = NULL, final = NULL, fractions = NULL,
                  stock_fraction = NA, wc_strength = NA))
    }
    f <- setNames(as.numeric(f), included)
  }
  f0 <- 1 - sum(f)

  weak <- names(f)[f <= 0]
  # a stock that is not more concentrated than its target
  weak <- union(weak, included[p$stock_base[match(included, p$id)] <=
                                 target[included]])
  if (length(weak) > 0) issues <- c(issues, list(list(code = "weak_stock", ids = weak)))
  if (f0 < -1e-12) issues <- c(issues, list(list(code = "over_volume", value = sum(f))))

  final <- as.numeric(comp[, included, drop = FALSE] %*% f) + b * f0
  names(final) <- p$id
  wc_strength <- f0 + sum(f[p$stock_solvent[match(names(f), p$id)] == "WC"])

  vol_uL <- f * volume_mL * 1000
  infeasible <- length(weak) > 0 || f0 < -1e-12

  if (!infeasible) {
    small <- names(vol_uL)[vol_uL > 0 & vol_uL < min_pipette_uL]
    if (length(small) > 0)
      issues <- c(issues, list(list(code = "small_volume", ids = small,
                                    value = min_pipette_uL)))
    if (wc_strength < min_wc_strength)
      issues <- c(issues, list(list(code = "wc_diluted", value = wc_strength)))
    others <- setdiff(p$id[p$kind == "dose"], included)
    off <- others[abs(final[others] / b[others] - 1) > 0.02]
    if (length(off) > 0)
      issues <- c(issues, list(list(code = "nutrient_off", ids = off,
                                    value = final[off] / b[off])))
  }

  recipe <- data.frame(
    id = c(names(f), "WC"),
    fraction = c(f, f0),
    volume_uL = c(vol_uL, f0 * volume_mL * 1000),
    stringsAsFactors = FALSE
  )

  status <- if (infeasible) "infeasible" else if (length(issues) > 0) "warning" else "ok"
  list(status = status, issues = issues, recipe = recipe,
       final = final, target = target, fractions = f,
       stock_fraction = sum(f), wc_strength = wc_strength)
}

# ---- stock diagnostics ---------------------------------------------------

#' Per stressor: fraction of the final volume its stock takes up when it is
#' the only stressor, and the stock concentration needed for that fraction to
#' be at most `max_fraction`.
stock_diagnostics <- function(settings, max_fraction = 0.02) {
  p <- prepare_settings(settings)
  need <- p$target_base - p$baseline
  frac_alone <- ifelse(p$stock_base > p$target_base,
                       need / (p$stock_base - p$baseline), NA)
  suggested_base <- p$baseline + need / max_fraction
  data.frame(
    id = p$id,
    target_base = p$target_base,
    stock_base = p$stock_base,
    fraction_alone = frac_alone,
    suggested_stock = vapply(seq_len(nrow(p)), function(k)
      from_base(suggested_base[k], p$stock_unit[k], p$id[k], p[k, ]), 0),
    stock_unit = p$stock_unit,
    stringsAsFactors = FALSE
  )
}

# ---- experiment design ---------------------------------------------------

#' Build the list of treatments.
#' @param levels numbers of stressors per treatment (e.g. c(2, 4, 6))
#' @param n_random NULL or named/positional integer vector: for each level the
#'   number of combinations to draw at random (NA or Inf = all combinations)
#' @param pool stressor ids to draw from
make_design <- function(levels, n_random = NULL, pool = ALL_IDS,
                        include_control = TRUE, seed = 1) {
  set.seed(seed)
  rows <- list()
  if (include_control) rows[[1]] <- data.frame(n_stressors = 0, stressors = "", stringsAsFactors = FALSE)
  for (i in seq_along(levels)) {
    k <- levels[i]
    if (k < 1 || k > length(pool)) next
    combos <- utils::combn(pool, k, simplify = FALSE)
    n <- if (is.null(n_random)) NA else n_random[i]
    if (!is.na(n) && is.finite(n) && n < length(combos))
      combos <- combos[sort(sample(seq_along(combos), n))]
    rows[[length(rows) + 1]] <- data.frame(
      n_stressors = k,
      stressors = vapply(combos, paste, "", collapse = "+"),
      stringsAsFactors = FALSE
    )
  }
  d <- do.call(rbind, rows)
  d$treatment <- sprintf("T%02d", seq_len(nrow(d)))
  d[, c("treatment", "n_stressors", "stressors")]
}

split_ids <- function(x) if (is.na(x) || x == "") character(0) else strsplit(x, "+", fixed = TRUE)[[1]]

chem_key <- function(stressors) {
  vapply(stressors, function(s) paste(intersect(CHEM_IDS, split_ids(s)), collapse = "+"), "")
}

#' One medium per distinct set of chemical stressors (physical stressors do
#' not change the medium), with the number of wells and volume to prepare.
media_plan <- function(design, settings, replicates, well_volume_mL,
                       margin = 0.1, min_pipette_uL = 2, min_wc_strength = 0.95) {
  design$medium_key <- chem_key(design$stressors)
  keys <- unique(design$medium_key)
  keys <- keys[order(lengths(lapply(keys, split_ids)), keys)]
  media <- data.frame(medium = sprintf("M%02d", seq_along(keys)),
                      chem_stressors = keys, stringsAsFactors = FALSE)
  media$n_treatments <- vapply(keys, function(k) sum(design$medium_key == k), 0)
  media$wells <- media$n_treatments * replicates
  media$volume_mL <- media$wells * well_volume_mL * (1 + margin)
  sols <- lapply(seq_len(nrow(media)), function(i)
    solve_mixture(settings, split_ids(media$chem_stressors[i]), media$volume_mL[i],
                  min_pipette_uL, min_wc_strength))
  media$status <- vapply(sols, `[[`, "", "status")
  media$stock_fraction <- vapply(sols, function(s) s$stock_fraction, 0)
  design$medium <- media$medium[match(design$medium_key, media$chem_stressors)]
  design$medium_key <- NULL
  list(design = design, media = media, solutions = sols)
}

#' Smart volume formatting: uL below 1 mL, otherwise mL.
fmt_volume <- function(uL) {
  ifelse(is.na(uL), "",
         ifelse(abs(uL) < 1000, sprintf("%.1f\u00a0µL", uL), sprintf("%.2f\u00a0mL", uL / 1000)))
}
