#!/bin/bash

# 企业知识库问答系统 - 完整搭建指南

echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║     企业知识库问答系统 - 完整搭建指南                  ║"
echo "║                                                        ║"
echo "║     基于 Dify + Ollama 本地模型                        ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

echo "这个向导将帮助您一步步搭建完整的企业知识库问答系统。"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 搭建流程概览"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✓ 步骤 0: 环境检查 (自动)"
echo "  步骤 1: 启动 Dify 服务"
echo "  步骤 2: 配置 Web UI"
echo "  步骤 3: 创建知识库"
echo "  步骤 4: 创建智能问答工作流"
echo "  步骤 5: 测试和发布"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 步骤 0: 环境检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 运行环境检查
if ! ./scripts/stress-test/check_kb_environment.sh; then
    echo ""
    echo "❌ 环境检查失败，请先解决问题"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 开始搭建"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "准备好了吗？按 Enter 继续，或 Ctrl+C 退出 " 

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 搭建步骤说明"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "由于需要在 Web UI 中操作，建议："
echo ""
echo "1. 打开多个终端窗口："
echo "   • 终端 1: 运行 API 服务器"
echo "   • 终端 2: 运行 Web UI"
echo "   • 终端 3: 执行搭建脚本"
echo ""
echo "2. 按照每个步骤的指引操作"
echo ""
echo "3. 每完成一步，运行下一步脚本"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 快速开始"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "运行以下命令开始每个步骤："
echo ""
echo "步骤 1 - 启动 Dify 服务:"
echo "  ./scripts/stress-test/setup_kb_step1.sh"
echo ""
echo "步骤 2 - 配置 Web UI:"
echo "  ./scripts/stress-test/setup_kb_step2.sh"
echo ""
echo "步骤 3 - 创建知识库:"
echo "  ./scripts/stress-test/setup_kb_step3.sh"
echo ""
echo "步骤 4 - 创建工作流:"
echo "  ./scripts/stress-test/setup_kb_step4.sh"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 参考文档"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "• 完整实现指南: scripts/stress-test/ENTERPRISE_KB_SYSTEM.md"
echo "• 应用场景合集: scripts/stress-test/USE_CASES.md"
echo "• Ollama 配置: scripts/stress-test/OLLAMA_SETUP.md"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 提示"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "• 整个搭建过程约需 30-60 分钟"
echo "• 建议先用示例文档测试，熟悉后再导入真实文档"
echo "• 每个步骤都可以反复调整优化"
echo "• 遇到问题可以查看详细文档或重新运行检查脚本"
echo ""

read -p "现在开始步骤 1？(y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🚀 启动步骤 1..."
    echo ""
    ./scripts/stress-test/setup_kb_step1.sh
else
    echo ""
    echo "好的！当准备好时，运行："
    echo "  ./scripts/stress-test/setup_kb_step1.sh"
    echo ""
fi
