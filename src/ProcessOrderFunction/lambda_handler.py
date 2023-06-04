import json
import boto3
import os

sqs = boto3.client('sqs')
secrets_manager = boto3.client('secretsmanager')
pg = boto3.client('rds-data')
UPDATE_STOCKS_QUEUE_URL=os.environ("UPDATE_STOCKS_QUEUE_URL")

def lambda_handler(event, context):
    try:
        # Retrieve the PostgresDB credentials from Secrets Manager
        secret = secrets_manager.get_secret_value(SecretId='YOUR_POSTGRES_DB_CREDENTIALS_SECRET_ID')
        credentials = json.loads(secret['SecretString'])

        # Connect to the PostgresDB
        pg.execute_statement(
            secretArn=credentials['secretArn'],
            resourceArn=credentials['resourceArn'],
            sql='SELECT * FROM Orders'
        )

        # Process each message from SQS Queue 2
        for record in event['Records']:
            body = json.loads(record['body'])
            order_number = body['orderNumber']
            customer_name = body['customerName']

            # Perform the necessary processing logic for the order

            # Update the ProductInfo table in the PostgresDB
            pg.execute_statement(
                secretArn=credentials['secretArn'],
                resourceArn=credentials['resourceArn'],
                sql='UPDATE ProductInfo SET ...'
            )

            # Send a message to SQS Queue 3 or invoke another Lambda function for further processing

            # Delete the processed message from SQS Queue 2
            sqs.delete_message(
                QueueUrl=UPDATE_STOCKS_QUEUE_URL,
                ReceiptHandle=record['receiptHandle']
            )

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Orders processed successfully'
            })
        }
    except Exception as e:
        print('Error processing orders:', e)
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Internal Server Error'
            })
        }
