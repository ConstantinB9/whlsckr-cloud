from io import BytesIO
import json
import time
import boto3
from stravalib.client import Client

s3_client = boto3.client("s3")
db_client = boto3.client("dynamodb")


def lambda_handler(event, context):
    print(event)

    strv_client = Client()

    response = db_client.get_item(
        TableName="whlsckr_app_credentials", Key={"AppName": {"S": "Strava"}}
    )

    key = response["Item"]["Key"]["S"]
    secret = response["Item"]["Secret"]["S"]

    for record in event.get("Records", []):
        obj_key = record["s3"]["object"]["key"].replace("+", " ")

        s3_response_object = s3_client.get_object(
            Bucket=record["s3"]["bucket"]["name"], Key=obj_key
        )
        object_content = BytesIO(s3_response_object["Body"].read())
        object_content.seek(0)

        user_id = obj_key.split("/")[0]
        response = db_client.get_item(
            TableName="whlsckr_user_data", Key={"UserId": {"S": user_id}}
        )
        token = json.loads(response["Item"]["StravaToken"]["S"])
        strv_client.access_token = token["access_token"]
        if time.time() > token["expires_at"]:
            token = strv_client.refresh_access_token(
                key, secret, token["refresh_token"]
            )
            db_client.update_item(
                TableName="whlsckr_user_data",
                Key={"UserId": {"S": user_id}},
                UpdateExpression="set StravaToken=:t",
                ExpressionAttributeValues={":t": {"S": json.dumps(token)}},
            )

        uploader = strv_client.upload_activity(
            activity_file=object_content, data_type=obj_key.split(".")[-1]
        )

        s3_client.delete_object(Bucket=record["s3"]["bucket"]["name"], Key=obj_key)
        retries = 5
        while retries:
            try:
                uploader.wait()
            except Exception as _ex:
                retries -= 1
                if uploader.activity_id is not None:
                    break
                if not retries:
                    raise _ex
                print(_ex)
                time.sleep(0.5)
        print(uploader.activity_id)

        boto3.client("sqs").send_message(
            QueueUrl="https://sqs.eu-central-1.amazonaws.com/574639460976/whlsckr-strava-uploads",
            MessageBody=json.dumps(
                dict(
                    UserId=user_id,
                    ActivityId=uploader.activity_id,
                    StatsVisibility=dict(heart_rate=False),
                )
            ),
        )

    return {"statusCode": 200, "details": "Uploading to Strava"}
