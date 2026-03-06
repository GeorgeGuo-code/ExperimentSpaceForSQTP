#!/bin/bash

# SSL 证书初始化脚本（支持多域名）
# 用法：./init-ssl.sh "domain1.com domain2.com" email@example.com

if [ -z "$1" ]; then
    echo "用法: $0 \"域名列表\" [邮箱]"
    echo "示例: $0 \"example.com www.example.com\" admin@example.com"
    echo "示例（两个域名）: $0 \"example1.com example2.com\" admin@example.com"
    exit 1
fi

DOMAINS=$1
EMAIL=${2:-"admin@$(echo $DOMAINS | awk '{print $1}')"}

# 创建必要的目录
mkdir -p certbot/conf certbot/www

echo "正在获取 SSL 证书..."
echo "域名: $DOMAINS"
echo "邮箱: $EMAIL"

# 构建 certbot 域名参数
DOMAIN_ARGS=""
for domain in $DOMAINS; do
    DOMAIN_ARGS="$DOMAIN_ARGS -d $domain"
done

# 获取证书（使用 standalone 模式，因为 nginx 还未配置好）
docker run --rm \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  -v $(pwd)/certbot/www:/var/www/certbot \
  -p 80:80 \
  certbot/certbot certonly --standalone \
  $DOMAIN_ARGS \
  --email $EMAIL \
  --agree-tos \
  --non-interactive

if [ $? -eq 0 ]; then
    echo "SSL 证书获取成功！"
    echo "已包含的域名: $DOMAINS"
    echo "请编辑 nginx.conf，更新 server_name 配置"
    echo "然后运行: docker-compose -f docker-compose.prod.yml up -d nginx"
else
    echo "SSL 证书获取失败！"
    exit 1
fi