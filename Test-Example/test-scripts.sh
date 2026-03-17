#!/bin/bash
################################################################################
# test-scripts.sh -- Comprehensive functional test for all 8 shell scripts
# Tester: Sentinel | Date: 2026-03-17
################################################################################

set -u

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"
SHARED_DIR="$PROJECT_ROOT/shared"
MEMORY_DIR="$SHARED_DIR/memory"
NOTIFY_DIR="$SHARED_DIR/notifications"
BACKUP_DIR="$(dirname "$0")/backups"

PASS=0
FAIL=0
SKIP=0

pass() { PASS=$((PASS + 1)); echo "  [PASS] $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  [FAIL] $1 -- $2"; }
skip() { SKIP=$((SKIP + 1)); echo "  [SKIP] $1"; }

echo "================================================================"
echo "  Shell Scripts Functional Test Suite"
echo "  Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "  Project: $PROJECT_ROOT"
echo "================================================================"
echo ""

# ---- SETUP: Backup existing data ----
echo "--- SETUP: Backing up shared data ---"
mkdir -p "$BACKUP_DIR"
cp "$MEMORY_DIR/shared-memory.json" "$BACKUP_DIR/shared-memory.json.bak" 2>/dev/null
cp "$MEMORY_DIR/approval-queue.json" "$BACKUP_DIR/approval-queue.json.bak" 2>/dev/null
cp "$MEMORY_DIR/status.json" "$BACKUP_DIR/status.json.bak" 2>/dev/null
# Backup notification files if they exist
if [ -d "$NOTIFY_DIR" ]; then
    cp -r "$NOTIFY_DIR" "$BACKUP_DIR/notifications_bak" 2>/dev/null
fi
echo "Backups saved to $BACKUP_DIR"
echo ""

# Reset shared-memory.json to clean state for testing
cat > "$MEMORY_DIR/shared-memory.json" <<'JSONEOF'
{
  "meta": {
    "version": "1.0.0",
    "description": "TEST STATE",
    "last_updated": "",
    "updated_by": ""
  },
  "entries": {}
}
JSONEOF

# Reset approval-queue.json to clean state
cat > "$MEMORY_DIR/approval-queue.json" <<'JSONEOF'
{
  "meta": {
    "description": "TEST STATE"
  },
  "requests": []
}
JSONEOF

# ========================================================================
# TEST 1: notify.sh
# ========================================================================
echo "========================================"
echo "TEST 1: notify.sh"
echo "========================================"

# 1a: Send from marshall to euler
echo "[1a] Send notification: marshall -> euler"
OUTPUT=$(bash "$SCRIPTS_DIR/notify.sh" marshall euler "TEST_subject_1" "TEST_content_hello" 2>&1)
if echo "$OUTPUT" | grep -q "euler"; then
    pass "notify.sh marshall->euler sent successfully"
else
    fail "notify.sh marshall->euler" "Unexpected output: $OUTPUT"
fi

# 1b: Verify notification file created
if [ -f "$NOTIFY_DIR/euler.json" ]; then
    if python3 -c "
import json
with open('$NOTIFY_DIR/euler.json') as f:
    data = json.load(f)
notifs = data['notifications']
found = any(n['subject'] == 'TEST_subject_1' and n['from'] == 'marshall' for n in notifs)
exit(0 if found else 1)
"; then
        pass "Notification file contains correct data for euler"
    else
        fail "Notification content check" "TEST_subject_1 not found in euler.json"
    fi
else
    fail "Notification file creation" "euler.json not found in $NOTIFY_DIR"
fi

# 1c: Send from forge to all
echo "[1c] Send notification: forge -> all"
OUTPUT=$(bash "$SCRIPTS_DIR/notify.sh" forge all "TEST_broadcast" "TEST_broadcast_content" 2>&1)
# forge->all should notify everyone except forge
BROADCAST_OK=true
for agent in marshall euler sentinel lens atlas chronicle; do
    if [ -f "$NOTIFY_DIR/${agent}.json" ]; then
        if ! python3 -c "
