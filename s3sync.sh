#!/bin/sh

# s3sync.sh - sync specified directories in s3 buckets via local.
#
# Usage:
#   s3sync.sh [--dry-run] src dest
# * src and dest is one of local|test|staging|production
# * src must not be the same as dest
# * one of src and dest must be local
#
# Typical use cases:
#
# * Download files in test bucket to local.
#   s3sync.sh test local
#
# * Upload file in local to staging bucket.
#   s3sync.sh local staging
#
# * Upload file in local to production bucket.
#   s3sync.sh local production
#
# Prerequisites:
#   This script depends on s3cmd http://s3tools.org/s3cmd
#   Please run s3cmd --configure to make .s3cfg
#
# Copyright (c) 2013 Hiroaki Nakamura <hnakamur@gmail.com>
#
# License:
#   MIT

# Settings: edit these for your environment
localdir=~/s3work
paths="\
/foo/ \
/bar/ \
"
test_bucket=${your_test_bucket_here}
staging_bucket=${your_staging_bucket_here}
production_bucket=${your_production_bucket_here}



if [ $# -ne 2 -a $# -ne 3 ]; then
  cat <<EOF
Usage: $0 [--dry-run] src dest
src or dest: one of local, test, staging, production
EOF
  exit 1
fi

if [ "$1" = "--dry-run" ]; then
  dry_run=$1
  shift
else
  dry_run=
fi

if [ "$1" = "$2" ]; then
  echo Error: src and dest cannot be same.
  exit 1
fi

if [ "$1" = "local" ]; then
  op=upload
  remote=$2
elif [ "$2" = "local" ]; then
  op=download
  remote=$1
else
  echo Error: src or dest must be local.
  exit 1
fi

case $remote in
test)
  bucket=$test_bucket
  ;;
staging)
  bucket=$staging_bucket
  ;;
production)
  bucket=$production_bucket
  ;;
*)
  echo Error: remote must be one of test|staging|production
  ;;
esac

s3url=s3://$bucket
if [ $op = download ]; then
  src=$s3url
  dest=$localdir
else
  src=$localdir
  dest=$s3url
fi

for path in $paths; do
  if [ $op = download -a ! -d ${dest}$path ]; then
    mkdir -p ${dest}$path
  fi
  s3cmd sync $dry_run --recursive ${src}$path ${dest}$path
done
