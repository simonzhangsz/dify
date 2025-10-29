# 🔧 Dify 空白页面问题解决方案

## 问题描述
在 VS Code Dev Container 中访问 Dify Web UI 时，浏览器显示空白页面。

## ✅ 完整解决步骤

### 步骤 1：确认服务正在运行

运行以下命令检查：
```bash
cd /workspaces/dify.git
./scripts/stress-test/manage_servers.sh status
```

应该显示：
```
✓ API 服务器运行中 (PID: xxxxx)
✓ Web UI 运行中 (PID: xxxxx)
```

如果未运行，启动服务：
```bash
./scripts/stress-test/manage_servers.sh start
```

---

### 步骤 2：通过 VS Code PORTS 面板访问（推荐）

这是**最可靠**的方式！

1. **打开 PORTS 面板**：
   - 点击 VS Code 底部状态栏的 **PORTS** 标签
   - 或按 `Ctrl+J`（Windows/Linux）/ `Cmd+J`（Mac）打开面板，然后选择 PORTS

2. **查看端口列表**：
   您应该看到：
   ```
   端口 | 本地地址 | 运行进程
   3000 | 127.0.0.1:3000 | next-server
   5001 | 127.0.0.1:5001 | python
   ```

3. **点击 🌐 图标**：
   - 在端口 3000 的行上
   - 点击右侧的 **Open in Browser** 图标（🌐）
   - Dify 会在您的默认浏览器中打开

4. **如果端口没有显示**：
   - 点击 **Forward a Port** 按钮
   - 输入 `3000` 然后回车
   - 现在应该能看到端口 3000
   - 点击 🌐 图标

---

### 步骤 3：使用正确的 URL

⚠️ **关键点**：在 Dev Container 中，服务监听地址很重要！

**检查 Web UI 实际监听的端口**：
```bash
tail -30 /tmp/dify_web_new.log | grep "Local:"
```

输出类似：
```
- Local:        http://localhost:3000
```

**然后通过 PORTS 面板访问该端口**（见步骤 2）

---

### 步骤 4：解决空白页面

如果通过 PORTS 面板打开后仍然空白：

#### 方法 A：等待并刷新
1. 等待 5-10 秒（首次加载需要编译）
2. 按 `F5` 或 `Ctrl+R`（Windows/Linux）/ `Cmd+R`（Mac）刷新页面
3. 查看浏览器开发者工具（F12）的 Console 和 Network 标签是否有错误

#### 方法 B：清除缓存
1. 在浏览器中按 `Ctrl+Shift+Delete`（Windows/Linux）/ `Cmd+Shift+Delete`（Mac）
2. 选择清除缓存和 Cookie
3. 重新通过 PORTS 面板打开

#### 方法 C：检查 API 连接
空白页面可能是因为前端无法连接到 API：

```bash
# 测试 API 服务器
curl http://localhost:5001/console/api/setup

# 应该返回 JSON：
# {"step":"finished","setup_at":"..."}
```

如果 API 不响应：
```bash
# 重启 API 服务器
pkill -f "python.*app\.run"
cd /workspaces/dify.git/api
nohup uv run python -c "from app import app; app.run(host='0.0.0.0', port=5001, debug=False, threaded=True)" > /tmp/dify_api.log 2>&1 &
```

#### 方法 D：检查浏览器控制台错误

1. 在浏览器中按 `F12` 打开开发者工具
2. 切换到 **Console** 标签
3. 查找红色错误信息，常见错误：

| 错误信息 | 原因 | 解决方法 |
|---------|------|----------|
| `Failed to fetch` | API 服务器未运行或端口未转发 | 确保端口 5001 也在 PORTS 面板中 |
| `CORS error` | 跨域问题 | 通过 PORTS 面板访问，不要直接用 IP |
| `net::ERR_CONNECTION_REFUSED` | 服务未启动 | 检查服务状态并重启 |
| 空白无错误 | 页面加载中或路由问题 | 等待或访问 `/install` 路径 |

---

### 步骤 5：尝试直接访问特定路径

