#!/bin/bash

set -e

echo "🚀 Starting Dify with Ollama Support"
echo "===================================="
echo ""

# 检查 Ollama 连接
echo "🔍 Checking Ollama connection..."
if curl -s http://172.17.0.1:11434/api/tags > /dev/null 2>&1; then
    echo "✅ Ollama is accessible"
    MODELS=$(curl -s http://172.17.0.1:11434/api/tags | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
    echo "   Available models:"
    echo "$MODELS" | while read -r model; do
        echo "   - $model"
    done
else
    echo "❌ Ollama is not accessible"
    echo ""
    echo "⚠️  Please start Ollama on your host machine:"
    echo "   export OLLAMA_HOST=0.0.0.0:11434"
    echo "   ollama serve"
    echo ""
    exit 1
fi

echo ""
echo "🔧 Configuration:"
echo "   Ollama URL: http://172.17.0.1:11434"
echo "   Config file: /workspaces/dify.git/api/.env"
echo ""

# 询问是否启动 API 服务器
read -p "🚀 Start Dify API server now? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Starting Dify API server with Gunicorn..."
    echo "   Workers: 4"
    echo "   Worker class: gevent"
    echo "   Timeout: 120s"
    echo ""
    echo "💡 Access points:"
    echo "   API: http://localhost:5001"
    echo "   Web UI: http://localhost:3000"
    echo "   Docs: http://localhost:5001/console/api/swagger"
    echo ""
    echo "🛑 Press Ctrl+C to stop"
    echo ""
    
    cd /workspaces/dify.git/api
    uv run gunicorn \
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
    echo "💡 To start manually:"
    echo "   cd /workspaces/dify.git/api"
    echo "   uv run gunicorn --bind 0.0.0.0:5001 --workers 4 --worker-class gevent app:app"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Start the API server (see command above)"
    echo "   2. Open http://localhost:3000"
    echo "   3. Go to Settings → Model Provider → Ollama"
    echo "   4. Enter Base URL: http://172.17.0.1:11434"
    echo "   5. Save and create workflows!"
fi