import json
with open('$NOTIFY_DIR/${agent}.json') as f:
    data = json.load(f)
found = any(n['subject'] == 'TEST_broadcast' for n in data['notifications'])
exit(0 if found else 1)
"; then
            BROADCAST_OK=false
            fail "notify.sh forge->all ($agent)" "Broadcast not received by $agent"
        fi
    else
        BROADCAST_OK=false
        fail "notify.sh forge->all ($agent)" "File ${agent}.json not created"
    fi
done
if $BROADCAST_OK; then
    pass "notify.sh forge->all: all 6 agents received broadcast"
fi

# 1d: forge should NOT have the broadcast (self-skip)
if [ -f "$NOTIFY_DIR/forge.json" ]; then
    if python3 -c "
import json
with open('$NOTIFY_DIR/forge.json') as f:
    data = json.load(f)
found = any(n['subject'] == 'TEST_broadcast' for n in data['notifications'])
exit(0 if not found else 1)
"; then
        pass "notify.sh self-skip: forge did not receive own broadcast"
    else
        fail "notify.sh self-skip" "forge received its own broadcast"
    fi
else
    pass "notify.sh self-skip: forge.json not created (correct)"
fi

# 1e: Missing arguments
echo "[1e] Test missing arguments"
OUTPUT=$(bash "$SCRIPTS_DIR/notify.sh" 2>&1) || true
if [ $? -ne 0 ] || echo "$OUTPUT" | grep -qi "用法\|usage\|error\|缺少"; then
    pass "notify.sh missing args returns error"
else
    fail "notify.sh missing args" "Did not error on missing args"
fi

echo ""

# ========================================================================
# TEST 2: check-notify.sh
# ========================================================================
echo "========================================"
echo "TEST 2: check-notify.sh"
echo "========================================"

# 2a: Check notifications for euler (should have unread)
echo "[2a] Check notifications for euler"
# Remove cache to force fresh check
rm -rf "$NOTIFY_DIR/.cache" 2>/dev/null
OUTPUT=$(bash "$SCRIPTS_DIR/check-notify.sh" euler 2>&1)
EXIT_CODE=$?
if echo "$OUTPUT" | grep -q "TEST_subject_1\|TEST_broadcast\|未读"; then
    pass "check-notify.sh euler: found unread notifications"
else
    fail "check-notify.sh euler" "Output: $OUTPUT"
fi

# 2b: Check for non-existent agent
echo "[2b] Check notifications for non-existent agent"
OUTPUT=$(bash "$SCRIPTS_DIR/check-notify.sh" nonexistent_agent_xyz 2>&1)
if echo "$OUTPUT" | grep -q "无通知"; then
    pass "check-notify.sh nonexistent agent: reports no notifications"
else
    fail "check-notify.sh nonexistent agent" "Output: $OUTPUT"
fi

# 2c: Second check for euler should show no NEW notifications (mtime cache)
echo "[2c] Second check for euler (mtime cache)"
OUTPUT=$(bash "$SCRIPTS_DIR/check-notify.sh" euler 2>&1)
if echo "$OUTPUT" | grep -q "无新通知\|无变化"; then
    pass "check-notify.sh mtime cache: no new notifications on recheck"
else
    fail "check-notify.sh mtime cache" "Output: $OUTPUT"
fi

echo ""

# ========================================================================
# TEST 3: memory-request.sh
# ========================================================================
echo "========================================"
echo "TEST 3: memory-request.sh"
echo "========================================"

# 3a: Submit a test request
echo "[3a] Submit memory change request"
OUTPUT=$(bash "$SCRIPTS_DIR/memory-request.sh" write "TEST_key_1" "TEST_value_1" "testing memory request" 2>&1)
if echo "$OUTPUT" | grep -q "pending\|已提交"; then
    pass "memory-request.sh submitted successfully"
