# Stressor medium calculator

Shiny app that computes how much of each intermediate stock solution to add to WC medium to reach target stressor concentrations in microcosm wells (6-well plates, 6 mL per well). The interface is in English and French.

*Application Shiny qui calcule les volumes de solutions intermédiaires à ajouter au milieu WC pour atteindre les concentrations voulues dans les puits. Interface en anglais et en français.*

## Run

Install the packages once:

```r
install.packages(c("shiny", "bslib", "DT", "writexl"))
```

Then open `app.R` in RStudio and click **Run App**, or run `shiny::runApp("path/to/medium-calculator")`.

## Tabs

1. **Stocks & targets**: intermediate solutions (concentration, made in WC or water) and targets. A check table shows the share of the final volume each solution takes, and the concentration needed to keep it small. Settings can be saved to and loaded from a CSV file.
2. **One mixture**: pick chemical stressors, number of wells and well volume. You get the volumes to pipette.
3. **Experiment plan**: treatment list from the 8 stressors (all combinations or random draws per level), one medium per distinct set of chemical stressors, and a pipetting sheet as an Excel download.
4. **Help**: the calculation and its assumptions.

## Files

- `app.R`: user interface and server
- `R/calc.R`: calculations (no Shiny code, can be used on its own)
- `R/i18n.R`: English/French text
- `help/`: help pages
- `tests/test_calc.R`: checks against hand calculations (`Rscript tests/test_calc.R`)

## Default values (Laura Willam, Oct 2026)

| Stressor | Intermediate solution | Target in wells |
|---|---|---|
| N (WC = 1 mL/L of 85.01 g/L NaNO₃ stock**) | 10 mL stock/L, in WC | 4 × WC in total (= 56.0 mg N/L) |
| P (WC = 1.5 mL/L of 8.71 g/L K₂HPO₄ stock**) | 10 mL stock/L, in WC | 4 × WC in total (= 9.29 mg P/L) |
| NaCl | 1000 mg/L, in water* | 300 mg Cl⁻/L added |
| Glyphosate (isopropylamine salt) | 50 mg/L, in water* | 300 µg/L |
| Tylosin tartrate | 0.5 g/L, in water* | 0.2 mg/L |

\* to be confirmed; this can be changed in tab 1.
\*\* standard WC stock concentrations, to be checked against the lab recipe. All targets and stocks can be entered in other units (mg N/L, mg/L of the salt, µM, …).
