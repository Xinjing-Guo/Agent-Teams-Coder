#!/bin/bash
################################################################################
# memory-request.sh — 成员提交共享记忆变更请求
# 用法: bash memory-request.sh <action> <key> <content> <reason>
#   action:  write | edit | delete
#   key:     记忆条目的键名
#   content: 写入/编辑的内容（delete 时可传 ""）
#   reason:  变更理由
#
# 示例:
#   bash memory-request.sh write "api_auth" "使用 JWT" "统一认证方案"
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
QUEUE_FILE="$SCRIPT_DIR/../shared/memory/approval-queue.json"

ACTION="${1:?用法: memory-request.sh <action> <key> <content> <reason>}"
KEY="${2:?缺少 key 参数}"
CONTENT="${3:-}"
REASON="${4:-未说明}"

# 生成请求 ID: req_<时间戳>_<随机数>
REQUEST_ID="req_$(date +%Y%m%d%H%M%S)_$((RANDOM % 1000))"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# 获取提交者（从环境变量或默认 unknown）
REQUESTER="${CLAUDE_CODE_TEAM_NAME:-${AGENT_NAME:-unknown}}"

# 验证 action
case "$ACTION" in
    write|edit|delete) ;;
    *) echo "❌ 无效的 action: $ACTION（只支持 write/edit/delete）"; exit 1 ;;
esac

# 构建新请求的 JSON
NEW_REQUEST=$(cat <<EOF
{
    "id": "$REQUEST_ID",
    "requester": "$REQUESTER",
    "action": "$ACTION",
    "key": "$KEY",
    "content": "$CONTENT",
    "reason": "$REASON",
    "status": "pending",
    "reviewer_comment": "",
    "created_at": "$TIMESTAMP"
}
EOF
)

# 检查 python3 或 python 可用性
if command -v python3 &>/dev/null; then
    PY=python3
elif command -v python &>/dev/null; then
    PY=python
else
    echo "❌ 需要 Python 来操作 JSON"
    exit 1
fi

# 将请求追加到队列
$PY -c "
import json, sys

with open('$QUEUE_FILE', 'r') as f:
    queue = json.load(f)

new_req = json.loads('''$NEW_REQUEST''')
queue['requests'].append(new_req)

with open('$QUEUE_FILE', 'w') as f:
    json.dump(queue, f, ensure_ascii=False, indent=2)
"

echo "✅ 变更请求已提交"
echo "   请求 ID: $REQUEST_ID"
echo "   操作: $ACTION"
echo "   键: $KEY"
echo "   状态: pending（等待 Leader 审批）"
echo ""
echo "📌 请通知 Leader 审批:"
echo "   bash $SCRIPT_DIR/notify.sh $REQUESTER leader \"共享记忆变更请求\" \"请审批 $REQUEST_ID: $ACTION '$KEY'\""
