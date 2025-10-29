#!/bin/bash

# 企业知识库问答系统 - 步骤 1: 启动 Dify 服务

echo "╔════════════════════════════════════════════════════════╗"
echo "║   步骤 1: 启动 Dify 服务                               ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

echo "我们需要启动两个服务："
echo "1. Dify API 服务器 (后端)"
echo "2. Dify Web UI (前端)"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "启动 Dify API 服务器"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 提示："
echo "   - API 服务器将在端口 5001 运行"
echo "   - 使用 Gunicorn 生产模式（4 个 worker）"
echo "   - 支持异步（gevent worker）"
echo "   - 按 Ctrl+C 可以停止服务"
echo ""

read -p "是否启动 Dify API 服务器? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🚀 启动 Dify API 服务器..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📍 访问地址："
    echo "   API: http://localhost:5001"
    echo "   API 文档: http://localhost:5001/console/api/swagger"
    echo ""
    echo "🛑 按 Ctrl+C 停止服务后，继续下一步"
    echo ""
    
    cd /workspaces/dify.git/api
    uv run python -m gunicorn \
        --bind 0.0.0.0:5001 \
        --workers 4 \
        --worker-class gevent \
        --timeout 120 \
        --keep-alive 5 \
        --log-level info \
        --access-logfile - \
        --error-logfile - \
        app:app
else
    echo ""
    echo "跳过启动 API 服务器"
    echo ""
    echo "手动启动命令："
    echo "cd /workspaces/dify.git/api"
    echo "uv run gunicorn --bind 0.0.0.0:5001 --workers 4 --worker-class gevent app:app"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "💡 请在另一个终端启动 API 服务器，然后继续："
    echo "   ./scripts/stress-test/setup_kb_step2.sh"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi
