# Skill: R & Julia Expert

## Trigger

When implementing in R or Julia.

---

# R

## Style

- Tidyverse style: `snake_case` for variables and functions
- Pipe operator: `|>` (base R 4.1+) or `%>%` (magrittr)
- Vectorized operations over explicit loops

## Patterns

### Vectorized Operations

```r
# Good: vectorized
result <- sqrt(x^2 + y^2)

# Bad: loop
result <- numeric(length(x))
for (i in seq_along(x)) {
  result[i] <- sqrt(x[i]^2 + y[i]^2)
}
```

### Tidyverse Data Pipeline

```r
library(dplyr)
library(tidyr)

result <- raw_data |>
  filter(!is.na(value)) |>
  group_by(category) |>
  summarise(
    mean_val = mean(value),
    sd_val = sd(value),
    n = n()
  ) |>
  arrange(desc(mean_val))
```

### Function Documentation (roxygen2)

```r
#' Calculate weighted mean with error handling
#'
#' @param x Numeric vector of values
#' @param w Numeric vector of weights (same length as x)
#' @return Weighted mean as a single numeric value
#' @export
#' @examples
#' weighted_mean(c(1, 2, 3), c(0.5, 0.3, 0.2))
weighted_mean <- function(x, w) {
  stopifnot(length(x) == length(w))
  stopifnot(all(w >= 0))
  sum(x * w) / sum(w)
}
```

### Rcpp for Performance

```r
Rcpp::cppFunction('
  double fast_sum(NumericVector x) {
    double total = 0;
    for (int i = 0; i < x.size(); i++) {
      total += x[i];
    }
    return total;
  }
')
```

## Key Libraries

| Domain            | Package                      |
| ----------------- | ---------------------------- |
| Data manipulation | dplyr, tidyr, data.table     |
| Visualization     | ggplot2, plotly              |
| Statistics        | stats (base), lme4, survival |
| ML                | caret, tidymodels, xgboost   |
| String            | stringr, glue                |
| I/O               | readr, readxl, haven         |

---

# Julia

## Style

- Functions: `snake_case`; Types: `CamelCase`
- Use multiple dispatch as the core design pattern
- Avoid global variables; use `const` for constants

## Patterns

### Multiple Dispatch

```julia
abstract type Shape end
struct Circle <: Shape
    radius::Float64
end
struct Rectangle <: Shape
    width::Float64
    height::Float64
end

area(s::Circle) = π * s.radius^2
area(s::Rectangle) = s.width * s.height
# Julia selects the right method at runtime
```

### Type-Stable Functions

```julia
# Good: type-stable
function safe_divide(a::Float64, b::Float64)::Float64
    b == 0.0 ? 0.0 : a / b
end

# Bad: type-unstable (returns Int or Float)
function unstable(x)
    x > 0 ? 1 : 0.5
end
```

### Performance Tips

```julia
# Use @inbounds for tight loops (after verifying correctness)
function fast_sum(v::Vector{Float64})
    s = 0.0
    @inbounds for i in eachindex(v)
        s += v[i]
    end
    return s
end

# Use StaticArrays for small fixed-size arrays
using StaticArrays
v = SVector(1.0, 2.0, 3.0)  # stack-allocated, zero overhead
```

### Documentation

````julia
"""
    solve(A::Matrix, b::Vector) -> Vector

Solve the linear system Ax = b using LU factorization.

# Arguments
- `A::Matrix{Float64}`: coefficient matrix (must be square)
- `b::Vector{Float64}`: right-hand side vector

# Examples
```julia
A = [1.0 2.0; 3.0 4.0]
b = [5.0, 6.0]
x = solve(A, b)
````

"""
function solve(A::Matrix{Float64}, b::Vector{Float64})::Vector{Float64}
return A \ b
end

```

## Key Packages
| Domain | Package |
|--------|---------|
| Linear algebra | LinearAlgebra (stdlib) |
| ODE/PDE | DifferentialEquations.jl |
| Optimization | Optim.jl, JuMP.jl |
| Statistics | Statistics (stdlib), Distributions.jl |
| Data | DataFrames.jl, CSV.jl |
| Plotting | Plots.jl, Makie.jl |
| Benchmarking | BenchmarkTools.jl |
```
