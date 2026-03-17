# Skill: Optimization Algorithms

## Trigger

When the problem requires finding minimum/maximum of a function, constraint satisfaction, or resource allocation.

## Algorithm Selection Decision Tree

```
Is the objective differentiable?
├─ Yes → Is it convex?
│        ├─ Yes → Gradient Descent / L-BFGS / Interior Point
│        └─ No  → Multiple restarts + local optimizer / Basin-hopping
└─ No  → Is the search space discrete?
         ├─ Yes → Is it combinatorial (NP-hard)?
         │        ├─ Yes, small → Branch & Bound / Dynamic Programming
         │        └─ Yes, large → Genetic Algorithm / Simulated Annealing
         └─ No  → Nelder-Mead / Particle Swarm / Bayesian Optimization
```

## Method Reference

### Exact Methods

| Method                       | Complexity          | Best For                                      |
| ---------------------------- | ------------------- | --------------------------------------------- |
| Linear Programming (Simplex) | Polynomial (avg)    | Linear constraints + objective                |
| Quadratic Programming        | O(n³)               | Quadratic objective, linear constraints       |
| Branch & Bound               | Exponential (worst) | Integer programming, small instances          |
| Dynamic Programming          | O(n·W) etc.         | Overlapping subproblems, optimal substructure |

### Gradient-Based

| Method             | Convergence | Memory | Best For                         |
| ------------------ | ----------- | ------ | -------------------------------- |
| Gradient Descent   | O(1/k)      | O(n)   | Simple, large-scale              |
| Conjugate Gradient | O(√κ)       | O(n)   | Quadratic-like, sparse           |
| L-BFGS             | Superlinear | O(mn)  | General smooth, medium-scale     |
| Newton's Method    | Quadratic   | O(n²)  | Small-scale, Hessian available   |
| Adam               | Adaptive    | O(n)   | Neural networks, noisy gradients |

### Metaheuristic

| Method                 | Population | Best For                            |
| ---------------------- | ---------- | ----------------------------------- |
| Genetic Algorithm      | Yes        | Complex landscapes, mixed variables |
| Simulated Annealing    | No         | Combinatorial, escape local optima  |
| Particle Swarm         | Yes        | Continuous, few constraints         |
| Differential Evolution | Yes        | Global optimization, black-box      |

## Constraint Handling

| Constraint Type   | Technique                               |
| ----------------- | --------------------------------------- |
| Equality h(x)=0   | Lagrange multipliers, substitution      |
| Inequality g(x)≤0 | KKT conditions, barrier/penalty methods |
| Box constraints   | Projected gradient, L-BFGS-B            |
| Integer variables | Branch & Bound, relaxation + rounding   |

## Output Format

```markdown
### Optimization Design: [Problem Name]

**Objective**: minimize/maximize f(x) = [...]
**Constraints**: [list]
**Variables**: [continuous/discrete, dimensions]

**Selected Method**: [name]
**Reason**: [why this method fits]
**Expected Convergence**: [rate]
**Fallback**: [alternative if primary fails]
```
