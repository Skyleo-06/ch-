FROM ubuntu:22.04

# --- 1. CÀI ĐẶT MÔI TRƯỜNG ---
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    sudo \
    nano \
    unzip \
    ca-certificates \
    procps \
    net-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# --- 2. TẠO USER 'trthaodev' (Full quyền Sudo không cần mật khẩu) ---
RUN useradd -m -s /bin/bash trthaodev && \
    echo "trthaodev:thaodev@" | chpasswd && \
    usermod -aG sudo trthaodev && \
    echo "trthaodev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# --- 3. CÀI ĐẶT CLOUDFLARED (Tunnel) ---
RUN wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && \
    dpkg -i cloudflared-linux-amd64.deb && \
    rm cloudflared-linux-amd64.deb

# --- 4. CÀI ĐẶT FILEBROWSER (Quản lý File & Web Terminal) ---
RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

# --- 5. SCRIPT KHỞI ĐỘNG (Xử lý Token thông minh) ---
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'echo "=== KHOI DONG SERVER (MODE: TOKEN) ==="' >> /start.sh && \
    echo '' >> /start.sh && \
    # Kiểm tra xem người dùng đã nhập Token chưa
    echo 'if [ -z "$CF_TOKEN" ]; then' >> /start.sh && \
    echo '  echo "❌ LOI: Ban chua nhap Cloudflare Token!"' >> /start.sh && \
    echo '  echo "👉 Hay them tham so: -e CF_TOKEN=eyJ..."' >> /start.sh && \
    echo '  echo "   vao lenh docker run cua ban."' >> /start.sh && \
    echo '  exit 1' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo '' >> /start.sh && \
    # 1. Chạy FileBrowser (Cổng 8080, Root path, Không pass)
    echo 'echo "1. Dang chay FileBrowser (Web Admin)..."' >> /start.sh && \
    echo 'nohup filebrowser -r / -p 8080 --no-auth > /var/log/fb.log 2>&1 &' >> /start.sh && \
    echo '' >> /start.sh && \
    # 2. Chạy Cloudflare Tunnel với Token
    echo 'echo "2. Dang ket noi Cloudflare..."' >> /start.sh && \
    # Chạy cloudflared và giữ process này làm main process (để Docker không tắt)
    echo 'cloudflared tunnel run --token $CF_TOKEN' >> /start.sh && \
    chmod +x /start.sh

# --- 6. CHẠY ---
EXPOSE 8080
CMD ["/start.sh"]
