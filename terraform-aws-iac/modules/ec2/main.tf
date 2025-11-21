resource "aws_instance" "web_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  associate_public_ip_address = true
  key_name                    = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    # Ghi lại log để dễ dàng gỡ lỗi (debug)
    exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

    echo "--- Bắt đầu script User Data ---"

    # 1. Cập nhật và Cài đặt các gói cơ bản (1 lần)
    apt-get update -y
    apt-get install -y \
      nginx \
      net-tools \
      nodejs \
      npm \
      zip \
      git \
      ca-certificates \
      curl \
      gnupg # Cần thiết cho việc quản lý key của Docker

    # 2. Cài đặt Docker (Theo phương pháp "keyring" MỚI và an toàn nhất)
    echo "--- Cài đặt Docker ---"
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    # Thêm repository của Docker vào APT
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Cập nhật APT một lần nữa sau khi thêm repo
    apt-get update -y

    # Cài đặt Docker VÀ Docker Compose V2 (plugin)
    echo "--- Cài đặt Docker Engine và Compose V2 ---"
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # 3. Cấu hình Docker cho user 'ubuntu' (Rất quan trọng)
    # Thêm user 'ubuntu' (user mặc định) vào nhóm 'docker'
    usermod -aG docker ubuntu

    # 4. Kích hoạt Nginx (từ script cũ)
    # echo "--- Kích hoạt Nginx ---"
    # systemctl start nginx
    # systemctl enable nginx

    # 5. Kiểm tra cài đặt
    echo "--- Cài đặt hoàn tất! Kiểm tra phiên bản ---"
    docker --version
    docker compose version # Chú ý: 'docker compose' (V2), không phải 'docker-compose'
    
    echo "--- Script User Data hoàn tất ---"
  EOF

  tags = {
    Name = "web-server"
  }
}
