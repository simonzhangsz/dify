# 🌐 如何访问 Dify Web UI

## 问题说明

您在 **Dev Container** 中运行服务，不能直接通过 `localhost` 访问。需要使用 VS Code 的端口转发功能。

## ✅ 正确的访问方式

### 方法 1：VS Code 端口转发（推荐）

1. **打开 VS Code 的端口面板**：
   - 点击 VS Code 底部的 **PORTS** 标签
   - 或使用快捷键：`Ctrl+Shift+P` (Windows/Linux) 或 `Cmd+Shift+P` (Mac)
   - 搜索并选择：**Ports: Focus on Ports View**

2. **查看已转发的端口**：
   VS Code 应该已自动转发端口 3000 和 5001，您会看到类似这样的列表：
   ```
   Port    | Local Address           | Running Process
   --------|-------------------------|----------------
   3000    | localhost:3000          | Next.js
   5001    | localhost:5001          | Python/Flask
   ```

3. **访问服务**：
   - **Web UI**: 点击端口 3000 旁边的 **🌐 图标** 或 **Open in Browser**
   - **API**: 点击端口 5001 旁边的 **🌐 图标**
   
   或者在浏览器直接访问：
   - Web UI: `http://localhost:3000`
   - API: `http://localhost:5001`

### 方法 2：使用 VS Code 内置浏览器

在 VS Code 终端运行：
```bash
# 这会在 VS Code 内打开浏览器
echo "http://localhost:3000"
```

然后：
- 按住 `Ctrl` (Windows/Linux) 或 `Cmd` (Mac)
- 点击链接，VS Code 会在内置浏览器中打开

### 方法 3：如果端口没有自动转发

如果端口列表中没有显示 3000 或 5001：

1. 在 **PORTS** 面板中，点击 **Forward a Port** 按钮
2. 输入端口号：`3000`
3. 再次点击 **Forward a Port**，输入：`5001`
4. 端口转发成功后，点击 🌐 图标打开

## 🔍 故障排查

### 检查 1：端口是否在监听

在 VS Code 终端运行：
```bash
./scripts/stress-test/manage_servers.sh status
```

应该显示：
- ✓ API 服务器运行中 (PID: xxxxx)
- ✓ Web UI 运行中 (PID: xxxxx)

### 检查 2：容器内测试

在 VS Code 终端运行：
```bash
# 测试 API
curl http://localhost:5001/console/api/setup

# 测试 Web UI
curl -I http://localhost:3000
```

如果返回数据，说明服务运行正常，问题在于端口转发。

### 检查 3：查看 VS Code 端口转发日志

1. 打开 **PORTS** 面板
2. 查看每个端口的 **Visibility** 列：
   - 应该显示为 **Public** 或 **Private**
   - 如果显示 **Not Forwarded**，手动转发该端口

### 常见错误

#### ❌ 错误：在宿主机浏览器输入 `localhost:3000` 无响应

**原因**：服务运行在 Dev Container 中，宿主机不能直接访问。

**解决**：使用 VS Code 的端口转发功能（见上方方法 1）。

#### ❌ 错误：端口转发显示但无法访问

**原因**：可能是端口冲突或转发配置问题。

**解决**：
1. 在 PORTS 面板中，右键点击端口
2. 选择 **Stop Forwarding Port**
3. 再次点击 **Forward a Port** 重新转发

#### ❌ 错误：页面显示 "Failed to fetch"

**原因**：Web UI 可以访问，但无法连接到 API 服务器。

**解决**：
1. 确保端口 5001 也已转发
2. 检查 `.env` 配置中的 API 地址

## 📱 移动设备或远程访问

如果您想从其他设备访问（如手机、其他电脑）：

1. 在 **PORTS** 面板中，右键点击端口
2. 选择 **Port Visibility** → **Public**
3. VS Code 会生成一个公网可访问的 URL（类似 `https://xxx.vscode-cdn.net`）
4. 使用该 URL 在任何设备访问

**⚠️ 安全提示**：Public 端口会暴露在互联网上，测试完成后记得改回 Private 或停止转发。

## 🎯 快速访问脚本

我已创建一个便捷脚本，运行后直接显示访问链接：

```bash
cd /workspaces/dify.git
./scripts/stress-test/show_access_urls.sh
```

## 📝 推荐工作流

1. **启动服务**：
   ```bash
   ./scripts/stress-test/manage_servers.sh start
   ```

2. **等待启动完成**（约 10 秒）

3. **打开 VS Code 的 PORTS 面板**

4. **点击端口 3000 的 🌐 图标**

5. **开始使用 Dify！** 🎉

---

## ✅ 总结

| 位置 | 如何访问 |
|------|----------|
| **Dev Container 内** | `curl http://localhost:3000` ✅ |
| **宿主机浏览器** | 通过 VS Code PORTS 面板的端口转发 ✅ |
| **直接访问 localhost** | ❌ 不可行（服务在容器内） |

**记住**：在 Dev Container 环境中，必须通过 **VS Code 的端口转发** 来访问服务！
