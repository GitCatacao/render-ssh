FROM debian:stable-slim

# Installa SSH server e client (per Serveo)
RUN apt-get update && apt-get install -y \
    openssh-server \
    openssh-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Crea utente e imposta password
RUN useradd -m -u 1000 user && echo "user:password" | chpasswd
RUN mkdir -p /var/run/sshd

# Script di avvio che avvia SSH e crea il tunnel Serveo
RUN echo '#!/bin/bash\n\
service ssh start\n\
sleep 2\n\
# Crea un alias unico per il tunnel (usa l'hostname del container)\n\
ALIAS=$(hostname | cut -c1-10)\n\
echo "Avvio tunnel Serveo per SSH..."\n\
# Tunnel TCP privato per SSH (porta 22)\n\
ssh -o StrictHostKeyChecking=no -R $ALIAS:22:localhost:22 serveo.net &\n\
echo "Tunnel avviato su serveo.net con alias: $ALIAS"\n\
echo "Per connetterti: ssh -J serveo.net user@$ALIAS"\n\
echo "Password: password"\n\
# Mantieni il container in esecuzione\n\
tail -f /dev/null\n\
' > /start.sh && chmod +x /start.sh

EXPOSE 22
CMD ["/bin/bash", "/start.sh"]
