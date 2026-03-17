# Agent Teams Coder

> A multi-agent software development collaboration framework powered by Claude Code. Seven specialized AI agents work together under a strict shared memory governance model.

<p align="center">
  <img src="docs/architecture.svg" alt="Agent Teams Coder Architecture" width="100%"/>
</p>

## Installation

### Option A: Claude Code Plugin (Recommended)

```bash
# Step 1: Add the marketplace
claude plugin marketplace add Xinjing-Guo/Agent-Teams-Coder --sparse .claude-plugin plugin

# Step 2: Install the plugin
claude plugin install agent-teams-coder
```

Then in any Claude Code session:

```bash
/agent-team Write a high-performance FFT library in Python and C
```

`/agent-team` auto-detects tmux:

- **tmux available** → asks you: multi-window (7 visible panes) or single-window (automated)
- **tmux not available** → runs in single-window mode automatically

### Option B: tmux Multi-Pane (No Plugin Needed)

```bash
git clone https://github.com/Xinjing-Guo/Agent-Teams-Coder.git
cd Agent-Teams-Coder
./panel.sh
```

Choose a launch preset:

| Option                    | Agents                              | Use Case                  |
| ------------------------- | ----------------------------------- | ------------------------- |
| a) Full team              | All 7                               | Complete workflow         |
| b) Core dev               | Marshall + Euler + Forge + Sentinel | Algorithm → Code → Test   |
| c) Leader only            | Marshall                            | Planning and coordination |
| d) Algorithm + Dev        | Euler + Forge                       | Focused implementation    |
| e) Test + Analysis + Docs | Sentinel + Lens + Atlas             | Post-development pipeline |

Each agent supports model selection:

```bash
./start-euler.sh           # Default: Sonnet
./start-euler.sh opus      # Opus for complex algorithm design
./start-chronicle.sh haiku # Haiku for logging (cost-efficient)
```

### Option C: Local Plugin Install

```bash
git clone https://github.com/Xinjing-Guo/Agent-Teams-Coder.git
claude plugin add ./Agent-Teams-Coder/plugin/agent-teams-coder
```

### Plugin Management

```bash
claude plugin list                          # List installed plugins
claude plugin enable agent-teams-coder      # Enable
claude plugin disable agent-teams-coder     # Disable
claude plugin uninstall agent-teams-coder   # Uninstall
```

---

## Team Members

| Codename      | Role                   | Skills (32 total)                                                                                                        |
| ------------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| **Marshall**  | Leader                 | task-decomposition, risk-assessment, progress-tracking, team-coordination                                                |
| **Euler**     | Algorithm Designer     | algorithm-design, complexity-analysis, numerical-methods, optimization-algorithms, data-structures, statistical-modeling |
| **Forge**     | Code Developer         | multi-language-coding, code-review-checklist, python-expert, c-cpp-expert, r-julia-expert, build-and-packaging           |
| **Sentinel**  | Code Tester            | test-strategy, bug-tracking, python-testing, c-cpp-testing, performance-testing                                          |
| **Lens**      | Code Analyst           | code-analysis-framework, static-analysis, design-pattern-recognition, call-graph-generation                              |
| **Atlas**     | Documentation Engineer | manual-structure, api-documentation, tutorial-writing, diagram-generation                                                |
| **Chronicle** | Log Recorder           | activity-logging, changelog-generation, decision-log                                                                     |

## Standard Workflow

```
Phase 1: Requirements   → Marshall decomposes requirements, Chronicle starts logging
Phase 2: Algorithm       → Euler designs algorithm, aligns with Forge
Phase 3: Development     → Forge implements code based on Euler's algorithm
Phase 4: Testing         → Sentinel tests rigorously, broadcasts test report
                            ↻ Bug found → Forge fixes → Sentinel retests (max 3 rounds)
Phase 5: Analysis        → Lens analyzes code structure, line-by-line explanation
Phase 6: Documentation   → Atlas integrates manual (test cases + code analysis)
Phase 7: Delivery        → Marshall consolidates, Chronicle generates summary
```

## Core Mechanisms

### 1. Shared Memory with Approval Governance

The shared memory (`shared-memory.json`) stores team-wide architectural decisions, API conventions, and coding standards. It is **protected by an approval mechanism**:

| Operation | Who                  | How                                                              |
| --------- | -------------------- | ---------------------------------------------------------------- |
| **Read**  | All members          | Direct file read — always allowed                                |
| **Write** | Members (non-Leader) | Submit request via `memory-request.sh` → Leader approves/rejects |
| **Write** | Marshall (Leader)    | Direct write via `memory-write.sh` — no approval needed          |

