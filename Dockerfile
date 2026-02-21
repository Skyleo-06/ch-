FROM ubuntu:22.04

# --- 1. CÀI ĐẶT MÔI TRƯỜNG ---
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    curl wget sudo nano unzip \
    openssh-server \
    net-tools iputils-ping \
    ca-certificates \
    python3 python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /var/run/sshd

# --- 2. CẤU HÌNH SSH ---
# Đổi port SSH trong container thành 2222 để tránh trùng với Port 22 của VPS chủ
RUN sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# --- 3. TẠO USER & MẬT KHẨU ---
RUN useradd -m -s /bin/bash trthaodev && \
    echo "trthaodev:thaodev@" | chpasswd && \
    usermod -aG sudo trthaodev && \
    echo "root:123456" | chpasswd

EXPOSE 2222 8080
CMD ["/start.sh"]
