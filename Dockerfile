FROM debian:stable-slim

WORKDIR /app

RUN apt update && apt install -y \
    # nice to have
    curl \
    procps \
    iproute2 \
    # the shit
    mosh \
    ncdu \
    net-tools \
    oidentd \
    openssh-server \
    screen \
    weechat \
    supervisor


RUN apt install -y npm git nginx --no-install-recommends

# Glowing Bear
RUN git clone https://github.com/glowing-bear/glowing-bear.git
RUN cd glowing-bear/ && npm install
RUN cd glowing-bear/ && npm run build
RUN cp -r glowing-bear/build/* /var/www/html/

# irc user and weechat config
RUN useradd -ms /bin/bash torvald
RUN mkdir /home/torvald/.weechat
COPY config/irc.conf /home/torvald/.weechat/irc.conf
COPY config/weechat.conf /home/torvald/.weechat/weechat.conf
COPY config/relay.conf /home/torvald/.weechat/relay.conf
RUN chown -R torvald:torvald /home/torvald/.weechat

# ssh setup
RUN mkdir /run/sshd

COPY startup.sh .
RUN chmod a+x startup.sh

# supervisor
COPY config/supervisor.conf .
CMD supervisord -c supervisor.conf

EXPOSE 2222
