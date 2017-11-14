# rclone fails when s3 buckets use default encryption
## Manual test
To reproduce the bug, enable a default kms encryption key on an s3 bucket and try to rclone move a small file (small enough to not use multipart uploads). The rest of this document describes an automated test to reproduce the problem.

## Cost warning
Creating a kms key incurs a cost ($1 per month per key). S3 transfers also incur costs, but the transfer costs for this test are small compared to the cost of the key.

## Preconditions
This requires that you have the aws cli, bash, python, and rclone.
I have made some effort to make this test work with python 2.7 and 3.
The test should work on OS X or debian.

This was tested with an admin user on a near-empty aws account.

## Running the test
First, create a virtual environment for python:

`virtualenv venv`

`pip install -r requirements.txt`

This ensures that a current version of botocore is installed, which is necessary for the put_bucket_encryption call to succeed.

Now run the setup script:

`./setup.sh`

This creates a bucket, creates a kms key, associates the kms key as the default encryption key for the bucket, and makes a configuration file for rclone with a new access key and secret key.

You might want to wait approximately 30 seconds for the new access key to properly sync.

Now run the test script:

`./exercise_bug.sh`

This creates a small test file and a large test file (to force multipart uploads and get an etag back that doesn't look like an MD5).

## Cleanup
Run the cleanup script:

`./cleanup.sh`

This schedules the kms key for deletion, deletes the contents of the s3 bucket, deletes the s3 bucket, deletes the access key, deletes the rclone configuration, and deletes the test file that failed to move.
