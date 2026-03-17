# Skill: Progress Tracking

## Trigger

During multi-phase workflows, track each agent's progress and identify blockers.

## Phase Status Board

Update at each phase transition:

```markdown
## Progress Board — [Task Name]

Last updated: YYYY-MM-DD HH:MM

| Phase           | Agent    | Status  | Output      | Blockers         |
| --------------- | -------- | ------- | ----------- | ---------------- |
| 1 Requirements  | Marshall | done    | Task matrix | —                |
| 2 Algorithm     | Euler    | working | —           | —                |
| 3 Development   | Forge    | waiting | —           | Depends on Euler |
| 4 Testing       | Sentinel | idle    | —           | —                |
| 5 Analysis      | Lens     | idle    | —           | —                |
| 6 Documentation | Atlas    | idle    | —           | —                |
| 7 Delivery      | Marshall | idle    | —           | —                |
```

Status values: `idle` → `waiting` → `working` → `done` / `blocked`

## Blocker Resolution

When an agent is blocked:

1. Identify the dependency (who is blocking whom)
2. Check if the blocking agent needs help or input
3. If resolvable → provide needed input
4. If external → escalate to user
5. Consider parallel alternatives (can another phase start early?)

## Milestone Checkpoints

At each phase completion:

- [ ] Output deliverable received and validated
- [ ] No unresolved blockers for next phase
- [ ] Chronicle notified to log phase completion
- [ ] status.json updated via `update-phase.sh`
