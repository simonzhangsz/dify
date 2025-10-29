# Ollama 集成指南

## ✅ 配置完成

Ollama 已成功配置并可从 Dify Dev Container 访问！

## 📋 配置摘要

- **Ollama 主机**: `http://172.17.0.1:11434`
- **连接状态**: ✅ 正常
- **可用模型**: `deepseek-r1:latest`
- **配置位置**: `/workspaces/dify.git/api/.env`

## 🚀 在 Dify 中使用 Ollama

### 方法 1: 通过 Web UI 配置（推荐）

1. **启动 Dify 服务**:
   ```bash
   cd /workspaces/dify.git/api
   uv run gunicorn \
     --bind 0.0.0.0:5001 \
     --workers 4 \
     --worker-class gevent \
     --timeout 120 \
     app:app
   ```

2. **打开 Web UI**: `http://localhost:3000`

3. **配置 Ollama 提供商**:
   - 进入 **Settings** → **Model Provider**
   - 找到 **Ollama** 部分
   - 配置：
     ```
     Base URL: http://172.17.0.1:11434
     API Key: ollama  (任意值，Ollama 不需要真实的 API key)
     ```
   - 点击 **Validate** 测试连接
   - 点击 **Save** 保存

4. **创建工作流使用 Ollama**:
   - 创建新的 Chatflow 或 Workflow
   - 添加 LLM 节点
   - 在 Model 选择器中选择 **Ollama** 提供商
   - 选择模型：`deepseek-r1:latest`
   - 配置提示词并测试

### 方法 2: 通过 API 使用

```python
import requests

# Dify API 端点
DIFY_API = "http://localhost:5001/v1"
API_KEY = "your-api-key-here"  # 从 Dify Web UI 获取

# 创建使用 Ollama 的对话
response = requests.post(
    f"{DIFY_API}/chat-messages",
    headers={
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    },
    json={
        "inputs": {},
        "query": "你好，请介绍一下自己",
        "response_mode": "blocking",
        "user": "test-user"
    }
)

print(response.json()["answer"])
```

## 🔧 验证配置

运行快速测试确认一切正常：

```bash
cd /workspaces/dify.git
uv run --project api python scripts/stress-test/test_ollama_quick.py
```

应该看到：
```
✅ OLLAMA IS READY!
```

## 📦 安装更多模型

在**宿主机**上拉取更多 Ollama 模型：

```bash
# 轻量级模型（推荐用于开发）
ollama pull qwen2.5:3b        # 1.9GB - 中文优化
ollama pull llama3.2:3b       # 2.0GB - 英文优化
ollama pull phi3:mini         # 2.3GB - 微软

# 中等模型
ollama pull qwen2.5:7b        # 4.7GB - 更强中文能力
ollama pull llama3.2:7b       # 4.7GB - 更强英文能力
ollama pull mistral:7b        # 4.1GB - 平衡性能

# 查看已安装模型
ollama list
```

拉取新模型后，它们会自动在 Dify 的模型选择器中出现。

## 🐛 故障排查

### 问题 1: 连接失败

**症状**: `Connection refused` 或 `timeout`

**解决方案**:

1. 确认 Ollama 在宿主机运行：
   ```bash
   # 在宿主机执行
   curl 127.0.0.1:11434/api/tags
   ```

2. 确认 Ollama 监听所有网络接口：
   ```bash
   # 在宿主机执行
   sudo netstat -tlnp | grep 11434
   # 应该看到 0.0.0.0:11434，而不是 127.0.0.1:11434
   ```

3. 如果只监听 localhost，重新配置 Ollama：
   ```bash
   # 在宿主机执行
   export OLLAMA_HOST=0.0.0.0:11434
   ollama serve
   ```

### 问题 2: 模型未显示

**症状**: Dify UI 中看不到 Ollama 模型

**解决方案**:

1. 验证模型已下载：
   ```bash
   # 在宿主机执行
   ollama list
   ```

2. 测试从 Dev Container 访问：
   ```bash
   curl http://172.17.0.1:11434/api/tags
   ```

3. 重新保存 Dify 中的 Ollama 配置

### 问题 3: 生成超时

**症状**: 请求超时或响应很慢

**解决方案**:

1. **使用更小的模型**:
   ```bash
   ollama pull qwen2.5:3b  # 替代 deepseek-r1
   ```

2. **增加 Dify API 超时**:
   ```bash
   # 编辑 gunicorn 启动命令
   uv run gunicorn \
     --bind 0.0.0.0:5001 \
     --workers 4 \
     --worker-class gevent \
     --timeout 300 \  # 增加到 5 分钟
     app:app
   ```

3. **调整模型参数**（在 Dify UI 中）:
   - 降低 Max Tokens (如 512 或更少)
   - 增加 Temperature 可能加快生成速度

## 🎯 推荐工作流示例

### 1. 简单问答

```
开始 → Ollama LLM → 结束
```

**LLM 节点配置**:
- 模型: `qwen2.5:3b` (快速)
- 系统提示: "你是一个有帮助的助手"
- 输入: `{{user_question}}`

### 2. 带知识库的问答

```
开始 → 知识检索 → Ollama LLM → 结束
```

**优势**: 本地模型 + 私有知识库 = 完全私有化部署

### 3. 多步推理

```
开始 → Ollama (分析) → 条件分支 → Ollama (详细回答) → 结束
```

**DeepSeek-R1 特别适合**: 复杂推理任务

## 📊 性能对比

| 模型 | 大小 | 速度 | 适用场景 |
|-----|------|------|---------|
| qwen2.5:3b | 1.9GB | ⚡⚡⚡ | 快速问答、对话 |
| llama3.2:7b | 4.7GB | ⚡⚡ | 通用任务 |
| deepseek-r1:8b | 5.2GB | ⚡ | 复杂推理 |

## 🔐 安全优势

使用 Ollama 的好处：

✅ **完全本地运行** - 数据不离开您的服务器  
✅ **无 API 费用** - 无需支付 OpenAI/Claude 费用  
✅ **无速率限制** - 只受硬件限制  
✅ **隐私保护** - 敏感数据完全私有  

## 📚 相关资源

- [Ollama 官方文档](https://github.com/ollama/ollama)
- [Ollama 模型库](https://ollama.com/library)
- [Dify 文档](https://docs.dify.ai/)
- [DeepSeek-R1 模型介绍](https://github.com/deepseek-ai/DeepSeek-R1)

## ✅ 下一步

1. **启动 Dify API 服务器**
2. **在 Web UI 中配置 Ollama**
3. **创建第一个使用 Ollama 的工作流**
4. **体验完全本地化的 LLM 应用！**

---

**需要帮助？** 运行测试脚本诊断问题：
```bash
uv run --project api python scripts/stress-test/test_ollama_quick.py
```
