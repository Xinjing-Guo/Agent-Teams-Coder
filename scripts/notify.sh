#!/bin/bash
################################################################################
# notify.sh — 发送通知给其他 Agent
# 用法: bash notify.sh <from> <to> <subject> <content>
#   to 可以是: marshall, euler, forge, sentinel, lens, atlas, chronicle, all
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NOTIFY_DIR="$SCRIPT_DIR/../shared/notifications"

FROM="${1:?用法: notify.sh <from> <to> <subject> <content>}"
TO="${2:?缺少 to 参数}"
SUBJECT="${3:?缺少 subject 参数}"
CONTENT="${4:-}"

TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
NOTIF_ID="notif_$(date +%Y%m%d%H%M%S)_$((RANDOM % 1000))"

# 创建通知目录（按接收者）
mkdir -p "$NOTIFY_DIR"

# 如果是 all，写入每个 Agent 的通知文件
if [ "$TO" = "all" ]; then
    TARGETS=("marshall" "euler" "forge" "sentinel" "lens" "atlas" "chronicle")
else
    TARGETS=("$TO")
fi

if command -v python3 &>/dev/null; then
    PY=python3
elif command -v python &>/dev/null; then
    PY=python
else
    echo "❌ 需要 Python"; exit 1
fi

for TARGET in "${TARGETS[@]}"; do
    # 跳过给自己发
    [ "$TARGET" = "$FROM" ] && continue

    TARGET_FILE="$NOTIFY_DIR/${TARGET}.json"

    # 如果文件不存在，初始化
    if [ ! -f "$TARGET_FILE" ]; then
        echo '{"notifications": []}' > "$TARGET_FILE"
    fi

    $PY -c "
import json

with open('$TARGET_FILE', 'r') as f:
    data = json.load(f)

data['notifications'].append({
    'id': '$NOTIF_ID',
    'from': '$FROM',
    'to': '$TARGET',
    'subject': '$SUBJECT',
    'content': '''$CONTENT''',
    'timestamp': '$TIMESTAMP',
    'read': False
})

with open('$TARGET_FILE', 'w') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
"
    echo "📬 已通知 $TARGET: $SUBJECT"
done
