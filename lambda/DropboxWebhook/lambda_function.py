import json
from hashlib import sha256
import hmac
import boto3
import logging

logging.basicConfig(level=logging.DEBUG)
logging.getLogger().setLevel(logging.DEBUG)
requests_log = logging.getLogger("requests.packages.urllib3")
requests_log.setLevel(logging.DEBUG)
requests_log.propagate = True

refresh_token = "AI96VOgGGbMAAAAAAAAAAWPHo8j_piuiq1lD_M5k6npJ8yGlBkCYgiDN18PVIcVf"
app_key = "0782fwlvi1phfgf"
app_secret = "9llu6y52oty3et8"

def process_account(account):
    pass


def lambda_handler(event, context):
    print(event)
    print(context)

    # handle challenge
    event = event if event is not None else {}
    params = event.get("queryStringParameters", {})
    if params is not None and "challenge" in params:
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "text/plain",
                "X-Content-Type-Options": "nosniff"
            },
            "body": event["queryStringParameters"]["challenge"]
        }

    signature = event.get("headers", {}).get("X-Dropbox-Signature", "")
    payload = event.get("body", {})
    try:
        valid = hmac.compare_digest(signature, hmac.new(app_secret.encode(), json.dumps(payload, sort_keys=True).encode(), sha256).hexdigest())
    except TypeError:
        valid = False
    if not valid:
        return {
            "statusCode": 403,
            "details": "X-Dropbox-Signature invalid!"
        }
    print("Validated")
    
    lmd_client = boto3.client("lambda")
    response = lmd_client.invoke(
        FunctionName="arn:aws:lambda:eu-central-1:574639460976:function:ProcessUserUpdate",
        InvocationType="RequestResponse",
        Payload=json.dumps({})
    )
    
    print("Response: ")
    print(response)
    print(json.load(response['Payload']))
    

    import threading

    for account in payload.get("list_folder", {}).get("accounts", []):
        threading.Thread(target=process_account, args=(account,)).start()

    return {
        "statusCode": 200,
        "body": "Hello!",
    }
