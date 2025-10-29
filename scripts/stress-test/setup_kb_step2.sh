#!/bin/bash

# 企业知识库问答系统 - 步骤 2: Web UI 配置指南

echo "╔════════════════════════════════════════════════════════╗"
echo "║   步骤 2: 配置 Dify Web UI                             ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# 检查 API 是否运行
if curl -s http://localhost:5001/health > /dev/null 2>&1; then
    echo "✅ Dify API 服务器正在运行"
else
    echo "❌ Dify API 服务器未运行"
    echo ""
    echo "请先在另一个终端启动 API 服务器："
    echo "  ./scripts/stress-test/setup_kb_step1.sh"
    echo ""
    echo "或手动启动："
    echo "  cd /workspaces/dify.git/api"
    echo "  uv run gunicorn --bind 0.0.0.0:5001 --workers 4 --worker-class gevent app:app"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "启动 Dify Web UI"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "是否启动 Web UI? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🚀 启动 Dify Web UI..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📍 访问地址: http://localhost:3000"
    echo ""
    echo "🛑 按 Ctrl+C 停止服务后，继续配置"
    echo ""
    
    cd /workspaces/dify.git/web
    pnpm dev
else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📝 Web UI 配置步骤"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "1. 启动 Web UI（在另一个终端）:"
    echo "   cd /workspaces/dify.git/web"
    echo "   pnpm dev"
    echo ""
    echo "2. 打开浏览器访问: http://localhost:3000"
    echo ""
    echo "3. 注册/登录 Dify 账户"
    echo ""
    echo "4. 配置 Ollama 模型提供商:"
    echo "   - 进入: Settings → Model Provider"
    echo "   - 找到: Ollama"
    echo "   - 配置:"
    echo "     • Base URL: http://172.17.0.1:11434"
    echo "     • API Key: ollama (任意值)"
    echo "   - 点击: Validate (验证连接)"
    echo "   - 点击: Save (保存配置)"
    echo ""
    echo "5. 配置成功后，运行下一步:"
    echo "   ./scripts/stress-test/setup_kb_step3.sh"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi
