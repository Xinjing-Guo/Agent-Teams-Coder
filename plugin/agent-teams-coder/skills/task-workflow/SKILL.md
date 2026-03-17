---
name: Task Workflow
description: The 7-phase standard development workflow from requirements to delivery. Use when coordinating multi-agent software development tasks.
version: 1.0.1
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

## Chronicle CC Rule

Every agent MUST notify Chronicle upon completing their phase work:

```bash
bash scripts/notify.sh <agent_name> chronicle "<phase summary>" "<details: what was done, files produced, key data>"
```

| Phase | Who CCs Chronicle | Content                                               |
| ----- | ----------------- | ----------------------------------------------------- |
| 2     | Euler             | Algorithm design summary, complexity analysis         |
| 3     | Forge             | Code files, language, lines, implementation notes     |
| 4     | Sentinel          | Test case count, pass rate, bug list, fix status      |
| 5     | Lens              | Analysis scope, issues found, architecture assessment |
| 6     | Atlas             | Document chapters, page count, coverage               |
| 7     | Marshall          | Final deliverables list, overall summary              |

Chronicle cannot passively "listen" — it must be actively notified by each member.

## Parallel Opportunities

- Chronicle runs throughout all phases (receives notifications from all members)
- Lens + Atlas can start together after Phase 4 passes
- Euler can pre-work on Phase 2 while Marshall finishes Phase 1
