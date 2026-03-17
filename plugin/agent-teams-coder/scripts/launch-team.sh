#!/bin/bash
################################################################################
# launch-team.sh — 智能启动团队
# 检测 tmux 可用性，有则开多窗格，无则提示用子 Agent 模式
#
# 用法: bash launch-team.sh <plugin_root> <requirement> [model]
#   plugin_root: 插件根目录（用于定位 agent 配置）
#   requirement: 用户需求描述
#   model:       可选模型 (opus/haiku，默认 sonnet)
#
# 返回值:
#   exit 0 — tmux 已启动，多窗口模式
#   exit 1 — tmux 不可用，需要降级到子 Agent 模式
#   exit 2 — 已在 tmux 中，直接分屏
################################################################################

set -e

PLUGIN_ROOT="${1:?用法: launch-team.sh <plugin_root> <requirement> [model]}"
REQUIREMENT="${2:?缺少需求描述}"
MODEL="${3:-}"
SESSION="agent-team"

# ─── 检测 tmux ───
if ! command -v tmux &>/dev/null; then
    echo "TMUX_NOT_AVAILABLE"
    exit 1
fi

# ─── 检测 claude ───
if ! command -v claude &>/dev/null; then
    echo "CLAUDE_NOT_AVAILABLE"
    exit 1
fi

# ─── 模型参数 ───
MODEL_FLAG=""
case "$MODEL" in
    opus)  MODEL_FLAG="--model claude-opus-4-6" ;;
    haiku) MODEL_FLAG="--model claude-haiku-4-5-20251001" ;;
    "")    MODEL_FLAG="" ;;
esac

# ─── 查找 agent 工作目录 ───
# 优先用项目根目录下的 agent 目录，否则用插件内的 agents/
find_agent_dir() {
    local agent_name="$1"
    # 检查项目里是否有独立的 agent 目录
    local project_dir
    project_dir="$(pwd)"
    if [ -d "$project_dir/$agent_name" ] && [ -f "$project_dir/$agent_name/CLAUDE.md" ]; then
        echo "$project_dir/$agent_name"
    else
        # 用插件目录
        echo "$PLUGIN_ROOT/agents"
    fi
}

# ─── 创建临时启动脚本（给每个 agent 一个初始 prompt）───
create_agent_prompt() {
    local agent_name="$1"
    local role="$2"
    local tmp_file
    tmp_file=$(mktemp /tmp/agent_team_${agent_name}_XXXXXX.txt)
    cat > "$tmp_file" << PROMPT
你是 ${role}。团队收到以下需求:

${REQUIREMENT}

请按照你的 CLAUDE.md 和 PERSONA.md 中的指令执行初始化，然后等待 Marshall 的任务分配。
PROMPT
    echo "$tmp_file"
}

# ─── 如果已经在 tmux 内 ───
if [ -n "${TMUX:-}" ]; then
    echo "TMUX_INSIDE"
    # 在当前 tmux 会话中分屏
    CURRENT_WINDOW=$(tmux display-message -p '#I')

    # 创建新窗口放团队
    tmux new-window -n "Agent Team"

    # Marshall (主窗格)
    tmux send-keys "claude $MODEL_FLAG" C-m

    # Euler
    tmux split-window -h
    tmux send-keys "claude $MODEL_FLAG" C-m

    # Forge
    tmux select-pane -t 0
    tmux split-window -v
    tmux send-keys "claude $MODEL_FLAG" C-m

    # Sentinel
    tmux select-pane -t 2
    tmux split-window -v
    tmux send-keys "claude $MODEL_FLAG" C-m

    # Lens
    tmux split-window -v
    tmux send-keys "claude $MODEL_FLAG" C-m

    # Atlas
    tmux select-pane -t 1
    tmux split-window -v
    tmux send-keys "claude $MODEL_FLAG" C-m

    # Chronicle
    tmux split-window -v
    tmux send-keys "claude $MODEL_FLAG" C-m

    # 回到 Marshall 窗格
    tmux select-pane -t 0

    echo "TMUX_SPLIT_DONE"
    exit 2
fi

# ─── 正常启动新 tmux 会话 ───
if tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux kill-session -t "$SESSION"
fi

# Marshall (左上)
tmux new-session -d -s "$SESSION" -n "Agent Team"
tmux send-keys -t "$SESSION" "claude $MODEL_FLAG" C-m

# Euler (右上)
tmux split-window -h -t "$SESSION"
tmux send-keys -t "$SESSION" "claude $MODEL_FLAG" C-m

# Forge (右中)
tmux split-window -v -t "$SESSION"
tmux send-keys -t "$SESSION" "claude $MODEL_FLAG" C-m

# Sentinel (左中)
tmux select-pane -t "$SESSION:0.0"
tmux split-window -v -t "$SESSION"
tmux send-keys -t "$SESSION" "claude $MODEL_FLAG" C-m

# Lens (左下)
tmux split-window -v -t "$SESSION"
tmux send-keys -t "$SESSION" "claude $MODEL_FLAG" C-m

# Atlas (右下)
tmux select-pane -t "$SESSION:0.2"
tmux split-window -v -t "$SESSION"
tmux send-keys -t "$SESSION" "claude $MODEL_FLAG" C-m

# Chronicle (最右下)
tmux split-window -v -t "$SESSION"
tmux send-keys -t "$SESSION" "claude $MODEL_FLAG" C-m

# 回到 Marshall
tmux select-pane -t "$SESSION:0.0"

# 设置窗格标题
tmux select-pane -t "$SESSION:0.0" -T "Marshall (Leader)"
tmux select-pane -t "$SESSION:0.1" -T "Euler (Algorithm)"
tmux select-pane -t "$SESSION:0.2" -T "Forge (Code)"
tmux select-pane -t "$SESSION:0.3" -T "Sentinel (Test)"
tmux select-pane -t "$SESSION:0.4" -T "Lens (Analysis)"
tmux select-pane -t "$SESSION:0.5" -T "Atlas (Docs)"
tmux select-pane -t "$SESSION:0.6" -T "Chronicle (Log)"

# 启用窗格边框标题显示
tmux set-option -t "$SESSION" pane-border-status top
tmux set-option -t "$SESSION" pane-border-format " #{pane_title} "

echo "TMUX_SESSION_CREATED"
echo "SESSION_NAME=$SESSION"
echo "REQUIREMENT=$REQUIREMENT"

# 不 attach — 让调用方决定是否 attach
# 用户可以执行: tmux attach -t agent-team
exit 0
