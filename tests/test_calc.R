# Run from the project folder with:  Rscript tests/test_calc.R
library(testthat)
source(file.path("R", "calc.R"), encoding = "UTF-8")

s <- default_settings()
vol <- function(res, id) res$recipe$volume_uL[res$recipe$id == id]

test_that("single compounds match hand calculations (72 mL)", {
  # glyphosate: 300 ug/L from 50 mg/L -> 72000 uL * 0.3/50 = 432 uL
  r <- solve_mixture(s, "Gly", 72)
  expect_equal(vol(r, "Gly"), 432, tolerance = 1e-9)
  expect_equal(vol(r, "WC"), 72000 - 432, tolerance = 1e-9)
  expect_equal(unname(r$final["Gly"]), 0.3, tolerance = 1e-9)
  # tylosin: 0.2 mg/L from 0.5 g/L -> 28.8 uL
  expect_equal(vol(solve_mixture(s, "Tyl", 72), "Tyl"), 28.8, tolerance = 1e-9)
  # N: 4 doses (4 mL/L) from WC-based stock at 10 mL/L, WC has 1 mL/L
  #   f*10 + (1-f)*1 = 4 -> f = 1/3 -> 24 mL
  r <- solve_mixture(s, "N", 72)
  expect_equal(vol(r, "N"), 24000, tolerance = 1e-9)
  expect_equal(unname(r$final["N"]), 4 * 85.01, tolerance = 1e-9)      # mg/L NaNO3
  expect_equal(unname(r$final["P"]), 1.5 * 8.71, tolerance = 1e-9)    # P untouched
  # P: 4 doses (6 mL/L) from 10 mL/L, WC has 1.5 -> f = 4.5/8.5
  expect_equal(vol(solve_mixture(s, "P", 72), "P"), 72000 * 4.5 / 8.5, tolerance = 1e-9)
  # Cl-: 300 mg/L Cl- = 494.5 mg/L NaCl from 1000 mg/L NaCl
  r <- solve_mixture(s, "NaCl", 72)
  expect_equal(vol(r, "NaCl"), 72000 * 300 / CL_FRACTION_NACL / 1000, tolerance = 1e-9)
  expect_equal(unname(r$final["NaCl"]) * CL_FRACTION_NACL, 300, tolerance = 1e-9)
})

test_that("water-based stocks dilute WC and N is compensated", {
  r <- solve_mixture(s, c("N", "NaCl"), 72)
  expect_equal(unname(r$final["N"]), 4 * 85.01, tolerance = 1e-9)
  f_nacl <- 300 / CL_FRACTION_NACL / 1000
  expect_equal(unname(r$fractions["N"]), (3 + f_nacl) / 9, tolerance = 1e-9)
  expect_equal(r$wc_strength, 1 - f_nacl, tolerance = 1e-9)
  expect_equal(r$status, "warning")
  expect_true("wc_diluted" %in% vapply(r$issues, `[[`, "", "code"))
  expect_true("nutrient_off" %in% vapply(r$issues, `[[`, "", "code")) # P diluted
})

test_that("impossible mixtures are flagged", {
  r <- solve_mixture(s, c("P", "NaCl"), 72)
  expect_equal(r$status, "infeasible")
  expect_true("over_volume" %in% vapply(r$issues, `[[`, "", "code"))
  s2 <- s; s2$stock_value[s2$id == "Gly"] <- 0.1  # 0.1 mg/L < 0.3 mg/L target
  r <- solve_mixture(s2, "Gly", 72)
  expect_equal(r$status, "infeasible")
})

test_that("all targets are met in every feasible mixture", {
  for (k in 1:5) for (cmb in combn(CHEM_IDS, k, simplify = FALSE)) {
    r <- solve_mixture(s, cmb, 50)
    if (r$status != "infeasible")
      expect_equal(unname(r$final[cmb]), unname(r$target[cmb]), tolerance = 1e-9)
    expect_equal(sum(r$recipe$volume_uL), 50000, tolerance = 1e-6)
  }
})

