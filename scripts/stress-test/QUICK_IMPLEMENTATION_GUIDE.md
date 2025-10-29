# 🚀 企业知识库问答系统 - 快速实施卡片

## ✅ 准备完成

- ✅ 示例文档已生成（3 个知识库，共 13KB）
- ✅ Dify 在宿主机运行（端口 8081）
- ✅ 实施向导已准备

---

## 📋 实施清单（30 分钟完成）

### ☐ 第 1 步：访问 Dify（2 分钟）

```
在宿主机浏览器打开：http://localhost:8081
```

**首次访问**：
- 创建管理员账户
- 邮箱、用户名、密码

---

### ☐ 第 2 步：配置 Ollama（5 分钟）

1. 点击右上角头像 → **Settings** → **Model Provider**
2. 找到 **Ollama** → 点击 **Setup**
3. 填写：
   ```
   Base URL: http://172.17.0.1:11434
   （或 http://宿主机IP:11434）
   
   API Key: ollama
   ```
4. 点击 **Validate** ✅
5. 点击 **Save**

**验证成功标志**：看到 qwen2.5:3b 和 deepseek-r1:latest 模型

---

### ☐ 第 3 步：创建知识库（10 分钟）

#### 知识库 1：产品知识库

1. 左侧菜单 → **Knowledge** → **Create Knowledge Base**
2. 填写：
   - Name: `产品知识库`
   - Description: `产品介绍、功能说明、价格信息`
   - Indexing Mode: `High Quality`
3. 点击 **Create**
4. 上传文档：
   - 点击 **Upload**
   - 选择：`/tmp/enterprise_kb_samples/product/产品介绍.md`
   - 等待处理（约 2 分钟）

#### 知识库 2：技术支持库

重复上述步骤：
- Name: `技术支持库`
- 文件：`/tmp/enterprise_kb_samples/technical/常见技术问题.md`

#### 知识库 3：HR 知识库

重复上述步骤：
- Name: `HR知识库`
- 文件：`/tmp/enterprise_kb_samples/hr/员工手册.md`

---

### ☐ 第 4 步：创建问答应用（10 分钟）

1. 左侧菜单 → **Studio** → **Create Application**
2. 选择 **Chatflow**
3. 填写：
   - Name: `企业知识库问答助手`
   - Description: `基于企业知识库的智能问答系统`
4. 点击 **Create**

#### 简化版工作流（推荐新手）

**节点配置**：

```
Start (输入)
  ↓
  变量：user_question
  ↓
Knowledge Retrieval (知识检索)
  ↓
  知识库：选择全部 3 个知识库
  Query: {{#sys.query#}}
  Top K: 3
  Score: 0.7
  ↓
LLM (生成答案)
  ↓
  Model: Ollama / qwen2.5:3b
  System Prompt:
    你是企业知识助手。基于以下知识库内容准确回答用户问题。
    如果知识库中没有相关信息，礼貌地告知用户。
    
  Context: {{#knowledge.result#}}
  Query: {{#sys.query#}}
  Temperature: 0.7
  ↓
Answer (输出)
```

**连接节点**：
1. 拖拽 **Start** 到画布
2. 添加 **Knowledge Retrieval** 节点，连接 Start
3. 添加 **LLM** 节点，连接 Knowledge Retrieval
4. 添加 **Answer** 节点，连接 LLM

---

### ☐ 第 5 步：测试应用（3 分钟）

点击右侧 **Run** 按钮，输入测试问题：

**产品问题**：
```
产品有哪些核心功能？
基础版多少钱？
```

**技术问题**：
```
忘记密码怎么办？
文档上传失败的原因？
```

**HR 问题**：
```
年假有多少天？
工作时间怎么安排？
```

**检查**：
- ✅ 回答准确
- ✅ 引用知识库内容
- ✅ 语气友好

---

### ☐ 第 6 步：发布应用（2 分钟）

1. 点击右上角 **Publish**
2. 选择发布方式：
   - **Web App**：独立网页
   - **API**：接口集成
   - **Embed**：嵌入网站
