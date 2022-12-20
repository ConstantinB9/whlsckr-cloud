import time
from typing import Dict, Optional
import boto3
import asyncio
from boto3.dynamodb.conditions import Key
import jwt
import json

db_client = boto3.client("dynamodb")

loop = asyncio.get_event_loop()


async def get_whlsckr_secret():
    return db_client.get_item(
        TableName="whlsckr_app_credentials", Key={"AppName": {"S": "Whlsckr"}}
    )["Item"]["Secret"]["S"]


async def get_user_data(user_id: str) -> Optional[Dict[str, str]]:
    dynamodb = boto3.resource("dynamodb")
    user_data_table = dynamodb.Table("whlsckr_user_data")
    acc_matches = user_data_table.query(
        KeyConditionExpression=Key("UserId").eq("67afa993-614f-11ed-a81b-f1554fcd65ad")
    )
    try:
        match_acc = acc_matches.get("Items", [None])[0]
    except IndexError:
        return None

    return match_acc


def lambda_handler(event, context):
    return loop.run_until_complete(main(event, context))


async def main(event, context):
    print(event)
    token = event.get("queryStringParameters", {}).get("token", None)
    if token is None:
        return {"statusCode": 400, "details": "Missing Parameter 'token'"}

    whlsckr_secret = await get_whlsckr_secret()

    try:
        payload = jwt.decode(token, key=whlsckr_secret, algorithms=["HS256"])
    except Exception as exp:
        print(exp)
        return {"statusCode": 400, "details": "Invalid Token"}

    user_data = await get_user_data(payload["uid"])
    if user_data is None:
        return {"statusCode": 400, "details": "Token holder not recognized"}

    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "strava_registered": user_data.get("StravaToken", "") != "",
                "strava_creds_registered": user_data.get("StravaCredentials", "") != "",
                "dropbox_registered": user_data.get("DropboxToken", "") != "",
                "strava-privacy-settings": user_data.get("StravaSettings", ""),
            }
        ),
    }
