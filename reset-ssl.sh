#!/bin/bash

# 完全重置 SSL 证书
# 用法：./reset-ssl.sh

echo "警告：这将删除所有现有的 SSL 证书！"
read -p "确认删除？: " confirm

if [ "$confirm" != "yes" ]; then
    echo "取消操作"
    exit 0
fi

# 停止所有服务
echo "停止所有服务..."
docker-compose -f docker-compose.prod.yml down

# 删除所有证书
echo "删除所有证书..."
docker run --rm \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  certbot/certbot delete --non-interactive --cert-name $(docker run --rm -v $(pwd)/certbot/conf:/etc/letsencrypt certbot/certbot certificates 2>/dev/null | grep "Certificate Name:" | awk '{print $3}')

# 清理证书目录
echo "清理证书目录..."
rm -rf certbot/conf/* certbot/www/*

echo "SSL 证书已完全重置！"
echo "请运行 ./init-ssl.sh <域名> <邮箱> 重新获取证书"