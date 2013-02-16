#!/bin/sh
. /root/.amazon_address_finder_key

region=`ec2-metadata | sed -n 's/^local-hostname: ip-[0-9-]*\.\(.*\)\.compute\.internal/\1/p'`

ec2-describe-instances --region $region -H --show-empty-fields | gawk '
BEGIN {OFS="\t"; print "127.0.0.1", "localhost localhost.localdomain"}
/^INSTANCE/ {ip = $18}
/^TAG/ {print ip, gensub(/.*\tName\t([^\t]*).*/, "\\1", $0)}
' > /etc/hosts
