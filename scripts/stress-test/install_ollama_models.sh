#!/bin/bash

# 此脚本应在宿主机上运行，用于拉取推荐的 Ollama 模型
# 这将解决 Dify 的模型验证问题

echo "╔════════════════════════════════════════════════════════╗"
echo "║   Ollama 模型快速安装脚本                              ║"
echo "║   用于解决 Dify 模型验证 404 错误                      ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# 检查 Ollama 是否安装
if ! command -v ollama &> /dev/null; then
    echo "❌ Ollama 未安装"
    echo ""
    echo "请先安装 Ollama："
    echo "curl -fsSL https://ollama.com/install.sh | sh"
    exit 1
fi

echo "✅ Ollama 已安装"
echo ""

# 检查 Ollama 服务是否运行
if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "⚠️  Ollama 服务未运行"
    echo ""
    echo "请启动 Ollama："
    echo "export OLLAMA_HOST=0.0.0.0:11434"
    echo "ollama serve"
    exit 1
fi

echo "✅ Ollama 服务运行中"
echo ""

# 显示当前已安装的模型
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 当前已安装的模型："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ollama list
echo ""

# 检查是否有快速模型
has_quick_model=false
if ollama list | grep -q "qwen2.5:3b\|llama3.2:3b\|phi3:mini"; then
    has_quick_model=true
fi

if [ "$has_quick_model" = true ]; then
    echo "✅ 您已有快速模型，Dify 验证应该可以通过"
    echo ""
    echo "💡 如果仍有问题，请在 Dify Web UI 中："
    echo "   1. 进入 Settings → Model Provider → Ollama"
    echo "   2. Base URL: http://172.17.0.1:11434"
    echo "   3. 点击 Validate 和 Save"
    exit 0
fi

# 推荐模型
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 推荐模型（选择一个或多个）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "快速模型（适合日常对话）："
echo "  1) qwen2.5:3b    - 1.9GB - ⭐ 推荐：快速中文"
echo "  2) llama3.2:3b   - 2.0GB - 快速英文"
echo "  3) phi3:mini     - 2.3GB - 微软小模型"
echo ""
echo "中等模型（更好的质量）："
echo "  4) qwen2.5:7b    - 4.7GB - 更好的中文"
echo "  5) llama3.2:7b   - 4.7GB - 更好的英文"
echo ""
echo "  0) 退出"
echo ""

read -p "请输入选项（可以输入多个，用空格分隔，如: 1 2）: " choices

if [ "$choices" = "0" ]; then
    echo "退出安装"
    exit 0
fi

# 模型映射
declare -A models
models[1]="qwen2.5:3b"
models[2]="llama3.2:3b"
models[3]="phi3:mini"
models[4]="qwen2.5:7b"
models[5]="llama3.2:7b"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📥 开始下载模型"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 拉取选择的模型
for choice in $choices; do
    if [ -n "${models[$choice]}" ]; then
        model="${models[$choice]}"
        echo "⏬ 拉取 $model ..."
        ollama pull "$model"
        
        if [ $? -eq 0 ]; then
            echo "✅ $model 下载成功"
        else
            echo "❌ $model 下载失败"
        fi
        echo ""
    else
        echo "⚠️  无效选项: $choice"
    fi
done

# 显示最终结果
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 安装完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 当前所有模型："
ollama list
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 下一步："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. 在 Dev Container 中验证连接："
echo "   curl http://172.17.0.1:11434/api/tags"
echo ""
echo "2. 在 Dify Web UI 中配置："
echo "   - 打开: http://localhost:3000"
echo "   - 进入: Settings → Model Provider → Ollama"
echo "   - Base URL: http://172.17.0.1:11434"
echo "   - API Key: ollama"
echo "   - 点击 Validate (应该成功 ✅)"
echo "   - 点击 Save"
echo ""
echo "3. 创建工作流并选择 Ollama 模型！"
echo ""
