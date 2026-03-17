#!/bin/bash
################################################################################
# memory-write.sh — Leader 直接写入共享记忆（无需审批）
# 用法: bash memory-write.sh <key> <content>
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MEMORY_FILE="$SCRIPT_DIR/../shared/memory/shared-memory.json"

KEY="${1:?用法: memory-write.sh <key> <content>}"
CONTENT="${2:?缺少 content 参数}"

if command -v python3 &>/dev/null; then
    PY=python3
elif command -v python &>/dev/null; then
    PY=python
else
    echo "❌ 需要 Python"; exit 1
fi

$PY -c "
import json
from datetime import datetime

with open('$MEMORY_FILE', 'r') as f:
    memory = json.load(f)

memory['entries']['$KEY'] = {
    'content': '''$CONTENT''',
    'author': 'leader',
    'approved_by': 'leader (direct)',
    'updated_at': datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
}
memory['meta']['last_updated'] = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
memory['meta']['updated_by'] = 'leader'

with open('$MEMORY_FILE', 'w') as f:
    json.dump(memory, f, ensure_ascii=False, indent=2)

print('✅ 共享记忆已更新')
print(f'   键: $KEY')
print(f'   作者: leader (直接写入)')
"
