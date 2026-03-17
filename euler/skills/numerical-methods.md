# Skill: Numerical Methods

## Trigger

When the problem involves continuous mathematics, differential equations, interpolation, numerical integration, or floating-point considerations.

## Method Selection Guide

| Problem Type   | Recommended Method                  | When to Use                           |
| -------------- | ----------------------------------- | ------------------------------------- |
| Root finding   | Newton-Raphson, Bisection           | f(x)=0, smooth functions              |
| Interpolation  | Lagrange, cubic spline              | Fitting curves through known points   |
| Integration    | Simpson's, Gauss quadrature         | Definite integrals, smooth integrands |
| ODE            | RK4, adaptive RK45                  | Initial value problems                |
| PDE            | Finite difference, FEM              | Boundary/initial value in 2D+         |
| Linear systems | LU, Cholesky, iterative (CG, GMRES) | Ax=b, sparse or dense                 |
| Eigenvalues    | QR algorithm, power method          | Dominant eigenvalues, full spectrum   |
| Optimization   | Gradient descent, L-BFGS, Newton    | Smooth objective functions            |
| FFT            | Cooley-Tukey radix-2                | Power-of-2 length signals             |

## Numerical Stability Checklist

- [ ] Avoid subtracting nearly equal numbers (catastrophic cancellation)
- [ ] Use compensated summation (Kahan) for long sums
- [ ] Check condition number for linear systems
- [ ] Use relative error, not absolute, for convergence tests
- [ ] Guard against division by zero and overflow
- [ ] Test with adversarial inputs (nearly singular, ill-conditioned)

## Error Analysis Template

```markdown
### Error Analysis: [Method Name]

- **Truncation error**: O(h^p) where p = [order]
- **Round-off error**: affected by [condition number / cancellation]
- **Total error**: minimized at h ≈ [optimal step size]
- **Stability region**: [describe]
- **Convergence**: [rate and conditions]
```

## Language Considerations

| Language | Numeric Library                         | Notes                                       |
| -------- | --------------------------------------- | ------------------------------------------- |
| Python   | numpy, scipy                            | Good defaults, watch for float64 vs float32 |
| C/C++    | LAPACK, FFTW, Eigen                     | Manual memory, but fastest                  |
| R        | built-in, pracma                        | Vectorized, but slow loops                  |
| Julia    | LinearAlgebra, DifferentialEquations.jl | Native speed, great ecosystem               |
