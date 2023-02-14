#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# openssl req -nodes -newkey rsa:2048 -keyout relay.pem -x509 -subj "/C=US/ST=Cyberspace/L=NoWhere /O=.../OU=.../CN=.../emailAddress=..." -out /tmp/relay.pem

# mkdir -p ~torvald/.weechat/ssl
# cat /etc/letsencrypt/live/localhost/{fullchain,privkey}.pem > ~username/.weechat/ssl/relay.pem
# chown -R username:username ~username/.weechat/ssl/

echo "Done!"
