#!/bin/bash

# load the bucket and key arn
. settings.sh

# create a random txt file.
cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 32 | head -c 1000 > copy_small.txt

rclone -vv --config ./rclone.conf move copy_small.txt s3:${bucketname}

# create a larger txt file.
cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 32 | head -c 5500000 > copy_large.txt

rclone --config ./rclone.conf move copy_large.txt s3:${bucketname}
