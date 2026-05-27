
import json
import os
from typing import Dict, Any
from utils import getInput

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Simple Lambda handler for direct invocation from frontend.
    Logs the event and handles CORS for browser requests.
    """
    print("Event:", event)
    method = event.get('requestContext', {}).get('http', {}).get('method', '')

    # Handle CORS preflight
    if method == 'OPTIONS':
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'POST,OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type',
            },
            'body': ''
        }

    # Retrieve the body from the event
    body = getInput(event)
    raw_input = ''
    session_id = ''
    if body:
        try:
            body_json = json.loads(body)
            raw_input = body_json.get('rawInput', '')
            session_id = body_json.get('sessionId', '')
        except Exception as e:
            print(f"Error parsing body: {e}")


    # Get Bedrock agent parameters from environment variables
    agent_id = os.environ.get("BEDROCK_AGENT_ID", "")
    alias_id = os.environ.get("BEDROCK_AGENT_ALIAS_ID", "")
    region = os.environ.get("BEDROCK_AGENT_REGION", "us-east-1")

    # Call Bedrock agent to validate input
    validation_result = call_bedrock_agent(raw_input, session_id, agent_id, alias_id, region)

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST,OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type',
        },
        'body': json.dumps(validation_result)
    }


def call_bedrock_agent(raw_input: str, session_id: str, agent_id: str, alias_id: str, region: str) -> dict:
    """
    Call the real Bedrock agent using boto3.
    Args:
        raw_input (str): The user input to validate.
        session_id (str): The session ID.
        agent_id (str): The Bedrock agent ID.
        alias_id (str): The Bedrock agent alias ID.
        region (str): AWS region.
    Returns:
        dict: The response from the Bedrock agent.
    """
    import boto3
    import botocore

    client = boto3.client("bedrock-agent-runtime", region_name=region)
    try:
        response = client.invoke_agent(
            agentId=agent_id,
            agentAliasId=alias_id,
            sessionId=session_id or "default-session",
            inputText=raw_input
        )
        # The response structure may vary; adjust as needed
        return {
            "status": "success",
            "message": response.get("completion", {}).get("content", ""),
            "details": response
        }
    except botocore.exceptions.BotoCoreError as e:
        return {
            "status": "error",
            "message": str(e),
            "details": {}
        }
