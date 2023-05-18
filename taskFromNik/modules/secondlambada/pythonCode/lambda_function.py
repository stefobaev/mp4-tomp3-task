import boto3
import json
from botocore.exceptions import ClientError

sqs = boto3.client('sqs')
s3 = boto3.client('s3')
ses = boto3.client('ses')

def lambda_handler(event,context):
    # URL of the SQS queue
    queue_url = 'your-queque'
    
    response = sqs.receive_message(
        QueueUrl=queue_url,
        MaxNumberOfMessages=1
    )

    if 'Messages' in response:
        message = response['Messages'][0]
        receipt_handle = message['ReceiptHandle']
        
        body = json.loads(message['Body'])
        filename,email = body.get('filename'),body.get('email')
        
        print(f"I got the following: {filename} and {email}")
        
        bucket = 'your-bucket'
        object_key = f'processed/{filename}'
        
        url = s3.generate_presigned_url(
            'get_object',
            Params={
                'Bucket': bucket,
                'Key': object_key
            },
            ExpiresIn=3600
        )
        
        subject = 'Your file is ready for download'
        message = f"Hello, \n\nYour processed file {filename} is ready for download at: \n\n{url}"
        
        try:
            ses.send_email(
                Source='your-email',
                Destination={
                    'ToAddresses': [email]
                },
                Message={
                    'Subject': {
                        'Data': subject
                    },
                    'Body': {
                        'Text': {
                            'Data': message
                        }
                    }
                }
            )
            print(f"Email sent to {email} with presigned URL for file {filename}")
        except ClientError as e:
            print(f"Error sending email: {e}")
                
        sqs.delete_message(
            QueueUrl=queue_url,
            ReceiptHandle=receipt_handle
        )
    else:
        print("No messages in queue")
