# 🎉 Dify 企业知识库系统 - 快速启动指南

## ✅ 环境已准备完毕！

我已经为您完成了所有配置：
- ✅ Ollama 已配置（qwen2.5:3b + deepseek-r1）
- ✅ PostgreSQL 已启动
- ✅ Redis 已启动
- ✅ 数据库已初始化
- ✅ 存储配置已添加

## 🚀 现在开始！

### 步骤 1: 启动 API 服务器

**在当前终端运行**（保持运行，不要关闭）：

```bash
cd /workspaces/dify.git/api
uv run python -c "from app import app; app.run(host='0.0.0.0', port=5001, debug=False, threaded=True)"
```

看到以下输出表示成功：
```
 * Running on http://127.0.0.1:5001
```

**⚠️  重要：保持这个终端运行！**

---

### 步骤 2: 启动 Web UI

**打开新终端 2** 并运行：

```bash
cd /workspaces/dify.git/web
pnpm dev
```

看到以下输出表示成功：
```
✓ Ready in Xms
○ Local:   http://localhost:3000 (或 3001)
```

**⚠️  保持这个终端也运行！**

**提示**: 如果端口 3000 被占用，Next.js 会自动使用 3001，这是正常的！

---

### 步骤 3: 打开浏览器配置

1. **打开浏览器访问**: `http://localhost:3000` 或 `http://localhost:3001`（查看终端输出的实际端口）

2. **首次访问会要求设置管理员账户**:
   - Email: 您的邮箱
   - 用户名: admin
   - 密码: 设置一个密码

3. **配置 Ollama 模型**:
   - 登录后，点击右上角头像
   - 进入 **Settings** → **Model Provider**
   - 找到 **Ollama** 部分
   - 点击 **Configure** 或 **Set API Key**
   - 输入配置:
     ```
     Base URL: http://172.17.0.1:11434
     API Key: ollama
     ```
   - 点击 **Validate** (应该显示成功 ✅)
   - 点击 **Save**

---

### 步骤 4: 创建知识库

**打开新终端 3** 来生成示例文档：

```bash
cd /workspaces/dify.git
./scripts/stress-test/setup_kb_step3.sh
```

按 `y` 生成示例文档，然后：

1. 在 Web UI 中，点击左侧 **Knowledge** 菜单
2. 点击 **Create Knowledge Base**
3. 填写:
   - Name: `产品知识库`
   - Description: `产品相关文档和FAQ`
   - Indexing Mode: `High Quality`
4. 点击 **Create**
5. 上传文档：`/tmp/kb_samples/product/product_intro.md`
6. 等待处理完成

重复创建其他知识库（技术、HR 等）

---

### 步骤 5: 创建工作流

在 Web UI 中：

1. 点击 **Studio** → **Create App**
2. 选择 **Chatflow**
3. 名称: `企业知识库问答系统`
4. 按照 `./scripts/stress-test/setup_kb_step4.sh` 中的指引配置节点

---

## 🔧 故障排查

### 问题 1: Web UI 显示 "Failed to fetch"

**原因**: API 服务器未运行

**解决**: 
- 检查终端 1 的 API 服务器是否仍在运行
- 如果停止了，重新启动它

### 问题 2: 模型验证失败

**原因**: Ollama 配置错误

**解决**:
```bash
# 测试 Ollama 连接
curl http://172.17.0.1:11434/api/tags

# 如果失败，在宿主机确保 Ollama 运行：
ollama serve
```

### 问题 3: 数据库连接错误

**原因**: PostgreSQL 或 Redis 未运行

**解决**:
```bash
# 检查服务状态
docker ps | grep -E "postgres|redis"

# 如果没有运行，启动它们
cd /workspaces/dify.git/docker
docker compose -f docker-compose.middleware.yaml up -d db redis
```

---

## 📚 下一步

完成配置后，您就拥有了一个完整的企业知识库问答系统！

**当前访问地址**: `http://localhost:3001` ⭐

**参考文档**:
- 完整实现指南: `scripts/stress-test/ENTERPRISE_KB_SYSTEM.md`
- 应用场景: `scripts/stress-test/USE_CASES.md`
- Ollama 配置: `scripts/stress-test/OLLAMA_SETUP.md`

---

## 💡 快速命令参考

```bash
# 服务器管理（推荐使用）
./scripts/stress-test/manage_servers.sh status   # 查看状态
./scripts/stress-test/manage_servers.sh start    # 启动所有
./scripts/stress-test/manage_servers.sh stop     # 停止所有
./scripts/stress-test/manage_servers.sh logs     # 查看日志

# 手动启动 API (终端 1)
cd /workspaces/dify.git/api && uv run python -c "from app import app; app.run(host='0.0.0.0', port=5001, debug=False, threaded=True)"

# 手动启动 Web UI (终端 2)
cd /workspaces/dify.git/web && pnpm dev

# 生成示例文档 (终端 3)
cd /workspaces/dify.git && ./scripts/stress-test/setup_kb_step3.sh

# 检查服务状态
docker ps | grep -E "postgres|redis"
curl http://localhost:5001/console/api/setup
curl http://172.17.0.1:11434/api/tags
```

**享受使用！** 🎉
