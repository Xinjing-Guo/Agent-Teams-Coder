#!/bin/bash
################################################################################
# panel.sh — 交互式启动面板（tmux 多窗格）
# 需要: tmux (brew install tmux / apt install tmux)
#
# 布局示意（全员模式）:
# ┌──────────────────┬──────────────────┐
# │   Marshall       │    Euler         │
# │   (Leader)       │   (算法设计)     │
# │                  ├──────────────────┤
# │                  │    Forge         │
# │                  │   (代码开发)     │
# ├──────────────────┼──────────────────┤
# │   Sentinel       │    Lens          │
# │   (代码测试)     │   (代码分析)     │
# ├──────────────────┼──────────────────┤
# │   Atlas          │    Chronicle     │
# │   (文档编写)     │   (日志记录)     │
# └──────────────────┴──────────────────┘
################################################################################

SESSION="agent-team"
DIR="$(cd "$(dirname "$0")" && pwd)"

# ─── 向指定窗格发送初始化 prompt ───
# 参数: $1=tmux_target (如 "$SESSION:0.0"), $2=agent_name
# panel.sh 无需求参数，仅发送初始化指令
send_init_prompt() {
    local target="$1"
    local agent_name="$2"
    if [ "$agent_name" = "marshall" ]; then
        tmux send-keys -t "$target" "请执行七步检查点初始化（读取 PERSONA.md -> 共享记忆 -> 检查通知 -> 更新状态 -> 检查 Skills -> 评估任务）。初始化完成后，等待用户输入需求。" C-m
    else
        tmux send-keys -t "$target" "请执行七步检查点初始化（读取 PERSONA.md -> 共享记忆 -> 检查通知 -> 更新状态 -> 检查 Skills -> 评估任务），然后等待 Marshall 的任务分配通知。执行: bash ../scripts/check-notify.sh ${agent_name}" C-m
    fi
}

# ─── 批量发送初始 prompt ───
# 参数: 成对的 "pane_index agent_name" 列表
# 示例: send_all_init_prompts "0 marshall" "1 euler" "2 forge"
send_all_init_prompts() {
    sleep 4
    for pair in "$@"; do
        local pane_idx="${pair%% *}"
        local agent_name="${pair#* }"
        send_init_prompt "${SESSION}:0.${pane_idx}" "$agent_name"
        sleep 1
    done
}

# 检查 tmux
if ! command -v tmux &>/dev/null; then
    echo "❌ 需要安装 tmux"
    echo "   macOS:  brew install tmux"
    echo "   Ubuntu: sudo apt install tmux"
    exit 1
fi

# 检查 claude
if ! command -v claude &>/dev/null; then
    echo "❌ 需要安装 Claude Code"
    echo "   npm install -g @anthropic-ai/claude-code"
    exit 1
fi

# 如果 session 已存在
if tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "Agent Team 会话已存在"
    echo ""
    echo "  1) 连接到现有会话"
    echo "  2) 关闭并重新启动"
    echo "  3) 退出"
    echo ""
    read -rp "请选择 [1-3]: " choice
    case $choice in
        1) tmux attach-session -t "$SESSION"; exit 0 ;;
        2) tmux kill-session -t "$SESSION" ;;
        *) exit 0 ;;
    esac
fi

echo "=========================================="
echo "  Agent Team — 启动面板"
echo "=========================================="
echo ""
echo "  a) 全员启动 (Marshall + Euler + Forge + Sentinel + Lens + Atlas + Chronicle)"
echo "  b) 核心开发 (Marshall + Euler + Forge + Sentinel)"
echo "  c) 仅 Leader (Marshall)"
echo "  d) 算法+开发 (Euler + Forge)"
echo "  e) 测试+分析+文档 (Sentinel + Lens + Atlas)"
echo "  q) 退出"
echo ""
read -rp "请选择: " selection

case $selection in
    a|A)
        # 全员: 7 个窗格
        tmux new-session -d -s "$SESSION" -c "$DIR/leader" -n "Agent Team"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux split-window -h -t "$SESSION" -c "$DIR/euler"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux select-pane -t "$SESSION:0.0"
        tmux split-window -v -t "$SESSION" -c "$DIR/sentinel"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux split-window -v -t "$SESSION" -c "$DIR/atlas"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux select-pane -t "$SESSION:0.1"
        tmux split-window -v -t "$SESSION" -c "$DIR/forge"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux split-window -v -t "$SESSION" -c "$DIR/lens"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux split-window -v -t "$SESSION" -c "$DIR/chronicle"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux select-pane -t "$SESSION:0.0"

        # 发送初始化 prompt（后台执行，不阻塞 attach）
        send_all_init_prompts \
            "0 marshall" "1 euler" "2 sentinel" "3 atlas" \
            "4 forge" "5 lens" "6 chronicle" &

        tmux attach-session -t "$SESSION"
        ;;
    b|B)
        # 核心开发: Marshall + Euler + Forge + Sentinel
        tmux new-session -d -s "$SESSION" -c "$DIR/leader" -n "Agent Team"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux split-window -h -t "$SESSION" -c "$DIR/euler" -p 50
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux split-window -v -t "$SESSION" -c "$DIR/forge"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux select-pane -t "$SESSION:0.0"
        tmux split-window -v -t "$SESSION" -c "$DIR/sentinel"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux select-pane -t "$SESSION:0.0"

        # 发送初始化 prompt（后台执行）
        send_all_init_prompts \
            "0 marshall" "1 euler" "2 forge" "3 sentinel" &

        tmux attach-session -t "$SESSION"
        ;;
    c|C)
        tmux new-session -d -s "$SESSION" -c "$DIR/leader" -n "Agent Team"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        # 发送初始化 prompt（后台执行）
        send_all_init_prompts "0 marshall" &

        tmux attach-session -t "$SESSION"
        ;;
    d|D)
        # 算法+开发: Euler + Forge
        tmux new-session -d -s "$SESSION" -c "$DIR/euler" -n "算法+开发"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux split-window -h -t "$SESSION" -c "$DIR/forge"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        # 发送初始化 prompt（后台执行）
        send_all_init_prompts "0 euler" "1 forge" &

        tmux attach-session -t "$SESSION"
        ;;
    e|E)
        # 测试+分析+文档
        tmux new-session -d -s "$SESSION" -c "$DIR/sentinel" -n "测试+分析+文档"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux split-window -h -t "$SESSION" -c "$DIR/lens"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux split-window -v -t "$SESSION" -c "$DIR/atlas"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux select-pane -t "$SESSION:0.0"

        # 发送初始化 prompt（后台执行）
        send_all_init_prompts "0 sentinel" "1 lens" "2 atlas" &

        tmux attach-session -t "$SESSION"
        ;;
    *)
        exit 0
        ;;
esac
