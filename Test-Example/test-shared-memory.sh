#!/bin/bash
################################################################################
# test-shared-memory.sh -- Shared memory integrity test
# Tester: Sentinel | Date: 2026-03-17
################################################################################

set -u

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"
MEMORY_DIR="$PROJECT_ROOT/shared/memory"
BACKUP_DIR="$(dirname "$0")/backups_mem"
PASS=0
FAIL=0
SKIP=0

pass() { PASS=$((PASS + 1)); echo "  [PASS] $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  [FAIL] $1 -- $2"; }

echo "================================================================"
echo "  Shared Memory Integrity Test"
echo "  Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "  Project: $PROJECT_ROOT"
echo "================================================================"
echo ""

# ---- SETUP ----
echo "--- SETUP: Backing up data ---"
mkdir -p "$BACKUP_DIR"
cp "$MEMORY_DIR/shared-memory.json" "$BACKUP_DIR/shared-memory.json.bak" 2>/dev/null
cp "$MEMORY_DIR/approval-queue.json" "$BACKUP_DIR/approval-queue.json.bak" 2>/dev/null
cp "$MEMORY_DIR/status.json" "$BACKUP_DIR/status.json.bak" 2>/dev/null
echo "Done."
echo ""

# ---- Test 1: JSON validity ----
echo "========================================"
echo "TEST 1: JSON file validity"
echo "========================================"

JSON_FILES=("shared-memory.json" "approval-queue.json" "status.json")
for jf in "${JSON_FILES[@]}"; do
    FULL_PATH="$MEMORY_DIR/$jf"
    if [ -f "$FULL_PATH" ]; then
        if python3 -c "
import json
with open('$FULL_PATH') as f:
    data = json.load(f)
print(f'  Valid JSON: {len(str(data))} chars')
" 2>/dev/null; then
            pass "$jf is valid JSON"
        else
            fail "$jf JSON validation" "Parse error"
        fi
    else
        fail "$jf existence" "File not found: $FULL_PATH"
    fi
done
echo ""

# ---- Test 2: shared-memory.json structure ----
echo "========================================"
echo "TEST 2: shared-memory.json structure"
echo "========================================"

python3 -c "
import json, sys
with open('$MEMORY_DIR/shared-memory.json') as f:
    data = json.load(f)

errors = []
if 'meta' not in data:
    errors.append('Missing top-level key: meta')
if 'entries' not in data:
    errors.append('Missing top-level key: entries')
if 'meta' in data:
    for key in ['version', 'description', 'last_updated', 'updated_by']:
        if key not in data['meta']:
            errors.append(f'Missing meta key: {key}')
if errors:
    for e in errors:
        print(f'  ERROR: {e}')
    sys.exit(1)
else:
    print('  Structure OK: meta{version,description,last_updated,updated_by}, entries{}')
    sys.exit(0)
" 2>&1
if [ $? -eq 0 ]; then
    pass "shared-memory.json has correct structure"
else
    fail "shared-memory.json structure" "Missing required keys"
fi

# ---- Test 3: approval-queue.json structure ----
echo ""
echo "========================================"
echo "TEST 3: approval-queue.json structure"
echo "========================================"

python3 -c "
import json, sys
with open('$MEMORY_DIR/approval-queue.json') as f:
    data = json.load(f)

errors = []
if 'meta' not in data:
    errors.append('Missing top-level key: meta')
if 'requests' not in data:
    errors.append('Missing top-level key: requests')
elif not isinstance(data['requests'], list):
    errors.append('requests should be a list')
if errors:
    for e in errors:
        print(f'  ERROR: {e}')
    sys.exit(1)
else:
    print(f'  Structure OK: meta, requests[] ({len(data[\"requests\"])} items)')
    sys.exit(0)
" 2>&1
if [ $? -eq 0 ]; then
    pass "approval-queue.json has correct structure"
else
    fail "approval-queue.json structure" "Missing required keys"
fi

# ---- Test 4: status.json structure ----
echo ""
echo "========================================"
echo "TEST 4: status.json structure"
echo "========================================"

python3 -c "
import json, sys
with open('$MEMORY_DIR/status.json') as f:
    data = json.load(f)

errors = []
if 'meta' not in data:
    errors.append('Missing top-level key: meta')
if 'team_status' not in data:
    errors.append('Missing top-level key: team_status')
if 'members' not in data:
    errors.append('Missing top-level key: members')
else:
    expected_members = ['marshall','euler','forge','sentinel','lens','atlas','chronicle']
    for m in expected_members:
        if m not in data['members']:
            errors.append(f'Missing member: {m}')
        else:
            for field in ['status','current_work','blockers','last_active']:
                if field not in data['members'][m]:
                    errors.append(f'{m} missing field: {field}')
