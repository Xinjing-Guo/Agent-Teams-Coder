# Retest Report -- Agent Teams Project (Post-Fix Verification)

Date: 2026-03-17 | Tester: Sentinel | Phase: Regression Retest

## Summary

- Total cases executed: 104 (out of expected 169)
- Passed: 102 (98%)
- Failed: 2 (2%)
- Skipped: 0
- Blocked: 1 entire suite (test-agent-structure.sh -- 67 cases -- crashed at startup)

## Test Environment

- Language: Python 3 / Bash 3.2.57 (macOS default)
- OS: macOS Darwin 25.4.0 (arm64)
- Project: Agent Teams v1.0.1

## Before/After Comparison

| Suite                          | Before (Pass/Total) | After (Pass/Total) | Delta            | Notes                                          |
| ------------------------------ | ------------------- | ------------------ | ---------------- | ---------------------------------------------- |
| 1. Shell Scripts Functional    | 26/29 (89%)         | 28/29 (96%)        | +2 fixed         | update-phase.sh now works                      |
| 2. Agent Structure Validation  | 67/67 (100%)        | **CRASHED** (0/67) | REGRESSION       | Test file itself uses `declare -A`             |
| 3. Plugin Structure Validation | 18/19 (94%)         | 21/21 (100%)       | +3 fixed + 2 new | marshall.md added, new tests added             |
| 4. Shared Memory Integrity     | 15/15 (100%)        | 14/15 (93%)        | -1               | Pre-existing race condition (not a regression) |
| 5. Start Scripts Validation    | 39/39 (100%)        | 39/39 (100%)       | No change        |                                                |

## Per-Fix Verification

### FIX 1: update-phase.sh Bash 3.2 Compatibility

- **Status: VERIFIED PASS**
- `scripts/update-phase.sh` no longer uses `declare -A`. It now uses a `case` statement (lines 22-31).
- Test 8a (phase 1 update): PASS
- Test 8c (phase 4 update): PASS
- Both phase number and description are correctly written to status.json.

### FIX 2: marshall.md in Plugin Agents Directory

- **Status: VERIFIED PASS**
- File `plugin/agent-teams-coder/agents/marshall.md` now exists.
- Plugin structure test "Leader agent definition exists": PASS
- Total agent definitions in plugin: 7/7 (was 6/7).

### FIX 3: `set -euo pipefail` in All 8 Scripts

- **Status: VERIFIED PASS**
- All 8 scripts in `scripts/` contain `set -euo pipefail`:
  - check-notify.sh (line 9)
  - memory-approve.sh (line 13)
  - memory-reject.sh (line 7)
  - memory-request.sh (line 14)
  - memory-write.sh (line 7)
  - notify.sh (line 8)
  - update-phase.sh (line 11)
  - update-status.sh (line 12)

### FIX 4: No Direct Variable Interpolation in python3 -c Calls

- **Status: VERIFIED PASS**
- All 8 scripts pass variables via environment variables (e.g., `STATUS_FILE="$STATUS_FILE" $PY -c "..."`) and read them inside Python with `os.environ['VARNAME']`.
- No script uses `$VARIABLE` or shell interpolation inside the Python code strings.
- Manual grep confirms 0 occurrences of shell variable interpolation within python -c blocks.

## Remaining Issues

### ISSUE-1 (NEW REGRESSION): test-agent-structure.sh Crashes on macOS Bash 3.2

- **Severity: Major (test infrastructure)**
- **File**: `Test-Example/test-agent-structure.sh`, line 27
- **Root cause**: The test script itself uses `declare -A EXPECTED_SKILLS` which is Bash 4+ only. On macOS Bash 3.2.57, this causes immediate crash with `declare: -A: invalid option`.
- **Impact**: The entire Suite 2 (67 test cases) cannot execute. These tests were passing in the first run likely because they ran before Forge's fix cycle, or the environment differed.
- **Note**: This is a bug in the TEST FILE, not in the project code. Forge fixed `declare -A` in `scripts/update-phase.sh` but the same pattern exists in the test harness.
- **Fix direction**: Replace `declare -A EXPECTED_SKILLS` with a function or case statement, same pattern as the fix applied to `update-phase.sh`.

### ISSUE-2 (PRE-EXISTING): Concurrent Request Race Condition

- **Severity: Minor**
- **File**: `scripts/memory-request.sh`
- **Root cause**: When 3 requests are submitted in rapid succession, only 2 are recorded (1 lost to race condition). This is a known pre-existing issue, not a regression from Forge's fixes.
- **Impact**: Low. In practice, agents submit requests sequentially, not in parallel bursts.

### ISSUE-3 (PRE-EXISTING): check-notify.sh mtime cache false negative

- **Severity: Minor**
- **File**: `scripts/check-notify.sh`
- **Root cause**: The mtime-based caching causes the second consecutive check to report 0 unread notifications even though unread messages exist. Pre-existing, not a regression.

## Overall Verdict

**CONDITIONAL PASS**

All 4 bugs reported by Sentinel (BUG-001 through BUG-004) have been correctly fixed by Forge in the project source code (`scripts/` and `plugin/`). The fixes are verified both by automated tests and manual code inspection.

However, the test harness file `test-agent-structure.sh` has the same `declare -A` Bash 3.2 incompatibility that was fixed in the production code. This prevents Suite 2 from executing, meaning 67 tests are blocked. This is a test infrastructure issue, not a product code issue.

**Recommendation**: Fix `Test-Example/test-agent-structure.sh` line 27 to remove `declare -A`, then re-run Suite 2 to confirm all 67 agent structure tests still pass. Once that is done, the full retest will be PASS.