else
    fail "memory-request.sh submission" "Output: $OUTPUT"
fi

# Extract request ID
REQ_ID_1=$(echo "$OUTPUT" | grep -o 'req_[0-9_]*' | head -1)
echo "  Request ID: $REQ_ID_1"

# 3b: Verify request in approval-queue.json
if python3 -c "
import json
with open('$MEMORY_DIR/approval-queue.json') as f:
    data = json.load(f)
found = any(r['key'] == 'TEST_key_1' and r['status'] == 'pending' for r in data['requests'])
exit(0 if found else 1)
"; then
    pass "Request appears in approval-queue.json with status pending"
else
    fail "Request in queue" "TEST_key_1 not found as pending in approval-queue.json"
fi

# 3c: Invalid action
echo "[3c] Test invalid action"
OUTPUT=$(bash "$SCRIPTS_DIR/memory-request.sh" invalid_action "key" "val" "reason" 2>&1) || true
if echo "$OUTPUT" | grep -qi "无效\|invalid\|error"; then
    pass "memory-request.sh rejects invalid action"
else
    fail "memory-request.sh invalid action" "Output: $OUTPUT"
fi

echo ""

# ========================================================================
# TEST 4: memory-approve.sh
# ========================================================================
echo "========================================"
echo "TEST 4: memory-approve.sh"
echo "========================================"

# 4a: Approve the test request
echo "[4a] Approve request $REQ_ID_1"
OUTPUT=$(bash "$SCRIPTS_DIR/memory-approve.sh" "$REQ_ID_1" "Approved by Sentinel test" 2>&1)
if echo "$OUTPUT" | grep -q "已批准\|approved"; then
    pass "memory-approve.sh approved successfully"
else
    fail "memory-approve.sh approval" "Output: $OUTPUT"
fi

# 4b: Verify written to shared-memory.json
if python3 -c "
import json
with open('$MEMORY_DIR/shared-memory.json') as f:
    data = json.load(f)
entry = data['entries'].get('TEST_key_1')
exit(0 if entry and entry['content'] == 'TEST_value_1' else 1)
"; then
    pass "Approved entry written to shared-memory.json"
else
    fail "Entry in shared-memory.json" "TEST_key_1 not found in shared-memory.json"
fi

# 4c: Verify approval-queue.json status changed
if python3 -c "
import json
with open('$MEMORY_DIR/approval-queue.json') as f:
    data = json.load(f)
found = any(r['id'] == '$REQ_ID_1' and r['status'] == 'approved' for r in data['requests'])
exit(0 if found else 1)
"; then
    pass "Queue status changed to approved"
else
    fail "Queue status update" "$REQ_ID_1 not marked as approved"
fi

# 4d: Approve non-existent request
echo "[4d] Approve non-existent request"
OUTPUT=$(bash "$SCRIPTS_DIR/memory-approve.sh" "req_nonexistent_999" 2>&1) || true
if echo "$OUTPUT" | grep -qi "找不到\|not found\|error"; then
    pass "memory-approve.sh rejects non-existent request"
else
    fail "memory-approve.sh non-existent" "Output: $OUTPUT"
fi

# 4e: Approve already-approved request
echo "[4e] Approve already-approved request"
OUTPUT=$(bash "$SCRIPTS_DIR/memory-approve.sh" "$REQ_ID_1" 2>&1) || true
if echo "$OUTPUT" | grep -qi "不是 pending\|not pending\|already\|approved"; then
    pass "memory-approve.sh rejects re-approval"
else
    fail "memory-approve.sh re-approval" "Output: $OUTPUT"
fi

echo ""

# ========================================================================
# TEST 5: memory-reject.sh
# ========================================================================
echo "========================================"
echo "TEST 5: memory-reject.sh"
echo "========================================"