if errors:
    for e in errors:
        print(f'  ERROR: {e}')
    sys.exit(1)
else:
    print(f'  Structure OK: meta, team_status, members(7)')
    sys.exit(0)
" 2>&1
if [ $? -eq 0 ]; then
    pass "status.json has correct structure with all 7 members"
else
    fail "status.json structure" "See errors above"
fi
echo ""

# ---- Test 5: Orphaned notifications check ----
echo "========================================"
echo "TEST 5: Orphaned notifications check"
echo "========================================"

NOTIFY_DIR="$PROJECT_ROOT/shared/notifications"
VALID_AGENTS="marshall euler forge sentinel lens atlas chronicle"
if [ -d "$NOTIFY_DIR" ]; then
    ORPHANED=0
    for nf in "$NOTIFY_DIR"/*.json; do
        [ -f "$nf" ] || continue
        BASENAME=$(basename "$nf" .json)
        if echo "$VALID_AGENTS" | grep -qw "$BASENAME"; then
            pass "Notification file $BASENAME.json belongs to valid agent"
        else
            fail "Orphaned notification: $BASENAME.json" "Not a known agent"
            ORPHANED=$((ORPHANED + 1))
        fi
    done
    if [ $ORPHANED -eq 0 ]; then
        echo "  No orphaned notifications found."
    fi
else
    pass "No notifications directory (clean state)"
fi
echo ""

# ---- Test 6: Concurrent access safety ----
echo "========================================"
echo "TEST 6: Concurrent request submission"
echo "========================================"

# Reset queue for clean test
cat > "$MEMORY_DIR/approval-queue.json" <<'JSONEOF'
{
  "meta": {
    "description": "CONCURRENT TEST STATE"
  },
  "requests": []
}
JSONEOF

# Also reset shared-memory for this test
cat > "$MEMORY_DIR/shared-memory.json" <<'JSONEOF'
{
  "meta": {
    "version": "1.0.0",
    "description": "CONCURRENT TEST STATE",
    "last_updated": "",
    "updated_by": ""
  },
  "entries": {}
}
JSONEOF

echo "Submitting 3 requests in quick succession..."
bash "$SCRIPTS_DIR/memory-request.sh" write "TEST_concurrent_1" "value_1" "concurrent test 1" > /dev/null 2>&1 &
PID1=$!
bash "$SCRIPTS_DIR/memory-request.sh" write "TEST_concurrent_2" "value_2" "concurrent test 2" > /dev/null 2>&1 &
PID2=$!
bash "$SCRIPTS_DIR/memory-request.sh" write "TEST_concurrent_3" "value_3" "concurrent test 3" > /dev/null 2>&1 &
PID3=$!

wait $PID1 $PID2 $PID3

# Check how many requests ended up in the queue
RESULT=$(python3 -c "
import json
with open('$MEMORY_DIR/approval-queue.json') as f:
    data = json.load(f)
reqs = data['requests']
test_reqs = [r for r in reqs if r['key'].startswith('TEST_concurrent_')]
print(len(test_reqs))
for r in test_reqs:
    print(f'  {r[\"id\"]}: {r[\"key\"]}')
" 2>&1)

COUNT=$(echo "$RESULT" | head -1)
echo "$RESULT"

if [ "$COUNT" -eq 3 ]; then
    pass "All 3 concurrent requests recorded (no data loss)"
else
    fail "Concurrent access" "Expected 3 requests, got $COUNT (possible race condition)"
fi

# Check queue is still valid JSON after concurrent writes
if python3 -c "import json; json.load(open('$MEMORY_DIR/approval-queue.json'))" 2>/dev/null; then
    pass "approval-queue.json still valid JSON after concurrent writes"
else
    fail "JSON integrity after concurrent writes" "File corrupted"
fi
echo ""

# ---- TEARDOWN ----
echo "--- TEARDOWN: Restoring backups ---"
cp "$BACKUP_DIR/shared-memory.json.bak" "$MEMORY_DIR/shared-memory.json" 2>/dev/null
cp "$BACKUP_DIR/approval-queue.json.bak" "$MEMORY_DIR/approval-queue.json" 2>/dev/null
cp "$BACKUP_DIR/status.json.bak" "$MEMORY_DIR/status.json" 2>/dev/null
rm -rf "$BACKUP_DIR"
echo "Done."
echo ""

# ---- SUMMARY ----
TOTAL=$((PASS + FAIL + SKIP))
echo "================================================================"
echo "  SUMMARY: Shared Memory Integrity Test"
echo "  Total: $TOTAL | Pass: $PASS | Fail: $FAIL | Skip: $SKIP"
if [ $TOTAL -gt 0 ]; then
    echo "  Pass Rate: $(( PASS * 100 / TOTAL ))%"
fi
echo "================================================================"

exit $FAIL
