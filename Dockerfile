# Sử dụng Ubuntu 22.04 cơ bản
FROM ubuntu:22.04

# 1. Thiết lập môi trường để không bị hỏi khi cài đặt
ENV DEBIAN_FRONTEND=noninteractive
ENV VNC_RESOLUTION=1280x720
ENV VNC_PW=123456

# 2. Cài đặt các công cụ cơ bản & Desktop XFCE
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg2 \
    software-properties-common \
    supervisor \
    xfce4 \
    xfce4-terminal \
    tigervnc-standalone-server \
    novnc \
    websockify \
    net-tools \
    dbus-x11 \
    xz-utils \
    & rm -rf /var/lib/apt/lists/*

# 3. Cài FIREFOX (Bản Native từ PPA - Không dùng Snap)
# Thêm PPA, chặn Snap, và cài đặt
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    apt-get update && \
    apt-get install -y firefox

# 4. Cài qBittorrent-nox (Phiên bản Web UI)
RUN apt-get install -y qbittorrent-nox

# 5. Cấu hình Supervisord (Quản lý đa nhiệm)
# Tạo file cấu hình để chạy song song: VNC, noVNC, qBittorrent
RUN mkdir -p /var/log/supervisor
RUN echo "[supervisord]" > /etc/supervisor/conf.d/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    # Cấu hình Xvnc (Server hình ảnh)
    echo "[program:xvnc]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=/usr/bin/Xvnc :1 -geometry $VNC_RESOLUTION -depth 24 -rfbauth /root/.vnc/passwd" >> /etc/supervisor/conf.d/supervisord.conf && \
    # Cấu hình XFCE (Giao diện)
    echo "[program:xfce]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=dbus-launch /usr/bin/startxfce4" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "environment=DISPLAY=\":1\",HOME=\"/root\",USER=\"root\"" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    # Cấu hình noVNC (Web Remote)
    echo "[program:novnc]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=/usr/share/novnc/utils/launch.sh --vnc localhost:5901 --listen 6080" >> /etc/supervisor/conf.d/supervisord.conf && \
    # Cấu hình qBittorrent (Web UI)
    echo "[program:qbittorrent]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=qbittorrent-nox --webui-port=8080 --confirm-legal-notice" >> /etc/supervisor/conf.d/supervisord.conf

# 6. Thiết lập Script khởi động (Đặt mật khẩu VNC)
RUN echo "#!/bin/bash" > /entrypoint.sh && \
    echo "mkdir -p /root/.vnc" >> /entrypoint.sh && \
    echo "echo \$VNC_PW | vncpasswd -f > /root/.vnc/passwd" >> /entrypoint.sh && \
    echo "chmod 600 /root/.vnc/passwd" >> /entrypoint.sh && \
    echo "exec /usr/bin/supervisord" >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Mở các cổng cần thiết
# 6080: Cổng vào noVNC (Desktop)
# 8080: Cổng vào qBittorrent
EXPOSE 6080 8080

# Chạy
CMD ["/entrypoint.sh"]
