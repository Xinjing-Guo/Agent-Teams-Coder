# Skill: Decision Log

## Trigger

When team members make important technical decisions that should be recorded for future reference.

## Decision Record Format (ADR - Architecture Decision Record)

```markdown
# ADR-[number]: [Title]

**Date**: YYYY-MM-DD
**Status**: proposed / accepted / deprecated / superseded by ADR-N
**Decider**: [Agent name]

## Context

[What is the issue? What forces are at play?]

## Decision

[What was decided and why]

## Alternatives Considered

| Option           | Pros | Cons |
| ---------------- | ---- | ---- |
| [A]              | [+]  | [-]  |
| [B]              | [+]  | [-]  |
| **[C] (chosen)** | [+]  | [-]  |

## Consequences

- **Positive**: [benefits]
- **Negative**: [tradeoffs accepted]
- **Risks**: [what could go wrong]

## Related

- Related to: ADR-N
- Supersedes: ADR-M (if applicable)
```

## What Qualifies as a Decision

### Must Record

- Algorithm choice (Euler) — e.g., "chose Cooley-Tukey over Bluestein for FFT"
- Language choice (Forge) — e.g., "C for core, Python wrapper for usability"
- Data structure choice (Euler/Forge) — e.g., "hash map over BST for O(1) lookup"
- Test strategy (Sentinel) — e.g., "property-based testing for sorting correctness"
- API design (Forge) — e.g., "functional API, no class hierarchy"
- Documentation scope (Atlas) — e.g., "include Jupyter notebook examples"

### Don't Record

- Trivial choices (variable names, formatting)
- Temporary decisions overridden within the same session
- Standard practices that don't need justification

## Decision Log Index

Maintain a running index:

```markdown
# Decision Log Index

| #       | Title                   | Date       | Decider  | Status   |
| ------- | ----------------------- | ---------- | -------- | -------- |
| ADR-001 | Use Cooley-Tukey FFT    | 2026-03-17 | Euler    | accepted |
| ADR-002 | C core + Python wrapper | 2026-03-17 | Forge    | accepted |
| ADR-003 | 80% coverage minimum    | 2026-03-17 | Sentinel | accepted |
```