```bash
# Member submits a change request
bash scripts/memory-request.sh write "api_auth" "Use JWT tokens" "Standardize auth"

# Leader approves
bash scripts/memory-approve.sh req_20260317120000_42

# Leader rejects
bash scripts/memory-reject.sh req_20260317120000_42 "Conflicts with existing decision"
```

### 2. Seven-Point Mandatory Checkpoint

Every agent must complete these 7 steps **before executing any task**:

| Step | Check                    | Purpose                                     |
| ---- | ------------------------ | ------------------------------------------- |
| 1    | Task scope confirmation  | Prevent overreach or misunderstanding       |
| 2    | Shared memory read       | Ensure compliance with team conventions     |
| 3    | Smart notification check | Don't miss teammate messages (mtime-cached) |
| 4    | Team status sync         | Read current phase, update own status       |
| 5    | Skill applicability      | Use specialized skill if available          |
| 6    | Task decomposability     | Split if >= 3 steps or multi-file           |
| 7    | Git operation detection  | Require explicit user authorization         |

Violation triggers auto-correction: stop → restart from step 1.

### 3. Real-Time Team Status (`status.json`)

All agents read/write a shared status file so every member knows who is doing what:

```bash
# Member updates their own status
bash scripts/update-status.sh forge working "Implementing sort algorithm"
bash scripts/update-status.sh sentinel blocked "" "Waiting for Forge"

# Marshall updates workflow phase
bash scripts/update-phase.sh 3 "Sort library development"
```

Status values: `idle` | `working` | `blocked` | `waiting` | `done`

### 4. Skill System (32 Skills)

Each agent has a `skills/` directory containing specialized knowledge packages — method selection guides, code templates, checklists, and tool references. Skills are checked at checkpoint step 5 and used when applicable.

<details>
<summary><b>Marshall — 4 Skills</b></summary>

| Skill                   | Purpose                                                          |
| ----------------------- | ---------------------------------------------------------------- |
| `task-decomposition.md` | Requirement classification, dependency analysis, task matrix     |
| `risk-assessment.md`    | Risk matrix, technical/process risks, mitigation strategies      |
| `progress-tracking.md`  | Phase status board, blocker resolution, milestone checks         |
| `team-coordination.md`  | Euler↔Forge alignment, bug loop limits (max 3), escalation rules |

</details>

<details>
<summary><b>Euler — 6 Skills</b></summary>

| Skill                        | Purpose                                                                    |
| ---------------------------- | -------------------------------------------------------------------------- |
| `algorithm-design.md`        | Problem modeling → candidates → selection → pseudocode → boundary analysis |
| `complexity-analysis.md`     | Big-O derivation framework, best/avg/worst, practical performance notes    |
| `numerical-methods.md`       | Root finding, interpolation, ODE/PDE, FFT, stability checklist             |
| `optimization-algorithms.md` | Decision tree: differentiable? convex? discrete? → method selection        |
| `data-structures.md`         | Selection guide by access pattern, language-specific implementations       |
| `statistical-modeling.md`    | Hypothesis testing, distributions, Monte Carlo, sample size estimation     |

</details>

<details>
<summary><b>Forge — 6 Skills</b></summary>

| Skill                      | Purpose                                                                     |
| -------------------------- | --------------------------------------------------------------------------- |
| `multi-language-coding.md` | Language selection guide, coding checklist, multi-language templates        |
| `code-review-checklist.md` | Correctness, robustness, readability, performance, security checks          |
| `python-expert.md`         | Type hints, patterns (context managers, dataclasses), logging, libraries    |
| `c-cpp-expert.md`          | Memory safety, RAII, smart pointers, CMake, valgrind, sanitizers            |
| `r-julia-expert.md`        | Tidyverse/vectorized R, multiple dispatch/type-stable Julia, key packages   |
| `build-and-packaging.md`   | pyproject.toml, CMake, Makefile, R/Julia package structure, deps management |

</details>

<details>
<summary><b>Sentinel — 5 Skills</b></summary>

| Skill                    | Purpose                                                                    |
| ------------------------ | -------------------------------------------------------------------------- |
| `test-strategy.md`       | Test pyramid (60/30/10), equivalence class, boundary value, error guessing |
| `bug-tracking.md`        | Bug lifecycle, report template, severity definitions                       |
| `python-testing.md`      | pytest essentials: parametrize, fixtures, mocking, coverage, benchmarks    |
| `c-cpp-testing.md`       | GTest, CUnit, valgrind, AddressSanitizer, UBSan, CMake integration         |
| `performance-testing.md` | Benchmarking methodology, profiling tools, scaling analysis, red flags     |

</details>

<details>
<summary><b>Lens — 4 Skills</b></summary>

