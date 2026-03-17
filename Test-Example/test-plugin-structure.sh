#!/bin/bash
################################################################################
# test-plugin-structure.sh -- Validate plugin directory structure
# Tester: Sentinel | Date: 2026-03-17
################################################################################

set -u

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_DIR="$PROJECT_ROOT/plugin/agent-teams-coder"
PASS=0
FAIL=0
SKIP=0

pass() { PASS=$((PASS + 1)); echo "  [PASS] $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  [FAIL] $1 -- $2"; }

echo "================================================================"
echo "  Plugin Structure Validation Test"
echo "  Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "  Project: $PROJECT_ROOT"
echo "================================================================"
echo ""

# ---- Test 1: Plugin root directory exists ----
echo "========================================"
echo "TEST 1: Plugin directory structure"
echo "========================================"

EXPECTED_DIRS=("agents" "skills" "hooks" "commands" "scripts")
for dir in "${EXPECTED_DIRS[@]}"; do
    if [ -d "$PLUGIN_DIR/$dir" ]; then
        pass "Plugin subdirectory exists: $dir/"
    else
        fail "Plugin subdirectory missing: $dir/" "Expected $PLUGIN_DIR/$dir"
    fi
done
echo ""

# ---- Test 2: Agent definition files ----
echo "========================================"
echo "TEST 2: Agent definition files in plugin"
echo "========================================"

EXPECTED_AGENTS=("euler" "forge" "sentinel" "lens" "atlas" "chronicle")
for agent in "${EXPECTED_AGENTS[@]}"; do
    AGENT_FILE="$PLUGIN_DIR/agents/${agent}.md"
    if [ -f "$AGENT_FILE" ]; then
        SIZE=$(wc -c < "$AGENT_FILE")
        if [ "$SIZE" -gt 0 ]; then
            pass "Agent definition: ${agent}.md ($SIZE bytes)"
        else
            fail "Agent definition empty: ${agent}.md" "0 bytes"
        fi
    else
        fail "Agent definition missing: ${agent}.md" "Expected $AGENT_FILE"
    fi
done

# Check for marshall/leader agent definition
LEADER_FILE="$PLUGIN_DIR/agents/marshall.md"
LEADER_FILE2="$PLUGIN_DIR/agents/leader.md"
if [ -f "$LEADER_FILE" ] || [ -f "$LEADER_FILE2" ]; then
    pass "Leader agent definition exists"
else
    fail "Leader agent definition" "Neither marshall.md nor leader.md found in plugin/agents/"
fi
echo ""

# ---- Test 3: plugin.json exists and is valid JSON ----
echo "========================================"
echo "TEST 3: plugin.json validation"
echo "========================================"

PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"
if [ -f "$PLUGIN_JSON" ]; then
    pass "plugin.json exists at $PLUGIN_JSON"

    if python3 -c "
import json
with open('$PLUGIN_JSON') as f:
    data = json.load(f)
print(f'  Keys: {list(data.keys())}')
" 2>/dev/null; then
        pass "plugin.json is valid JSON"
    else
        fail "plugin.json invalid" "JSON parse error"
    fi
else
    # Check alternate locations
    ALT_JSON="$PLUGIN_DIR/plugin.json"
    if [ -f "$ALT_JSON" ]; then
        pass "plugin.json found at alternate location"
        if python3 -c "import json; json.load(open('$ALT_JSON'))" 2>/dev/null; then
            pass "plugin.json is valid JSON"
        else
            fail "plugin.json invalid" "JSON parse error"
        fi
    else
        fail "plugin.json missing" "Not found in expected locations"
    fi
fi
echo ""

# ---- Test 4: Skill files in plugin ----
echo "========================================"
echo "TEST 4: Plugin skill files"
echo "========================================"

SKILLS_DIR="$PLUGIN_DIR/skills"
if [ -d "$SKILLS_DIR" ]; then
    SKILL_COUNT=0
    EMPTY_COUNT=0
    while IFS= read -r -d '' skill_file; do
        SKILL_COUNT=$((SKILL_COUNT + 1))
        SIZE=$(wc -c < "$skill_file")
        RELPATH="${skill_file#$SKILLS_DIR/}"
        if [ "$SIZE" -gt 0 ]; then
            pass "Skill file: $RELPATH ($SIZE bytes)"
        else
            EMPTY_COUNT=$((EMPTY_COUNT + 1))
            fail "Skill file empty: $RELPATH" "0 bytes"
        fi
    done < <(find "$SKILLS_DIR" -name "*.md" -type f -print0)

    if [ "$SKILL_COUNT" -gt 0 ]; then
        echo "  Total skill files: $SKILL_COUNT"
    else
        fail "No skill files found" "Expected .md files in $SKILLS_DIR"
    fi
else
    fail "Plugin skills directory" "Not found: $SKILLS_DIR"
fi
echo ""

# ---- Test 5: Scripts and commands ----
echo "========================================"
echo "TEST 5: Plugin scripts and commands"
echo "========================================"

LAUNCH_SCRIPT="$PLUGIN_DIR/scripts/launch-team.sh"
if [ -f "$LAUNCH_SCRIPT" ]; then
    pass "launch-team.sh exists"
    if [ -x "$LAUNCH_SCRIPT" ] || head -1 "$LAUNCH_SCRIPT" | grep -q "#!/bin/bash\|#!/usr/bin/env bash"; then
        pass "launch-team.sh is executable or has shebang"
    else
        fail "launch-team.sh" "Not executable and no shebang"
    fi
else
    fail "launch-team.sh missing" "Expected $LAUNCH_SCRIPT"
fi

CMD_FILE="$PLUGIN_DIR/commands/agent-team.md"
if [ -f "$CMD_FILE" ]; then
    SIZE=$(wc -c < "$CMD_FILE")
    pass "Command file: agent-team.md ($SIZE bytes)"
else
    fail "Command file missing" "Expected $CMD_FILE"
fi

HOOKS_DIR="$PLUGIN_DIR/hooks"
if [ -d "$HOOKS_DIR" ]; then
    HOOK_COUNT=$(find "$HOOKS_DIR" -type f | wc -l | tr -d ' ')
    if [ "$HOOK_COUNT" -gt 0 ]; then
        pass "Hooks directory has $HOOK_COUNT file(s)"
    else
        pass "Hooks directory exists (empty - may be intentional)"
    fi
fi
echo ""

# ---- SUMMARY ----
TOTAL=$((PASS + FAIL + SKIP))
echo "================================================================"
echo "  SUMMARY: Plugin Structure Validation"
echo "  Total: $TOTAL | Pass: $PASS | Fail: $FAIL | Skip: $SKIP"
if [ $TOTAL -gt 0 ]; then
    echo "  Pass Rate: $(( PASS * 100 / TOTAL ))%"
fi
echo "================================================================"

exit $FAIL
