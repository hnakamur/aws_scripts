#!/bin/sh
. /root/.amazon_address_finder_key

region=`ec2-metadata | sed -n 's/^local-hostname: ip-[0-9-]*\.\(.*\)\.compute\.internal/\1/p'`

ec2-describe-instances --region $region -H --show-empty-fields | sed -n '1i\
127.0.0.1\tlocalhost localhost.localdomain
/^INSTANCE/{
s/^[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t\([^\t]*\).*/\1/
h
}
/^TAG/{x;G;s/^\([^\n]*\)\n.*\tName\t\([^\t]*\).*/\1\t\2/p}
' > /etc/hosts

instance_id=`ec2-metadata | sed -n 's/^instance-id: //p'`
tag_name=`ec2-describe-instances --region $region -H --show-empty-fields $instance_id | sed -n '/^TAG/{s/.*\tName\t\([^\t]*\).*/\1/p}'`

hostname $tag_name
sed -i 's/^HOSTNAME=.*/HOSTNAME='$tag_name'/' /etc/sysconfig/network