如果首页空白，尝试直接访问这些路径：

通过 PORTS 面板打开端口 3000，然后在 URL 后面添加：

- `/install` - 安装/设置页面
- `/apps` - 应用列表
- `/signin` - 登录页面

例如：`http://localhost:3000/install`

---

### 步骤 6：检查 Web UI 日志

```bash
# 查看最新日志
tail -50 /tmp/dify_web_new.log

# 实时监控日志
tail -f /tmp/dify_web_new.log
```

正常的日志应该包含：
```
✓ Ready in X.Xs
GET /apps 200 in XXXms
```

如果看到错误或服务器不断重启，需要进一步排查。

---

## 🎯 推荐工作流（从头开始）

```bash
# 1. 停止所有服务
cd /workspaces/dify.git
./scripts/stress-test/manage_servers.sh stop

# 2. 启动所有服务
./scripts/stress-test/manage_servers.sh start

# 3. 等待启动完成（约 10 秒）
sleep 10

# 4. 检查状态
./scripts/stress-test/manage_servers.sh status

# 5. 打开 VS Code 的 PORTS 面板
# 6. 点击端口 3000 的 🌐 图标
# 7. 等待页面加载（5-10 秒）
# 8. 如果空白，刷新页面（F5）
```

---

## 🐛 高级调试

### 查看完整的网络请求

在浏览器开发者工具（F12）中：
1. 切换到 **Network** 标签
2. 刷新页面
3. 查看所有请求的状态码：
   - 200 OK ✅
   - 307 Redirect ✅（正常）
   - 404 Not Found ❌（路径错误）
   - 500 Server Error ❌（服务器错误）
   - Failed（红色）❌（无法连接）

### 测试端口转发

在 VS Code 终端运行：
```bash
# 从容器内访问（应该成功）
curl -I http://localhost:3000

# 如果失败，Web UI 没有运行
# 如果成功（返回 HTTP/1.1 307），端口转发可能有问题
```

### 完全重置

如果所有方法都失败：

```bash
# 1. 停止所有进程
pkill -f "pnpm dev"
pkill -f "next-server"
pkill -f "python.*app\.run"

# 2. 清除日志
rm -f /tmp/dify_*.log

# 3. 重启数据库
cd /workspaces/dify.git/docker
docker compose -f docker-compose.middleware.yaml restart db redis

# 4. 重新启动服务
cd /workspaces/dify.git
./scripts/stress-test/manage_servers.sh start

# 5. 通过 PORTS 面板访问
```

---

## ✅ 成功标志

当一切正常时，您应该看到：

1. **PORTS 面板**：
   - 端口 3000 和 5001 都显示为绿色或正常状态

2. **浏览器**：
   - Dify 登录页面或设置向导
   - 或者 "Install Dify" 页面

3. **开发者工具 Console**：
   - 没有红色错误
   - 可能有一些黄色警告（正常）

4. **Web UI 日志**：
   ```
   GET /apps 200 in XXXms
   GET /install 200 in XXXms
   ```

---

## 📞 快速帮助命令

```bash
# 显示访问信息
./scripts/stress-test/show_access_urls.sh

# 一键打开 Dify
./scripts/stress-test/open_dify.sh

# 查看服务状态
./scripts/stress-test/manage_servers.sh status

# 查看日志
./scripts/stress-test/manage_servers.sh logs

# 重启所有服务
./scripts/stress-test/manage_servers.sh restart
```

---

## 💡 关键要点

1. ⚠️ **必须通过 VS Code PORTS 面板访问**，不能直接在宿主机浏览器输入 localhost:3000
2. ⏱️ **首次加载需要时间**，请等待 5-10 秒
3. 🔄 **空白页面时刷新**（F5）通常能解决问题
4. 🔍 **使用浏览器开发者工具**（F12）查看具体错误
5. 📊 **检查 PORTS 面板**确保端口 3000 和 5001 都已转发

---

希望这能帮助您解决空白页面问题！如果还有问题，请检查浏览器开发者工具的 Console 和 Network 标签，并分享错误信息。
