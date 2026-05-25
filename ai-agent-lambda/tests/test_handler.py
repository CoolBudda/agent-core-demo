"""Tests for the Lambda handler."""
from __future__ import annotations

import json
from unittest.mock import MagicMock, patch


def _make_event(body: dict) -> dict:
    return {"body": json.dumps(body)}


@patch("ai_agent_lambda.handler._bedrock_client")
def test_valid_submission_routes_to_handoff(mock_client: MagicMock) -> None:
    from ai_agent_lambda.handler import lambda_handler

    mock_client.invoke_agent.return_value = {
        "completion": [{"chunk": {"bytes": b"valid submission"}}]
    }

    event = _make_event({"name": "Alice", "email": "alice@example.com", "phone": "555-0100", "sport": "tennis"})
    response = lambda_handler(event, context=None)

    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["status"] == "submitted"


@patch("ai_agent_lambda.handler._bedrock_client")
def test_invalid_submission_creates_ticket(mock_client: MagicMock) -> None:
    from ai_agent_lambda.handler import lambda_handler

    mock_client.invoke_agent.return_value = {
        "completion": [{"chunk": {"bytes": b"invalid email format. Ticket ID: TKT-001"}}]
    }

    event = _make_event({"name": "Bob", "email": "not-an-email", "phone": "555-0101", "sport": "golf"})
    response = lambda_handler(event, context=None)

    assert response["statusCode"] == 422
    body = json.loads(response["body"])
    assert body["status"] == "validation_failed"


def test_bad_json_body_returns_400() -> None:
    from ai_agent_lambda.handler import lambda_handler

    response = lambda_handler({"body": "not json"}, context=None)
    assert response["statusCode"] == 400
