import boto3
import os


# Init SES client
ses = boto3.client('ses')


def lambda_handler(event, context):
    # Get bucket name and team email from Lambda event
    bucket_name = os.environ.get("bucket_name")
    team_email = os.environ.get("target_email")

    # Delete objects in bucket
    s3 = boto3.resource('s3')
    bucket = s3.Bucket(bucket_name)
    deleted_objects = []
    for obj in bucket.objects.all():
        obj.delete()
        deleted_objects.append(obj.key)

    # Check if all objects were deleted
    remaining_objects = [obj.key for obj in bucket.objects.all()]
    if len(remaining_objects) == 0:
        exit
    else:
        # Send an email to the team
        subject = f"Failed to delete objects in S3 bucket {bucket_name}"
        body = f"The following objects could not be deleted: {remaining_objects}"
        response = ses.send_email(
            Source=team_email,
            Destination={'ToAddresses': [team_email]},
            Message={
                'Subject': {'Data': subject},
                'Body': {'Text': {'Data': body}}
            }
        )
