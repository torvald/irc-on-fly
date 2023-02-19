FROM debian:stable-slim as final
FROM debian:stable-slim as build

WORKDIR /app

# Glowing Bear
RUN apt update && apt install -y --no-install-recommends \
    npm \
    git
RUN git clone https://github.com/glowing-bear/glowing-bear.git
RUN cd glowing-bear/ && npm install
RUN cd glowing-bear/ && npm run build
RUN mkdir glowing-bear-build
RUN cp -r glowing-bear/build/* glowing-bear-build/

# So we dont need to ship 500mb of npm stuff
FROM final

WORKDIR /app

ARG user=weechat
ARG ssh_pub_key=keys/id.pub

RUN apt update && apt install -y --no-install-recommends \
    # nice to have
    # curl \
    # procps \
    # iproute2 \
    # net-tools \
    # ncdu \
    # the shit
    wget \
    mosh \
    openssh-server \
    screen \
    weechat \
    weechat-plugins \
    weechat-python \
    supervisor \
    ca-certificates \
    nginx

# Glowing Bear
COPY --from=build /app/glowing-bear-build /var/www/html

# Lets not run things as root
RUN useradd -ms /bin/bash $user

# User and weechat config
RUN mkdir /tmp/weechat/
COPY config/weechat/*.conf /tmp/weechat/
COPY scripts/start-weechat.sh .
RUN mkdir /tmp/weechat/plugins
RUN wget https://weechat.org/files/scripts/autojoin.py -O /tmp/weechat/plugins/autojoin.py

# ssh setup
RUN mkdir /run/sshd
COPY config/sshd_config /etc/ssh/sshd_config
# and keys
RUN mkdir /home/$user/.ssh/
COPY $ssh_pub_key id.pub
RUN cat id.pub >> /home/$user/.ssh/authorized_keys
RUN chown -R $user:$user /home/$user/.ssh

# supervisor
COPY config/supervisor.conf .
CMD supervisord -c supervisor.conf
