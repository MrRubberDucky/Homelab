#!/bin/bash
# Grabs current Cloudflare IPs and just dumps them to terminal. Amazing.
for i in `curl -s https://www.cloudflare.com/ips-v4`; do echo -n "$i "; done
for i in `curl -s https://www.cloudflare.com/ips-v6`; do echo -n "$i "; done
echo
