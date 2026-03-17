#!/bin/bash
# 启动 Sentinel（哨兵）
# 用法: ./start-sentinel.sh [模型]
#   无参数 → 默认 Sonnet
#   opus   → 使用 Opus 模型
#   haiku  → 使用 Haiku 模型
cd "$(dirname "$0")/sentinel"

MODEL_FLAG=""
case "${1:-}" in
    opus)  MODEL_FLAG="--model claude-opus-4-6" ;;
    haiku) MODEL_FLAG="--model claude-haiku-4-5-20251001" ;;
    "")    MODEL_FLAG="" ;;
    *)     echo "未知模型: $1（可选: opus, haiku）"; exit 1 ;;
esac

echo "=========================================="
echo "  启动 Sentinel（哨兵）"
[ -n "$MODEL_FLAG" ] && echo "  模型: $1"
echo "=========================================="
claude $MODEL_FLAG -c 2>/dev/null || claude $MODEL_FLAG
