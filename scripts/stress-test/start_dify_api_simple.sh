#!/bin/bash

# 启动 Dify API 的简化脚本

echo "🚀 启动 Dify API 服务器..."
echo ""

cd /workspaces/dify.git/api

# 确保存储配置存在
if ! grep -q "STORAGE_TYPE" .env; then
    echo "📝 添加存储配置..."
    echo -e "\n# Storage Configuration\nSTORAGE_TYPE=local\nSTORAGE_LOCAL_PATH=storage" >> .env
fi

# 创建存储目录
mkdir -p storage

echo "✅ 配置已准备"
echo ""
echo "启动服务器（开发模式）..."
echo "访问地址: http://localhost:5001"
echo "按 Ctrl+C 停止服务"
echo ""

# 使用 Flask 开发服务器启动
uv run python -c "from app import app; app.run(host='0.0.0.0', port=5001, debug=False, threaded=True)"
