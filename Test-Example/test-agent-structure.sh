#!/bin/bash
################################################################################
# test-agent-structure.sh -- Validate agent directory structure
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
echo "  Agent Structure Validation Test"
echo "  Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "  Project: $PROJECT_ROOT"
echo "================================================================"
echo ""

AGENTS=("leader" "euler" "forge" "sentinel" "lens" "atlas" "chronicle")

# Expected skill counts per agent (POSIX-compatible, no declare -A)
get_expected_skills() {
    case "$1" in
        leader)    echo 4 ;;
        euler)     echo 6 ;;
        forge)     echo 6 ;;
        sentinel)  echo 5 ;;
        lens)      echo 4 ;;
        atlas)     echo 4 ;;
        chronicle) echo 3 ;;
        *)         echo 0 ;;
    esac
}

# ---- Test 1: Agent directories exist ----
echo "========================================"
echo "TEST 1: Agent directories exist"
echo "========================================"
for agent in "${AGENTS[@]}"; do
    if [ -d "$PROJECT_ROOT/$agent" ]; then
        pass "Directory exists: $agent/"
    else
        fail "Directory missing: $agent/" "Expected $PROJECT_ROOT/$agent"
    fi
done
echo ""

# ---- Test 2: Each agent has PERSONA.md ----
echo "========================================"
echo "TEST 2: PERSONA.md exists for each agent"
echo "========================================"
for agent in "${AGENTS[@]}"; do
    if [ -f "$PROJECT_ROOT/$agent/PERSONA.md" ]; then
        SIZE=$(wc -c < "$PROJECT_ROOT/$agent/PERSONA.md")
        if [ "$SIZE" -gt 0 ]; then
            pass "PERSONA.md exists and non-empty: $agent/ ($SIZE bytes)"
        else
            fail "PERSONA.md empty: $agent/" "File exists but is 0 bytes"
        fi
    else
        fail "PERSONA.md missing: $agent/" "Expected $PROJECT_ROOT/$agent/PERSONA.md"
    fi
done
echo ""

# ---- Test 3: Each agent has CLAUDE.md ----
echo "========================================"
echo "TEST 3: CLAUDE.md exists for each agent"
echo "========================================"
for agent in "${AGENTS[@]}"; do
    if [ -f "$PROJECT_ROOT/$agent/CLAUDE.md" ]; then
        SIZE=$(wc -c < "$PROJECT_ROOT/$agent/CLAUDE.md")
        if [ "$SIZE" -gt 0 ]; then
            pass "CLAUDE.md exists and non-empty: $agent/ ($SIZE bytes)"
        else
            fail "CLAUDE.md empty: $agent/" "File exists but is 0 bytes"
        fi
    else
        fail "CLAUDE.md missing: $agent/" "Expected $PROJECT_ROOT/$agent/CLAUDE.md"
    fi
done
echo ""

# ---- Test 4: Each agent has skills/ directory ----
echo "========================================"
echo "TEST 4: skills/ directory exists for each agent"
echo "========================================"
for agent in "${AGENTS[@]}"; do
    if [ -d "$PROJECT_ROOT/$agent/skills" ]; then
        pass "skills/ directory exists: $agent/"
    else
        fail "skills/ directory missing: $agent/" "Expected $PROJECT_ROOT/$agent/skills/"
    fi
done
echo ""

# ---- Test 5: Expected skill count per agent ----
echo "========================================"
echo "TEST 5: Skill file count per agent"
echo "========================================"
for agent in "${AGENTS[@]}"; do
    SKILLS_DIR="$PROJECT_ROOT/$agent/skills"
    if [ -d "$SKILLS_DIR" ]; then
        ACTUAL_COUNT=$(find "$SKILLS_DIR" -name "*.md" -type f | wc -l | tr -d ' ')
        EXPECTED=$(get_expected_skills "$agent")
        if [ "$ACTUAL_COUNT" -eq "$EXPECTED" ]; then
            pass "$agent: $ACTUAL_COUNT skills (expected $EXPECTED)"
        else
            fail "$agent skill count" "Expected $EXPECTED, got $ACTUAL_COUNT"
        fi
    else
        fail "$agent skills dir" "skills/ directory not found"
    fi
done
echo ""

# ---- Test 6: All skill files are non-empty ----
echo "========================================"
echo "TEST 6: All skill files non-empty"
echo "========================================"
EMPTY_SKILLS=0
for agent in "${AGENTS[@]}"; do
    SKILLS_DIR="$PROJECT_ROOT/$agent/skills"
    if [ -d "$SKILLS_DIR" ]; then
        for skill_file in "$SKILLS_DIR"/*.md; do
            if [ -f "$skill_file" ]; then
                SIZE=$(wc -c < "$skill_file")
                BASENAME=$(basename "$skill_file")
                if [ "$SIZE" -gt 0 ]; then
                    pass "$agent/skills/$BASENAME non-empty ($SIZE bytes)"
                else
                    fail "$agent/skills/$BASENAME" "File is empty (0 bytes)"
                    EMPTY_SKILLS=$((EMPTY_SKILLS + 1))
                fi
            fi
        done
    fi
done
echo ""

# ---- SUMMARY ----
TOTAL=$((PASS + FAIL + SKIP))
echo "================================================================"
echo "  SUMMARY: Agent Structure Validation"
echo "  Total: $TOTAL | Pass: $PASS | Fail: $FAIL | Skip: $SKIP"
if [ $TOTAL -gt 0 ]; then
    echo "  Pass Rate: $(( PASS * 100 / TOTAL ))%"
fi
echo "================================================================"

exit $FAIL
