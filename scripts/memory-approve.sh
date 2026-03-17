#!/bin/bash
################################################################################
# memory-approve.sh — Leader 批准共享记忆变更请求
# 用法: bash memory-approve.sh <request_id> [comment]
#
# 执行逻辑:
#   1. 在 approval-queue.json 中找到该请求
#   2. 将状态改为 approved
#   3. 将内容写入 shared-memory.json
#   4. 通知提交者
################################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
QUEUE_FILE="$SCRIPT_DIR/../shared/memory/approval-queue.json"
MEMORY_FILE="$SCRIPT_DIR/../shared/memory/shared-memory.json"

REQUEST_ID="${1:?用法: memory-approve.sh <request_id> [comment]}"
COMMENT="${2:-已批准}"

if command -v python3 &>/dev/null; then
    PY=python3
elif command -v python &>/dev/null; then
    PY=python
else
    echo "❌ 需要 Python"; exit 1
fi

QUEUE_FILE="$QUEUE_FILE" MEMORY_FILE="$MEMORY_FILE" \
REQUEST_ID="$REQUEST_ID" COMMENT="$COMMENT" \
$PY -c "
import json, sys, os
from datetime import datetime

queue_file = os.environ['QUEUE_FILE']
memory_file = os.environ['MEMORY_FILE']
request_id = os.environ['REQUEST_ID']
comment = os.environ['COMMENT']

with open(queue_file, 'r') as f:
    queue = json.load(f)

with open(memory_file, 'r') as f:
    memory = json.load(f)

# 查找请求
found = False
for req in queue['requests']:
    if req['id'] == request_id:
        if req['status'] != 'pending':
            print(f'request {req[\"id\"]} status is {req[\"status\"]}, not pending')
            sys.exit(1)

        # 更新审批状态
        req['status'] = 'approved'
        req['reviewer_comment'] = comment
        req['reviewed_at'] = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')

        # 执行变更
        if req['action'] in ('write', 'edit'):
            memory['entries'][req['key']] = {
                'content': req['content'],
                'author': req['requester'],
                'approved_by': 'leader',
                'updated_at': datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
            }
        elif req['action'] == 'delete':
            memory['entries'].pop(req['key'], None)

        memory['meta']['last_updated'] = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
        memory['meta']['updated_by'] = 'leader'

        found = True
        requester = req['requester']
        key = req['key']
        action = req['action']
        break

if not found:
    print(f'error: not found request: {request_id}')
    sys.exit(1)

with open(queue_file, 'w') as f:
    json.dump(queue, f, ensure_ascii=False, indent=2)

with open(memory_file, 'w') as f:
    json.dump(memory, f, ensure_ascii=False, indent=2)

print(f'approved request {request_id}')
print(f'   action: {action} \"{key}\"')
print(f'   requester: {requester}')
print(f'   shared memory updated')
"
