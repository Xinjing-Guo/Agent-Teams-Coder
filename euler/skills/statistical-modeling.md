# Skill: Statistical Modeling

## Trigger

When the problem involves data analysis, hypothesis testing, probability distributions, sampling, or statistical inference.

## Method Selection

| Goal                     | Method                                | When to Use                     |
| ------------------------ | ------------------------------------- | ------------------------------- |
| Compare two groups       | t-test / Mann-Whitney                 | Normal / non-normal data        |
| Compare >2 groups        | ANOVA / Kruskal-Wallis                | Multiple group comparison       |
| Correlation              | Pearson / Spearman                    | Linear / monotonic relationship |
| Prediction (continuous)  | Linear / Ridge / Lasso regression     | Y = f(X)                        |
| Prediction (binary)      | Logistic regression                   | Classification                  |
| Dimensionality reduction | PCA / t-SNE / UMAP                    | High-dimensional data           |
| Clustering               | K-means / DBSCAN / Hierarchical       | Group discovery                 |
| Time series              | ARIMA / exponential smoothing         | Temporal patterns               |
| Bayesian inference       | MCMC / Variational                    | Prior knowledge + uncertainty   |
| Monte Carlo              | Random sampling / importance sampling | Simulation, integration         |

## Hypothesis Testing Framework

```markdown
### Hypothesis Test: [Name]

**H₀**: [null hypothesis]
**H₁**: [alternative hypothesis]
**Test**: [test name]
**Significance level**: α = 0.05
**Assumptions**:

- [ ] Independence
- [ ] Normality (if parametric)
- [ ] Equal variance (if applicable)
      **Result**: test statistic = [value], p-value = [value]
      **Conclusion**: [reject/fail to reject H₀]
```

## Distribution Quick Reference

| Distribution | Use Case                        | Parameters |
| ------------ | ------------------------------- | ---------- |
| Normal       | Natural measurements            | μ, σ       |
| Binomial     | Count of successes              | n, p       |
| Poisson      | Rare event counts               | λ          |
| Exponential  | Time between events             | λ          |
| Uniform      | Equal probability               | a, b       |
| Beta         | Probability of probability      | α, β       |
| Gamma        | Wait times, positive continuous | α, β       |

## Sample Size Estimation

```
n = (Z_{α/2})² · σ² / E²

Where:
  Z_{α/2} = 1.96 (for 95% confidence)
  σ = estimated standard deviation
  E = desired margin of error
```
