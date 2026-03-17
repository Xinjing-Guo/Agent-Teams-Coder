#!/bin/bash
################################################################################
# memory-write.sh — Leader 直接写入共享记忆（无需审批）
# 用法: bash memory-write.sh <key> <content>
################################################################################

set -euo pipefail

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

MEMORY_FILE="$MEMORY_FILE" KEY="$KEY" CONTENT="$CONTENT" \
$PY -c "
import json, os
from datetime import datetime

memory_file = os.environ['MEMORY_FILE']
key = os.environ['KEY']
content = os.environ['CONTENT']

with open(memory_file, 'r') as f:
    memory = json.load(f)

memory['entries'][key] = {
    'content': content,
    'author': 'leader',
    'approved_by': 'leader (direct)',
    'updated_at': datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
}
memory['meta']['last_updated'] = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
memory['meta']['updated_by'] = 'leader'

with open(memory_file, 'w') as f:
    json.dump(memory, f, ensure_ascii=False, indent=2)

print('shared memory updated')
print(f'   key: {key}')
print(f'   author: leader (direct write)')
"
