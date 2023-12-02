import json
from hashlib import sha256
import hmac
import boto3
import logging

logging.basicConfig(level=logging.DEBUG)
logging.getLogger().setLevel(logging.DEBUG)


def lambda_handler(event, context):

    dynamodb_client = boto3.client("dynamodb")

    # handle challenge
    event = event if event is not None else {}
    params = event.get("queryStringParameters", {})
    if params is not None and "challenge" in params:
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "text/plain",
                "X-Content-Type-Options": "nosniff",
            },
            "body": event["queryStringParameters"]["challenge"],
        }

    signature = event.get("headers", {}).get("X-Dropbox-Signature", "")
    payload = json.loads(event.get("body", {}))
    if isinstance(payload, str):
        payload = json.loads(payload)

    try:
        app_secret = dynamodb_client.get_item(
            TableName="whlsckr_app_credentials", Key={"AppName": {"S": "Dropbox"}}
        )["Item"]["Secret"]["S"]
    except KeyError:
        logging.error(
            "App Secret for 'Dropbox' in table 'whlsckr_app_credentials' not found"
        )
        return {"statusCode": 500, "details": "Internal Server Error"}

    try:
        valid = hmac.compare_digest(
            signature,
            hmac.new(
                app_secret.encode(),
                event.get("body", "").encode(),
                sha256,
            ).hexdigest(),
        )
    except TypeError:
        logging.warning("Type Error")
        valid = False
    logging.info(valid)
    if not valid:
        logging.warning("X-Dropbox-Signature invalid")
        return {"statusCode": 403, "details": "X-Dropbox-Signature invalid!"}
    logging.info("Signature Validated")

    lmd_client = boto3.client("lambda")

    for account in payload.get("list_folder", {}).get("accounts", []):
        logging.info("Calling lambda")
        lmd_client.invoke(
            FunctionName="arn:aws:lambda:eu-central-1:574639460976:function:ProcessUserUpdate",
            InvocationType="Event",
            Payload=json.dumps({"account": account}),
        )

    return {
        "statusCode": 200,
        "body": "Hello!",
    }
