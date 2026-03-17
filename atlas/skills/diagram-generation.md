# Skill: Diagram Generation

## Trigger

When documentation needs visual aids — architecture diagrams, flow charts, data flow, class diagrams.

## Mermaid (GitHub-native rendering)

### Flowchart

```mermaid
flowchart TD
    A[Input Data] --> B{Valid?}
    B -->|Yes| C[Process]
    B -->|No| D[Error Handler]
    C --> E[Output Results]
    D --> F[Log Error]
```

### Sequence Diagram

```mermaid
sequenceDiagram
    participant U as User
    participant M as Marshall
    participant E as Euler
    participant F as Forge
    U->>M: Submit requirement
    M->>E: Design algorithm
    E-->>M: Algorithm + pseudocode
    M->>F: Implement code
    F-->>M: Source code
```

### Class Diagram

```mermaid
classDiagram
    class Solver {
        -config: Config
        -algorithm: Algorithm
        +solve(data) Result
        +validate(data) bool
    }
    class Algorithm {
        <<interface>>
        +compute(input) output
        +complexity() string
    }
    Solver --> Algorithm
    QuickSort ..|> Algorithm
    MergeSort ..|> Algorithm
```

### State Diagram

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Working: receive_task
    Working --> Done: complete
    Working --> Blocked: dependency
    Blocked --> Working: unblocked
    Done --> Idle: new_task
    Done --> [*]
```

## ASCII Diagrams (universal fallback)

### Architecture

```
┌─────────────┐     ┌─────────────┐
│   Frontend   │────→│   Backend   │
│  (React)     │←────│  (FastAPI)  │
└─────────────┘     └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  Database   │
                    │ (PostgreSQL)│
                    └─────────────┘
```

### Data Flow

```
Raw CSV ──→ [Parser] ──→ DataFrame ──→ [Filter] ──→ Clean Data
                                                        │
                                                   [Analyzer]
                                                        │
                                                   ┌────▼────┐
                                              Report    Plot
```

## When to Use Which

| Diagram Type | Best For                        | Tool                   |
| ------------ | ------------------------------- | ---------------------- |
| Flowchart    | Algorithm logic, decision trees | Mermaid                |
| Sequence     | API calls, agent communication  | Mermaid                |
| Class        | OOP structure, interfaces       | Mermaid                |
| Architecture | System overview, deployment     | ASCII or Mermaid       |
| Data Flow    | Input → Processing → Output     | ASCII                  |
| Call Graph   | Function relationships          | ASCII tree (from Lens) |

## Checklist

- [ ] Every diagram has a title/caption
- [ ] Color/style used consistently
- [ ] ASCII version available as fallback
- [ ] Diagrams match actual code (not aspirational)
- [ ] Max ~15 nodes per diagram (split if larger)
