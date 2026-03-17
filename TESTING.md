# Agent Teams Coder — Feature List & Testing Guide

**Repository**: https://github.com/Xinjing-Guo/Agent-Teams-Coder
**Files**: 85 | **Commits**: 9 | **Branches**: main, Claude

---

## 1. Team Architecture (7 Agents)

| Codename  | Role                   | Responsibility                                                         | Skills |
| --------- | ---------------------- | ---------------------------------------------------------------------- | ------ |
| Marshall  | Leader                 | Task decomposition, assignment, memory approval, delivery              | 4      |
| Euler     | Algorithm Designer     | Algorithm design, math modeling, complexity analysis, pseudocode       | 6      |
| Forge     | Code Developer         | Python/C/C++/R/Julia/Shell implementation                              | 6      |
| Sentinel  | Code Tester            | Functional/boundary/performance testing, bug tracking, test reports    | 5      |
| Lens      | Code Analyst           | Architecture analysis, function explanation, line-by-line, call graphs | 4      |
| Atlas     | Documentation Engineer | 4-chapter manual (intro, usage, examples, code explanation)            | 4      |
| Chronicle | Log Recorder           | Activity logging, update summaries, decision logs, changelogs          | 3      |

---

## 2. Core Mechanisms (6)

| #   | Mechanism                              | How to Test                                                                                                                                                      |
| --- | -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | **Shared Memory Approval**             | `bash scripts/memory-request.sh write "key" "value" "reason"` → check `approval-queue.json` → `bash scripts/memory-approve.sh <id>` → check `shared-memory.json` |
| 2   | **Seven-Point Checkpoint**             | Launch any agent, give it a task, observe if it follows 7 steps (scope → memory → notify → status → skill → decompose → git)                                     |
| 3   | **Real-Time Team Status**              | `bash scripts/update-status.sh forge working "coding"` → check `status.json`; `bash scripts/update-phase.sh 3 "dev task"`                                        |
| 4   | **Skill System** (32 total)            | Check each agent's `skills/` directory; give agent a relevant task and observe if corresponding skill is triggered                                               |
| 5   | **Notification System** (mtime-cached) | `bash scripts/notify.sh euler forge "test" "hello"` → `bash scripts/check-notify.sh forge`                                                                       |
| 6   | **Model Selection**                    | `./start-euler.sh opus` / `./start-chronicle.sh haiku`                                                                                                           |

---

## 3. Usage Modes (3)

| Mode                                  | Command                                                                                                                                                                | What to Verify                                                      |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| **A. Plugin**                         | `claude plugin marketplace add Xinjing-Guo/Agent-Teams-Coder --sparse .claude-plugin plugin` → `claude plugin install agent-teams-coder` → `/agent-team <requirement>` | Plugin installs, `/agent-team` triggers, subagents are dispatched   |
| **B. tmux**                           | `./panel.sh` → select a) full team                                                                                                                                     | 7 tmux panes launch correctly, each agent loads its own PERSONA.md  |
| **C. /agent-team + tmux auto-detect** | Install plugin, run `/agent-team`, observe tmux detection prompt                                                                                                       | tmux detection works, `launch-team.sh` creates labeled tmux session |

---

## 4. Testing Checklist

### 4.1 Script Functionality

```bash
cd worktree-claude/

# Notification system
bash scripts/notify.sh euler forge "test subject" "hello from euler"
bash scripts/check-notify.sh forge
# Expected: shows new notification

# Shared memory approval
bash scripts/memory-request.sh write "test_key" "test_value" "testing"
# Expected: outputs request_id (e.g., req_20260317120000_42)
cat shared/memory/approval-queue.json
# Expected: request with status "pending"

bash scripts/memory-approve.sh <request_id_from_above>
cat shared/memory/shared-memory.json
# Expected: "test_key": "test_value" appears

# Team status
bash scripts/update-status.sh forge working "testing scripts"
bash scripts/update-phase.sh 1 "test task"
cat shared/memory/status.json
# Expected: forge status = "working", phase = "1"
```

### 4.2 tmux Panel

```bash
./panel.sh
# Select a) full team
# Expected: 7 tmux panes, each running `claude`
# Verify: Ctrl+B then arrow keys to switch panes
# Cleanup: Ctrl+B then d to detach, `tmux kill-session -t agent-team`
```

### 4.3 Individual Agent Launch + Model Selection

```bash
./start-euler.sh           # Default Sonnet
# Expected: Claude starts in euler/ directory

./start-euler.sh opus      # Opus model
# Expected: Claude starts with --model claude-opus-4-6

./start-chronicle.sh haiku # Haiku model
# Expected: Claude starts with --model claude-haiku-4-5-20251001
```

### 4.4 Plugin Installation

```bash
claude plugin marketplace add Xinjing-Guo/Agent-Teams-Coder --sparse .claude-plugin plugin
# Expected: marketplace added successfully

claude plugin install agent-teams-coder
# Expected: plugin installed

claude plugin list
# Expected: agent-teams-coder appears in list
```

### 4.5 /agent-team Command

```
# In Claude Code session:
/agent-team Write a function to compute the dot product of two vectors, in Python and C
```

Expected behavior:

1. Marshall analyzes and decomposes the requirement
2. Euler designs the dot product algorithm (trivial but should still provide complexity analysis)
3. Forge implements in Python and C
4. Sentinel writes tests and runs them
5. Lens analyzes the code structure
6. Atlas writes a mini-manual
7. Chronicle generates update summary

### 4.6 tmux Auto-Detection

