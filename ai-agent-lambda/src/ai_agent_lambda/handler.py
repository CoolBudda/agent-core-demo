"""Lambda entry point for the multi-agent form processing pipeline."""
from __future__ import annotations

import json
import logging
import os
from typing import Any

import boto3

from ai_agent_lambda.agents import error_handler, handoff, validator
from ai_agent_lambda.models.form import FormSubmission

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# Agent IDs are injected via Lambda environment variables
_VALIDATOR_AGENT_ID = os.environ["VALIDATOR_AGENT_ID"]
_VALIDATOR_ALIAS_ID = os.environ["VALIDATOR_ALIAS_ID"]
_ERROR_HANDLER_AGENT_ID = os.environ["ERROR_HANDLER_AGENT_ID"]
_ERROR_HANDLER_ALIAS_ID = os.environ["ERROR_HANDLER_ALIAS_ID"]
_HANDOFF_AGENT_ID = os.environ["HANDOFF_AGENT_ID"]
_HANDOFF_ALIAS_ID = os.environ["HANDOFF_ALIAS_ID"]

_bedrock_client = boto3.client("bedrock-agent-runtime")


def lambda_handler(event: dict[str, Any], context: Any) -> dict[str, Any]:  # noqa: ANN401
    """AWS Lambda entry point.

    Expects an API Gateway proxy event. Parses the body as JSON and runs the
    three-agent pipeline: validate → error-handle or handoff.

    Args:
        event: API Gateway proxy event.
        context: Lambda context (unused).

    Returns:
        API Gateway proxy response dict.
    """
    try:
        body = json.loads(event.get("body") or "{}")
        submission = FormSubmission(
            name=body.get("name", ""),
            email=body.get("email", ""),
            phone=body.get("phone", ""),
            sport=body.get("sport", ""),
            raw_text=body.get("raw_text", ""),
        )
    except (json.JSONDecodeError, TypeError) as exc:
        logger.warning("Invalid request body: %s", exc)
        return _response(400, {"error": "Invalid JSON body"})

    # --- Agent 1: Validate ---
    validation_result = validator.run(
        client=_bedrock_client,
        agent_id=_VALIDATOR_AGENT_ID,
        agent_alias_id=_VALIDATOR_ALIAS_ID,
        submission=submission,
    )

    if not validation_result["valid"]:
        # --- Agent 2: Error Handler ---
        error_result = error_handler.run(
            client=_bedrock_client,
            agent_id=_ERROR_HANDLER_AGENT_ID,
            agent_alias_id=_ERROR_HANDLER_ALIAS_ID,
            submission=submission,
            errors=validation_result["errors"],
        )
        return _response(422, {
            "status": "validation_failed",
            "errors": validation_result["errors"],
            "ticket_id": error_result.get("ticket_id"),
        })

    # --- Agent 3: Human Handoff ---
    handoff_result = handoff.run(
        client=_bedrock_client,
        agent_id=_HANDOFF_AGENT_ID,
        agent_alias_id=_HANDOFF_ALIAS_ID,
        submission=submission,
    )
    return _response(200, {
        "status": "submitted",
        "routed_to": handoff_result.get("routed_to"),
    })


def _response(status_code: int, body: dict[str, Any]) -> dict[str, Any]:
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }
