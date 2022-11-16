import json
import time

import boto3
import jwt
from stravainteractweblib import InteractiveWebClient


def lambda_handler(event, context):
    print(event)
    dbclient = boto3.client("dynamodb")
    try:
        for record in event.get("Records", []):
            payload = json.loads(record.get("body"))
            user_id = payload.get("UserId", "")
            activity_id = payload.get("ActivityId", "")
            stats_viz_status = payload.get("StatsVisibility", "")

            resp = dbclient.get_item(
                TableName="whlsckr_user_data", Key={"UserId": {"S": user_id}}
            )

            strava_credentials = json.loads(resp["Item"]["StravaCredentials"]["S"])
            strava_jwt = resp["Item"].get("StravaJWT", {}).get("S", None)
            if strava_jwt is not None:
                payload = jwt.decode(strava_jwt, options={"verify_signature": False})
                if time.time() > int(payload.get("exp", 0)):
                    # JWT Expired
                    strava_jwt = None

            no_jwt = strava_jwt is None

            strv_client = InteractiveWebClient(
                jwt=strava_jwt,
                email=strava_credentials["email"],
                password=strava_credentials["password"],
            )

            if no_jwt:
                boto3.client("dynamodb").update_item(
                    TableName="whlsckr_user_data",
                    Key={"UserId": {"S": user_id}},
                    UpdateExpression="set StravaJWT=:t",
                    ExpressionAttributeValues={":t": {"S": strv_client.jwt}},
                )

            strv_client.set_stats_visibility(
                activity_id=activity_id, **stats_viz_status
            )
    except Exception as e:
        print(e)

    return {"statusCode": 200, "details": "Stats Vizibility Changed"}
