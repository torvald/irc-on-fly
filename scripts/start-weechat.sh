#!/bin/bash

# ensure folder exists
mkdir -p /home/weechat/.weechat/plugins/

# .weechat might be a mounted volume
chown -R weechat:weechat /home/weechat/.weechat

# get config weechat config from the repo and plugins from build
su weechat -c "cd && \
    /bin/cp /tmp/weechat/*.conf .weechat/ && \
    /bin/cp /tmp/weechat/plugins/* .weechat/plugins/ && \
    /usr/bin/screen -S weechat -d -m weechat"
