FROM debian:stable-slim

RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
    | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
    && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
    | tee /etc/apt/sources.list.d/ngrok.list \
    && apt-get update && apt-get install -y ngrok \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 user && echo "user:password" | chpasswd
RUN mkdir -p /var/run/sshd

RUN echo '#!/bin/bash\n\
service ssh start\n\
if [ "$NGROK_ENABLED" = "true" ] && [ -n "$NGROK_AUTHTOKEN" ]; then\n\
    ngrok config add-authtoken $NGROK_AUTHTOKEN\n\
    ngrok tcp 22 --log=stdout\n\
else\n\
    tail -f /dev/null\n\
fi' > /start.sh && chmod +x /start.sh

EXPOSE 22
CMD ["/bin/bash", "/start.sh"]
