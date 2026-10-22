# Peppermint Inequality Challenge

An interactive classroom activity for exploring **income inequality**, **Gini coefficients**, and **Lorenz curves** using peppermint candies.

Students work in teams to distribute peppermint candies among 10 hypothetical citizens, aiming to reproduce the level of income inequality represented by a target country's Gini coefficient. The instructor enters each team's distribution into an R script, which calculates its Gini coefficient, compares it with the target, and displays the income distribution and Lorenz curve.

## Learning objectives

By the end of the activity, students should be able to:

- Explain what the Gini coefficient measures and interpret values between 0 (perfect equality) and 1 (maximum inequality).
- Understand how a Lorenz curve represents the cumulative distribution of income.
- Connect differences in individual incomes to changes in overall inequality.
- Compare income inequality across countries and distinguish the **level of inequality** from the **level of average income**.

## Materials

- Peppermint candies (or another small, countable item)
- 10 spaces, cups, or representative citizens per team
- A computer with R installed (RStudio recommended)
- A projector or shared screen to display each team's results
- Target Gini coefficients for the countries or rounds being studied

Each candy represents one unit of income. All teams should ideally receive the **same number of candies per round** so they face comparable allocation constraints.

## Setup

Install the three required R packages once:

```r
install.packages(c("DescTools", "ggplot2", "gridExtra"))
```

Then open the R script and run it. It loads:

```r
library(DescTools)
library(ggplot2)
library(gridExtra)
```

## How to play

1. **Select a country and target.** The instructor announces a country and its Gini coefficient. Set this value in the script, for example:

   ```r
   Target <- 0.51
   ```

2. **Divide into teams.** Each team represents an economy containing 10 hypothetical citizens. Give each team its allotted peppermint candies.

3. **Distribute income.** Teams decide how many candies to allocate to each of the 10 citizens. Every citizen's allocation must be a nonnegative whole number; an allocation of zero is permitted. Teams should use all their candies.

4. **Submit the distribution.** The instructor enters each team's allocation as a vector of 10 numbers. For example:

   ```r
   # TEAM 1: one entry per citizen
   x <- c(1, 1, 2, 4, 5, 7, 8, 11, 12, 16)
   ```

   The script sorts the values for the visualizations, so the order in which citizens are entered does not matter.

5. **Display the results.** Run the corresponding team's block:

   ```r
   grid.arrange(
     plot_lorenz_curve(x),
     plot_group_barplot(x, Target),
     nrow = 1,
     top = "Team 1"
   )
   print(abs(Gini(x) - Target))
   ```

6. **Compare teams.** The script reports each team's calculated Gini and its *penalty*, defined as the absolute difference between its Gini and the target:

   \[\text{Penalty} = |\text{Team Gini} - \text{Target Gini}|\]

   **The team with the lowest penalty wins the round.** An exact match has a penalty of zero.

7. **Play another round.** Change `Target` to a different country's Gini coefficient, redistribute the candies, and compare outcomes again.

## Understanding the output

For each team, the script displays two plots side by side:

| Plot | Interpretation |
| --- | --- |
| **Lorenz curve** | The horizontal axis represents the cumulative share of people, ordered from lowest to highest income; the vertical axis represents the cumulative share of income. The dashed diagonal denotes perfect equality. More pronounced curvature away from the diagonal indicates greater inequality. |
| **Income distribution bar chart** | Displays the candy allocation for each of the 10 citizens, ordered from lowest to highest. The title shows the team's Gini coefficient; the red subtitle shows the penalty and the target Gini. |

A Gini coefficient near **0** corresponds to relatively equal allocations. A coefficient nearer **1** corresponds to a more unequal allocation. With only 10 citizens, the largest attainable Gini under the usual finite-population definition is **0.9**, achieved when one citizen receives all candies.

### Important note on the Gini calculation

The script uses `DescTools::Gini(x)`. Its default is a bias-corrected estimate (`unbiased = TRUE`), which differs from the conventional uncorrected finite-population Gini. For 10 citizens, this correction can matter substantially: a distribution with all candies held by one citizen produces a corrected Gini of **1**, rather than the uncorrected value of **0.9**.

**For comparison with published country Gini coefficients**, consider using `Gini(x, unbiased = FALSE)` consistently in both the bar chart and the penalty calculation. Published measures may also use different income concepts, equivalence scales, household/person units, and survey methods, so this activity is an illustration rather than an exact reconstruction of a country's income distribution.

## Choosing country targets

Look up Gini coefficients from a consistent source, such as the [World Bank Gini index](https://data.worldbank.org/indicator/SI.POV.GINI). The World Bank publishes the index on a **0–100 scale**; divide by 100 to obtain the **0–1 scale** used by the R script.

For example, a country Gini index of **51** corresponds to:

```r
Target <- 51 / 100  # 0.51
```

Use documented **country-year** observations rather than assuming the latest observation is from the same year for every country. You can choose several countries with contrasting levels of inequality and have teams discuss how the distributions differ.

## Tips for instructors

- Start with an intuitive round (e.g., a low target near equality) before progressing to more unequal distributions.
- Have students predict whether a transfer from a richer citizen to a poorer one will raise or lower the Gini.
- Emphasize that changing the total number of candies by proportionally scaling everyone's allocation does **not** change the Gini coefficient; changing their relative shares does.
- Ask whether two visibly different allocations can have similar Gini coefficients. (They can: one summary measure does not describe every feature of a distribution.)
- Have teams explain *why* their allocation approaches the target, rather than merely experimenting until the penalty is small.

## Current script structure

The supplied script includes:

- `plot_lorenz_curve(x)`: plots a Lorenz curve for a team's distribution.
- `plot_group_barplot(x, target)`: plots sorted candy allocations and displays Gini and penalty.
- `Target`: the target Gini coefficient for the current round.
- Five team blocks (`TEAM 1` through `TEAM 5`), each using a 10-number vector `x`.

To add more teams, copy a team block, change its label, and replace the 10 allocation values.