```
# With tmux installed, run /agent-team
# Expected: prompt asking "Multi-window mode or Single-window mode?"

# Choose 1 (multi-window)
# Then in another terminal:
tmux ls
# Expected: session "agent-team" exists

tmux attach -t agent-team
# Expected: 7 labeled panes visible
```

### 4.7 Shared Memory Protection

```
# As a non-Leader agent (e.g., Forge):
# Try to directly edit shared-memory.json
# Expected: CLAUDE.md rules should prevent direct editing
# The agent should use memory-request.sh instead
```

### 4.8 Skill Triggering

| Test                  | Agent     | Input                                  | Expected Skill                  |
| --------------------- | --------- | -------------------------------------- | ------------------------------- |
| Optimization problem  | Euler     | "Design an algorithm to minimize f(x)" | `optimization-algorithms.md`    |
| Numerical problem     | Euler     | "Implement FFT"                        | `numerical-methods.md`          |
| Python implementation | Forge     | "Write this in Python"                 | `python-expert.md`              |
| C implementation      | Forge     | "Write this in C"                      | `c-cpp-expert.md`               |
| Python testing        | Sentinel  | "Test this Python code"                | `python-testing.md`             |
| C memory testing      | Sentinel  | "Check for memory leaks"               | `c-cpp-testing.md`              |
| Performance benchmark | Sentinel  | "Benchmark this function"              | `performance-testing.md`        |
| Code structure        | Lens      | "Analyze this codebase"                | `code-analysis-framework.md`    |
| Pattern detection     | Lens      | "What design patterns are used?"       | `design-pattern-recognition.md` |
| API docs              | Atlas     | "Document this API"                    | `api-documentation.md`          |
| Tutorial              | Atlas     | "Write a quick-start guide"            | `tutorial-writing.md`           |
| Update summary        | Chronicle | "Generate update summary"              | `activity-logging.md`           |
| Decision record       | Chronicle | "Record this architecture decision"    | `decision-log.md`               |

---

## 5. File Structure Overview

```
worktree-claude/                         (85 files)
├── .claude-plugin/marketplace.json       ← Marketplace registration
├── CLAUDE.md                             ← Project instructions (7-point checkpoint, collaboration network)
├── README.md                             ← English documentation (all features)
├── TESTING.md                            ← This file
├── docs/architecture.svg                 ← Architecture diagram (SVG)
│
├── leader/   (CLAUDE.md + PERSONA.md + 4 skills)
│   └── skills/: task-decomposition, risk-assessment, progress-tracking, team-coordination
├── euler/    (CLAUDE.md + PERSONA.md + 6 skills)
│   └── skills/: algorithm-design, complexity-analysis, numerical-methods,
│                 optimization-algorithms, data-structures, statistical-modeling
├── forge/    (CLAUDE.md + PERSONA.md + 6 skills)
│   └── skills/: multi-language-coding, code-review-checklist, python-expert,
│                 c-cpp-expert, r-julia-expert, build-and-packaging
├── sentinel/ (CLAUDE.md + PERSONA.md + 5 skills)
│   └── skills/: test-strategy, bug-tracking, python-testing, c-cpp-testing, performance-testing
├── lens/     (CLAUDE.md + PERSONA.md + 4 skills)
│   └── skills/: code-analysis-framework, static-analysis, design-pattern-recognition,
│                 call-graph-generation
├── atlas/    (CLAUDE.md + PERSONA.md + 4 skills)
│   └── skills/: manual-structure, api-documentation, tutorial-writing, diagram-generation
├── chronicle/(CLAUDE.md + PERSONA.md + 3 skills)
│   └── skills/: activity-logging, changelog-generation, decision-log
│
├── shared/
│   ├── memory/shared-memory.json         ← Protected shared memory
│   ├── memory/approval-queue.json        ← Approval queue
│   ├── memory/status.json                ← Real-time team status
│   ├── tasks/                            ← Task records & logs
│   ├── notifications/                    ← Notification files
│   └── templates/ (prd.md, bug.md, api.md)
│
├── scripts/ (8 scripts)
│   ├── memory-request.sh                 ← Submit memory change request
│   ├── memory-approve.sh                 ← Leader approves
│   ├── memory-reject.sh                  ← Leader rejects
│   ├── memory-write.sh                   ← Leader direct write
│   ├── notify.sh                         ← Send notification
│   ├── check-notify.sh                   ← Check notifications (mtime-cached)
│   ├── update-status.sh                  ← Update member status
│   └── update-phase.sh                   ← Update workflow phase
│
├── plugin/agent-teams-coder/             ← Claude Code plugin
│   ├── .claude-plugin/plugin.json        ← Plugin manifest
│   ├── commands/agent-team.md            ← /agent-team slash command
│   ├── agents/ (6 subagent definitions)
│   │   ├── euler.md, forge.md, sentinel.md, lens.md, atlas.md, chronicle.md
│   ├── skills/ (3 knowledge packages)
│   │   ├── shared-memory-protocol/SKILL.md
│   │   ├── seven-point-checkpoint/SKILL.md
│   │   └── task-workflow/SKILL.md
│   └── scripts/launch-team.sh            ← tmux auto-detection launcher
│
├── panel.sh                              ← tmux multi-pane launcher (5 presets)
├── start-leader.sh                       ← Individual launchers
├── start-euler.sh                        ←   (all support: ./start-X.sh [opus|haiku])
├── start-forge.sh
├── start-sentinel.sh
├── start-lens.sh
├── start-atlas.sh
└── start-chronicle.sh
```
