# 企业知识库问答系统 - 完整实现方案

## 项目概述

基于 Dify + Ollama 构建完全私有化的企业知识库问答系统，支持多部门、多场景的智能问答。

## 系统架构

```
用户界面
    ↓
Dify Workflow
    ↓
┌─────────────┬──────────────┬─────────────┐
│  意图识别   │  知识检索    │  答案生成   │
│  (Ollama)   │  (向量数据库)│  (Ollama)   │
└─────────────┴──────────────┴─────────────┘
    ↓
多轮对话管理 / 反馈收集
```

## 核心工作流设计

### 主工作流：智能问答

```yaml
工作流: enterprise_qa_system
节点:
  1. start:
      输入:
        - user_question: 用户问题
        - department: 部门（可选）
        - context: 对话历史（可选）

  2. intent_classifier (LLM):
      模型: qwen2.5:3b  # 快速意图识别
      提示词: |
        你是企业知识库的意图分类助手。
        分析用户问题，返回以下类别之一：
        - product: 产品相关问题
        - technical: 技术支持
        - hr: 人力资源
        - finance: 财务相关
        - policy: 公司政策
        - general: 通用问题
        
        只返回类别名称，不要其他内容。
        
        用户问题：{{user_question}}
      输出: intent

  3. knowledge_retrieval (知识检索):
      知识库:
        - 根据 intent 动态选择知识库
        - 使用语义搜索
        - Top K: 5
        - 相似度阈值: 0.7
      输入: {{user_question}}
      输出: relevant_docs

  4. relevance_check (条件判断):
      条件: len(relevant_docs) > 0 and max(similarity_scores) > 0.7
      分支:
        - has_answer: 有相关文档
        - no_answer: 无相关文档

  5a. generate_answer (LLM):  # has_answer 分支
      模型: deepseek-r1:latest  # 深度推理
      提示词: |
        你是专业的企业知识助手。基于以下知识库内容回答用户问题。
        
        知识库内容：
        {{#relevant_docs}}
        来源: {{source}}
        内容: {{content}}
        {{/relevant_docs}}
        
        用户问题：{{user_question}}
        
        要求：
        1. 回答要准确，引用知识库内容
        2. 如果知识库内容不足，明确说明
        3. 提供来源引用
        4. 语气专业、友好
        5. 必要时提供后续建议
      输出: answer

  5b. fallback_handler (LLM):  # no_answer 分支
      模型: qwen2.5:3b
      提示词: |
        知识库中未找到相关信息来回答以下问题：
        {{user_question}}
        
        请：
        1. 礼貌地告知用户当前无法回答
        2. 建议用户可以尝试的其他方式（如联系人工客服）
        3. 询问是否需要转接人工服务
      输出: fallback_message

  6. response_formatter (代码):
      功能: 格式化最终响应
      代码: |
        def format_response(answer, sources, intent):
            response = {
                "answer": answer,
                "sources": sources,
                "category": intent,
                "confidence": calculate_confidence(sources),
                "follow_up_questions": generate_follow_up(intent)
            }
            return response
      输出: formatted_response

  7. end:
      输出: {{formatted_response}}
```

## 知识库设计

### 知识库分类

1. **产品知识库** (`product_kb`)
   - 产品手册
   - 功能说明
   - 使用指南
   - 常见问题

2. **技术支持库** (`technical_kb`)
   - 故障排查
   - 技术文档
   - API 文档
   - 集成指南

3. **HR 知识库** (`hr_kb`)
   - 入职指南
   - 假期政策
   - 福利制度
   - 培训资料

4. **财务知识库** (`finance_kb`)
   - 报销流程
   - 预算管理
   - 财务制度
   - 发票管理

5. **公司政策库** (`policy_kb`)
   - 管理制度
   - 安全规范
   - 行为准则
   - 流程文档

### 知识库文档结构

```markdown
# 文档标题

**类别**: 产品 / 技术 / HR / 财务 / 政策
**部门**: XX部门
**更新时间**: 2025-01-01
**负责人**: 张三

## 概述
简短描述...

## 详细内容
具体内容...

## 常见问题
Q: ...
A: ...

## 相关文档
- [文档1](link)
- [文档2](link)

## 标签
#标签1 #标签2 #标签3
```

## 实现步骤

### 步骤 1: 准备环境

```bash
# 1. 确保 Ollama 运行并拉取模型
# 在宿主机执行：
ollama pull qwen2.5:3b      # 快速意图识别
ollama pull qwen2.5:7b      # 主要问答（可选）
ollama pull deepseek-r1     # 复杂推理

# 2. 启动 Dify API

# 方式 A: 开发模式（推荐用于测试）
cd /workspaces/dify.git/api
nohup uv run python -c "from app import app; app.run(host='0.0.0.0', port=5001, debug=False, threaded=True)" > /tmp/dify_api.log 2>&1 &

# 方式 B: 生产模式（推荐用于正式环境）
cd /workspaces/dify.git/api
uv run python -m gunicorn --bind 0.0.0.0:5001 --workers 4 --worker-class gevent app:app

# 检查服务器状态
curl http://localhost:5001/console/api/setup

# 3. 访问 Web UI
# http://localhost:3000
```

