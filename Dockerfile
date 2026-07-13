FROM debian:stable-slim

# Installa SSH server, client, sudo e curl
RUN apt-get update && apt-get install -y \
    openssh-server \
    openssh-client \
    sudo \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Crea utente e imposta password
RUN useradd -m -u 1000 user && echo "user:password" | chpasswd

# Aggiungi user al gruppo sudo e permetti sudo senza password
RUN usermod -aG sudo user && \
    echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Crea la directory per SSH e configura il server
RUN mkdir -p /var/run/sshd

# Abilita l'accesso TTY e la shell interattiva
RUN sed -i 's/^#PermitTTY yes/PermitTTY yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# Script di avvio
RUN echo '#!/bin/bash\n\
service ssh start\n\
sleep 2\n\
ALIAS=$(hostname | cut -c1-10)\n\
echo "Avvio tunnel Serveo per SSH..."\n\
ssh -o StrictHostKeyChecking=no -R $ALIAS:22:localhost:22 serveo.net &\n\
echo "Tunnel avviato su serveo.net con alias: $ALIAS"\n\
echo "Per connetterti: ssh -J serveo.net user@$ALIAS"\n\
echo "Password: password"\n\
tail -f /dev/null\n\
' > /start.sh && chmod +x /start.sh

EXPOSE 22
CMD ["/bin/bash", "/start.sh"]
