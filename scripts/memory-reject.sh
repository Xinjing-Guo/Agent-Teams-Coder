#!/bin/bash
################################################################################
# memory-reject.sh — Leader 拒绝共享记忆变更请求
# 用法: bash memory-reject.sh <request_id> <reason>
################################################################################

set -euo pipefail

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

QUEUE_FILE="$QUEUE_FILE" REQUEST_ID="$REQUEST_ID" REASON="$REASON" \
$PY -c "
import json, sys, os
from datetime import datetime

queue_file = os.environ['QUEUE_FILE']
request_id = os.environ['REQUEST_ID']
reason = os.environ['REASON']

with open(queue_file, 'r') as f:
    queue = json.load(f)

found = False
for req in queue['requests']:
    if req['id'] == request_id:
        if req['status'] != 'pending':
            print(f'request {req[\"id\"]} status is {req[\"status\"]}, not pending')
            sys.exit(1)

        req['status'] = 'rejected'
        req['reviewer_comment'] = reason
        req['reviewed_at'] = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
        found = True
        requester = req['requester']
        key = req['key']
        break

if not found:
    print(f'error: not found request: {request_id}')
    sys.exit(1)

with open(queue_file, 'w') as f:
    json.dump(queue, f, ensure_ascii=False, indent=2)

print(f'rejected request {request_id}')
print(f'   key: {key}')
print(f'   requester: {requester}')
print(f'   reason: {reason}')
"
