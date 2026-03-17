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

set -e

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

$PY -c "
import json, sys
from datetime import datetime

with open('$QUEUE_FILE', 'r') as f:
    queue = json.load(f)

with open('$MEMORY_FILE', 'r') as f:
    memory = json.load(f)

# 查找请求
found = False
for req in queue['requests']:
    if req['id'] == '$REQUEST_ID':
        if req['status'] != 'pending':
            print(f'⚠️  请求 {req[\"id\"]} 状态为 {req[\"status\"]}，不是 pending')
            sys.exit(1)

        # 更新审批状态
        req['status'] = 'approved'
        req['reviewer_comment'] = '$COMMENT'
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
    print(f'❌ 找不到请求: $REQUEST_ID')
    sys.exit(1)

with open('$QUEUE_FILE', 'w') as f:
    json.dump(queue, f, ensure_ascii=False, indent=2)

with open('$MEMORY_FILE', 'w') as f:
    json.dump(memory, f, ensure_ascii=False, indent=2)

print(f'✅ 已批准请求 $REQUEST_ID')
print(f'   操作: {action} \"{key}\"')
print(f'   提交者: {requester}')
print(f'   共享记忆已更新')
"
