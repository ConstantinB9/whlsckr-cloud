import time
import boto3
import asyncio
from boto3.dynamodb.conditions import Key
import jwt
import json

db_client = boto3.client("dynamodb")

loop = asyncio.get_event_loop()


def lambda_handler(event, context):
    return loop.run_until_complete(main(event, context))


async def get_whlsckr_secret():
    return db_client.get_item(
        TableName="whlsckr_app_credentials", Key={"AppName": {"S": "Whlsckr"}}
    )["Item"]["Secret"]["S"]


async def get_user_data_from_email(email: str):
    dynamodb = boto3.resource("dynamodb")
    user_data_table = dynamodb.Table("whlsckr_user_data")
    acc_matches = user_data_table.query(
        IndexName="EmailIndex", KeyConditionExpression=Key("Email").eq(email)
    )
    try:
        match_acc = acc_matches.get("Items", [None])[0]
    except IndexError:
        return None

    return user_data_table.query(
        KeyConditionExpression=Key("UserId").eq(match_acc["UserId"])
    ).get("Items", [None])[0]


async def main(event, context):
    email = event.get("queryStringParameters", {}).get("email", "").lower()
    password = event.get("queryStringParameters", {}).get("password", None)

    if email == "" or password is None:
        return {"statusCode": 400, "details": "Missing field 'user' or 'password'"}

    whlsckr_secret_task = asyncio.create_task(get_whlsckr_secret())
    user_data_entry = await get_user_data_from_email(email=email)
    if user_data_entry is None:
        return {"statusCode": 400, "details": "Credential Invalid"}

    if password == user_data_entry.get("Password", ""):
        whlsckr_secret = await whlsckr_secret_task

        user_jwt = jwt.encode(
            {
                "email": email,
                "exp": int(time.time() + 7 * 24 * 60 * 60),
                "uid": user_data_entry.get("UserId"),
            },
            whlsckr_secret,
            algorithm="HS256",
        )

        return {
            "statusCode": 200,
            "headers": {"Set-Cookie": f"x-whlsckr-auth={user_jwt}"},
            "body": json.dumps({"x-whlsckr-auth": user_jwt}),
        }

    return {"statusCode": 400, "details": "Credential Invalid"}