# 5a: Submit another request to reject
echo "[5a] Submit request for rejection test"
OUTPUT=$(bash "$SCRIPTS_DIR/memory-request.sh" write "TEST_key_reject" "TEST_reject_value" "will be rejected" 2>&1)
REQ_ID_2=$(echo "$OUTPUT" | grep -o 'req_[0-9_]*' | head -1)
echo "  Request ID: $REQ_ID_2"

# 5b: Reject it
echo "[5b] Reject request $REQ_ID_2"
OUTPUT=$(bash "$SCRIPTS_DIR/memory-reject.sh" "$REQ_ID_2" "Rejected by Sentinel test" 2>&1)
if echo "$OUTPUT" | grep -q "已拒绝\|rejected"; then
    pass "memory-reject.sh rejected successfully"
else
    fail "memory-reject.sh rejection" "Output: $OUTPUT"
fi

# 5c: Verify status is rejected in queue
if python3 -c "
import json
with open('$MEMORY_DIR/approval-queue.json') as f:
    data = json.load(f)
found = any(r['id'] == '$REQ_ID_2' and r['status'] == 'rejected' for r in data['requests'])
exit(0 if found else 1)
"; then
    pass "Queue status changed to rejected"
else
    fail "Queue rejection status" "$REQ_ID_2 not marked as rejected"
fi

# 5d: Verify rejected key NOT in shared-memory.json
if python3 -c "
import json
with open('$MEMORY_DIR/shared-memory.json') as f:
    data = json.load(f)
exit(0 if 'TEST_key_reject' not in data['entries'] else 1)
"; then
    pass "Rejected key NOT written to shared-memory.json"
else
    fail "Rejected key leak" "TEST_key_reject was written despite rejection"
fi

echo ""

# ========================================================================
# TEST 6: memory-write.sh (Leader direct write)
# ========================================================================
echo "========================================"
echo "TEST 6: memory-write.sh"
echo "========================================"

# 6a: Direct write
echo "[6a] Leader direct write"
OUTPUT=$(bash "$SCRIPTS_DIR/memory-write.sh" "TEST_leader_key" "TEST_leader_value" 2>&1)
if echo "$OUTPUT" | grep -q "已更新\|updated"; then
    pass "memory-write.sh direct write successful"
else
    fail "memory-write.sh direct write" "Output: $OUTPUT"
fi

# 6b: Verify in shared-memory.json
if python3 -c "
import json
with open('$MEMORY_DIR/shared-memory.json') as f:
    data = json.load(f)
entry = data['entries'].get('TEST_leader_key')
exit(0 if entry and entry['content'] == 'TEST_leader_value' and entry['author'] == 'leader' else 1)
"; then
    pass "Direct write entry in shared-memory.json with author=leader"
else
    fail "Direct write verification" "TEST_leader_key not correctly in shared-memory.json"
fi

# 6c: Missing arguments
echo "[6c] Test missing arguments"
OUTPUT=$(bash "$SCRIPTS_DIR/memory-write.sh" 2>&1) || true
if [ $? -ne 0 ] || echo "$OUTPUT" | grep -qi "用法\|usage\|缺少"; then
    pass "memory-write.sh missing args returns error"
else
    fail "memory-write.sh missing args" "Did not error"
fi

echo ""

# ========================================================================
# TEST 7: update-status.sh
# ========================================================================
echo "========================================"
echo "TEST 7: update-status.sh"
echo "========================================"

# 7a: Update marshall to working
echo "[7a] Update marshall status to working"
OUTPUT=$(bash "$SCRIPTS_DIR/update-status.sh" marshall working "TEST_task_in_progress" "" 2>&1)
if echo "$OUTPUT" | grep -q "已更新\|updated\|working"; then
    pass "update-status.sh marshall->working"
else
    fail "update-status.sh marshall working" "Output: $OUTPUT"
fi

# 7b: Verify in status.json
if python3 -c "
import json
with open('$MEMORY_DIR/status.json') as f:
    data = json.load(f)
