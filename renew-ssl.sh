#!/bin/bash

# SSL 证书续期脚本
# 用法：./renew-ssl.sh

echo "正在续期 SSL 证书..."

# 续期证书
docker run --rm \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  -v $(pwd)/certbot/www:/var/www/certbot \
  certbot/certbot renew --dry-run

if [ $? -eq 0 ]; then
    echo "证书续期检查成功！"

    # 重新加载 nginx 配置
    echo "重新加载 nginx 配置..."
    docker-compose -f docker-compose.prod.yml exec nginx nginx -s reload

    echo "证书续期完成！"
else
    echo "证书续期失败！"
    exit 1
fi