#!/bin/bash
################################################################################
# memory-reject.sh — Leader 拒绝共享记忆变更请求
# 用法: bash memory-reject.sh <request_id> <reason>
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
QUEUE_FILE="$SCRIPT_DIR/../shared/memory/approval-queue.json"

REQUEST_ID="${1:?用法: memory-reject.sh <request_id> <reason>}"
REASON="${2:?请提供拒绝理由}"

if command -v python3 &>/dev/null; then
    PY=python3
elif command -v python &>/dev/null; then
    PY=python
else
    echo "❌ 需要 Python"; exit 1
fi

$PY -c "
import json, sys
from datetime import datetime

with open('$QUEUE_FILE', 'r') as f:
    queue = json.load(f)

found = False
for req in queue['requests']:
    if req['id'] == '$REQUEST_ID':
        if req['status'] != 'pending':
            print(f'⚠️  请求 {req[\"id\"]} 状态为 {req[\"status\"]}，不是 pending')
            sys.exit(1)

        req['status'] = 'rejected'
        req['reviewer_comment'] = '$REASON'
        req['reviewed_at'] = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
        found = True
        requester = req['requester']
        key = req['key']
        break

if not found:
    print(f'❌ 找不到请求: $REQUEST_ID')
    sys.exit(1)

with open('$QUEUE_FILE', 'w') as f:
    json.dump(queue, f, ensure_ascii=False, indent=2)

print(f'❌ 已拒绝请求 $REQUEST_ID')
print(f'   键: {key}')
print(f'   提交者: {requester}')
print(f'   理由: $REASON')
"
