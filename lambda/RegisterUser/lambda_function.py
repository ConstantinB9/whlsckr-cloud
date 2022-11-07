from datetime import datetime
import json
import uuid
import dropbox
import boto3


def lambda_handler(event, context):
    print(event)
    print(context)
    client = boto3.client("dynamodb")
    response = client.get_item(
        TableName="whlsckr_app_credentials", Key={"AppName": {"S": "Dropbox"}}
    )

    secret = response["Item"]["Secret"]["S"]
    key = response["Item"]["Key"]["S"]

    auth_flow = dropbox.DropboxOAuth2Flow(
        consumer_key=key,
        redirect_uri="https://c1hls2l1pl.execute-api.eu-central-1.amazonaws.com/whlsckr/register",
        consumer_secret=secret,
        csrf_token_session_key="dropbox-auth-csrf-token",
        session={},
        token_access_type="offline"
    )

    if (
        event.get("queryStringParameters", None) is not None
        and "code" in event["queryStringParameters"]
    ):
        try:
            auth_flow.session = {
                auth_flow.csrf_token_session_key: event["headers"][
                    "Cookie"
                ].removeprefix(f"{auth_flow.csrf_token_session_key}=")
            }
        except KeyError:
            return {"statusCode": 403, "body": "Authentication Failed"}
        result = auth_flow.finish(event["queryStringParameters"])
        dbx = dropbox.Dropbox(oauth2_access_token=result.access_token)
        has_more = True
        cursor = None
        while has_more:
            if cursor is None:
                result = dbx.files_list_folder(path="/Apps/WahooFitness")
            else: 
                result = dbx.files_list_folder_continue(cursor)
            cursor = result.cursor
            has_more = result.has_more

        
        client.put_item(
            TableName="whlsckr_user_data",
            Item={
                "UserId": {"S": str(uuid.uuid1())},
                "DropboxId": {"S": result.account_id},
                "DropboxToken": {
                    "S": json.dumps(
                        {
                            "access_token": result.access_token,
                            "refresh_token": result.refresh_token,
                            "expires_at": datetime.timestamp(result.expires_at) if result.expires_at is not None else 0,
                        }
                    )
                },
                "DropboxCursor": {"S": cursor}
            },
        )
        # todo: add user to db
        return {"statusCode": 200, "body": "Registration complete"}

    url = auth_flow.start()
    return {
        "statusCode": 301,
        "headers": {
            "Location": url,
            "Set-Cookie": f"{auth_flow.csrf_token_session_key}={auth_flow.session[auth_flow.csrf_token_session_key]}",
        },
    }