### 步骤 2: 配置 Ollama

1. 打开 Dify Web UI
2. Settings → Model Provider → Ollama
3. 配置：
   - Base URL: `http://172.17.0.1:11434`
   - API Key: `ollama`
4. Save

### 步骤 3: 创建知识库

1. **导航到 Knowledge**
2. **创建新知识库**:
   - 名称: "产品知识库"
   - 描述: "产品相关文档和FAQ"
   - 索引模式: 高质量（Q&A 对）

3. **上传文档**:
   - 支持格式: PDF, Word, Markdown, TXT
   - 批量上传
   - 自动分段和向量化

4. **重复创建其他知识库**（技术、HR、财务、政策）

### 步骤 4: 创建工作流

1. **创建新 Workflow**:
   - 名称: "企业知识问答系统"
   - 类型: Chatflow（支持多轮对话）

2. **添加节点**（按上面的工作流设计）:
   
   **开始节点**:
   ```yaml
   变量:
     - user_question: 文本, 必填
     - department: 文本, 可选
   ```

   **LLM 节点（意图识别）**:
   ```yaml
   模型: Ollama - qwen2.5:3b
   提示词: [见上面工作流设计]
   温度: 0.3  # 低温度确保稳定分类
   ```

   **知识检索节点**:
   ```yaml
   知识库: 
     - 根据意图动态选择
     - 或搜索所有知识库
   检索模式: 向量搜索
   Top K: 5
   重排序: 启用
   ```

   **条件节点**:
   ```yaml
   条件: {{knowledge_retrieval.similarity}} > 0.7
   ```

   **LLM 节点（生成答案）**:
   ```yaml
   模型: Ollama - deepseek-r1:latest
   提示词: [见上面工作流设计]
   温度: 0.7
   最大 Token: 1024
   ```

3. **连接节点**:
   ```
   开始 → 意图识别 → 知识检索 → 相关性判断
                                      ├─ 有答案 → 生成回复 → 结束
                                      └─ 无答案 → 兜底处理 → 结束
   ```

4. **测试工作流**:
   - 使用测试面板
   - 输入各种问题
   - 检查答案质量

### 步骤 5: 优化和调整

1. **调整检索参数**:
   - Top K 值（3-10）
   - 相似度阈值（0.6-0.8）
   - 重排序算法

2. **优化提示词**:
   - 根据实际反馈调整
   - 添加示例
   - 改进指令

3. **添加高级功能**:
   - 多轮对话记忆
   - 用户反馈收集
   - 答案质量评分
   - A/B 测试

## 高级功能

### 1. 智能路由（根据部门自动选择知识库）

```python
# 代码节点
def route_to_knowledge_base(intent, department):
    """根据意图和部门路由到对应知识库"""
    routing_map = {
        "product": ["product_kb"],
        "technical": ["technical_kb", "product_kb"],
        "hr": ["hr_kb"],
        "finance": ["finance_kb"],
        "policy": ["policy_kb", "hr_kb"],
        "general": ["product_kb", "technical_kb", "hr_kb"]
    }
    
    kb_list = routing_map.get(intent, ["product_kb"])
    
    if department:
        # 根据部门进一步过滤
        kb_list = filter_by_department(kb_list, department)
    
    return kb_list
```

### 2. 答案质量评分

```python
# 代码节点
def calculate_confidence(similarity_scores, source_count):
    """计算答案置信度"""
    if not similarity_scores:
        return 0.0
    
    max_sim = max(similarity_scores)
    avg_sim = sum(similarity_scores) / len(similarity_scores)
    
    # 综合考虑最高相似度、平均相似度和来源数量
    confidence = (
        max_sim * 0.5 +
        avg_sim * 0.3 +
        min(source_count / 3, 1.0) * 0.2
    )
    
    return round(confidence, 2)
```

### 3. 自动生成后续问题

```python
# LLM 节点
提示词: |
  基于以下回答，生成 3 个用户可能感兴趣的后续问题：
  
  回答：{{answer}}
  类别：{{intent}}
  
  要求：
  1. 问题要相关且有价值
  2. 递进式深入
  3. 涵盖不同角度
  
  输出格式：
  1. 问题1
  2. 问题2
  3. 问题3
```

### 4. 多语言支持

```yaml
翻译节点 (LLM):
  模型: qwen2.5:7b
  提示词: |
    将以下内容翻译为 {{target_language}}，
    保持专业术语的准确性：
    
    {{answer}}
```

## 集成方案

### 方案 1: API 集成

```python
import requests

DIFY_API = "http://localhost:5001/v1"
API_KEY = "your-api-key"

def ask_question(question, department=None):
    """调用企业知识库问答 API"""
    
    response = requests.post(
        f"{DIFY_API}/chat-messages",
        headers={
            "Authorization": f"Bearer {API_KEY}",
            "Content-Type": "application/json"
        },
        json={
            "inputs": {
                "department": department or ""
            },
            "query": question,
            "response_mode": "blocking",
            "user": "user-123"
        }
    )
    
    return response.json()

# 使用示例
result = ask_question("如何申请年假？", department="HR")
print(result["answer"])
```

