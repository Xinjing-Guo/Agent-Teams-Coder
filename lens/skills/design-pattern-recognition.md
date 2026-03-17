# Skill: Design Pattern Recognition

## Trigger

When analyzing code structure to identify design patterns, anti-patterns, and architectural decisions.

## Common Patterns to Identify

### Creational

| Pattern   | Signature                                       | Example                            |
| --------- | ----------------------------------------------- | ---------------------------------- |
| Factory   | Function returns different types based on input | `create_solver(type)`              |
| Builder   | Step-by-step object construction with chaining  | `Config().set_x().set_y().build()` |
| Singleton | Class-level instance, private constructor       | `instance = None; get_instance()`  |

### Structural

| Pattern   | Signature                             | Example                                  |
| --------- | ------------------------------------- | ---------------------------------------- |
| Adapter   | Wraps one interface to match another  | `class NumpyAdapter(OurInterface)`       |
| Decorator | Wraps function/class adding behavior  | `@cache`, `@validate_input`              |
| Facade    | Simple interface to complex subsystem | `class Solver` hiding 5 internal modules |
| Composite | Tree structure, uniform interface     | `Node.children: list[Node]`              |

### Behavioral

| Pattern         | Signature                                         | Example                                   |
| --------------- | ------------------------------------------------- | ----------------------------------------- |
| Strategy        | Interchangeable algorithms                        | `sort(data, algorithm=quicksort)`         |
| Observer        | Callbacks on state change                         | `on_complete(callback)`                   |
| Iterator        | Sequential access without exposing structure      | `__iter__`, `__next__`                    |
| Template Method | Base class defines skeleton, subclass fills steps | `process() calls _validate(), _compute()` |
| Command         | Encapsulate action as object                      | `class SortCommand(Command)`              |

## Anti-Patterns to Flag

| Anti-Pattern           | Symptom                                  | Recommendation               |
| ---------------------- | ---------------------------------------- | ---------------------------- |
| God Class              | >300 lines, >10 methods, does everything | Split by responsibility      |
| Spaghetti Code         | No clear structure, goto-like jumps      | Refactor into functions      |
| Premature Optimization | Complex code for marginal gain           | Simplify, benchmark first    |
| Copy-Paste Programming | >6 identical lines in multiple places    | Extract shared function      |
| Stringly Typed         | Uses strings where enums/types should be | Define proper types/enums    |
| Arrow Code             | Deep nesting (if inside if inside if)    | Guard clauses, early returns |

## Report Format

```markdown
### Design Patterns Identified

| Pattern   | Location      | Purpose                   | Quality             |
| --------- | ------------- | ------------------------- | ------------------- |
| Strategy  | solver.py:L45 | Swappable sort algorithms | Good use            |
| Singleton | config.py:L10 | Global config access      | Consider DI instead |

### Anti-Patterns Found

| Anti-Pattern | Location | Impact                | Suggestion           |
| ------------ | -------- | --------------------- | -------------------- |
| God Class    | core.py  | Hard to test/maintain | Split into 3 classes |
```
