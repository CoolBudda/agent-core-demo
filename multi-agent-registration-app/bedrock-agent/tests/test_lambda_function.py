import unittest
from unittest.mock import patch, MagicMock
from lambda_function import lambda_handler

class TestLambdaHandler(unittest.TestCase):
    @patch("lambda_function.call_bedrock_agent")
    def test_valid_input(self, mock_bedrock):
        mock_bedrock.return_value = {
            'status': 'valid',
            'message': 'test input',
            'details': []
        }
        event = {
            'requestContext': {'http': {'method': 'POST'}},
            'body': '{"rawInput": "test input", "sessionId": "sess-1"}'
        }
        result = lambda_handler(event, None)
        self.assertEqual(result['statusCode'], 200)
        self.assertIn('valid', result['body'])

    @patch("lambda_function.call_bedrock_agent")
    def test_invalid_input(self, mock_bedrock):
        mock_bedrock.return_value = {
            'status': 'invalid',
            'message': 'Missing email or phone',
            'details': []
        }
        event = {
            'requestContext': {'http': {'method': 'POST'}},
            'body': '{"rawInput": "no email", "sessionId": "sess-2"}'
        }
        result = lambda_handler(event, None)
        self.assertEqual(result['statusCode'], 200)
        self.assertIn('invalid', result['body'])

    def test_cors_options(self):
        event = {
            'requestContext': {'http': {'method': 'OPTIONS'}},
            'body': ''
        }
        result = lambda_handler(event, None)
        self.assertEqual(result['statusCode'], 200)
        self.assertEqual(result['body'], '')

if __name__ == "__main__":
    unittest.main()
