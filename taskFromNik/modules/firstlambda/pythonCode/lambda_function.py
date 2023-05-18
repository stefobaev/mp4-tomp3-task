import boto3
import os
import tempfile
import json
from moviepy.editor import VideoFileClip

s3 = boto3.client('s3')
sqs = boto3.client('sqs')
queue_url = "your-queque"

def lambda_handler(event,context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    
    input_file = '/tmp/input.mp4'
    output_file = '/tmp/output.mp3'
    
    with open(input_file, 'wb') as f:
        s3.download_fileobj(bucket,key,f)
        
    clip = VideoFileClip(input_file)
    clip.audio.write_audiofile(output_file)
    
    processed_key = 'processed/'+output_file.strip('/tmp')
    s3.upload_file(output_file,bucket,processed_key)
    
    response = s3.head_object(Bucket=bucket, Key=key)
    email = response['Metadata']['email']
    
    message = {
        'filename': output_file.strip('/tmp/'),
        'email': email
    }
    
    
    response = sqs.send_message(
        QueueUrl = queue_url,
        MessageBody = json.dumps(message)
        )
        
    os.remove(input_file)
    os.remove(output_file)
