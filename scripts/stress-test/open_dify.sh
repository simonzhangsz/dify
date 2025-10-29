#!/bin/bash
# 一键打开 Dify Web UI

echo "🚀 正在打开 Dify Web UI..."
echo ""

# 检查服务状态
if ! pgrep -f "next.*3000" > /dev/null; then
    echo "❌ Web UI 未运行！"
    echo ""
    echo "请先启动服务："
    echo "  cd /workspaces/dify.git"
    echo "  ./scripts/stress-test/manage_servers.sh start"
    exit 1
fi

echo "✅ Web UI 运行正常"
echo ""
echo "📌 访问方式："
echo ""
echo "1️⃣  在 VS Code 中："
echo "   - 查看底部的 PORTS 面板"
echo "   - 找到端口 3000"
echo "   - 点击 🌐 图标"
echo ""
echo "2️⃣  按住 Ctrl/Cmd + 点击下面的链接："
echo ""
echo "   http://localhost:3000"
echo ""
echo "3️⃣  使用 VS Code 简单浏览器："
echo "   运行命令: \$BROWSER http://localhost:3000"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 提示：如果看到空白页面，请："
echo "   - 等待 5-10 秒让页面加载"
echo "   - 刷新浏览器（F5 或 Ctrl+R）"
echo "   - 清除浏览器缓存后重试"
echo ""

# 尝试在简单浏览器中打开
if command -v code > /dev/null 2>&1; then
    echo "🌐 正在 VS Code 简单浏览器中打开..."
    $BROWSER http://localhost:3000 2>/dev/null &
fi
