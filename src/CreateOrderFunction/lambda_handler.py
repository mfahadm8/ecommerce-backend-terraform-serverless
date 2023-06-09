import json
import boto3
import os


sqs = boto3.client('sqs')
ORDER_PROCESSING_QUEUE_URL=os.environ("ORDER_PROCESSING_QUEUE_URL")
def lambda_handler(event, context):
    try:
        # Parse the request body to extract the necessary order information
        body = json.loads(event['body'])
        order_number = body['orderNumber']
        customer_name = body['customerName']

        # Create a message with the order information
        message = {
            'orderNumber': order_number,
            'customerName': customer_name
        }

        # Send the message to the SQS Queue 1
        sqs.send_message(
            QueueUrl=ORDER_PROCESSING_QUEUE_URL,
            MessageBody=json.dumps(message)
        )

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Order created successfully'
            })
        }
    except Exception as e:
        print('Error creating order:', e)
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Internal Server Error'
            })
        }
