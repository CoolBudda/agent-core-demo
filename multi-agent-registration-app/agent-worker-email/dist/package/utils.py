import os
import boto3

ses = boto3.client("ses", region_name="us-east-1")

SENDER = os.environ.get("SES_SENDER_EMAIL", "no-reply@example.com")


def send_registration_email(
    to_address: str,
    name: str,
    phone: str,
    favorite_sport: str,
) -> None:
    """
    Send a registration confirmation email via Amazon SES.
    Replace with your preferred email provider as needed.
    """
    subject = "Registration Confirmed"
    body = (
        f"Hi {name},\n\n"
        f"Your registration is complete.\n\n"
        f"Details:\n"
        f"  Phone: {phone}\n"
        f"  Favourite sport: {favorite_sport}\n\n"
        f"Welcome aboard!"
    )

    ses.send_email(
        Source=SENDER,
        Destination={"ToAddresses": [to_address]},
        Message={
            "Subject": {"Data": subject},
            "Body": {"Text": {"Data": body}},
        },
    )
