"""ReAct strategy implementation."""

import json
import re
from collections.abc import Generator
from typing import Any

from core.agent.entities import AgentLog, AgentResult, AgentScratchpadUnit
from core.agent.output_parser.cot_output_parser import CotAgentOutputParser
from core.agent.prompt.template import REACT_PROMPT_TEMPLATES
from core.file import File
from core.model_runtime.entities import (
    AssistantPromptMessage,
    LLMResultChunk,
    LLMResultChunkDelta,
    PromptMessage,
    SystemPromptMessage,
)
from core.tools.__base.tool import Tool
from core.tools.entities.tool_entities import ToolInvokeMessage
from core.tools.tool_engine import DifyWorkflowCallbackHandler, ToolEngine

from .base import AgentPattern


class ReActStrategy(AgentPattern):
    """ReAct strategy using reasoning and acting approach."""

    def run(
        self,
        prompt_messages: list[PromptMessage],
        model_parameters: dict[str, Any],
        stop: list[str] = [],
        stream: bool = True,
    ) -> Generator[LLMResultChunk | AgentLog, None, AgentResult]:
        """Execute the ReAct agent strategy."""
        # Initialize variables
        agent_scratchpad: list[AgentScratchpadUnit] = []
        iteration_step = 1
        max_iterations = self.max_iterations + 1
        llm_usage = {"usage": None}
        files: list[File] = []  # Track files produced by tools
        final_text: str = ""
        finish_reason: str | None = None

        # Add "Observation" to stop sequences
        if "Observation" not in stop:
            stop = stop.copy()
            stop.append("Observation")

        # Build initial prompt with tools
        current_messages = self._build_prompt_with_react_format(prompt_messages, agent_scratchpad)

        while iteration_step <= max_iterations:
            # Start round log
            round_log = self._create_log(
                label=f"ROUND {iteration_step}",
                status=AgentLog.LogStatus.START,
                data={},
            )
            yield round_log

            # Remove tools on last iteration to force final answer
            if iteration_step == max_iterations:
                current_messages = self._build_prompt_with_react_format(
                    prompt_messages, agent_scratchpad, include_tools=False
                )

            # Start model log
            model_log = self._create_log(
                label=f"{self.model_instance.model} Thought",
                status=AgentLog.LogStatus.START,
                data={},
                parent_id=round_log.id,
                extra_metadata={
                    AgentLog.LogMetadata.PROVIDER: self.model_instance.provider,
                },
            )
            yield model_log

            # Check for files to add to messages before invoking model
            messages_to_use = self._prepare_messages_with_files(current_messages)

            # Invoke model
            chunks = self.model_instance.invoke_llm(
                prompt_messages=messages_to_use,
                model_parameters=model_parameters,
                tools=[],
                stop=stop,
                stream=True,
                user=self.context.user_id or "",
                callbacks=[],
            )

            # Parse output
            usage_dict: dict[str, Any] = {}
            react_chunks = CotAgentOutputParser.handle_react_stream_output(chunks, usage_dict)

            # Initialize scratchpad unit
            scratchpad = AgentScratchpadUnit(
                agent_response="",
                thought="",
                action_str="",
                observation="",
                action=None,
            )

            # Process chunks
            for chunk in react_chunks:
                if isinstance(chunk, AgentScratchpadUnit.Action):
                    # Action detected
                    action_str = json.dumps(chunk.model_dump())
                    scratchpad.agent_response = (scratchpad.agent_response or "") + action_str
                    scratchpad.action_str = action_str
                    scratchpad.action = chunk

                    yield self._create_text_chunk(json.dumps(chunk.model_dump()), current_messages)
                else:
                    # Text chunk
                    chunk_text = str(chunk)
                    scratchpad.agent_response = (scratchpad.agent_response or "") + chunk_text
                    scratchpad.thought = (scratchpad.thought or "") + chunk_text

                    yield self._create_text_chunk(chunk_text, current_messages)

            # Update usage
            if usage_dict.get("usage") and llm_usage.get("usage"):
                self._accumulate_usage(llm_usage, usage_dict["usage"])
            elif usage_dict.get("usage"):
                llm_usage["usage"] = usage_dict["usage"]

            # Clean up thought
            scratchpad.thought = (scratchpad.thought or "").strip() or "I am thinking about how to help you"
            agent_scratchpad.append(scratchpad)

            # Finish model log
            yield self._finish_log(
                model_log,
                data={
                    "thought": scratchpad.thought,
                    "action": scratchpad.action_str if scratchpad.action else None,
                },
                usage=llm_usage.get("usage"),
            )

            # Check for final answer
            if not scratchpad.action or scratchpad.action.action_name.lower() == "final answer":
                # Extract final answer
                final_answer = None
                if scratchpad.action and scratchpad.action.action_input:
                    final_answer = scratchpad.action.action_input
                    if isinstance(final_answer, dict):
                        final_answer = json.dumps(final_answer, ensure_ascii=False)
                    final_text = str(final_answer)
                    yield self._create_text_chunk(final_text, current_messages)

                # Finish round log before breaking
                yield self._finish_log(
                    round_log,
                    data={
                        "thought": scratchpad.thought,
                        "action": scratchpad.action_str if scratchpad.action else None,
                        "final_answer": str(final_answer) if final_answer else None,
                    },
                    usage=llm_usage.get("usage"),
                )
                break

            # Execute tool
            observation = yield from self._handle_tool_call(scratchpad.action, current_messages, round_log)
            scratchpad.observation = observation

            # Add observation to scratchpad
            yield self._create_text_chunk(f"\nObservation: {observation}\n", current_messages)

            # Rebuild prompt with updated scratchpad
            current_messages = self._build_prompt_with_react_format(prompt_messages, agent_scratchpad)

            # Finish round log
            yield self._finish_log(
                round_log,
                data={
                    "thought": scratchpad.thought,
                    "action": scratchpad.action_str if scratchpad.action else None,
                    "observation": scratchpad.observation,
                },
                usage=llm_usage.get("usage"),
            )

            iteration_step += 1

        # Return final result
        from core.agent.entities import AgentResult

        return AgentResult(text=final_text, files=files, usage=llm_usage.get("usage"), finish_reason=finish_reason)

    def _build_prompt_with_react_format(
        self,
        original_messages: list[PromptMessage],
        agent_scratchpad: list[AgentScratchpadUnit],
        include_tools: bool = True,
    ) -> list[PromptMessage]:
        """Build prompt messages with ReAct format."""
        # Get ReAct prompt template for chat
        prompt_template = REACT_PROMPT_TEMPLATES["english"]["chat"]["prompt"]

        # Format tools
        tools_str = ""
        tool_names = []
        if include_tools and self.tools:
            tools_list = []
            for tool in self.tools:
                if hasattr(tool, "identity"):
                    tool_names.append(tool.identity.name)
                    tools_list.append(f"{tool.identity.name}: {tool.identity.description}")
            tools_str = "\n".join(tools_list)
            tool_names_str = ", ".join(f'"{name}"' for name in tool_names)
        else:
            tools_str = "No tools available"
            tool_names_str = ""

        # Format agent scratchpad
        scratchpad_str = ""
        if agent_scratchpad:
            scratchpad_parts: list[str] = []
            for unit in agent_scratchpad:
                if unit.thought:
                    scratchpad_parts.append(f"Thought: {unit.thought}")
                if unit.action_str:
                    scratchpad_parts.append(f"Action:\n```\n{unit.action_str}\n```")
                if unit.observation:
                    scratchpad_parts.append(f"Observation: {unit.observation}")
            scratchpad_str = "\n".join(scratchpad_parts)

        # Fill in the template with default values for unused placeholders
        prompt = prompt_template.replace("{{instruction}}", "")
        prompt = prompt.replace("{{tools}}", tools_str)
        prompt = prompt.replace("{{tool_names}}", tool_names_str)

        # Create new message list with system prompt and original messages
        messages: list[PromptMessage] = [SystemPromptMessage(content=prompt)]

        # Add original messages (keep user messages as is)
        messages.extend(original_messages)

        # If there's a scratchpad, append it to the last message
        if scratchpad_str:
            messages.append(AssistantPromptMessage(content=scratchpad_str))

        return messages

    def _create_text_chunk(self, text: str, prompt_messages: list[PromptMessage]) -> LLMResultChunk:
        """Create a text chunk for streaming."""
        return LLMResultChunk(
            model=self.model_instance.model,
            prompt_messages=prompt_messages,
            delta=LLMResultChunkDelta(
                index=0,
                message=AssistantPromptMessage(content=text),
                usage=None,
            ),
            system_fingerprint="",
        )

    def _handle_tool_call(
        self,
        action: AgentScratchpadUnit.Action,
        prompt_messages: list[PromptMessage],
        round_log: AgentLog,
    ) -> Generator[AgentLog, None, str]:
        """Handle tool call and return observation."""
        tool_name = action.action_name
        tool_args: dict[str, Any] | str = action.action_input

        # Start tool log
        tool_log = self._create_log(
            label=f"CALL {tool_name}",
            status=AgentLog.LogStatus.START,
            data={
                "input": {
                    "name": tool_name,
                    "args": tool_args,
                },
            },
            parent_id=round_log.id,
        )
        yield tool_log

        # Find tool instance
        tool_instance: Tool | None = None
        for tool in self.tools:
            if hasattr(tool, "identity") and tool.identity.name == tool_name:
                tool_instance = tool
                break

        if not tool_instance:
            # Finish tool log with error
            yield self._finish_log(
                tool_log,
                data={
                    **tool_log.data,
                    "error": f"Tool {tool_name} not found",
                },
            )
            return f"Tool {tool_name} not found"

        # Ensure tool_args is a dict
        if isinstance(tool_args, str):
            try:
                tool_args = json.loads(tool_args)
            except json.JSONDecodeError:
                tool_args = {"input": tool_args}
        elif not isinstance(tool_args, dict):
            tool_args = {"input": str(tool_args)}

        # Process tool_args to replace file references with actual File objects
        tool_args = self._replace_file_references(tool_args)

        # Invoke tool
        tool_response = ToolEngine().generic_invoke(
            tool=tool_instance,
            tool_parameters=tool_args,
            user_id=self.context.user_id or "",
            workflow_tool_callback=DifyWorkflowCallbackHandler(),
            workflow_call_depth=self.workflow_call_depth,
            app_id=self.context.app_id,
            conversation_id=self.context.conversation_id,
            message_id=self.context.message_id,
        )

        # Collect response and files
        response_content = ""
        tool_files: list[File] = []

        for response in tool_response:
            # Don't yield ToolInvokeMessage, just collect the content
            if hasattr(response, "type"):
                if response.type == ToolInvokeMessage.MessageType.TEXT:
                    response_content += str(response.message)
                elif response.type == ToolInvokeMessage.MessageType.FILE:
                    # Extract file from meta
                    if response.meta and "file" in response.meta:
                        file = response.meta["file"]
                        if isinstance(file, File):
                            # Check if file is for model or tool output
                            if response.meta.get("target") == "self":
                                # File is for model - add to files for next prompt
                                self.files.append(file)
                                response_content += f"File '{file.filename}' has been loaded into your context."
                            else:
                                # File is tool output
                                tool_files.append(file)

        # Track files produced by this tool
        self.files.extend(tool_files)

        # Finish tool log
        yield self._finish_log(
            tool_log,
            data={
                **tool_log.data,
                "output": response_content,
                "files": len(tool_files),
            },
        )

        return response_content or "Tool executed successfully"

    def _replace_file_references(self, tool_args: dict[str, Any]) -> dict[str, Any]:
        """
        Replace file references in tool arguments with actual File objects.

        Args:
            tool_args: Dictionary of tool arguments

        Returns:
            Updated tool arguments with file references replaced
        """
        # Process each argument in the dictionary
        processed_args = {}
        for key, value in tool_args.items():
            processed_args[key] = self._process_file_reference(value)
        return processed_args

    def _process_file_reference(self, data: Any) -> Any:
        """
        Recursively process data to replace file references.
        Supports both single file [File: file_id] and multiple files [Files: file_id1, file_id2, ...].

        Args:
            data: The data to process (can be dict, list, str, or other types)

        Returns:
            Processed data with file references replaced
        """
        single_file_pattern = re.compile(r"^\[File:\s*([^\]]+)\]$")
        multiple_files_pattern = re.compile(r"^\[Files:\s*([^\]]+)\]$")

        if isinstance(data, dict):
            # Process dictionary recursively
            return {key: self._process_file_reference(value) for key, value in data.items()}
        elif isinstance(data, list):
            # Process list recursively
            return [self._process_file_reference(item) for item in data]
        elif isinstance(data, str):
            # Check for single file pattern [File: file_id]
            single_match = single_file_pattern.match(data.strip())
            if single_match:
                file_id = single_match.group(1).strip()
                # Find the file in self.files
                for file in self.files:
                    if hasattr(file, "id") and str(file.id) == file_id:
                        return file
                # If file not found, return original value
                return data

            # Check for multiple files pattern [Files: file_id1, file_id2, ...]
            multiple_match = multiple_files_pattern.match(data.strip())
            if multiple_match:
                file_ids_str = multiple_match.group(1).strip()
                # Split by comma and strip whitespace
                file_ids = [fid.strip() for fid in file_ids_str.split(",")]

                # Find all matching files
                matched_files = []
                for file_id in file_ids:
                    for file in self.files:
                        if hasattr(file, "id") and str(file.id) == file_id:
                            matched_files.append(file)
                            break

                # Return list of files if any were found, otherwise return original
                return matched_files or data

            return data
        else:
            # Return other types as-is
            return data
