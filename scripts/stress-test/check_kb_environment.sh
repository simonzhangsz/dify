#!/bin/bash

# 企业知识库问答系统 - 环境检查脚本
# 确保所有依赖都已就绪

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║   企业知识库问答系统 - 环境检查                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_passed=0
check_failed=0

# 检查函数
check_item() {
    local name="$1"
    local command="$2"
    
    echo -n "检查 $name... "
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ 通过${NC}"
        ((check_passed++))
        return 0
    else
        echo -e "${RED}✗ 失败${NC}"
        ((check_failed++))
        return 1
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Ollama 连接检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if check_item "Ollama 服务" "curl -s http://172.17.0.1:11434/api/tags"; then
    # 检查可用模型
    echo ""
    echo "📋 可用模型："
    curl -s http://172.17.0.1:11434/api/tags | python3 -c "
import sys, json
data = json.load(sys.stdin)
for model in data.get('models', []):
    name = model['name']
    size_gb = model['size'] / (1024**3)
    print(f'   ✓ {name} ({size_gb:.1f} GB)')
"
    echo ""
    
    # 检查推荐模型
    models=$(curl -s http://172.17.0.1:11434/api/tags | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
    
    has_fast_model=false
    has_reasoning_model=false
    
    if echo "$models" | grep -q "qwen2.5:3b\|llama3.2:3b"; then
        has_fast_model=true
        echo -e "   ${GREEN}✓ 快速模型已就绪${NC} (qwen2.5:3b 或 llama3.2:3b)"
    else
        echo -e "   ${YELLOW}⚠ 建议安装快速模型${NC}"
        echo "     在宿主机运行: ollama pull qwen2.5:3b"
    fi
    
    if echo "$models" | grep -q "deepseek-r1\|qwen2.5:7b"; then
        has_reasoning_model=true
        echo -e "   ${GREEN}✓ 推理模型已就绪${NC} (deepseek-r1 或 qwen2.5:7b)"
    else
        echo -e "   ${YELLOW}⚠ 建议安装推理模型${NC}"
        echo "     在宿主机运行: ollama pull qwen2.5:7b"
    fi
else
    echo -e "${RED}✗ 无法连接到 Ollama${NC}"
    echo ""
    echo "解决方案："
    echo "1. 在宿主机确保 Ollama 运行："
    echo "   export OLLAMA_HOST=0.0.0.0:11434"
    echo "   ollama serve"
    echo ""
    echo "2. 验证连接："
    echo "   curl http://172.17.0.1:11434/api/tags"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. Dify 配置检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "/workspaces/dify.git/api/.env" ]; then
    echo -e "${GREEN}✓ .env 文件存在${NC}"
    ((check_passed++))
    
    # 检查 Ollama 配置
    if grep -q "OLLAMA_API_BASE_URL" /workspaces/dify.git/api/.env; then
        ollama_url=$(grep "OLLAMA_API_BASE_URL" /workspaces/dify.git/api/.env | cut -d'=' -f2)
        echo "   Ollama URL: $ollama_url"
    else
        echo -e "   ${YELLOW}⚠ 未找到 OLLAMA_API_BASE_URL 配置${NC}"
        echo "   运行: uv run --project api python scripts/stress-test/setup/configure_ollama.py"
    fi
else
    echo -e "${RED}✗ .env 文件不存在${NC}"
    ((check_failed++))
    echo "   需要先运行 Dify 设置脚本"
fi

echo ""
check_item "Python 环境" "python3 --version"
check_item "UV 包管理器" "uv --version"
check_item "curl 工具" "curl --version"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. 端口检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if lsof -i :5001 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Dify API 正在运行${NC} (端口 5001)"
    ((check_passed++))
else
    echo -e "${YELLOW}⚠ Dify API 未运行${NC} (端口 5001)"
    echo "   启动命令："
    echo "   cd /workspaces/dify.git/api"
    echo "   uv run gunicorn --bind 0.0.0.0:5001 --workers 4 --worker-class gevent app:app"
fi

if lsof -i :3000 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Dify Web UI 正在运行${NC} (端口 3000)"
    ((check_passed++))
else
    echo -e "${YELLOW}⚠ Dify Web UI 未运行${NC} (端口 3000)"
    echo "   启动命令："
    echo "   cd /workspaces/dify.git/web"
    echo "   pnpm dev"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "检查结果汇总"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "通过: ${GREEN}$check_passed${NC} 项"
echo -e "失败: ${RED}$check_failed${NC} 项"
echo ""

if [ $check_failed -eq 0 ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}✅ 环境准备完成！可以开始搭建知识库系统${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📚 下一步："
    echo "   ./scripts/stress-test/setup_kb_step1.sh"
    exit 0
else
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${YELLOW}⚠️  请先解决上述问题，然后重新运行此脚本${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
fi
