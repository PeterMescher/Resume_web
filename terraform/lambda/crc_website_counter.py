import boto3
import os

counter_table_name = os.environ['DYNAMODB_TABLE_NAME']

ddb_client = boto3.client('dynamodb', region_name='us-east-1')

# increments visitor counter for given page_name 
# (DDB partition key is name of page)

# Note: boto3 docs indicate that update_item will create the item with
# the given partition key (which is the page name) if it does not already exist, so there is no need
# to test if the table already an entry for this page

def increment_page_counter(input_page_name):
    response = ddb_client.update_item(
        TableName=counter_table_name,
        Key={'page_name': {'S': input_page_name}},
        UpdateExpression='ADD visits :incr',
        ExpressionAttributeValues={
            ':incr': {'N': '1'}
        },
        ReturnValues='UPDATED_NEW'
    )
    return response

def lambda_handler(event, context):
    """
    Using the page_name from the event, increment the visitor counter 
    for that page
    """
    input_page_name = event['queryStringParameters']['page_name']
    response = increment_page_counter(input_page_name)
    return {
        'statusCode': 200,
        'body': response['Attributes']['visits']['N']
    }
