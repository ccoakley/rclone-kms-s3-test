#!/bin/bash

# first, we create a key
if [[ ! -f $(which aws) ]]; then
  echo "You must have the aws command line tools installed."
  exit 1
fi

# I have faith in uuid uniqueness, but feel free to use your own
uuid=$(python -c 'from __future__ import print_function; import uuid; print(uuid.uuid4().hex)')
keyname=key_${uuid}
bucketname=bucket_${uuid}

echo "bucketname=${bucketname}" > settings.sh

# create an s3 bucket
aws s3 mb s3://${bucketname} || aws_err=1

if [[ newkey -eq 1 ]]; then
  echo "bucket creation failure"
  exit 1
fi

# create a kms key
keyout=$(aws kms create-key --description test_rclone_bug_key_${uuid} --output=json)
arn=$(echo $keyout | python -c 'from __future__ import print_function; import sys, json; print(json.load(sys.stdin)["KeyMetadata"]["Arn"])')

if [ ! $(echo $arn | grep arn | grep aws | grep kms | grep key) ]; then
  echo "key creation failure"
  exit 1
fi

echo "arn=${arn}" >> settings.sh

# configure rclone
# this is a bit invasive, so if you are paranoid, make an explicit rclone.conf and kill this
access_key_output=$(aws iam create-access-key --output=json)
access_key=$(echo ${access_key_output} | python -c 'from __future__ import print_function; import sys, json; print(json.load(sys.stdin)["AccessKey"]["AccessKeyId"])')
secret_key=$(echo ${access_key_output} | python -c 'from __future__ import print_function; import sys, json; print(json.load(sys.stdin)["AccessKey"]["SecretAccessKey"])')

echo "access_key=${access_key}" >> settings.sh

echo "[s3]" > rclone.conf
echo "type = s3" >> rclone.conf
echo "env_auth = false" >> rclone.conf
echo "access_key_id = ${access_key}" >> rclone.conf
echo "secret_access_key = ${secret_key}" >> rclone.conf


# invoke python to use current botocore (via boto3)
# my cli was not current and prevented finishing the setup in cli land
python finish_setup.py $bucketname $arn
