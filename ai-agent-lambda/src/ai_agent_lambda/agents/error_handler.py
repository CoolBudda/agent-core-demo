"""Agent 2: Error Handler.

Invoked when data validation fails.
Creates a support ticket in the configured tracking system via Bedrock AgentCore.
"""
from __future__ import annotations

import logging

import boto3

from ai_agent_lambda.models.form import FormSubmission

logger = logging.getLogger(__name__)


def run(
    client: "boto3.client",
    agent_id: str,
    agent_alias_id: str,
    submission: FormSubmission,
    errors: list[str],
) -> dict:
    """Invoke the error-handling agent to create a ticket for validation failures.

    Args:
        client: A boto3 Bedrock AgentRuntime client.
        agent_id: Bedrock AgentCore agent ID for the error handler.
        agent_alias_id: Alias ID for the error-handler agent.
        submission: The form submission that failed validation.
        errors: List of validation error messages from the validator agent.

    Returns:
        dict with keys:
            - ``ticket_id`` (str | None): Created ticket ID, or None on failure.
            - ``raw`` (dict): Raw Bedrock response.
    """
    logger.info("Running error-handler agent for submission: %s", submission.email)

    error_summary = "\n".join(f"- {e}" for e in errors)
    response = client.invoke_agent(
        agentId=agent_id,
        agentAliasId=agent_alias_id,
        sessionId=f"error-{submission.email}",
        inputText=(
            f"Create a support ticket for a failed form submission.\n"
            f"Submitter email: {submission.email}\n"
            f"Validation errors:\n{error_summary}"
        ),
    )

    output_text = _collect_completion(response)
    ticket_id = _extract_ticket_id(output_text)
    logger.info("Ticket created: %s", ticket_id)

    return {"ticket_id": ticket_id, "raw": response}


def _collect_completion(response: dict) -> str:
    chunks: list[str] = []
    for event in response.get("completion", []):
        if chunk := event.get("chunk", {}).get("bytes"):
            chunks.append(chunk.decode("utf-8"))
    return "".join(chunks)


def _extract_ticket_id(text: str) -> str | None:
    """Extract ticket ID from agent response text (e.g. 'Ticket ID: TKT-1234')."""
    import re

    match = re.search(r"(?:ticket\s*id[:\s]+)(\S+)", text, re.IGNORECASE)
    return match.group(1) if match else None
