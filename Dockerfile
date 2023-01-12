FROM debian:stable-slim

WORKDIR /app

RUN apt update && apt install -y \
    # nice to have
    curl \
    procps \
    iproute2 \
    # the shit
    weechat \
    supervisor

COPY startup.sh .
RUN chmod a+x startup.sh

COPY config/supervisor.conf .
CMD supervisord -c supervisor.conf

EXPOSE 2222
