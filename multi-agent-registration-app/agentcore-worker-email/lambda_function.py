from utils import send_registration_email


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
    name = event["name"]
    email = event["email"]
    phone = event["phone"]
    favorite_sport = event["favorite_sport"]

    send_registration_email(
        to_address=email,
        name=name,
        phone=phone,
        favorite_sport=favorite_sport,
    )

    return {"status": "email_sent", "recipient": email}
