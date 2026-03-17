#!/bin/bash
################################################################################
# update-phase.sh — Marshall 更新当前工作流阶段
# 用法: bash update-phase.sh <phase_number> <task_name>
#
# 示例:
#   bash update-phase.sh 1 "开发排序库"
#   bash update-phase.sh 4 "开发排序库"
################################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STATUS_FILE="$SCRIPT_DIR/../shared/memory/status.json"

PHASE="${1:?用法: update-phase.sh <phase_number> <task_name>}"
TASK="${2:?缺少 task_name 参数}"

TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# 阶段描述映射（兼容 Bash 3.2，不使用 declare -A）
case "$PHASE" in
    1) DESC="阶段 1: 需求分析" ;;
    2) DESC="阶段 2: 算法设计" ;;
    3) DESC="阶段 3: 代码开发" ;;
    4) DESC="阶段 4: 代码测试" ;;
    5) DESC="阶段 5: 代码分析" ;;
    6) DESC="阶段 6: 文档编写" ;;
    7) DESC="阶段 7: 汇总交付" ;;
    *) DESC="未知阶段" ;;
esac

if command -v python3 &>/dev/null; then
    PY=python3
elif command -v python &>/dev/null; then
    PY=python
else
    echo "❌ 需要 Python"; exit 1
fi

STATUS_FILE="$STATUS_FILE" TASK="$TASK" PHASE="$PHASE" DESC="$DESC" TIMESTAMP="$TIMESTAMP" \
$PY -c "
import json, os

status_file = os.environ['STATUS_FILE']
task = os.environ['TASK']
phase = os.environ['PHASE']
desc = os.environ['DESC']
timestamp = os.environ['TIMESTAMP']

with open(status_file, 'r') as f:
    data = json.load(f)

data['team_status']['current_task'] = task
data['team_status']['phase'] = phase
data['team_status']['phase_description'] = desc
data['meta']['last_updated'] = timestamp
data['meta']['updated_by'] = 'marshall'

with open(status_file, 'w') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
"

echo "✅ 工作流阶段已更新"
echo "   任务: $TASK"
echo "   $DESC"
