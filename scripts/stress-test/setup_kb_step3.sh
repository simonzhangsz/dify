#!/bin/bash

# 企业知识库问答系统 - 步骤 3: 创建知识库

echo "╔════════════════════════════════════════════════════════╗"
echo "║   步骤 3: 创建企业知识库                               ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

echo "现在我们要创建不同类别的知识库。"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 推荐的知识库分类"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. 产品知识库"
echo "   - 产品手册、功能说明、使用指南"
echo "   - 适合: 客户咨询、产品支持"
echo ""
echo "2. 技术知识库"
echo "   - 技术文档、API 文档、故障排查"
echo "   - 适合: 技术支持、开发人员"
echo ""
echo "3. HR 知识库"
echo "   - 入职指南、假期政策、福利制度"
echo "   - 适合: 员工自助服务"
echo ""
echo "4. 财务知识库"
echo "   - 报销流程、财务制度、发票管理"
echo "   - 适合: 财务相关问题"
echo ""
echo "5. 公司政策库"
echo "   - 管理制度、安全规范、流程文档"
echo "   - 适合: 合规性问题"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 创建知识库步骤 (在 Web UI 中操作)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. 在 Dify Web UI 中:"
echo "   http://localhost:3000"
echo ""
echo "2. 导航到 'Knowledge' 页面"
echo ""
echo "3. 点击 '+ Create Knowledge Base' (创建知识库)"
echo ""
echo "4. 填写知识库信息:"
echo "   • Name: 产品知识库"
echo "   • Description: 产品相关文档和常见问题"
echo "   • Indexing Mode: High Quality (高质量索引)"
echo "   • Retrieval Setting:"
echo "     - Vector Search (向量搜索)"
echo "     - Top K: 5"
echo "     - Score Threshold: 0.7"
echo ""
echo "5. 点击 'Create'"
echo ""
echo "6. 上传文档:"
echo "   - 支持: PDF, Word, TXT, Markdown"
echo "   - 可以批量上传"
echo "   - 或者直接输入文本"
echo ""
echo "7. 等待文档处理完成"
echo ""
echo "8. 重复步骤 3-7 创建其他知识库"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 示例文档准备"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "是否生成示例文档? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "生成示例文档到 /tmp/kb_samples/..."
    
    mkdir -p /tmp/kb_samples/product
    mkdir -p /tmp/kb_samples/technical
    mkdir -p /tmp/kb_samples/hr
    
    # 产品知识库示例
    cat > /tmp/kb_samples/product/product_intro.md << 'EOF'
# 产品介绍

## 产品概述

我们的产品是一个企业级智能问答系统，帮助企业构建内部知识库。

## 核心功能

### 1. 智能问答
- 自然语言理解
- 精准答案检索
- 上下文记忆
- 多轮对话

### 2. 知识管理
- 文档上传和管理
- 自动分类和标签
- 版本控制
- 权限管理

### 3. 多渠道集成
- Web 界面
- API 接口
- 企业微信
- 钉钉

## 常见问题

### Q: 支持哪些文档格式？
A: 支持 PDF、Word、Excel、TXT、Markdown 等常见格式。

### Q: 如何提高答案准确率？
A: 
1. 提供高质量的知识库文档
2. 使用清晰的文档结构
3. 定期更新知识库
4. 收集用户反馈优化

### Q: 是否支持多语言？
A: 是的，支持中文、英文等多种语言。

### Q: 数据安全如何保证？
A: 所有数据存储在本地服务器，支持加密传输和访问控制。
EOF

    # 技术知识库示例
    cat > /tmp/kb_samples/technical/api_guide.md << 'EOF'
# API 使用指南

## API 基础

### 接口地址
```
生产环境: https://api.example.com/v1
测试环境: https://test-api.example.com/v1
```

### 认证方式
使用 Bearer Token 认证：
```
Authorization: Bearer YOUR_API_KEY
```

## 问答接口

### 发送问题
```bash
POST /v1/chat-messages

Headers:
  Authorization: Bearer YOUR_API_KEY
  Content-Type: application/json

Body:
{
  "query": "如何重置密码？",
  "user": "user-123",
  "response_mode": "blocking"
}

Response:
{
  "answer": "重置密码步骤：1. 点击登录页的'忘记密码'...",
  "conversation_id": "conv-abc123",
  "message_id": "msg-def456"
}
```

### 错误代码

| 代码 | 说明 | 解决方案 |
|-----|------|---------|
| 401 | 认证失败 | 检查 API Key 是否正确 |
| 429 | 请求过快 | 降低请求频率 |
| 500 | 服务器错误 | 联系技术支持 |

## 常见问题

### Q: API 有请求限制吗？
A: 是的，默认每分钟 60 次请求。如需提高限制，请联系我们。

### Q: 如何处理长时间响应？
A: 使用流式响应模式 `response_mode: "streaming"`。

### Q: 支持批量查询吗？
A: 支持，使用 `/v1/batch-query` 端点。
EOF

    # HR 知识库示例
    cat > /tmp/kb_samples/hr/leave_policy.md << 'EOF'
# 休假制度

## 年假政策

### 年假天数

| 工龄 | 年假天数 |
|------|---------|
| 1年以下 | 0 天 |
| 1-5年 | 5 天 |
| 5-10年 | 10 天 |
| 10年以上 | 15 天 |

### 申请流程

1. **提前申请**
   - 至少提前 3 天申请
   - 节假日需提前 7 天

2. **在线申请**
   - 登录 HR 系统
   - 选择"请假申请"
   - 填写请假信息
   - 提交审批

3. **审批流程**
   - 直属上级审批
   - HR 确认
   - 系统自动通知

4. **假期使用规则**
   - 当年有效，不可跨年
   - 可以按半天或整天请假
   - 国家法定节假日不计入年假

## 病假政策

### 病假天数
- 凭医院证明
- 每年累计不超过 90 天
- 超过 3 天需提供诊断证明

### 病假工资
- 前 3 天: 100% 工资
- 4-30 天: 80% 工资
- 31-90 天: 60% 工资

## 其他假期

### 婚假
- 3 天带薪假期
- 需提供结婚证复印件

### 产假
- 98 天基础产假
- 难产增加 15 天
- 多胞胎每多一个婴儿增加 15 天

### 陪产假
- 15 天陪产假
- 需在配偶产假期间使用

## 常见问题

### Q: 年假可以一次性休完吗？
A: 可以，但建议分段使用，以免影响工作。

### Q: 年假没用完怎么办？
A: 年底未使用的年假将清零，建议提前规划。

### Q: 病假需要什么证明？
A: 需要医院开具的病假条或诊断证明。

### Q: 如何查询剩余年假？
A: 登录 HR 系统，在"我的假期"中查看。
EOF

    echo ""
    echo "✅ 示例文档已生成！"
    echo ""
    echo "📁 文档位置:"
    echo "   /tmp/kb_samples/product/product_intro.md"
    echo "   /tmp/kb_samples/technical/api_guide.md"
    echo "   /tmp/kb_samples/hr/leave_policy.md"
    echo ""
    echo "💡 在 Dify Web UI 中上传这些文档到对应的知识库"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 知识库创建完成后，继续下一步:"
echo "   ./scripts/stress-test/setup_kb_step4.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
