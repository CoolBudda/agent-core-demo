"""Agent 3: Human Handoff.

Invoked when data validation passes.
Forwards the submission to the appropriate employee via Bedrock AgentCore.
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
) -> dict:
    """Invoke the human-handoff agent to route a valid submission to an employee.

    Args:
        client: A boto3 Bedrock AgentRuntime client.
        agent_id: Bedrock AgentCore agent ID for the handoff agent.
        agent_alias_id: Alias ID for the handoff agent.
        submission: The validated form submission.

    Returns:
        dict with keys:
            - ``routed_to`` (str | None): Employee/queue the submission was sent to.
            - ``raw`` (dict): Raw Bedrock response.
    """
    logger.info("Running human-handoff agent for submission: %s", submission.email)

    response = client.invoke_agent(
        agentId=agent_id,
        agentAliasId=agent_alias_id,
        sessionId=f"handoff-{submission.email}",
        inputText=(
            f"Route the following validated form submission to the responsible employee.\n"
            f"name={submission.name}\n"
            f"email={submission.email}\n"
            f"phone={submission.phone}\n"
            f"sport={submission.sport}"
        ),
    )

    output_text = _collect_completion(response)
    logger.info("Handoff response: %s", output_text)

    return {"routed_to": output_text.strip() or None, "raw": response}


def _collect_completion(response: dict) -> str:
    chunks: list[str] = []
    for event in response.get("completion", []):
        if chunk := event.get("chunk", {}).get("bytes"):
            chunks.append(chunk.decode("utf-8"))
    return "".join(chunks)
