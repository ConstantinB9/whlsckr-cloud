def lambda_handler(event, context):
    print(event)
    account = event.get("Payload", {}).get("account", "")

    return {
        "statusCode": 200,
        "body": f"Hello from the User Update Process Lambda! Evaluating Account {account}",
    }
