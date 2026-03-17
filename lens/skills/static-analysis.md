# Skill: Static Analysis

## Trigger

When analyzing code quality without execution — linting, type checking, complexity metrics.

## Tools by Language

| Language | Linter               | Type Checker         | Formatter          |
| -------- | -------------------- | -------------------- | ------------------ |
| Python   | ruff, pylint         | mypy, pyright        | black, ruff format |
| C        | cppcheck, splint     | —                    | clang-format       |
| C++      | clang-tidy, cppcheck | —                    | clang-format       |
| R        | lintr                | —                    | styler             |
| Julia    | —                    | built-in type system | JuliaFormatter.jl  |
| Shell    | shellcheck           | —                    | shfmt              |

## Complexity Metrics

### Cyclomatic Complexity

- Count independent paths through code
- 1-10: simple, 11-20: moderate, 21-50: complex, >50: untestable
- Each `if`, `for`, `while`, `case`, `&&`, `||` adds 1

### Cognitive Complexity

- Measures how hard code is to **understand** (not just test)
- Nesting increases weight: `if` inside `for` inside `if` = high

### Halstead Metrics

- Vocabulary, length, volume, difficulty
- Useful for comparing refactored vs original

## Analysis Checklist

### Code Smells

- [ ] Functions > 50 lines
- [ ] Classes > 300 lines
- [ ] Cyclomatic complexity > 15
- [ ] Deep nesting (> 3 levels)
- [ ] Duplicated code blocks (> 6 lines identical)
- [ ] God objects (class does too much)
- [ ] Long parameter lists (> 5 params)
- [ ] Magic numbers without constants
- [ ] Dead code (unreachable branches)

### Security Smells

- [ ] Hardcoded credentials/paths
- [ ] Unsanitized user input
- [ ] Command injection risk (string-built commands)
- [ ] Buffer overflow risk (C/C++)
- [ ] SQL injection patterns

## Output Format

```markdown
### Static Analysis: [File]

| Metric                      | Value | Threshold | Status |
| --------------------------- | ----- | --------- | ------ |
| Lines of code               | N     | —         | —      |
| Cyclomatic complexity (max) | N     | ≤15       | ✓/✗    |
| Cognitive complexity (max)  | N     | ≤20       | ✓/✗    |
| Functions > 50 lines        | N     | 0         | ✓/✗    |
| Nesting depth (max)         | N     | ≤3        | ✓/✗    |

### Issues Found

| #   | Type | Location | Description | Severity |
| --- | ---- | -------- | ----------- | -------- |
```
