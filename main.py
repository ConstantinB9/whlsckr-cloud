import json
import boto3
client = boto3.client('lambda', region_name='eu-central-1')

response = client.invoke(
        FunctionName = 'arn:aws:lambda:eu-central-1:574639460976:function:test-child-function',
        InvocationType = 'RequestResponse',
        Payload = b"{}"
    )

print(response)
print(json.load(response['Payload']))