m = data['members']['marshall']
exit(0 if m['status'] == 'working' and 'TEST_task_in_progress' in m['current_work'] else 1)
"; then
    pass "status.json updated correctly for marshall"
else
    fail "status.json marshall update" "marshall not set to working"
fi

# 7c: Invalid status value
echo "[7c] Test invalid status"
OUTPUT=$(bash "$SCRIPTS_DIR/update-status.sh" marshall invalid_status 2>&1) || true
if echo "$OUTPUT" | grep -qi "无效\|invalid\|error"; then
    pass "update-status.sh rejects invalid status"
else
    fail "update-status.sh invalid status" "Output: $OUTPUT"
fi

# 7d: Unknown agent
echo "[7d] Test unknown agent"
OUTPUT=$(bash "$SCRIPTS_DIR/update-status.sh" unknown_agent_xyz idle 2>&1) || true
if [ $? -ne 0 ] || echo "$OUTPUT" | grep -qi "未知\|unknown\|error"; then
    pass "update-status.sh rejects unknown agent"
else
    fail "update-status.sh unknown agent" "Output: $OUTPUT"
fi

echo ""

# ========================================================================
# TEST 8: update-phase.sh
# ========================================================================
echo "========================================"
echo "TEST 8: update-phase.sh"
echo "========================================"

# 8a: Update to phase 1
echo "[8a] Update to phase 1 Testing"
OUTPUT=$(bash "$SCRIPTS_DIR/update-phase.sh" 1 "TEST_Testing_Phase" 2>&1)
if echo "$OUTPUT" | grep -q "已更新\|updated"; then
    pass "update-phase.sh phase 1 update"
else
    fail "update-phase.sh phase 1" "Output: $OUTPUT"
fi

# 8b: Verify in status.json
if python3 -c "
import json
with open('$MEMORY_DIR/status.json') as f:
    data = json.load(f)
ts = data['team_status']
exit(0 if ts['phase'] == '1' and 'TEST_Testing_Phase' in ts['current_task'] else 1)
"; then
    pass "status.json phase field updated correctly"
else
    fail "status.json phase update" "Phase not set to 1 / task not set"
fi

# 8c: Update to phase 4
echo "[8c] Update to phase 4"
OUTPUT=$(bash "$SCRIPTS_DIR/update-phase.sh" 4 "TEST_Code_Testing" 2>&1)
if echo "$OUTPUT" | grep -q "代码测试\|已更新"; then
    pass "update-phase.sh phase 4 with correct description"
else
    fail "update-phase.sh phase 4" "Output: $OUTPUT"
fi

echo ""

# ---- TEARDOWN: Restore backups ----
echo "--- TEARDOWN: Restoring backups ---"
cp "$BACKUP_DIR/shared-memory.json.bak" "$MEMORY_DIR/shared-memory.json" 2>/dev/null
cp "$BACKUP_DIR/approval-queue.json.bak" "$MEMORY_DIR/approval-queue.json" 2>/dev/null
cp "$BACKUP_DIR/status.json.bak" "$MEMORY_DIR/status.json" 2>/dev/null
# Restore notifications
if [ -d "$BACKUP_DIR/notifications_bak" ]; then
    rm -rf "$NOTIFY_DIR"
    cp -r "$BACKUP_DIR/notifications_bak" "$NOTIFY_DIR"
else
    # Clean up test notifications
    rm -rf "$NOTIFY_DIR"
    mkdir -p "$NOTIFY_DIR"
fi
rm -rf "$BACKUP_DIR"
echo "Backups restored."
echo ""

# ---- SUMMARY ----
TOTAL=$((PASS + FAIL + SKIP))
echo "================================================================"
echo "  SUMMARY: Shell Scripts Functional Test"
echo "  Total: $TOTAL | Pass: $PASS | Fail: $FAIL | Skip: $SKIP"
echo "  Pass Rate: $(( PASS * 100 / TOTAL ))%"
echo "================================================================"

exit $FAIL
