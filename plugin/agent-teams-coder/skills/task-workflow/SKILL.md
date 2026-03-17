---
name: Task Workflow
description: The 7-phase standard development workflow from requirements to delivery. Use when coordinating multi-agent software development tasks.
version: 1.0.0
---

# 7-Phase Standard Workflow

## Phase Overview

| Phase | Name          | Lead Agent | Output                        |
| ----- | ------------- | ---------- | ----------------------------- |
| 1     | Requirements  | Marshall   | Subtask matrix                |
| 2     | Algorithm     | Euler      | Algorithm design + pseudocode |
| 3     | Development   | Forge      | Source code                   |
| 4     | Testing       | Sentinel   | Test report                   |
| 5     | Analysis      | Lens       | Code analysis report          |
| 6     | Documentation | Atlas      | Software manual (4 chapters)  |
| 7     | Delivery      | Marshall   | Consolidated deliverables     |

## Phase Dependencies

```
Phase 1 ──→ Phase 2 ──→ Phase 3 ──→ Phase 4 ──→ Phase 5 ──┐
                                        ↑         │         │
                                        └─ Bug ───┘         ▼
                                                        Phase 6 ──→ Phase 7
```

- Phase 4 → Phase 3 loop: bugs found → fix → retest
- Phase 5 and Phase 6 can overlap (Lens starts while Atlas prepares)

## Task Categories

| Category                 | Phases Used   | Skip                                  |
| ------------------------ | ------------- | ------------------------------------- |
| New feature              | All 7         | None                                  |
| Bug fix                  | 1, 3, 4, 7    | 2 (algorithm), 5 (analysis), 6 (docs) |
| Documentation update     | 1, 5, 6, 7    | 2, 3, 4                               |
| Performance optimization | 1, 2, 3, 4, 7 | 5 (analysis), 6 (docs)                |

## Parallel Opportunities

- Chronicle runs throughout all phases (background)
- Lens + Atlas can start together after Phase 4 passes
- Euler can pre-work on Phase 2 while Marshall finishes Phase 1
