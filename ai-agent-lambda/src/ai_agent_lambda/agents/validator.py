"""Agent 1: Data Validator.

Validates form submission fields via Bedrock AgentCore.
Always runs as the first step in the pipeline.
"""
from __future__ import annotations

import logging

import boto3

from ai_agent_lambda.models.form import FormSubmission

logger = logging.getLogger(__name__)


def run(client: "boto3.client", agent_id: str, agent_alias_id: str, submission: FormSubmission) -> dict:
    """Invoke the data-validation agent and return its response payload.

    Args:
        client: A boto3 Bedrock AgentRuntime client.
        agent_id: Bedrock AgentCore agent ID for the validator.
        agent_alias_id: Alias ID for the validator agent.
        submission: The form submission to validate.

    Returns:
        dict with keys:
            - ``valid`` (bool): True when all fields pass validation.
            - ``errors`` (list[str]): Validation error messages, empty when valid.
            - ``raw`` (dict): Raw Bedrock response.
    """
    logger.info("Running data-validation agent for submission: %s", submission.email)

    response = client.invoke_agent(
        agentId=agent_id,
        agentAliasId=agent_alias_id,
        sessionId=f"validate-{submission.email}",
        inputText=(
            f"Validate the following form submission:\n"
            f"name={submission.name}\n"
            f"email={submission.email}\n"
            f"phone={submission.phone}\n"
            f"sport={submission.sport}"
        ),
    )

    # Collect streaming completion chunks
    output_text = _collect_completion(response)
    valid = "valid" in output_text.lower() and "invalid" not in output_text.lower()

    return {"valid": valid, "errors": [] if valid else [output_text], "raw": response}


def _collect_completion(response: dict) -> str:
    chunks: list[str] = []
    for event in response.get("completion", []):
        if chunk := event.get("chunk", {}).get("bytes"):
            chunks.append(chunk.decode("utf-8"))
    return "".join(chunks)
