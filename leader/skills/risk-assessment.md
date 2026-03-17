# Skill: Risk Assessment

## Trigger

When decomposing tasks or reviewing team progress, identify risks that could block or delay delivery.

## Risk Matrix

| Impact \ Likelihood | Low     | Medium   | High     |
| ------------------- | ------- | -------- | -------- |
| **High**            | Monitor | Mitigate | Escalate |
| **Medium**          | Accept  | Monitor  | Mitigate |
| **Low**             | Accept  | Accept   | Monitor  |

## Common Risk Categories

### Technical Risks

- Algorithm complexity exceeds time constraints
- Language/platform incompatibility
- Numerical instability in edge cases
- Memory safety issues (C/C++)
- Missing dependencies or version conflicts

### Process Risks

- Euler-Forge misalignment on algorithm feasibility
- Test coverage gaps (Sentinel misses edge cases)
- Documentation lag (Atlas starts before Lens finishes)
- Scope creep from unclear requirements

### Mitigation Strategies

1. **Early prototyping** — Have Forge build a minimal version before full implementation
2. **Parallel validation** — Sentinel writes test stubs while Forge codes
3. **Checkpoint reviews** — Review outputs at each phase transition
4. **Explicit constraints** — State what is NOT in scope

## Output Format

```markdown
## Risk Register — [Task Name]

| #   | Risk   | Category  | Likelihood | Impact | Mitigation | Owner   |
| --- | ------ | --------- | ---------- | ------ | ---------- | ------- |
| R1  | [desc] | Technical | H/M/L      | H/M/L  | [action]   | [agent] |
```
