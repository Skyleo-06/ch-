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

RUN curl -SSLs https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null && \
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | tee /etc/apt/sources.list.d/playit-cloud.list && \
    apt update && apt install -y playit

# 5. Copy script khởi chạy
COPY start-playit.sh /usr/local/bin/start-playit.sh
RUN chmod +x /usr/local/bin/start-playit.sh

# 6. Mở port (Thực tế Playit không cần mở port inbound, nhưng cứ để SSH hoạt động)
EXPOSE 22 8080

# 7. Chạy container
CMD ["/usr/local/bin/start-playit.sh"]
