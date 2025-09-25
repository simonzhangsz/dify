"""Entity definitions for Agent V2 Node."""

from collections.abc import Sequence

from pydantic import Field

from core.prompt.entities.advanced_prompt_entities import MemoryConfig
from core.tools.entities.tool_entities import ToolSelector
from core.workflow.nodes.base import BaseNodeData
from core.workflow.nodes.llm.entities import (
    ContextConfig,
    LLMNodeChatModelMessage,
    LLMNodeCompletionModelPromptTemplate,
    ModelConfig,
    PromptConfig,
    VisionConfig,
)


class AgentV2NodeData(BaseNodeData):
    """
    Agent V2 Node Data - maintains same structure as LLM Node with additional tools configuration.

    This node data structure is designed to be compatible with LLM Node while adding
    agent-specific functionality through the tools parameter.
    """

    # LLM configuration (same as LLMNodeData)
    model: ModelConfig
    prompt_template: Sequence[LLMNodeChatModelMessage] | LLMNodeCompletionModelPromptTemplate
    prompt_config: PromptConfig = Field(default_factory=PromptConfig)
    memory: MemoryConfig | None = None
    context: ContextConfig
    vision: VisionConfig = Field(default_factory=VisionConfig)

    # Agent-specific configuration
    tools: Sequence[ToolSelector] = Field(default_factory=list)
