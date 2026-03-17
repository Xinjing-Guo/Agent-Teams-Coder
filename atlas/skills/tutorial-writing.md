# Skill: Tutorial Writing

## Trigger

When writing step-by-step guides, quick-start tutorials, or how-to articles for the software manual.

## Tutorial Structure

````markdown
# Tutorial: [Task Name]

## What You'll Learn

- [Outcome 1]
- [Outcome 2]

## Prerequisites

- [Software version]
- [Dependencies installed]

## Steps

### Step 1: [Action Verb] — [What]

[Brief explanation of WHY this step]

```code
[Exact command or code to copy-paste]
```
````

Expected output:

```
[What the user should see]
```

### Step 2: ...

[Continue pattern]

## Complete Example

[Full working code combining all steps]

## What's Next

- [Link to advanced topic]
- [Link to API reference]

````

## Writing Rules

1. **Every code block must be copy-paste-ready** — no `...` or `[fill in]`
2. **Show expected output** for every command
3. **One concept per step** — don't combine multiple ideas
4. **Explain WHY before HOW** — motivation before instruction
5. **Test every tutorial yourself** — run all code blocks in order
6. **Progressive complexity** — start simple, add features gradually
7. **Include error scenarios** — "If you see X, try Y"

## Quick Start Template (< 5 Steps)

```markdown
# Quick Start

## 1. Install
```bash
pip install mypackage
````

## 2. Import

```python
from mypackage import Solver
```

## 3. Create

```python
solver = Solver(method="auto")
```

## 4. Run

```python
result = solver.solve([1.0, 2.0, 3.0])
print(result)  # Output: {'solution': 2.0, 'iterations': 3}
```

## 5. Done!

See [User Guide](guide.md) for advanced usage.

```

```
