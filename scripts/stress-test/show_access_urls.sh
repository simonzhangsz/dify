#!/bin/bash
# 显示 Dify 访问信息

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}         ${GREEN}🚀 Dify 访问信息${NC}                          ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# 检查服务状态
echo -e "${YELLOW}📊 服务状态：${NC}"
echo ""

if pgrep -f "python.*app\.run.*5001" > /dev/null; then
    echo -e "  ${GREEN}✓${NC} API 服务器运行中"
else
    echo -e "  ${RED}✗${NC} API 服务器未运行"
fi

if pgrep -f "pnpm dev\|next-server" > /dev/null; then
    echo -e "  ${GREEN}✓${NC} Web UI 运行中"
else
    echo -e "  ${RED}✗${NC} Web UI 未运行"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}🌐 如何访问：${NC}"
echo ""
echo -e "${BLUE}重要提示：${NC}您在 ${YELLOW}Dev Container${NC} 中运行，不能直接访问 localhost！"
echo ""

echo -e "${GREEN}✅ 正确方式 1：使用 VS Code 端口转发${NC}"
echo ""
echo "  1. 查看 VS Code 底部的 ${CYAN}PORTS${NC} 标签"
echo "  2. 找到端口 ${YELLOW}3000${NC}（Web UI）"
echo "  3. 点击该行的 ${GREEN}🌐 图标${NC} 或 'Open in Browser'"
echo "  4. 浏览器会自动打开 Dify Web UI"
echo ""

echo -e "${GREEN}✅ 正确方式 2：Ctrl/Cmd + 点击链接${NC}"
echo ""
echo "  在下面的链接上按住 Ctrl (Windows/Linux) 或 Cmd (Mac) 并点击："
echo ""
echo -e "  ${CYAN}http://localhost:3000${NC}  ← Web UI"
echo -e "  ${CYAN}http://localhost:5001${NC}  ← API 服务器"
echo ""
echo "  VS Code 会自动处理端口转发并打开浏览器"
echo ""

echo -e "${GREEN}✅ 正确方式 3：简单浏览器${NC}"
echo ""
echo "  运行以下命令在 VS Code 内置浏览器打开："
echo ""
echo -e "  ${YELLOW}\$BROWSER http://localhost:3000${NC}"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}🔧 如果端口没有自动转发：${NC}"
echo ""
echo "  1. 打开 VS Code 的 ${CYAN}PORTS${NC} 面板"
echo "  2. 点击 ${GREEN}Forward a Port${NC} 按钮"
echo "  3. 输入 ${YELLOW}3000${NC} 并回车"
echo "  4. 重复步骤，再转发 ${YELLOW}5001${NC}"
echo "  5. 点击端口旁的 🌐 图标访问"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}📱 远程访问（可选）：${NC}"
echo ""
echo "  如需从其他设备访问："
echo "  1. 在 PORTS 面板右键点击端口"
echo "  2. 选择 ${GREEN}Port Visibility → Public${NC}"
echo "  3. VS Code 会生成公网 URL"
echo "  4. 使用该 URL 在任何设备访问"
echo ""
echo -e "  ${RED}⚠️  安全提示：${NC}Public 端口暴露在互联网，用完记得改回 Private"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}🧪 测试端口转发：${NC}"
echo ""
echo "  在容器内测试（应该成功）："
echo -e "  ${CYAN}curl http://localhost:5001/console/api/setup${NC}"
echo -e "  ${CYAN}curl -I http://localhost:3000${NC}"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${GREEN}💡 快速帮助：${NC}"
echo ""
echo "  查看完整说明："
echo -e "  ${CYAN}cat scripts/stress-test/ACCESS_INFO.md${NC}"
echo ""
echo "  管理服务器："
echo -e "  ${CYAN}./scripts/stress-test/manage_servers.sh status${NC}"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${GREEN}🎯 现在就试试：${NC}"
echo ""
echo "  1. 打开 VS Code 底部的 ${CYAN}PORTS${NC} 面板"
echo "  2. 找到端口 ${YELLOW}3000${NC}"
echo "  3. 点击 ${GREEN}🌐${NC} 图标"
echo "  4. 享受 Dify！ 🎉"
echo ""
