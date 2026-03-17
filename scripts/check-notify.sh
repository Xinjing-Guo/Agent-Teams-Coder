#!/bin/bash
################################################################################
# check-notify.sh — 检查是否有新通知（带 mtime 缓存）
# 用法: bash check-notify.sh <agent_name>
# 返回: exit 0 = 无新通知, exit 1 = 有新通知（并显示内容）
#
# 借鉴 agentGroup 的 mtime 缓存机制，避免每次都解析 JSON
################################################################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NOTIFY_DIR="$SCRIPT_DIR/../shared/notifications"
AGENT_NAME="${1:?用法: check-notify.sh <agent_name>}"

NOTIFY_FILE="$NOTIFY_DIR/${AGENT_NAME}.json"
CACHE_DIR="$NOTIFY_DIR/.cache"
CACHE_FILE="$CACHE_DIR/${AGENT_NAME}_last_check"

mkdir -p "$CACHE_DIR"

# 没有通知文件
if [ ! -f "$NOTIFY_FILE" ]; then
    echo "📭 无通知"
    exit 0
fi

# 获取文件修改时间
get_mtime() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        stat -f %m "$1" 2>/dev/null || echo "0"
    else
        stat -c %Y "$1" 2>/dev/null || echo "0"
    fi
}

CURRENT_MTIME=$(get_mtime "$NOTIFY_FILE")

# 读取缓存
if [ -f "$CACHE_FILE" ]; then
    CACHED_MTIME=$(cat "$CACHE_FILE" 2>/dev/null || echo "0")
else
    CACHED_MTIME=0
fi

# 比较
if [ "$CURRENT_MTIME" -le "$CACHED_MTIME" ]; then
    echo "📭 无新通知（文件未变化）"
    exit 0
fi

# 有新通知，显示未读的
if command -v python3 &>/dev/null; then
    PY=python3
elif command -v python &>/dev/null; then
    PY=python
else
    echo "❌ 需要 Python"; exit 1
fi

UNREAD_COUNT=$($PY -c "
import json

with open('$NOTIFY_FILE', 'r') as f:
    data = json.load(f)

unread = [n for n in data['notifications'] if not n.get('read', False)]
for n in unread:
    print(f\"📬 [{n['from']}] {n['subject']}\")
    if n.get('content'):
        print(f\"   {n['content']}\")
    print()

# 标记为已读
for n in data['notifications']:
    n['read'] = True

with open('$NOTIFY_FILE', 'w') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f'共 {len(unread)} 条未读通知')
")

echo "$UNREAD_COUNT"

# 更新缓存
echo "$CURRENT_MTIME" > "$CACHE_FILE"

exit 1
