# Forge Fix Report

**Author**: Forge (Code Developer)
**Date**: 2026-03-17
**Task**: Fix all bugs identified during project audit (BUG-001 through BUG-004)
**Test Result**: 29/29 PASS (100%)

---

## FIX 1: BUG-001 (Major) -- `declare -A` in update-phase.sh

**File**: `scripts/update-phase.sh`

**Problem**: Used `declare -A PHASE_DESC` (Bash 4+ associative arrays). macOS ships with Bash 3.2 which does NOT support associative arrays. The script silently fails, writing empty strings to status.json.

**Fix**: Replaced the `declare -A` associative array with a POSIX-compatible `case` statement. All 7 phases map correctly:

- Phase 1-7 map to their Chinese descriptions
- Unknown phase numbers fall through to a default case

**Verification**: `update-phase.sh 3 "test"` now correctly outputs "阶段 3: 代码开发" (previously wrote empty string).

---

## FIX 2: BUG-002 (Minor) -- Missing marshall.md in plugin

**File created**: `plugin/agent-teams-coder/agents/marshall.md`

**Problem**: The plugin agents directory had definitions for 6 agents (euler, forge, sentinel, lens, atlas, chronicle) but was missing marshall (the Leader).

**Fix**: Created `marshall.md` following the exact same format as the other agent definition files. Includes:

- YAML frontmatter (name, description, examples, model, color)
- Identity section based on `leader/PERSONA.md`
- Workflow (7-phase coordination)
- Output format template
- Rules (delegate, do not code)

---

## FIX 3: Added `set -euo pipefail` to all 8 scripts

**Files modified**: All 8 scripts in `scripts/`

| Script            | Previous | After               |
| ----------------- | -------- | ------------------- |
| memory-request.sh | `set -e` | `set -euo pipefail` |
| memory-approve.sh | `set -e` | `set -euo pipefail` |
| memory-reject.sh  | `set -e` | `set -euo pipefail` |
| memory-write.sh   | `set -e` | `set -euo pipefail` |
| notify.sh         | `set -e` | `set -euo pipefail` |
| check-notify.sh   | (none)   | `set -euo pipefail` |
| update-status.sh  | `set -e` | `set -euo pipefail` |
| update-phase.sh   | `set -e` | `set -euo pipefail` |

**Additional compatibility fix**: Two scripts had `$VARIABLE（` patterns where Chinese full-width parenthesis `（` (U+FF08) immediately followed a `$VARIABLE` without braces. Under `set -u`, bash 3.2 misinterprets the leading byte of the multi-byte character as part of the variable name, causing "unbound variable" errors. Fixed by:

- Using `${VARIABLE}` with braces to delimit variable names
- Replacing `（）` with ASCII `()` in those specific error messages

**Additional compatibility fix**: `update-status.sh` had `[ -n "$VAR" ] && echo ...` patterns at the end of the script. Under `set -e`, when `$VAR` is empty, the `[` test returns non-zero and the `&&` short-circuits, causing the script to exit with error. Added `|| true` to prevent false failures.

---

## FIX 4: Shell injection risk in all python3 -c calls

**Files modified**: All 8 scripts in `scripts/`

**Problem**: All scripts used `python3 -c "..."` with shell variables interpolated directly into Python code via `$VAR` or `'''$VAR'''`. If a variable contained quotes, backslashes, or special characters, this could break execution or be exploited for injection.

**Fix**: Converted every `python3 -c` invocation to pass shell variables via environment variables instead of string interpolation. Pattern used:

```bash
# Before (vulnerable):
python3 -c "data['$KEY'] = '''$VALUE'''"

# After (safe):
KEY="$KEY" VALUE="$VALUE" python3 -c "
import os
data[os.environ['KEY']] = os.environ['VALUE']
"
```

**Scripts with python3 -c calls fixed**:

- `update-phase.sh` -- 1 call (5 variables)
- `update-status.sh` -- 1 call (6 variables)
- `memory-request.sh` -- 1 call (8 variables), also eliminated intermediate heredoc JSON construction
- `memory-approve.sh` -- 1 call (4 variables)
- `memory-reject.sh` -- 1 call (3 variables)
- `memory-write.sh` -- 1 call (3 variables)
- `notify.sh` -- 1 call inside loop (7 variables)
- `check-notify.sh` -- 1 call (1 variable)

**Verification**: Tested with values containing single quotes, double quotes, and backslashes -- all handled correctly.

---

## Test Results

```
================================================================
  SUMMARY: Shell Scripts Functional Test
  Total: 29 | Pass: 29 | Fail: 0 | Skip: 0
  Pass Rate: 100%
================================================================
```

Previous pass rate before fixes: 86% (25/29). All 4 previously failing tests now pass.
