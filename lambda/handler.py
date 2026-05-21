"""
AWS Lambda handler – receives form data from the React webapp and forwards it
to Amazon Bedrock AgentCore for AI-powered processing.

Environment variables
---------------------
AGENT_CORE_AGENT_ID      Amazon Bedrock AgentCore agent ID (required)
AGENT_CORE_AGENT_ALIAS_ID Amazon Bedrock AgentCore agent alias ID (required)
AWS_REGION               AWS region (defaults to us-east-1)
"""

from __future__ import annotations

import json
import logging
import os
import uuid

import boto3
from botocore.exceptions import BotoCoreError, ClientError

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

AGENT_ID = os.environ["AGENT_CORE_AGENT_ID"]
AGENT_ALIAS_ID = os.environ["AGENT_CORE_AGENT_ALIAS_ID"]
AWS_REGION = os.environ.get("AWS_REGION", "us-east-1")

bedrock_agent_runtime = boto3.client(
    "bedrock-agent-runtime",
    region_name=AWS_REGION,
)

# CORS headers – allow the React webapp origin to call this Lambda Function URL.
CORS_HEADERS = {
    "Access-Control-Allow-Origin": os.environ.get("ALLOWED_ORIGIN", "*"),
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "OPTIONS,POST",
}


def _build_response(status_code: int, body: dict) -> dict:
    return {
        "statusCode": status_code,
        "headers": {**CORS_HEADERS, "Content-Type": "application/json"},
        "body": json.dumps(body),
    }


def _parse_body(event: dict) -> dict:
    """Extract and JSON-decode the request body from either REST or HTTP API events."""
    raw = event.get("body", "{}")
    if not raw:
        return {}
    if event.get("isBase64Encoded"):
        import base64
        raw = base64.b64decode(raw).decode("utf-8")
    return json.loads(raw) if isinstance(raw, str) else raw


def _invoke_agent_core(user_data: dict, session_id: str) -> str:
    """
    Invoke the Amazon Bedrock AgentCore agent and return its final response text.

    The user data (user, phone, sport) is formatted into a natural-language prompt
    so the agent can validate or enrich the information.
    """
    prompt = (
        f"A new user has registered with the following details:\n"
        f"  Username : {user_data.get('user', 'N/A')}\n"
        f"  Phone    : {user_data.get('phone', 'N/A')}\n"
        f"  Sport    : {user_data.get('sport', 'N/A')}\n\n"
        "Please validate the information, check for any issues, "
        "and provide a brief confirmation or feedback."
    )

    response_chunks: list[str] = []
    response = bedrock_agent_runtime.invoke_agent(
        agentId=AGENT_ID,
        agentAliasId=AGENT_ALIAS_ID,
        sessionId=session_id,
        inputText=prompt,
    )

    event_stream = response.get("completion", [])
    for event in event_stream:
        chunk = event.get("chunk", {})
        if "bytes" in chunk:
            response_chunks.append(chunk["bytes"].decode("utf-8"))

    return "".join(response_chunks).strip() or "Processed successfully."


def handler(event: dict, context: object) -> dict:  # noqa: ARG001
    logger.info("Received event: %s", json.dumps(event))

    # Handle CORS pre-flight
    if event.get("requestContext", {}).get("http", {}).get("method") == "OPTIONS":
        return _build_response(200, {"message": "OK"})

    try:
        body = _parse_body(event)
    except (json.JSONDecodeError, ValueError) as exc:
        logger.warning("Invalid request body: %s", exc)
        return _build_response(400, {"error": "Invalid JSON body"})

    required_fields = {"user", "password", "phone", "sport"}
    missing = required_fields - body.keys()
    if missing:
        return _build_response(
            400, {"error": f"Missing required fields: {', '.join(sorted(missing))}"}
        )

    session_id = str(uuid.uuid4())

    # Strip password before sending to AgentCore (never log or forward passwords)
    user_data = {k: v for k, v in body.items() if k != "password"}

    try:
        agent_message = _invoke_agent_core(user_data, session_id)
        logger.info("AgentCore response for session %s: %s", session_id, agent_message)
        return _build_response(
            200,
            {
                "message": agent_message,
                "sessionId": session_id,
            },
        )
    except (BotoCoreError, ClientError) as exc:
        logger.error("AgentCore invocation failed: %s", exc)
        return _build_response(500, {"error": "AgentCore processing failed. Please try again."})