3. 复制访问链接

---

## 🎯 进阶版工作流（可选）

如果需要更智能的意图识别和路由：

```
Start
  ↓
LLM (意图识别)
  ↓
  Model: qwen2.5:3b
  Prompt: 分析问题，返回类别：product/technical/hr
  Temp: 0.3
  ↓
Condition (条件分支)
  ↓
  ├─ product → 产品知识库 → LLM → Answer
  ├─ technical → 技术知识库 → LLM → Answer
  └─ hr → HR知识库 → LLM → Answer
```

详细配置见：`scripts/stress-test/ENTERPRISE_KB_SYSTEM.md`

---

## 📊 测试问题库

### 产品类
- [ ] 这个产品的主要功能是什么？
- [ ] 专业版和企业版有什么区别？
- [ ] 支持手机使用吗？
- [ ] 可以试用吗？
- [ ] 数据存储在哪里？

### 技术类
- [ ] 如何重置密码？
- [ ] 账号被锁定了怎么办？
- [ ] 上传文件大小限制是多少？
- [ ] 搜索不到内容怎么办？
- [ ] 如何设置双因素认证？

### HR 类
- [ ] 试用期多长时间？
- [ ] 年假怎么计算？
- [ ] 加班有补偿吗？
- [ ] 如何申请请假？
- [ ] 五险一金比例是多少？

---

## 🔧 故障排查

### 问题 1：Ollama 验证失败

**检查**：
```bash
# 在宿主机运行
curl http://localhost:11434/api/tags

# 或在 Dev Container 运行
curl http://172.17.0.1:11434/api/tags
```

**解决**：
- 确保 Ollama 运行并监听 0.0.0.0:11434
- 检查防火墙设置
- 尝试不同的 IP 地址

### 问题 2：知识库上传失败

**原因**：
- 文件格式不支持
- 文件过大
- 存储空间不足

**解决**：
- 使用 Markdown 或 TXT 格式
- 分批上传
- 检查 Docker 卷空间

### 问题 3：回答不准确

**优化**：
- 调整 Top K（3-10）
- 调整 Score Threshold（0.6-0.8）
- 优化提示词
- 添加更多训练文档

### 问题 4：响应慢

**原因**：
- 模型推理慢
- 知识库太大
- 网络延迟

**解决**：
- 使用更小的模型（qwen2.5:3b）
- 减少 Top K 数量
- 优化知识库索引

---

## 📚 相关文档

- **完整实现指南**：`scripts/stress-test/ENTERPRISE_KB_SYSTEM.md`
- **Ollama 配置**：`scripts/stress-test/OLLAMA_SETUP.md`
- **应用场景**：`scripts/stress-test/USE_CASES.md`
- **Docker 部署**：`scripts/stress-test/DOCKER_CONTAINER_VS_HOST.md`

---

## 💡 下一步扩展

完成基础版后，可以：

1. **添加更多知识库**
   - 财务制度
   - 公司政策
   - 培训资料

2. **增强功能**
   - 多轮对话记忆
   - 用户反馈收集
   - 答案质量评分

3. **集成到现有系统**
   - 企业微信机器人
   - 钉钉机器人
   - 内部门户网站

4. **数据分析**
   - 问题热点分析
   - 用户满意度统计
   - 知识库优化建议

---

## ✅ 完成标志

当您完成所有步骤后，应该能够：

- ✅ 访问 Dify Web UI (http://localhost:8081)
- ✅ Ollama 模型配置成功
- ✅ 3 个知识库创建完成
- ✅ 问答应用正常运行
- ✅ 测试问题回答准确

---

## 🎉 恭喜！

您已经成功构建了一个**企业级知识库问答系统**！

这个系统可以：
- 24/7 自动回答员工问题
- 减少人工客服工作量
- 加速新员工培训
- 提升信息获取效率

**预计节省**：
- 客服时间：70%
- 培训成本：50%
- 信息检索时间：80%

继续优化和扩展，让它更好地服务您的企业！🚀
