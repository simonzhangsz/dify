#!/bin/bash

# 企业知识库问答系统 - 步骤 4: 创建智能问答工作流

echo "╔════════════════════════════════════════════════════════╗"
echo "║   步骤 4: 创建智能问答工作流                           ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

echo "现在我们要创建一个完整的智能问答工作流！"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 工作流架构"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "用户问题"
echo "    ↓"
echo "意图识别 (qwen2.5:3b - 快速分类)"
echo "    ↓"
echo "知识库检索 (向量搜索)"
echo "    ↓"
echo "相关性判断"
echo "    ├─ 有答案 → 生成回复 (deepseek-r1 - 深度理解)"
echo "    └─ 无答案 → 友好提示"
echo "    ↓"
echo "返回结果"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 在 Dify Web UI 中创建工作流"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. 打开 Dify Web UI: http://localhost:3000"
echo ""
echo "2. 点击 'Studio' → 'Create App'"
echo ""
echo "3. 选择 'Chatflow' (支持多轮对话)"
echo ""
echo "4. 输入应用信息:"
echo "   • Name: 企业知识库问答系统"
echo "   • Description: 基于知识库的智能问答助手"
echo "   • Icon: 选择一个图标"
echo ""
echo "5. 点击 'Create'"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 配置工作流节点"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "=== 节点 1: 开始节点 ==="
echo "已自动创建，配置输入变量："
echo "  • user_question (文本, 必填)"
echo ""
echo "=== 节点 2: LLM 节点 (意图识别) ==="
echo "点击 '+' → 添加 'LLM' 节点"
echo ""
echo "配置:"
echo "  • 节点名称: intent_classifier"
echo "  • Model:"
echo "    - Provider: Ollama"
echo "    - Model: qwen2.5:3b"
echo "  • System Prompt:"
cat << 'EOF'

你是企业知识库的意图分类助手。
分析用户问题，返回以下类别之一：
- product: 产品相关问题
- technical: 技术支持
- hr: 人力资源
- finance: 财务相关
- policy: 公司政策
- general: 通用问题

只返回类别名称，不要其他内容。

示例：
问题: 如何使用API？
回答: technical

问题: 年假有多少天？
回答: hr

EOF
echo "  • User Prompt: {{sys.query}}"
echo "  • Temperature: 0.3 (低温度确保稳定)"
echo "  • Max Tokens: 50"
echo ""
echo "=== 节点 3: 知识检索节点 ==="
echo "点击 '+' → 添加 'Knowledge Retrieval' 节点"
echo ""
echo "配置:"
echo "  • 节点名称: knowledge_search"
echo "  • Knowledge Bases: 选择您创建的所有知识库"
echo "  • Query Variable: {{sys.query}}"
echo "  • Retrieval Mode: Semantic Search (语义搜索)"
echo "  • Top K: 5"
echo "  • Score Threshold: 0.7"
echo "  • Reranking: Enable (启用重排序)"
echo ""
echo "=== 节点 4: 条件节点 ==="
echo "点击 '+' → 添加 'IF/ELSE' 节点"
echo ""
echo "配置:"
echo "  • 节点名称: check_relevance"
echo "  • Condition:"
echo "    - IF: knowledge_search.result is not empty"
echo "    - AND: knowledge_search.score > 0.7"
echo ""
echo "=== 节点 5a: LLM 节点 (生成答案) - IF 分支 ==="
echo "在 IF 分支添加 'LLM' 节点"
echo ""
echo "配置:"
echo "  • 节点名称: generate_answer"
echo "  • Model:"
echo "    - Provider: Ollama"
echo "    - Model: deepseek-r1:latest"
echo "  • System Prompt:"
cat << 'EOF'

你是专业的企业知识助手。基于以下知识库内容回答用户问题。

知识库内容：
{{knowledge_search.result}}

要求：
1. 回答要准确，严格基于知识库内容
2. 如果知识库内容不足，明确说明
3. 引用具体的来源文档
4. 语气专业、友好
5. 如有必要，提供后续建议或相关问题

回答格式：
[清晰的答案]

📚 参考来源：
- [文档名称]
EOF
echo "  • User Prompt: {{sys.query}}"
echo "  • Temperature: 0.7"
echo "  • Max Tokens: 1024"
echo ""
echo "=== 节点 5b: LLM 节点 (兜底回复) - ELSE 分支 ==="
echo "在 ELSE 分支添加 'LLM' 节点"
echo ""
echo "配置:"
echo "  • 节点名称: fallback_response"
echo "  • Model:"
echo "    - Provider: Ollama"
echo "    - Model: qwen2.5:3b"
echo "  • System Prompt:"
cat << 'EOF'

知识库中未找到相关信息来回答用户的问题。

请礼貌地告知用户：
1. 当前知识库中没有相关信息
2. 建议用户尝试其他方式：
   - 换一种方式提问
   - 联系人工客服
   - 查看帮助文档
3. 询问是否需要转接人工服务

保持友好和专业的语气。
EOF
echo "  • User Prompt: {{sys.query}}"
echo "  • Temperature: 0.7"
echo "  • Max Tokens: 256"
echo ""
echo "=== 节点 6: 结束节点 ==="
echo "两个分支都连接到 'End' 节点"
echo ""
echo "配置输出:"
echo "  • answer: {{generate_answer.text}} 或 {{fallback_response.text}}"
echo "  • intent: {{intent_classifier.text}}"
echo "  • sources: {{knowledge_search.sources}}"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔗 连接节点"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "拖动节点输出点到下一个节点的输入点："
echo ""
echo "Start → intent_classifier → knowledge_search → check_relevance"
echo "                                                      ↓"
echo "                                           ┌──────────┴──────────┐"
echo "                                           ↓                     ↓"
echo "                                    generate_answer      fallback_response"
echo "                                           ↓                     ↓"
echo "                                           └──────────┬──────────┘"
echo "                                                      ↓"
echo "                                                    End"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 测试工作流"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. 点击右上角的 'Run' 或 'Test' 按钮"
echo ""
echo "2. 在测试面板输入测试问题:"
echo "   • \"产品有哪些核心功能？\""
echo "   • \"如何申请年假？\""
echo "   • \"API 接口地址是什么？\""
echo ""
echo "3. 查看每个节点的输出"
echo ""
echo "4. 检查最终答案是否准确"
echo ""
echo "5. 调整参数优化效果:"
echo "   • 相似度阈值 (0.6-0.8)"
echo "   • Top K 值 (3-10)"
echo "   • 提示词内容"
echo "   • 模型温度"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 发布应用"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "测试通过后："
echo ""
echo "1. 点击 'Publish' 按钮"
echo ""
echo "2. 选择发布渠道:"
echo "   • Web App (网页应用)"
echo "   • API (API 接口)"
echo "   • Embed (嵌入代码)"
echo ""
echo "3. 获取访问方式:"
echo "   • Web URL: 分享给用户直接使用"
echo "   • API Key: 用于程序集成"
echo "   • Embed Code: 嵌入到网站"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 恭喜！企业知识库问答系统搭建完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📚 后续优化建议:"
echo ""
echo "1. 添加更多知识库文档"
echo "2. 收集用户反馈优化提示词"
echo "3. 调整检索参数提高准确率"
echo "4. 添加用户反馈机制"
echo "5. 监控使用情况和问题"
echo ""
echo "📖 详细文档:"
echo "   ENTERPRISE_KB_SYSTEM.md - 完整实现指南"
echo "   USE_CASES.md - 更多应用场景"
echo ""
echo "💡 需要帮助?"
echo "   查看文档或提问获取支持"
echo ""
