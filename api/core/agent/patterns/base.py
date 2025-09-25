"""Base class for agent strategies."""

import json
import time
from abc import ABC, abstractmethod
from collections.abc import Generator
from typing import Any

from core.agent.entities import AgentLog, ExecutionContext
from core.file import File
from core.model_manager import ModelInstance
from core.model_runtime.entities import LLMResult, LLMResultChunk, PromptMessage
from core.model_runtime.entities.llm_entities import LLMUsage
from core.tools.__base.tool import Tool


class AgentStrategy(ABC):
    """Base class for agent execution strategies."""

    def __init__(
        self,
        model_instance: ModelInstance,
        tools: list[Tool],
        context: ExecutionContext,
        max_iterations: int = 10,
        workflow_call_depth: int = 0,
    ):
        """Initialize the agent strategy."""
        self.model_instance = model_instance
        self.tools = tools
        self.context = context
        self.max_iterations = min(max_iterations, 99)  # Cap at 99 iterations
        self.workflow_call_depth = workflow_call_depth
        self.files: list[File] = []  # Track files produced during execution

    @abstractmethod
    def run(
        self,
        prompt_messages: list[PromptMessage],
        model_parameters: dict[str, Any],
        stop: list[str] = [],
        stream: bool = True,
    ) -> Generator[LLMResultChunk | AgentLog, None, None]:
        """Execute the agent strategy."""
        pass

    def _accumulate_usage(self, total_usage: dict[str, Any], delta_usage: LLMUsage) -> None:
        """Accumulate LLM usage statistics."""
        if not total_usage.get("usage"):
            total_usage["usage"] = delta_usage
        else:
            current: LLMUsage = total_usage["usage"]
            current.prompt_tokens += delta_usage.prompt_tokens
            current.completion_tokens += delta_usage.completion_tokens
            current.total_tokens += delta_usage.total_tokens
            current.prompt_price += delta_usage.prompt_price
            current.completion_price += delta_usage.completion_price
            current.total_price += delta_usage.total_price

    def _extract_content(self, content: Any) -> str:
        """Extract text content from message content."""
        if isinstance(content, list):
            return "".join(c.data for c in content if hasattr(c, "data"))
        return str(content)

    def _has_tool_calls(self, chunk: LLMResultChunk) -> bool:
        """Check if chunk contains tool calls."""
        return bool(hasattr(chunk, "delta") and chunk.delta.message and chunk.delta.message.tool_calls)

    def _has_tool_calls_result(self, result: LLMResult) -> bool:
        """Check if result contains tool calls (non-streaming)."""
        return bool(hasattr(result, "message") and result.message and result.message.tool_calls)

    def _extract_tool_calls(self, chunk: LLMResultChunk) -> list[tuple[str, str, dict[str, Any]]]:
        """Extract tool calls from streaming chunk."""
        tool_calls: list[tuple[str, str, dict[str, Any]]] = []
        if chunk.delta.message and chunk.delta.message.tool_calls:
            for tool_call in chunk.delta.message.tool_calls:
                if tool_call.function:
                    try:
                        args = json.loads(tool_call.function.arguments) if tool_call.function.arguments else {}
                    except json.JSONDecodeError:
                        args = {}
                    tool_calls.append((tool_call.id or "", tool_call.function.name, args))
        return tool_calls

    def _extract_tool_calls_result(self, result: LLMResult) -> list[tuple[str, str, dict[str, Any]]]:
        """Extract tool calls from non-streaming result."""
        tool_calls = []
        if result.message and result.message.tool_calls:
            for tool_call in result.message.tool_calls:
                if tool_call.function:
                    try:
                        args = json.loads(tool_call.function.arguments) if tool_call.function.arguments else {}
                    except json.JSONDecodeError:
                        args = {}
                    tool_calls.append((tool_call.id or "", tool_call.function.name, args))
        return tool_calls

    def _create_log(
        self,
        label: str,
        status: AgentLog.LogStatus,
        data: dict[str, Any] | None = None,
        parent_id: str | None = None,
        extra_metadata: dict[AgentLog.LogMetadata, Any] | None = None,
    ) -> AgentLog:
        """Create a new AgentLog with standard metadata."""
        metadata = {
            AgentLog.LogMetadata.STARTED_AT: time.perf_counter(),
        }
        if extra_metadata:
            metadata.update(extra_metadata)

        return AgentLog(
            label=label,
            status=status,
            data=data or {},
            parent_id=parent_id,
            metadata=metadata,
        )

    def _finish_log(
        self,
        log: AgentLog,
        data: dict[str, Any] | None = None,
        usage: LLMUsage | None = None,
    ) -> AgentLog:
        """Finish an AgentLog by updating its status and metadata."""
        log.status = AgentLog.LogStatus.SUCCESS

        if data is not None:
            log.data = data

        # Calculate elapsed time
        started_at = log.metadata.get(AgentLog.LogMetadata.STARTED_AT, time.perf_counter())
        finished_at = time.perf_counter()

        # Update metadata
        log.metadata = {
            **log.metadata,
            AgentLog.LogMetadata.FINISHED_AT: finished_at,
            AgentLog.LogMetadata.ELAPSED_TIME: finished_at - started_at,
        }

        # Add usage information if provided
        if usage:
            log.metadata.update(
                {
                    AgentLog.LogMetadata.TOTAL_PRICE: usage.total_price,
                    AgentLog.LogMetadata.CURRENCY: usage.currency,
                    AgentLog.LogMetadata.TOTAL_TOKENS: usage.total_tokens,
                }
            )

        return log
