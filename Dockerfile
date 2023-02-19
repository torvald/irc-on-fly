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

# So we dont need to package 500mb of npm stuff
FROM final

WORKDIR /app

ARG user=weechat
ARG ssh_pub_key=keys/id.pub

RUN apt update && apt install -y --no-install-recommends \
    # nice to have
    curl \
    procps \
    iproute2 \
    net-tools \
    # the shit
    mosh \
    ncdu \
    openssh-server \
    screen \
    weechat \
    weechat-plugins \
    supervisor \
    npm \
    git \
    nginx

# Glowing Bear
COPY --from=build /app/glowing-bear-build /var/www/html

# lets not run things as root
RUN useradd -ms /bin/bash $user

# irc user and weechat config
RUN mkdir /home/$user/.weechat
COPY config/irc.conf /home/$user/.weechat/irc.conf
COPY config/weechat.conf /home/$user/.weechat/weechat.conf
COPY config/relay.conf /home/$user/.weechat/relay.conf
RUN chown -R $user:$user /home/$user/.weechat

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