test_that("concentrated stocks make every mixture feasible", {
  s3 <- s
  s3$stock_value <- c(1000, 1000, 50, 50, 0.5)   # pure WC stocks, 50 g/L NaCl
  s3$stock_unit[3] <- "g/L"
  s3$stock_solvent <- c("water", "water", "water", "water", "water")
  r <- solve_mixture(s3, CHEM_IDS, 72)
  expect_equal(r$status, "ok")
  expect_lt(r$stock_fraction, 0.03)
})

test_that("suggested stock gives the requested fraction", {
  d <- stock_diagnostics(s, max_fraction = 0.02)
  s4 <- s; s4$stock_value <- d$suggested_stock
  for (id in CHEM_IDS)
    expect_equal(unname(solve_mixture(s4, id, 100)$fractions[id]), 0.02, tolerance = 1e-9)
})

test_that("N and P targets can be given as free concentrations", {
  # standard WC: 1 mL/L of 85.01 g/L NaNO3 = 85.01 mg/L NaNO3 = 14.01 mg N/L
  p <- prepare_settings(s)
  expect_equal(p$baseline[p$id == "N"], 85.01, tolerance = 1e-9)
  expect_equal(p$target_base[p$id == "N"], 4 * 85.01, tolerance = 1e-9)
  # the same target written in mg N/L, mg/L NaNO3 and uM gives the same recipe
  ref <- solve_mixture(s, c("N", "P"), 72)
  n_mgN <- 4 * 85.01 * 14.007 / 84.995
  for (u in list(c("mgEl/L", n_mgN), c("mg/L", 4 * 85.01), c("uM", 4 * 85.01 / 84.995 * 1000))) {
    s2 <- s; s2$target_unit[1] <- u[1]; s2$target_value[1] <- as.numeric(u[2])
    expect_equal(solve_mixture(s2, c("N", "P"), 72)$recipe, ref$recipe, tolerance = 1e-9)
  }
  # a free target: 20 mg P/L total from a WC-based intermediate at 10 mL/L
  s3 <- s; s3$target_unit[2] <- "mgEl/L"; s3$target_value[2] <- 20
  r <- solve_mixture(s3, "P", 100)
  b <- 1.5 * 8.71; c_int <- 10 * 8.71; t <- 20 * 174.176 / 30.974
  expect_equal(unname(r$fractions["P"]), (t - b) / (c_int - b), tolerance = 1e-9)
  expect_equal(unname(r$final["P"]) * 30.974 / 174.176, 20, tolerance = 1e-9)
})

test_that("unit conversion round trip and old settings files", {
  for (id in CHEM_IDS) for (u in union(TARGET_UNITS[[id]], STOCK_UNITS[[id]])) {
    r <- s[s$id == id, ]
    expect_equal(from_base(to_base(3.7, u, id, r), u, id, r), 3.7, tolerance = 1e-12)
  }
  old <- data.frame(id = CHEM_IDS, wc_baseline = c(1, 1.5, 0, 0, 0), stock_value = c(10, 10, 1000, 50, 0.5),
                    stock_unit = c("mL/L", "mL/L", "mg/L", "mg/L", "g/L"), stock_solvent = c("WC", "WC", "water", "water", "water"),
                    target_value = c(4, 4, 300, 300, 0.2), target_unit = c("x", "x", "mg/L", "\u00b5g/L", "mg/L"),
                    stringsAsFactors = FALSE)
  up <- upgrade_settings(old)
  up$kind <- s$kind
  expect_equal(prepare_settings(up)$target_base, prepare_settings(s)$target_base, tolerance = 1e-9)
})

test_that("design and media plan", {
  d <- make_design(c(2, 4, 6))
  expect_equal(nrow(d), 1 + choose(8, 2) + choose(8, 4) + choose(8, 6))
  d2 <- make_design(c(2, 4), n_random = c(5, 3), seed = 42)
  expect_equal(nrow(d2), 1 + 5 + 3)
  m <- media_plan(d2, s, replicates = 3, well_volume_mL = 6, margin = 0)
  expect_equal(sum(m$media$wells), nrow(d2) * 3)
  expect_equal(sum(m$media$volume_mL), nrow(d2) * 3 * 6)
  expect_true(all(m$design$medium %in% m$media$medium))
})

cat("All tests done.\n")