| Skill                           | Purpose                                                                      |
| ------------------------------- | ---------------------------------------------------------------------------- |
| `code-analysis-framework.md`    | 4-layer analysis: architecture → modules → functions → lines                 |
| `static-analysis.md`            | Linters/formatters by language, cyclomatic/cognitive complexity, code smells |
| `design-pattern-recognition.md` | Creational/structural/behavioral patterns + anti-pattern identification      |
| `call-graph-generation.md`      | Mermaid + ASCII formats, dependency graphs, data flow diagrams               |

</details>

<details>
<summary><b>Atlas — 4 Skills</b></summary>

| Skill                   | Purpose                                                                      |
| ----------------------- | ---------------------------------------------------------------------------- |
| `manual-structure.md`   | 4-chapter checklist matrix, writing principles per chapter, quality checks   |
| `api-documentation.md`  | Function/CLI/module doc templates with params, returns, examples, exceptions |
| `tutorial-writing.md`   | Step-by-step guide structure, writing rules, quick-start template            |
| `diagram-generation.md` | Mermaid (flowchart/sequence/class/state) + ASCII diagrams, when-to-use guide |

</details>

<details>
<summary><b>Chronicle — 3 Skills</b></summary>

| Skill                     | Purpose                                                                     |
| ------------------------- | --------------------------------------------------------------------------- |
| `activity-logging.md`     | What to record/skip, log file naming, update summary triggers, distribution |
| `changelog-generation.md` | Keep a Changelog format, semantic versioning, auto-generation process       |
| `decision-log.md`         | ADR (Architecture Decision Record) format, what qualifies, decision index   |

</details>

### 5. Notification System

File-based async notifications with mtime caching (97% token savings when no changes):

```bash
# Send notification
bash scripts/notify.sh euler forge "Algorithm ready" "Sorting algorithm design complete"

# Broadcast to all
bash scripts/notify.sh marshall all "Phase update" "Entering testing phase"

# Check notifications (mtime-cached — skips file read if no changes)
bash scripts/check-notify.sh forge
```

### 6. tmux Integration

`/agent-team` auto-detects tmux and offers two modes:

| Mode              | When                         | What Happens                                      |
| ----------------- | ---------------------------- | ------------------------------------------------- |
| **Multi-window**  | tmux available, user chooses | Creates 7 labeled tmux panes, one per agent       |
| **Single-window** | no tmux, or user prefers     | Marshall orchestrates via subagents in background |

tmux pane layout:

```
┌──────────────────┬──────────────────┐
│ Marshall (Leader) │ Euler (Algorithm) │
├──────────────────┼──────────────────┤
│ Forge (Code)     │ Sentinel (Test)   │
├──────────────────┼──────────────────┤
│ Lens (Analysis)  │ Atlas (Docs)      │
├──────────────────┤ Chronicle (Log)   │
└──────────────────┴──────────────────┘
```

tmux shortcuts:

- `Ctrl+B` then arrow keys — switch panes
- `Ctrl+B` then `z` — zoom/unzoom current pane
- `Ctrl+B` then `d` — detach (`tmux attach -t agent-team` to resume)

---

## Prerequisites

- Claude Code v2.1.32+ (`claude --version`)
- Enable Agent Teams (for tmux multi-instance mode):
  ```json
  { "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
  ```
- tmux (optional, for multi-pane mode): `brew install tmux`

## Plugin Structure

```
plugin/agent-teams-coder/
├── .claude-plugin/
│   └── plugin.json                    # Plugin manifest
├── commands/
│   └── agent-team.md                  # /agent-team slash command
├── agents/                            # 6 subagent definitions
│   ├── euler.md                       #   Algorithm Designer
│   ├── forge.md                       #   Code Developer
│   ├── sentinel.md                    #   Code Tester
│   ├── lens.md                        #   Code Analyst
│   ├── atlas.md                       #   Documentation Engineer
│   └── chronicle.md                   #   Log Recorder
├── skills/                            # 3 shared knowledge packages
│   ├── shared-memory-protocol/        #   Memory governance rules
│   │   └── SKILL.md
│   ├── seven-point-checkpoint/        #   Mandatory pre-task checklist
│   │   └── SKILL.md
│   └── task-workflow/                 #   7-phase pipeline definition
│       └── SKILL.md
└── scripts/
    └── launch-team.sh                 #   tmux auto-detection + launcher
```

## Project Structure

