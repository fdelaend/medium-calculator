## How the calculator works

**Tab 1 – Stocks & targets.** Enter the concentration of each intermediate solution, whether it was made in WC medium or in milliQ water, and the target in the wells.

- **N and P** are counted in *mL of the WC stock solution per litre*. Normal WC contains 1 mL/L NaNO₃ stock and 1.5 mL/L K₂HPO₄ stock. A target of "4 doses in total" means 4 × the normal amount, so 3 doses on top of the medium.
- **Salt**: the target is the **Cl⁻ added** (on top of the medium). The calculator converts it to NaCl using 35.45/58.44 = 0.607 g Cl⁻ per g NaCl, so 300 mg/L Cl⁻ = 494.5 mg/L NaCl.
- **Glyphosate and tylosin**: the target is the amount added. Stock and target must be expressed in the same form (here, isopropylamine salt and tartrate).

The check table shows how much of the final volume each intermediate solution takes on its own. **In a mixture these shares add up**, so they must stay small (a few % each). The last column gives the stock concentration you would need to reach the aim you set.

**Tab 2 – One mixture.** Tick the chemical stressors, set the number of wells and the well volume. You get the volume of each solution to pipette and the WC medium to top up with.

**Tab 3 – Experiment plan.** Builds the treatment list from the 8 stressors (all combinations, or a random draw of *n* combinations per level). Treatments that share the same chemical stressors use the same medium, because temperature, shading and harvesting don't change the medium. You get one recipe per medium and an Excel file for the bench.

## The calculation

Every solution (plain WC and each intermediate solution) has a known concentration of every stressor compound. With f_j the volume fraction of solution j:

C_i (well) = Σ_j f_j · c_ij + f_WC · b_i,   with f_WC = 1 − Σ_j f_j

Here b_i is the normal WC level (1 or 1.5 mL/L for N and P, 0 for the others). For the stressors in the mixture, C_i is set equal to the target and the small linear system is solved for the f_j. Volume of solution j = f_j × volume to prepare.

- **Intermediate made in WC medium**: it carries the normal WC nutrients, so it doesn't dilute the medium. For example, the N solution at 10 mL/L contains 10 doses of N, of which 1 is the WC dose.
- **Intermediate made in water**: it dilutes all WC ingredients. If N or P is a stressor in the same mixture, the calculation compensates for that dilution. For the other WC ingredients (trace elements, vitamins…), the app reports the remaining WC strength.

## Statuses

- **OK**: the mixture can be made.
- **Check**: the mixture can be made, but a volume is below what you pipette accurately, or water-based solutions dilute the WC medium below the threshold you set.
- **Impossible**: the solutions together would need more than 100 % of the volume, or a solution is weaker than its target. Use more concentrated intermediate solutions.

Settings can be saved to and loaded from a CSV file (tab 1).
