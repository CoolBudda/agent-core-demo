import os
import boto3

ses = boto3.client("ses", region_name="us-east-1")

SENDER = os.environ.get("SES_SENDER_EMAIL", "no-reply@example.com")


def send_registration_email(
    to_address: str,
    registration_info: str,
    registration_as: dict,
) -> None:
    """
    Send a registration confirmation email via Amazon SES.
    Replace with your preferred email provider as needed.
    """
    name = registration_as.get("name")
    email = registration_as.get("email")
    phone = registration_as.get("phone")
    favorite_sport = registration_as.get("favorite_sport")

    subject = "Registration Confirmed"

    body_text = (
        f"Name: {name}\n"
        f"Email: {email}\n"
        f"Phone: {phone}\n"
        f"Favorite Sport: {favorite_sport}\n"
    )

    ses.send_email(
        Source=SENDER,
        Destination={"ToAddresses": [email]},
        Message={
            "Subject": {"Data": subject},
            "Body": {
                "Text": {"Data": body_text}
            }
        }
    )
