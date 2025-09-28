"""Prompt utilities for agent built-in tools."""

from collections.abc import Sequence

from core.file import File


def generate_file_prompt(files: Sequence[File]) -> str:
    """Generate a prompt describing available files.

    Args:
        files: Available files

    Returns:
        Formatted prompt string describing the files
    """
    if not files:
        return ""

    file_info = "Files are available for your use. Use the 'file_access' tool to work with them:\n"

    for i, file in enumerate(files, 1):
        file_type = file.type.value if file.type else "unknown"
        file_size = f"{file.size:,} bytes" if file.size else "unknown size"
        file_info += f"{i}. {file.filename} (Type: {file_type}, Size: {file_size}, ID: {file.id})\n"

    file_info += "\nYou can use the file_access tool with:\n"
    file_info += "- action='view' to analyze file content/images yourself\n"
    file_info += "- action='prepare_for_tool' to make files available for other tools"

    return file_info