```
Agent-Teams-Coder/
├── .claude-plugin/
│   └── marketplace.json               # Marketplace registration
├── CLAUDE.md                          # Project-level instructions (shared)
├── README.md
│
├── leader/                            # Marshall (4 skills)
│   ├── CLAUDE.md
│   ├── PERSONA.md
│   └── skills/
│       ├── task-decomposition.md
│       ├── risk-assessment.md
│       ├── progress-tracking.md
│       └── team-coordination.md
│
├── euler/                             # Euler (6 skills)
│   ├── CLAUDE.md
│   ├── PERSONA.md
│   └── skills/
│       ├── algorithm-design.md
│       ├── complexity-analysis.md
│       ├── numerical-methods.md
│       ├── optimization-algorithms.md
│       ├── data-structures.md
│       └── statistical-modeling.md
│
├── forge/                             # Forge (6 skills)
│   ├── CLAUDE.md
│   ├── PERSONA.md
│   └── skills/
│       ├── multi-language-coding.md
│       ├── code-review-checklist.md
│       ├── python-expert.md
│       ├── c-cpp-expert.md
│       ├── r-julia-expert.md
│       └── build-and-packaging.md
│
├── sentinel/                          # Sentinel (5 skills)
│   ├── CLAUDE.md
│   ├── PERSONA.md
│   └── skills/
│       ├── test-strategy.md
│       ├── bug-tracking.md
│       ├── python-testing.md
│       ├── c-cpp-testing.md
│       └── performance-testing.md
│
├── lens/                              # Lens (4 skills)
│   ├── CLAUDE.md
│   ├── PERSONA.md
│   └── skills/
│       ├── code-analysis-framework.md
│       ├── static-analysis.md
│       ├── design-pattern-recognition.md
│       └── call-graph-generation.md
│
├── atlas/                             # Atlas (4 skills)
│   ├── CLAUDE.md
│   ├── PERSONA.md
│   └── skills/
│       ├── manual-structure.md
│       ├── api-documentation.md
│       ├── tutorial-writing.md
│       └── diagram-generation.md
│
├── chronicle/                         # Chronicle (3 skills)
│   ├── CLAUDE.md
│   ├── PERSONA.md
│   └── skills/
│       ├── activity-logging.md
│       ├── changelog-generation.md
│       └── decision-log.md
│
├── shared/                            # Shared workspace
│   ├── memory/
│   │   ├── shared-memory.json         #   Protected shared memory
│   │   ├── approval-queue.json        #   Approval queue
│   │   └── status.json                #   Real-time team status
│   ├── tasks/                         #   Task records & logs
│   ├── notifications/                 #   Notification files
│   └── templates/
│       ├── prd.md
│       ├── bug.md
│       └── api.md
│
├── scripts/
│   ├── memory-request.sh              #   Submit memory change request
│   ├── memory-approve.sh              #   Leader approves request
│   ├── memory-reject.sh               #   Leader rejects request
│   ├── memory-write.sh                #   Leader direct write
│   ├── notify.sh                      #   Send notification
│   ├── check-notify.sh                #   Check notifications (mtime-cached)
│   ├── update-status.sh               #   Update member status
│   └── update-phase.sh                #   Update workflow phase
│
├── plugin/agent-teams-coder/          #   Claude Code plugin (see above)
├── panel.sh                           #   tmux multi-pane launcher
├── start-leader.sh                    #   Individual agent launchers
├── start-euler.sh                     #     (all support: ./start-X.sh [opus|haiku])
├── start-forge.sh
├── start-sentinel.sh
├── start-lens.sh
├── start-atlas.sh
└── start-chronicle.sh
```

## Collaboration Network

| Relationship     | Description                                                                                                      |
| ---------------- | ---------------------------------------------------------------------------------------------------------------- |
| Euler ↔ Forge    | Algorithm → Code: Euler provides algorithm + pseudocode, Forge implements and feeds back engineering constraints |
| Forge → Sentinel | Code → Test: Forge notifies Sentinel when code is ready                                                          |
| Sentinel → Forge | Bug → Fix: Sentinel reports bugs, Forge fixes, regression test loop (max 3 rounds)                               |
| Lens → Atlas     | Analysis → Docs: Lens provides line-by-line code explanation for Atlas                                           |
| Sentinel → Atlas | Tests → Docs: Sentinel provides test cases, Atlas converts to usage examples                                     |
| Chronicle ← All  | Logging: Chronicle monitors all member activities and generates decision logs                                    |

### Atlas Manual — Four Chapters

| Chapter                               | Source                                               |
| ------------------------------------- | ---------------------------------------------------- |
| Part 1: Software Introduction         | Forge (architecture) + Euler (algorithm description) |
| Part 2: User Guide                    | Forge (API/interface info) + Atlas                   |
| Part 3: Usage Examples                | Sentinel (test cases converted)                      |
| Part 4: Line-by-Line Code Explanation | Lens (code analysis report)                          |

## License

MIT
