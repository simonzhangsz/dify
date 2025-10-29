# Ollama 配置完成 ✅

恭喜！您已成功配置 Dify 使用本地 Ollama 模型。

## 快速开始

### 1. 验证配置

```bash
cd /workspaces/dify.git
uv run --project api python scripts/stress-test/test_ollama_quick.py
```

应该看到：
```
✅ OLLAMA IS READY!
```

### 2. 启动 Dify

```bash
./scripts/stress-test/start_dify_with_ollama.sh
```

或手动启动：
```bash
cd /workspaces/dify.git/api
uv run gunicorn --bind 0.0.0.0:5001 --workers 4 --worker-class gevent app:app
```

### 3. 配置 Web UI

1. 打开 `http://localhost:3000`
2. 进入 **Settings** → **Model Provider** → **Ollama**
3. 配置：
   - **Base URL**: `http://172.17.0.1:11434`
   - **API Key**: `ollama` (任意值)
4. 点击 **Save**

### 4. 创建工作流

1. 创建新的 Chatflow/Workflow
2. 添加 LLM 节点
3. 选择 **Ollama** 提供商
4. 选择模型：`deepseek-r1:latest`
5. 开始使用！

## 配置详情

- **Ollama Host**: `http://172.17.0.1:11434`
- **当前模型**: `deepseek-r1:latest`
- **配置文件**: `/workspaces/dify.git/api/.env`

## 添加更多模型

在宿主机上运行：

```bash
# 快速轻量级模型
ollama pull qwen2.5:3b
ollama pull llama3.2:3b

# 查看所有模型
ollama list
```

## 故障排查

### 连接问题

确保 Ollama 在宿主机上监听所有接口：

```bash
# 在宿主机执行
export OLLAMA_HOST=0.0.0.0:11434
ollama serve
```

验证连接：
```bash
# 在 Dev Container 中
curl http://172.17.0.1:11434/api/tags
```

## 有用的脚本

- **快速测试**: `scripts/stress-test/test_ollama_quick.py`
- **完整测试**: `scripts/stress-test/test_ollama_integration.py`
- **配置脚本**: `scripts/stress-test/setup/configure_ollama.py`
- **启动脚本**: `scripts/stress-test/start_dify_with_ollama.sh`

## 详细文档

查看完整设置指南：
```bash
cat scripts/stress-test/OLLAMA_SETUP.md
```

## 问题排查

运行诊断：
```bash
uv run --project api python scripts/stress-test/test_ollama_quick.py
```

---

**享受使用完全本地化的 LLM！** 🎉