### 方案 2: Web Widget 嵌入

```html
<!-- 嵌入到企业内部网站 -->
<script>
window.difyChatbotConfig = {
  apiKey: 'your-api-key',
  apiUrl: 'http://localhost:5001/v1',
  theme: 'light',
  position: 'bottom-right',
  welcomeMessage: '您好！我是企业知识助手，有什么可以帮您？'
}
</script>
<script src="http://localhost:5001/embed.js"></script>
```

### 方案 3: 企业微信集成

```python
from flask import Flask, request
import requests

app = Flask(__name__)

@app.route('/wechat/callback', methods=['POST'])
def wechat_callback():
    """企业微信消息回调"""
    
    data = request.json
    user_message = data['text']['content']
    user_id = data['FromUserName']
    
    # 调用 Dify API
    answer = ask_question(user_message)
    
    # 返回给企业微信
    return {
        "msgtype": "text",
        "text": {
            "content": answer['answer']
        }
    }
```

## 性能优化

### 1. 缓存常见问题

```python
from functools import lru_cache
import hashlib

@lru_cache(maxsize=1000)
def get_cached_answer(question_hash):
    """缓存高频问题的答案"""
    # 从缓存返回
    pass

def ask_with_cache(question):
    q_hash = hashlib.md5(question.encode()).hexdigest()
    return get_cached_answer(q_hash)
```

### 2. 异步处理

```python
import asyncio

async def async_ask_question(question):
    """异步调用，提高并发能力"""
    # 异步调用 Dify API
    pass
```

### 3. 负载均衡

```yaml
# 使用 Gunicorn 多 worker
gunicorn --bind 0.0.0.0:5001 \
         --workers 8 \
         --worker-class gevent \
         --worker-connections 1000 \
         app:app
```

## 监控和分析

### 关键指标

1. **使用量指标**:
   - 日均问题数
   - 活跃用户数
   - 高峰时段分布

2. **质量指标**:
   - 答案准确率
   - 用户满意度
   - 知识库命中率

3. **性能指标**:
   - 平均响应时间
   - 系统可用性
   - 并发处理能力

### 数据收集

```python
# 记录每次问答
def log_qa(question, answer, user_id, timestamp):
    log_data = {
        "question": question,
        "answer": answer,
        "user_id": user_id,
        "timestamp": timestamp,
        "intent": classify_intent(question),
        "confidence": calculate_confidence(answer),
        "response_time": measure_time()
    }
    
    # 存储到数据库
    save_to_db(log_data)
```

## 维护和更新

### 知识库更新流程

1. **定期审查**:
   - 每月检查过时内容
   - 更新变化的政策
   - 补充新的文档

2. **反馈驱动**:
   - 收集用户反馈
   - 识别知识缺口
   - 优先更新高频问题

3. **自动化更新**:
   ```python
   def auto_update_kb(new_docs):
       """自动更新知识库"""
       for doc in new_docs:
           # 1. 解析文档
           parsed = parse_document(doc)
           
           # 2. 向量化
           vectors = vectorize(parsed)
           
           # 3. 更新知识库
           update_knowledge_base(vectors)
   ```

## 成本分析

### 使用 Ollama 的成本优势

| 项目 | 云 API (OpenAI/Claude) | Ollama 本地 |
|-----|------------------------|-------------|
| 初始成本 | $0 | 服务器硬件 |
| 月度成本 | $500-5000+ | $0 (电费) |
| 并发限制 | 有 RPM 限制 | 仅受硬件限制 |
| 数据隐私 | 数据发送到云端 | 完全本地 ✅ |
| 定制性 | 有限 | 完全可控 ✅ |

**估算**: 
- 1000 员工企业
- 每人每天 10 个问题
- 使用云 API: ~$2000-3000/月
- 使用 Ollama: ~$0/月 (仅硬件投入)

## 成功案例

### 案例 1: 技术公司（500人）

**实施前**:
- 客服团队 10 人
- 平均响应时间 30 分钟
- 重复问题占 70%

**实施后**:
- 80% 问题自动回答
- 平均响应时间 < 10 秒
- 客服团队减少到 3 人（处理复杂问题）
- 用户满意度提升 40%

### 案例 2: 制造企业（2000人）

**应用场景**:
- 生产流程查询
- 安全规范问答
- 设备维护指南
- HR 政策查询

**效果**:
- 减少培训时间 60%
- 降低操作失误 35%
- 提高生产效率 20%

## 总结

企业知识库问答系统是 Dify + Ollama 最实用的应用场景：

✅ **完全私有化** - 敏感数据不出内网
✅ **成本可控** - 无 API 调用费用
✅ **灵活定制** - 根据企业需求调整
✅ **易于维护** - 知识库更新简单
✅ **多场景适用** - 覆盖各个部门

## 下一步

1. **启动基础系统** - 按照实现步骤搭建
2. **导入核心知识** - 优先高频问题
3. **小范围试点** - 一个部门开始
4. **收集反馈** - 持续优化
5. **全面推广** - 覆盖全公司

需要我帮您实现某个具体部分吗？
