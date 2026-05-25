import os
import json
import boto3

def lambda_handler(event, context):
    """
    Receives user request with session id and user input, calls Bedrock agent, and returns the response.
    """
    # Parse input
    try:
        body = event.get('body')
        if body and isinstance(body, str):
            body = json.loads(body)
        session_id = body.get('sessionId')
        user_input = body.get('text')
    except Exception as e:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': f'Invalid input: {str(e)}'})
        }

    if not session_id or not user_input:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Missing sessionId or text in request body.'})
        }

    # Get Bedrock agent info from environment variables
    agent_id = os.environ.get('BEDROCK_AGENT_ID')
    agent_alias_id = os.environ.get('BEDROCK_AGENT_ALIAS_ID')
    region = os.environ.get('AWS_REGION', 'us-east-1')

    if not agent_id or not agent_alias_id:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Missing Bedrock agent configuration.'})
        }

    # Call Bedrock Agent
    bedrock = boto3.client('bedrock-agent-runtime', region_name=region)
    try:
        response = bedrock.invoke_agent(
            agentId=agent_id,
            agentAliasId=agent_alias_id,
            sessionId=session_id,
            inputText=user_input
        )
        agent_response = response.get('completion', '')
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'Bedrock agent call failed: {str(e)}'})
        }

    return {
        'statusCode': 200,
        'body': json.dumps({'result': agent_response})
    }
