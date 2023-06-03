import json
import boto3

secrets_manager = boto3.client('secretsmanager')
pg = boto3.client('rds-data')

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

        # Retrieve the customer orders from the Orders table
        orders = pg.fetchall()

        return {
            'statusCode': 200,
            'body': json.dumps(orders)
        }
    except Exception as e:
        print('Error retrieving customer orders:', e)
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Internal Server Error'
            })
        }
