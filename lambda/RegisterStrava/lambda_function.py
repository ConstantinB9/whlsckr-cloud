from hashlib import sha1
import json
import os
import boto3
from stravalib.client import Client

header_key = "strava-auth-csrf-token"


def lambda_handler(event, context):
    print(event)
    client = Client()

    db_client = boto3.client("dynamodb")
    response = db_client.get_item(
        TableName="whlsckr_app_credentials", Key={"AppName": {"S": "Strava"}}
    )

    key = response["Item"]["Key"]["S"]
    secret = response["Item"]["Secret"]["S"]
    csrf_cookie = [
        *[
            c.removeprefix(f"{header_key}=")
            for c in event.get("headers", {}).get("Cookie", "").split("; ")
            if header_key in c
        ],
        "",
    ][0]
    csrf_state = event.get("queryStringParameters", {}).get("state", "").split(".")[0]

    if csrf_cookie == csrf_state and csrf_state != "":
        code = event.get("queryStringParameters", {}).get("code", "")
        print(code)
        token = client.exchange_code_for_token(
            client_id=key, client_secret=secret, code=code
        )
        user_id = event.get("queryStringParameters", {}).get("state", "").split(".")[1]
        print(user_id)
        print(token)

        db_client.update_item(
            TableName="whlsckr_user_data",
            Key={"UserId": {"S": user_id}},
            UpdateExpression="set StravaToken=:t",
            ExpressionAttributeValues={":t": {"S": json.dumps(token)}},
        )

        return {"statusCode": 200, "body": "Registration complete"}

    user_id = event.get("queryStringParameters", {}).get("userid", "")
    user_in_db = db_client.get_item(
        TableName="whlsckr_user_data", Key={"UserId": {"S": user_id}}
    )
    print(user_in_db)

    if "Item" not in user_in_db:
        return {"statusCode": 400, "body": "User ID Invalid"}
    elif user_in_db["Item"].get("StravaToken", {}).get("S", "") != "":
        return {"statusCode": 200, "body": "Registration complete"}

    csrf = sha1(os.urandom(64)).hexdigest()

    auth_url = client.authorization_url(
        client_id=key,
        redirect_uri="https://c1hls2l1pl.execute-api.eu-central-1.amazonaws.com/whlsckr/register_strava",
        scope=["activity:write"],
        state=f"{csrf}.{user_id}",
    )

    return {
        "statusCode": 301,
        "headers": {
            "Location": auth_url,
            "Set-Cookie": f"{header_key}={csrf}",
        },
    }
