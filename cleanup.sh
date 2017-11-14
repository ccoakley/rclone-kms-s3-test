#!/bin/bash

. settings.sh

aws s3 rm s3://${bucketname}/copy_large.txt
aws s3 rb s3://${bucketname}
aws kms schedule-key-deletion --key-id ${arn} --pending-window-in-days 7
aws iam delete-access-key --access-key-id ${access_key}

rm copy_small.txt
if [[ -f ./copy_large.txt ]]; then
  echo I did not expect to see copy_large.txt, but I will clean it up
  rm copy_large.txt
fi
rm rclone.conf
rm settings.sh
