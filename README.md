scripts for Amazon web service

## Update hosts by tag names of instances in the region.

cp .amazon_address_finder_key.sample /root/.amazon_address_finder_key

edit it.

install update_hosts.sh /usr/local/sbin/
install cron.d.update_hosts /etc/cron.d/update_hosts
