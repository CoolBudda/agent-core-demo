from utils import send_registration_email
import json


def handler(event, context):
    """
    AgentCore action group worker — called by Bedrock Agent when all
    required registration fields (name, email, phone, favorite_sport) are present.

    Expected event payload:
    {
        "name": "Alice",
        "email": "alice@example.com",
        "phone": "+1-555-123-4567",
        "favorite_sport": "tennis"
    }
    """

    print("Received event:", json.dumps(event))
    
    # Extract inputText
    input_text = event.get("inputText")

    # Extract user_info from properties array
    properties = (
        event.get("requestBody", {})
        .get("content", {})
        .get("application/json", {})
        .get("properties", [])
    )
    user_info = {prop["name"]: prop["value"] for prop in properties}

    name = user_info.get("name")
    email = user_info.get("email")
    phone = user_info.get("phone")
    favorite_sport = user_info.get("favorite_sport")

    send_registration_email(
        to_address=email,
        registration_info= input_text,
        registration_as =user_info
    )

    msg = {
        "status": "email_sent",
        "recipient": email,
        "inputText": input_text,
        "user_info": user_info,
    }

    # bedrock agent requires return:
    return {
        "messageVersion": "1.0",
        "response": {
            "actionGroup": event["actionGroup"],
            "apiPath": event["apiPath"],
            "httpMethod": event["httpMethod"],
            "httpStatusCode": 200,
            "responseBody": {
                "application/json": {
                    "body": json.dumps(msg)
                }
            }
        }
    }