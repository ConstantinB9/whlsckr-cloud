from datetime import datetime
import json
import dropbox
import boto3

header_key = "dropbox-auth-csrf-token"


def lambda_handler(event, context):
    print(event)
    print(context)
    client = boto3.client("dynamodb")
    response = client.get_item(
        TableName="whlsckr_app_credentials", Key={"AppName": {"S": "Dropbox"}}
    )

    secret = response["Item"]["Secret"]["S"]
    key = response["Item"]["Key"]["S"]
    user_id = event.get("queryStringParameters", {}).get("userid", "")

    auth_flow = dropbox.DropboxOAuth2Flow(
        consumer_key=key,
        redirect_uri="https://c1hls2l1pl.execute-api.eu-central-1.amazonaws.com/whlsckr/register_dropbox",
        consumer_secret=secret,
        csrf_token_session_key=header_key,
        session={},
        token_access_type="offline",
    )

    if (
        event.get("queryStringParameters", None) is not None
        and "code" in event["queryStringParameters"]
    ):
        try:
            auth_flow.session = {
                header_key: [
                    *[
                        c.removeprefix(f"{header_key}=")
                        for c in event.get("headers", {}).get("Cookie", "").split("; ")
                        if header_key in c
                    ],
                    "",
                ][0]
            }
        except KeyError:
            return {"statusCode": 403, "body": "Authentication Failed"}

        auth_result = auth_flow.finish(event["queryStringParameters"])
        user_id = auth_result.url_state
        dbx = dropbox.Dropbox(oauth2_access_token=auth_result.access_token)
        has_more = True
        cursor = None
        while has_more:
            if cursor is None:
                result = dbx.files_list_folder(path="/Apps/WahooFitness")
            else:
                result = dbx.files_list_folder_continue(cursor)
            cursor = result.cursor
            has_more = result.has_more

        client.update_item(
            TableName="whlsckr_user_data",
            Key={"UserId": {"S": user_id}},
            UpdateExpression="set DropboxToken=:t, set DropboxId=:dbid, DropboxCursor=:dbcurs",
            ExpressionAttributeValues={
                ":t":
                    {"S": {
                        "S": json.dumps(
                            {
                                "access_token": auth_result.access_token,
                                "refresh_token": auth_result.refresh_token,
                                "expires_at": datetime.timestamp(auth_result.expires_at)
                                if auth_result.expires_at is not None
                                else 0,
                            })
                        }
                    },
                ":dbid": {"S": auth_result.account_id},
                ":dbcurs": {"S": cursor}},
        )
        return {"statusCode": 200, "body": "Registration complete"}

    user_in_db = client.get_item(
        TableName="whlsckr_user_data", Key={"UserId": {"S": user_id}}
    )

    if "Item" not in user_in_db:
        return {"statusCode": 400, "body": "User ID Invalid"}
    elif user_in_db["Item"].get("DropboxToken", {}).get("S", "") != "":
        return {"statusCode": 200, "body": "Registration complete"}

    url = auth_flow.start(url_state=user_id)
    return {
        "statusCode": 301,
        "headers": {
            "Location": url,
            "Set-Cookie": f"{header_key}={auth_flow.session[auth_flow.csrf_token_session_key]}",
        },
    }
