import json
from io import BytesIO
import dropbox
import boto3
from boto3.dynamodb.conditions import Key
from dropbox.files import DeletedMetadata, FolderMetadata


def lambda_handler(event, context):
    print(event)
    account = event.get("account", "")

    dynamodb = boto3.resource("dynamodb")
    s3_client = boto3.client("s3")
    user_data_table = dynamodb.Table("whlsckr_user_data")
    print(account)
    acc_matches = user_data_table.query(
        IndexName="DropboxIndex", KeyConditionExpression=Key("DropboxId").eq(account)
    )
    for item in acc_matches.get("Items"):
        full_item = user_data_table.query(
            KeyConditionExpression=Key("UserId").eq(item["UserId"])
        ).get("Items")[0]
        token = json.loads(full_item["DropboxToken"])
        print(item)
        dbx_app_data = boto3.client("dynamodb").get_item(TableName= "whlsckr_app_credentials", Key={"AppName": {"S": "Dropbox"}})[
            "Item"
        ]
        dbx = dropbox.Dropbox(
            app_key=dbx_app_data["Key"]["S"],
            app_secret=dbx_app_data["Secret"]["S"],
            oauth2_access_token=token["access_token"],
            oauth2_refresh_token=token["refresh_token"],
        )
        dbx.check_and_refresh_access_token()
        
        cursor = full_item["DropboxCursor"]
        has_more = True

        while has_more:
            if cursor is None:
                result: dropbox.files.ListFolderResult = dbx.files_list_folder(path="/Apps/WahooFitness")
            else:
                result: dropbox.files.ListFolderResult = dbx.files_list_folder_continue(cursor)

            for entry in result.entries:
            # Ignore deleted files, folders, and non-markdown files
                if (
                    isinstance(entry, DeletedMetadata)
                    or isinstance(entry, FolderMetadata)
                    or not entry.path_lower.endswith(".fit")
                ):
                    continue

                _, resp = dbx.files_download(entry.path_lower)
                f_obj = BytesIO()
                f_obj.write(resp.content)
                f_obj.seek(0)
                s3_client.upload_fileobj(f_obj, 'whlsckr-fitfile-buffer', f'{full_item["UserId"]}/{entry.path_lower.split("/")[-1]}')
                
            
            cursor = result.cursor
            has_more = result.has_more

        boto3.client("dynamodb").update_item(
            TableName="whlsckr_user_data",
            Key={"UserId": {"S": full_item["UserId"]}},
            UpdateExpression="set DropboxCursor=:t",
            ExpressionAttributeValues={":t": {"S": cursor}}
        )
                    
    return {
        "statusCode": 200,
        "body": f"Hello from the User Update Process Lambda! Evaluating Account {account}",
    }
