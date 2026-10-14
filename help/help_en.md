## How the calculator works

**Tab 1 – Stocks & targets.** Enter the concentration of each intermediate solution, whether it was made in WC medium or in milliQ water, and the target in the wells.

- **N and P**: the target is the **total** concentration in the well, including what normal WC already contains. Pick the unit you prefer:
  - **× WC**: a multiple of normal WC. 4 × WC = normal WC plus 3 extra doses.
  - **mg N/L** or **mg P/L**: mass of the element.
  - **mg/L NaNO₃** or **mg/L K₂HPO₄**: mass of the salt.
  - **µM** or **mM**: molar concentration.

  Changing the unit converts the number. With standard WC, 4 × WC = 56.0 mg N/L = 340 mg/L NaNO₃ for N, and 9.29 mg P/L = 52.3 mg/L K₂HPO₄ for P.
- The column *Normal WC medium contains* gives the WC recipe: 1 mL/L of a NaNO₃ stock and 1.5 mL/L of a K₂HPO₄ stock, with the concentration of those stocks. The defaults (85.01 g/L NaNO₃, 8.71 g/L K₂HPO₄) are standard WC; check them against your own recipe. They only matter when × WC or *mL stock/L* is combined with mass or molar units.
- Intermediate solutions for N and P can be given in *mL stock/L*: for example, WC medium made with 10 mL/L NaNO₃ stock instead of 1 mL/L. They can also be given in mass or molar units.
- **Salt**: the target is the amount **added** on top of the medium, in mg Cl⁻/L or in mg/L NaCl (0.607 g Cl⁻ per g NaCl, so 300 mg Cl⁻/L = 494.5 mg/L NaCl).
- **Glyphosate and tylosin**: the target is the amount added. Stock and target must be expressed in the same form (here, isopropylamine salt and tartrate).

The check table shows how much of the final volume each intermediate solution takes on its own. **In a mixture these shares add up**, so they must stay small (a few % each). The last column gives the stock concentration you would need to reach the aim you set.

**Tab 2 – One mixture.** Tick the chemical stressors, set the number of wells and the well volume. You get the volume of each solution to pipette and the WC medium to top up with.

**Tab 3 – Experiment plan.** Builds the treatment list from the 8 stressors (all combinations, or a random draw of *n* combinations per level). Treatments that share the same chemical stressors use the same medium, because temperature, shading and harvesting don't change the medium. You get one recipe per medium and an Excel file for the bench.

## The calculation

Every solution (plain WC and each intermediate solution) has a known concentration of every stressor compound. With f_j the volume fraction of solution j:

C_i (well) = Σ_j f_j · c_ij + f_WC · b_i,   with f_WC = 1 − Σ_j f_j

Here b_i is the normal WC level (for N and P: WC dose × stock concentration; 0 for the others). For the stressors in the mixture, C_i is set equal to the target and the small linear system is solved for the f_j. Volume of solution j = f_j × volume to prepare.

- **Intermediate made in WC medium**: it carries the normal WC nutrients, so it doesn't dilute the medium. For example, the N solution at 10 mL/L contains 10 doses of N, of which 1 is the WC dose.
- **Intermediate made in water**: it dilutes all WC ingredients. If N or P is a stressor in the same mixture, the calculation compensates for that dilution. For the other WC ingredients (trace elements, vitamins…), the app reports the remaining WC strength.

## Statuses

- **OK**: the mixture can be made.
- **Check**: the mixture can be made, but a volume is below what you pipette accurately, or water-based solutions dilute the WC medium below the threshold you set.
- **Impossible**: the solutions together would need more than 100 % of the volume, or a solution is weaker than its target. Use more concentrated intermediate solutions.

Settings can be saved to and loaded from a CSV file (tab 1).
