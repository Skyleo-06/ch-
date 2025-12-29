FROM ubuntu:22.04

# -----------------------------
# Install required packages
# -----------------------------
RUN apt update && apt install -y \
    openssh-server \
    curl \
    wget \
    unzip \
    sudo \
    python3 \
    # Thêm gói này để tải cloudflared
    ca-certificates \
    && mkdir /var/run/sshd

# -----------------------------
# Create user 'trthaodev'
# -----------------------------
RUN useradd -m trthaodev && echo "trthaodev:thaodev@" | chpasswd && adduser trthaodev sudo

# -----------------------------
# Configure SSH
# -----------------------------
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'ClientAliveInterval 60' >> /etc/ssh/sshd_config && \
    echo 'ClientAliveCountMax 3' >> /etc/ssh/sshd_config

# -----------------------------
# Install Cloudflare Tunnel (Thay thế Ngrok)
# -----------------------------
RUN curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && \
    dpkg -i cloudflared.deb && \
    rm cloudflared.deb

# -----------------------------
# Copy start script
# -----------------------------
COPY start-cloudflared.sh /usr/local/bin/start-cloudflared.sh
RUN chmod +x /usr/local/bin/start-cloudflared.sh

# -----------------------------
# Expose ports
# -----------------------------
EXPOSE 8080 22

# -----------------------------
# Start container
# -----------------------------
CMD ["/usr/local/bin/start-cloudflared.sh"]
