#!/bin/bash

# 使用 DNS 验证获取 SSL 证书
# 用法：./init-ssl-dns.sh yourdomain.com email@example.com

if [ -z "$1" ]; then
    echo "用法: $0 <域名> [邮箱]"
    echo "示例: $0 example.com admin@example.com"
    echo ""
    echo "支持的 DNS 提供商："
    echo "  - Cloudflare: --dns-cloudflare"
    echo "  - 腾讯云: --dns-dnspod"
    echo "  - 阿里云: --dns-aliyun"
    exit 1
fi

DOMAIN=$1
EMAIL=${2:-"admin@$DOMAIN"}

# 创建必要的目录
mkdir -p certbot/conf certbot/www

echo "正在使用 DNS 验证获取 SSL 证书..."
echo "域名: $DOMAIN"
echo "邮箱: $EMAIL"

# 首先尝试 DNS 验证
docker run --rm \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  -v $(pwd)/certbot/www:/var/www/certbot \
  certbot/certbot certonly --manual \
  -d $DOMAIN \
  -d www.$DOMAIN \
  --email $EMAIL \
  --agree-tos \
  --manual-public-ip-logging-ok \
  --preferred-challenges dns \
  --non-interactive \
  --manual-dns-cred /etc/letsencrypt/dns-credentials.ini

if [ $? -eq 0 ]; then
    echo "SSL 证书获取成功！"
    echo "请编辑 nginx.conf，将 'yourdomain.com' 替换为 '$DOMAIN'"
    echo "然后运行: docker-compose -f docker-compose.prod.yml up -d nginx"
else
    echo "SSL 证书获取失败！"
    echo "请确保："
    echo "1. 域名已正确解析到服务器 IP"
    echo "2. DNS 提供商的 API 凭证已配置"
    exit 1
fi