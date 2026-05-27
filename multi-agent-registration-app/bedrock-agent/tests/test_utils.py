import unittest
import sys
import os

# Add the parent directory to sys.path so we can import utils
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils import getInput

class TestGetInput(unittest.TestCase):
    def test_get_input_returns_body(self):
        event = {
            'body': '{"rawInput":"jon, phone 2232333333, eamil: jon@mail.com","sessionId":"c445307a-5530-4cc8-907b-a87aa1736d0d"}'
        }
        result = getInput(event)
        self.assertEqual(result, event['body'])

    def test_get_input_missing_body(self):
        event = {}
        result = getInput(event)
        self.assertIsNone(result)

if __name__ == '__main__':
    unittest.main()
