#!/bin/bash
# Dify 服务器管理脚本

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

API_LOG="/tmp/dify_api.log"
WEB_LOG="/tmp/dify_web.log"

# 显示使用说明
show_usage() {
    echo "用法: $0 {start|stop|restart|status|logs}"
    echo ""
    echo "命令:"
    echo "  start   - 启动 API 和 Web UI 服务器"
    echo "  stop    - 停止所有服务器"
    echo "  restart - 重启所有服务器"
    echo "  status  - 查看服务器状态"
    echo "  logs    - 查看服务器日志"
    exit 1
}

# 检查 API 服务器状态
check_api_status() {
    if pgrep -f "python.*app\.run.*5001" > /dev/null; then
        echo -e "${GREEN}✓${NC} API 服务器运行中 (PID: $(pgrep -f "python.*app\.run.*5001" | head -1))"
        return 0
    else
        echo -e "${RED}✗${NC} API 服务器未运行"
        return 1
    fi
}

# 检查 Web UI 状态
check_web_status() {
    if pgrep -f "pnpm dev" > /dev/null; then
        echo -e "${GREEN}✓${NC} Web UI 运行中 (PID: $(pgrep -f "pnpm dev" | head -1))"
        return 0
    else
        echo -e "${RED}✗${NC} Web UI 未运行"
        return 1
    fi
}

# 启动服务器
start_servers() {
    echo "🚀 启动 Dify 服务器..."
    echo ""
    
    # 检查是否已经运行
    if check_api_status 2>/dev/null; then
        echo -e "${YELLOW}⚠${NC}  API 服务器已在运行"
    else
        echo "启动 API 服务器..."
        cd /workspaces/dify.git/api
        nohup uv run python -c "from app import app; app.run(host='0.0.0.0', port=5001, debug=False, threaded=True)" > "$API_LOG" 2>&1 &
        sleep 3
        
        if check_api_status; then
            echo -e "  ${GREEN}✓${NC} API 服务器启动成功 (http://localhost:5001)"
        else
            echo -e "  ${RED}✗${NC} API 服务器启动失败，查看日志: tail -f $API_LOG"
            exit 1
        fi
    fi
    
    echo ""
    
    if check_web_status 2>/dev/null; then
        echo -e "${YELLOW}⚠${NC}  Web UI 已在运行"
    else
        echo "启动 Web UI..."
        cd /workspaces/dify.git/web
        nohup pnpm dev > "$WEB_LOG" 2>&1 &
        sleep 5
        
        if check_web_status; then
            # 从日志中提取实际端口
            PORT=$(grep -oP "Local:\s+http://localhost:\K\d+" "$WEB_LOG" | tail -1)
            echo -e "  ${GREEN}✓${NC} Web UI 启动成功 (http://localhost:${PORT:-3000})"
        else
            echo -e "  ${RED}✗${NC} Web UI 启动失败，查看日志: tail -f $WEB_LOG"
            exit 1
        fi
    fi
    
    echo ""
    echo -e "${GREEN}✓ 所有服务器已启动！${NC}"
    echo ""
    echo "访问 Web UI: http://localhost:3001"
    echo "API 端点: http://localhost:5001"
}

# 停止服务器
stop_servers() {
    echo "🛑 停止 Dify 服务器..."
    echo ""
    
    # 停止 API
    if pgrep -f "python.*app\.run.*5001" > /dev/null; then
        echo "停止 API 服务器..."
        pkill -f "python.*app\.run.*5001"
        sleep 2
        if ! pgrep -f "python.*app\.run.*5001" > /dev/null; then
            echo -e "  ${GREEN}✓${NC} API 服务器已停止"
        fi
    else
        echo -e "${YELLOW}⚠${NC}  API 服务器未运行"
    fi
    
    # 停止 Web UI
    if pgrep -f "pnpm dev" > /dev/null; then
        echo "停止 Web UI..."
        pkill -f "pnpm dev"
        sleep 2
        if ! pgrep -f "pnpm dev" > /dev/null; then
            echo -e "  ${GREEN}✓${NC} Web UI 已停止"
        fi
    else
        echo -e "${YELLOW}⚠${NC}  Web UI 未运行"
    fi
    
    echo ""
    echo -e "${GREEN}✓ 所有服务器已停止${NC}"
}

# 显示状态
show_status() {
    echo "📊 Dify 服务器状态"
    echo "===================="
    echo ""
    
    check_api_status || true
    
    if [ -f "$API_LOG" ]; then
        echo "   日志: $API_LOG"
        echo "   最近错误: $(grep -i error "$API_LOG" | tail -1 || echo '无')"
    fi
    
    echo ""
    
    check_web_status || true
    
    if [ -f "$WEB_LOG" ]; then
        echo "   日志: $WEB_LOG"
        PORT=$(grep -oP "Local:\s+http://localhost:\K\d+" "$WEB_LOG" | tail -1)
        [ -n "$PORT" ] && echo "   端口: $PORT"
    fi
    
    echo ""
    echo "数据库服务:"
    docker ps --filter "name=docker-db-1" --format "  {{.Names}}: {{.Status}}" 2>/dev/null || echo "  未运行"
    
    echo ""
    echo "Redis 服务:"
    docker ps --filter "name=docker-redis-1" --format "  {{.Names}}: {{.Status}}" 2>/dev/null || echo "  未运行"
}

# 查看日志
show_logs() {
    echo "📋 选择要查看的日志:"
    echo "1) API 日志"
    echo "2) Web UI 日志"
    echo "3) 同时查看两个日志"
    echo ""
    read -p "选择 (1-3): " choice
    
    case $choice in
        1)
            echo "查看 API 日志 (Ctrl+C 退出)..."
            tail -f "$API_LOG"
            ;;
        2)
            echo "查看 Web UI 日志 (Ctrl+C 退出)..."
            tail -f "$WEB_LOG"
            ;;
        3)
            echo "同时查看日志 (Ctrl+C 退出)..."
            tail -f "$API_LOG" "$WEB_LOG"
            ;;
        *)
            echo "无效选择"
            exit 1
            ;;
    esac
}

# 主逻辑
case "${1:-}" in
    start)
        start_servers
        ;;
    stop)
        stop_servers
        ;;
    restart)
        stop_servers
        sleep 2
        start_servers
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    *)
        show_usage
        ;;
esac
