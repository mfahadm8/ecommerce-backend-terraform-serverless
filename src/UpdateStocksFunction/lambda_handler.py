import json
import psycopg2
import boto3


def get_secret(secret_name):
    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager')

    # Retrieve the secret value from Secrets Manager
    response = client.get_secret_value(SecretId=secret_name)

    # Parse and return the secret value
    if 'SecretString' in response:
        secret = json.loads(response['SecretString'])
        return secret
    else:
        raise Exception('Failed to retrieve secret value from Secrets Manager.')


def lambda_handler(event, context):
    # Retrieve the records from the SQS event
    records = event['Records']

    # Retrieve the database credentials from Secrets Manager
    secret_name = 'your-secret-name'  # Replace with your Secrets Manager secret name
    secret = get_secret(secret_name)

    # Extract the database credentials
    db_host = secret['host']
    db_port = secret['port']
    db_name = secret['dbname']
    db_username = secret['username']
    db_password = secret['password']

    # Extract the stock information from the SQS records and update the database
    for record in records:
        message_body = json.loads(record['body'])
        stock_update = message_body['stock_update']

        # Connect to the PostgreSQL database
        conn = psycopg2.connect(
            host=db_host,
            port=db_port,
            database=db_name,
            user=db_username,
            password=db_password
        )

        try:
            # Create a cursor object to interact with the database
            cursor = conn.cursor()

            # Update the stock in the ProductsInfo table
            cursor.execute(
                "UPDATE ProductsInfo SET stock_count = stock_count + %s WHERE product_name = %s",
                (stock_update, message_body['product_name'])
            )

            # Commit the changes to the database
            conn.commit()
        except Exception as e:
            # Handle any exceptions that occur during the database update
            print(f"Error updating stock: {e}")
        finally:
            # Close the cursor and database connection
            cursor.close()
            conn.close()

    return {
        'statusCode': 200,
        'body': 'Stocks updated successfully'
    }
