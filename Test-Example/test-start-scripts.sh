#!/bin/bash
################################################################################
# test-start-scripts.sh -- Validate start scripts and panel.sh
# Tester: Sentinel | Date: 2026-03-17
################################################################################

set -u

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0
SKIP=0

pass() { PASS=$((PASS + 1)); echo "  [PASS] $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  [FAIL] $1 -- $2"; }

echo "================================================================"
echo "  Start Scripts Validation Test"
echo "  Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "  Project: $PROJECT_ROOT"
echo "================================================================"
echo ""

AGENTS=("leader" "euler" "forge" "sentinel" "lens" "atlas" "chronicle")

# ---- Test 1: All start scripts exist ----
echo "========================================"
echo "TEST 1: Start scripts existence"
echo "========================================"
for agent in "${AGENTS[@]}"; do
    SCRIPT="$PROJECT_ROOT/start-${agent}.sh"
    if [ -f "$SCRIPT" ]; then
        pass "start-${agent}.sh exists"
    else
        fail "start-${agent}.sh missing" "Expected $SCRIPT"
    fi
done
echo ""

# ---- Test 2: Start scripts are executable or have shebang ----
echo "========================================"
echo "TEST 2: Start scripts executable/shebang"
echo "========================================"
for agent in "${AGENTS[@]}"; do
    SCRIPT="$PROJECT_ROOT/start-${agent}.sh"
    if [ -f "$SCRIPT" ]; then
        HAS_SHEBANG=false
        IS_EXEC=false
        if head -1 "$SCRIPT" | grep -q "#!/bin/bash\|#!/usr/bin/env bash"; then
            HAS_SHEBANG=true
        fi
        if [ -x "$SCRIPT" ]; then
            IS_EXEC=true
        fi
        if $HAS_SHEBANG || $IS_EXEC; then
            pass "start-${agent}.sh: shebang=$HAS_SHEBANG executable=$IS_EXEC"
        else
            fail "start-${agent}.sh" "No shebang and not executable"
        fi
    fi
done
echo ""

# ---- Test 3: Each start script references correct agent directory ----
echo "========================================"
echo "TEST 3: Start scripts reference correct agent dir"
echo "========================================"
for agent in "${AGENTS[@]}"; do
    SCRIPT="$PROJECT_ROOT/start-${agent}.sh"
    if [ -f "$SCRIPT" ]; then
        CONTENT=$(cat "$SCRIPT")
        if echo "$CONTENT" | grep -q "$agent"; then
            pass "start-${agent}.sh references $agent"
        else
            fail "start-${agent}.sh" "Does not reference '$agent' in content"
        fi
    fi
done
echo ""

# ---- Test 4: Start scripts contain claude command ----
echo "========================================"
echo "TEST 4: Start scripts contain claude invocation"
echo "========================================"
for agent in "${AGENTS[@]}"; do
    SCRIPT="$PROJECT_ROOT/start-${agent}.sh"
    if [ -f "$SCRIPT" ]; then
        if grep -q "claude" "$SCRIPT"; then
            pass "start-${agent}.sh invokes claude"
        else
            fail "start-${agent}.sh" "No 'claude' command found"
        fi
    fi
done
echo ""

# ---- Test 5: panel.sh exists and is executable ----
echo "========================================"
echo "TEST 5: panel.sh validation"
echo "========================================"
PANEL="$PROJECT_ROOT/panel.sh"
if [ -f "$PANEL" ]; then
    pass "panel.sh exists"

    if [ -x "$PANEL" ] || head -1 "$PANEL" | grep -q "#!/bin/bash\|#!/usr/bin/env bash"; then
        pass "panel.sh is executable or has shebang"
    else
        fail "panel.sh" "Not executable and no shebang"
    fi

    # Check it references tmux (expected for multi-panel)
    if grep -q "tmux" "$PANEL"; then
        pass "panel.sh references tmux (multi-agent panel)"
    else
        fail "panel.sh" "No tmux reference found"
    fi

    # Check it references all agents or start scripts
    AGENTS_REFERENCED=0
    for agent in "${AGENTS[@]}"; do
        if grep -q "$agent" "$PANEL"; then
            AGENTS_REFERENCED=$((AGENTS_REFERENCED + 1))
        fi
    done
    if [ "$AGENTS_REFERENCED" -ge 5 ]; then
        pass "panel.sh references $AGENTS_REFERENCED/7 agents"
    else
        fail "panel.sh agent coverage" "Only $AGENTS_REFERENCED/7 agents referenced"
    fi
else
    fail "panel.sh missing" "Expected $PANEL"
fi
echo ""

# ---- Test 6: Start scripts model parameter handling ----
echo "========================================"
echo "TEST 6: Model parameter support"
echo "========================================"
for agent in "${AGENTS[@]}"; do
    SCRIPT="$PROJECT_ROOT/start-${agent}.sh"
    if [ -f "$SCRIPT" ]; then
        if grep -q "opus\|haiku\|MODEL" "$SCRIPT"; then
            pass "start-${agent}.sh supports model selection"
        else
            fail "start-${agent}.sh" "No model selection support found"
        fi
    fi
done
echo ""

# ---- SUMMARY ----
TOTAL=$((PASS + FAIL + SKIP))
echo "================================================================"
echo "  SUMMARY: Start Scripts Validation"
echo "  Total: $TOTAL | Pass: $PASS | Fail: $FAIL | Skip: $SKIP"
if [ $TOTAL -gt 0 ]; then
    echo "  Pass Rate: $(( PASS * 100 / TOTAL ))%"
fi
echo "================================================================"

exit $FAIL
