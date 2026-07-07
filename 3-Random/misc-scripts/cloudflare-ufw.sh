#!/bin/sh
# Not sure where I got this one from but all it does is add Cloudflare IP ranges to ufw
curl -s https://www.cloudflare.com/ips-v4 -o /tmp/cf_ips
printf "\n" >> /tmp/cf_ips
curl -s https://www.cloudflare.com/ips-v6 >> /tmp/cf_ips
for ip in `cat /tmp/cf_ips`; do ufw allow proto tcp from $ip to any port 80,443 comment 'Cloudflare'; done
rm /tmp/cf_ips
ufw reloadcurl -s https://www.cloudflare.com/ips-v4 -o /tmp/cf_ips
curl -s https://www.cloudflare.com/ips-v6 >> /tmp/cf_ips
for ip in `cat /tmp/cf_ips`; do ufw allow proto tcp from $ip to any port 80,443 comment 'Cloudflare'; done
rm /tmp/cf_ips
ufw reload
