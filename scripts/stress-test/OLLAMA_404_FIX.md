# 解决 Ollama 模型验证错误

## 问题

```
API request failed with status code 404: 
{"error":"model \"Qwen3\" not found, try pulling it first"}
```

## 原因

Dify 在验证 Ollama 连接时，会尝试访问一个默认模型（如 `Qwen3`）来测试连接。如果您的 Ollama 中没有这个模型，验证就会失败。

## 解决方案

### 方案 1：拉取轻量级模型（推荐 ✅）

在**宿主机**上执行以下命令：

```bash
# 选项 A: 快速中文模型（最推荐）
ollama pull qwen2.5:3b

# 选项 B: 快速英文模型
ollama pull llama3.2:3b

# 选项 C: 超小模型
ollama pull phi3:mini
```

拉取完成后：
1. 在 Dify Web UI 中重新配置 Ollama
2. Base URL: `http://172.17.0.1:11434`
3. 点击 **Validate** - 应该会成功 ✅
4. 点击 **Save**

### 方案 2：跳过验证（临时方案）

某些版本的 Dify 可能允许您：

1. 忽略验证错误，直接点击 **Save**
2. 配置可能已经保存
3. 在创建工作流时，直接选择 `deepseek-r1:latest`

### 方案 3：使用 API 直接配置

如果 Web UI 验证一直失败，可以通过 API 配置：

```python
import requests

# Dify API 端点
api_url = "http://localhost:5001/console/api/workspaces/current/model-providers/ollama"
api_key = "your-console-api-key"  # 从 Dify 后台获取

# 配置 Ollama
response = requests.post(
    api_url,
    headers={
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    },
    json={
        "credentials": {
            "api_base": "http://172.17.0.1:11434",
            "api_key": "ollama"
        }
    }
)

print(response.json())
```

## 验证配置

运行测试脚本确认一切正常：

```bash
cd /workspaces/dify.git
uv run --project api python scripts/stress-test/fix_ollama_config.py
```

## 推荐的模型设置

根据您的使用场景选择：

### 快速对话（推荐新手）

```bash
ollama pull qwen2.5:3b     # 1.9GB - 快速中文
ollama pull llama3.2:3b    # 2.0GB - 快速英文
```

### 平衡性能

```bash
ollama pull qwen2.5:7b     # 4.7GB - 更好的中文
ollama pull llama3.2:7b    # 4.7GB - 更好的英文
```

### 复杂推理

```bash
ollama pull deepseek-r1    # 5.2GB - 您已有
ollama pull qwen2.5:14b    # 9.0GB - 高级中文
```

## 完整步骤示例

### 在宿主机上：

```bash
# 1. 拉取快速模型
ollama pull qwen2.5:3b

# 2. 验证模型已下载
ollama list

# 输出应该包含：
# qwen2.5:3b         1.9 GB
# deepseek-r1:latest 4.9 GB
```

### 在 Dify Web UI 中：

1. 打开 `http://localhost:3000`
2. 登录后进入 **Settings**
3. 选择 **Model Provider**
4. 找到 **Ollama** 部分
5. 填写配置：
   ```
   Base URL: http://172.17.0.1:11434
   API Key: ollama
   ```
6. 点击 **Validate** - 现在应该显示 ✅ 成功
7. 点击 **Save**

### 创建工作流：

1. 点击 **Studio** → **Create App**
2. 选择 **Chatflow** 或 **Workflow**
3. 添加 **LLM** 节点
4. 在模型选择器中：
   - Provider: **Ollama**
   - Model: 选择 `qwen2.5:3b` 或 `deepseek-r1:latest`
5. 配置提示词
6. 测试运行 ✅

## 常见问题

### Q: 为什么 Dify 要验证特定模型？

A: Dify 使用一些知名模型名称来测试 Ollama 连接是否正常工作。这是一个健康检查机制。

### Q: 我不想下载额外的模型，可以用现有的吗？

A: 可以！尝试：
1. 忽略验证错误
2. 强制保存配置
3. 在工作流中直接使用 `deepseek-r1:latest`

但这取决于您的 Dify 版本是否允许。

### Q: 哪个模型最适合我？

A: 取决于您的需求：
- **快速测试/开发**: `qwen2.5:3b` 或 `llama3.2:3b`
- **中文应用**: `qwen2.5:7b`
- **复杂推理**: `deepseek-r1` (您已有)
- **英文应用**: `llama3.2:7b`

### Q: 模型拉取很慢怎么办？

A: 在宿主机上配置代理：
```bash
export HTTPS_PROXY=http://your-proxy:port
ollama pull qwen2.5:3b
```

## 下一步

配置成功后：

```bash
# 1. 验证所有模型
ollama list

# 2. 启动 Dify API
cd /workspaces/dify.git/api
uv run gunicorn --bind 0.0.0.0:5001 --workers 4 --worker-class gevent app:app

# 3. 打开 Web UI
# http://localhost:3000

# 4. 创建第一个工作流！
```

## 需要帮助？

运行诊断工具：
```bash
cd /workspaces/dify.git
uv run --project api python scripts/stress-test/fix_ollama_config.py
```

---

**提示**: 拉取 `qwen2.5:3b` 只需要 1.9GB，下载很快，强烈推荐！
