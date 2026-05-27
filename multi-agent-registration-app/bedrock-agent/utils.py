# Dummy utils.py for bedrock-agent Lambda package

def getInput(event):
    """
    Retrieve the 'body' field from the Lambda event.
    Args:
        event (dict): The Lambda event object.
    Returns:
        str: The body of the event (raw input as JSON string).
    """
    return event.get('body')

# Example event structure for reference:
example_event = {
    'version': '2.0',
    'routeKey': '$default',
    'rawPath': '/',
    'rawQueryString': '',
    'headers': {
        'sec-fetch-mode': 'cors',
        'referer': 'http://localhost:5173/',
        'content-length': '108',
        'x-amzn-tls-version': 'TLSv1.3',
        'sec-fetch-site': 'cross-site',
        'x-forwarded-proto': 'https',
        'accept-language': 'en-US,en;q=0.9',
        'origin': 'http://localhost:5173',
        'x-forwarded-port': '443',
        'x-forwarded-for': '135.12.197.47',
        'accept': 'application/json, text/plain, */*',
        'x-amzn-tls-cipher-suite': 'TLS_AES_128_GCM_SHA256',
        'sec-ch-ua': '"Chromium";v="148", "Google Chrome";v="148", "Not/A)Brand";v="99"',
        'x-amzn-trace-id': 'Root=1-6a17162f-752c8c4e5dea48692b1ee678',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"macOS"',
        'host': 'kkhop5fqvzd2qskuwe5ratm33a0fklyj.lambda-url.us-east-1.on.aws',
        'content-type': 'application/json',
        'accept-encoding': 'gzip, deflate, br, zstd',
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',
        'sec-fetch-dest': 'empty'
    },
    'requestContext': {
        'accountId': 'anonymous',
        'apiId': 'kkhop5fqvzd2qskuwe5ratm33a0fklyj',
        'domainName': 'kkhop5fqvzd2qskuwe5ratm33a0fklyj.lambda-url.us-east-1.on.aws',
        'domainPrefix': 'kkhop5fqvzd2qskuwe5ratm33a0fklyj',
        'http': {
            'method': 'POST',
            'path': '/',
            'protocol': 'HTTP/1.1',
            'sourceIp': '135.12.197.47',
            'userAgent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36'
        },
        'requestId': '48881068-d3a6-4d3a-a3f1-87af060db735',
        'routeKey': '$default',
        'stage': '$default',
        'time': '27/May/2026:16:05:03 +0000',
        'timeEpoch': 1779897903063
    },
    'body': '{"rawInput":"jon, phone 2232333333, eamil: jon@mail.com","sessionId":"c445307a-5530-4cc8-907b-a87aa1736d0d"}',
    'isBase64Encoded': False
}
