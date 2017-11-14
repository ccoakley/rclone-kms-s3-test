from __future__ import print_function

import boto3
import uuid
import sys
import time

client = boto3.client('s3')

def set_default_encryption(bucket, key_arn):
    """
    This is similar to the UI setting
    :param bucket: S3 Bucket name
    :param key_arn: KMS key arn
    :return:
    """
    response = client.put_bucket_encryption(
        Bucket=bucket,
        ServerSideEncryptionConfiguration={
            'Rules': [
                {
                    'ApplyServerSideEncryptionByDefault': {
                        'SSEAlgorithm': 'aws:kms',
                        'KMSMasterKeyID': key_arn
                    }
                },
            ]
        }
    )
    print(response)


def wait_for_update(bucket, key_arn):
    """
    Waits to verify the bucket reflects the encryption settings
    :param bucket: S3 Bucket name
    :param key_arn: KMS key arn
    :return:
    """
    response = client.get_bucket_encryption(Bucket=bucket)
    failure_counter = 0
    while not 'ServerSideEncryptionConfiguration' in response and \
            'Rules' in response['ServerSideEncryptionConfiguration'] and \
            'ApplyServerSideEncryptionByDefault' in response['ServerSideEncryptionConfiguration']['Rules'][0] and \
            'KMSMasterKeyID' in response['ServerSideEncryptionConfiguration']['Rules'][0]['ApplyServerSideEncryptionByDefault'] and \
            key_arn == response['ServerSideEncryptionConfiguration']['Rules'][0]['ApplyServerSideEncryptionByDefault']['KMSMasterKeyID']:
        if failure_counter > 5:
            print("Bucket not reflecting encryption update, aborting")
            sys.exit(1)
        failure_counter += 1
        time.sleep(10)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python finish_setup.py bucketname kms_arn")
        sys.exit(1)
    bucket = sys.argv[1]
    arn = sys.argv[2]
    set_default_encryption(bucket, arn)
    wait_for_update(bucket, arn)
