# HTTPS 配置指南

## 前置条件

1. 域名已解析到服务器 IP
2. 服务器 80 和 443 端口已开放
3. 已安装 Docker 和 Docker Compose

## 配置步骤

### 1. 修改 nginx.conf

编辑 `nginx.conf`，将 `yourdomain.com` 替换为你的实际域名：

```bash
nano nginx.conf
```

找到并修改：
```nginx
ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
```

改为：
```nginx
ssl_certificate /etc/letsencrypt/live/你的域名/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/你的域名/privkey.pem;
```

### 2. 获取 SSL 证书

```bash
# 赋予脚本执行权限
chmod +x init-ssl.sh

# 获取证书（替换为你的域名和邮箱）
./init-ssl.sh example.com admin@example.com
```

### 3. 启动所有服务

```bash
# 停止现有服务
docker-compose -f docker-compose.prod.yml down

# 启动所有服务（包括 nginx）
docker-compose -f docker-compose.prod.yml up -d
```

### 4. 验证 HTTPS

访问 `https://你的域名`，应该能看到浏览器地址栏显示安全锁图标。

## 自动续期配置

### 方式一：使用 cron 定时任务

```bash
# 编辑 crontab
crontab -e
```

添加以下内容（每周一凌晨 3 点检查续期）：
```
0 3 * * 1 cd /opt/tutome && ./renew-ssl.sh >> /opt/tutome/certbot/renew.log 2>&1
```

### 方式二：使用 certbot 自动续期（推荐）

Certbot 会自动续期证书，无需手动配置 cron。证书有效期为 90 天，certbot 会在到期前 30 天自动续期。

## 手动续期

```bash
# 赋予脚本执行权限
chmod +x renew-ssl.sh

# 手动续期
./renew-ssl.sh
```

## 故障排查

### 检查证书状态

```bash
# 查看证书详情
docker run --rm \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  certbot/certbot certificates

# 测试续期（不实际续期）
docker run --rm \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  -v $(pwd)/certbot/www:/var/www/certbot \
  certbot/certbot renew --dry-run
```

### 查看日志

```bash
# nginx 日志
docker logs nginx_proxy

# certbot 日志
docker logs certbot
```

### 重新获取证书

如果证书过期或配置错误，可以重新获取：

```bash
# 删除旧证书
docker run --rm \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  certbot/certbot delete --cert-name yourdomain.com

# 重新获取
./init-ssl.sh yourdomain.com admin@example.com
```

## 安全建议

1. **定期检查证书状态**：每月检查一次证书是否正常续期
2. **配置监控**：使用监控工具监控 HTTPS 服务状态
3. **备份证书**：定期备份 `certbot/conf` 目录
4. **使用强密码**：确保服务器和数据库密码足够复杂

## 目录结构

```
/opt/tutome/
├── certbot/
│   ├── conf/          # SSL 证书配置
│   └── www/           # Let's Encrypt 验证文件
├── nginx.conf         # Nginx 配置
├── init-ssl.sh        # 初始化 SSL 证书脚本
├── renew-ssl.sh       # 续期 SSL 证书脚本
└── docker-compose.prod.yml
```

## 注意事项

1. 首次获取证书需要确保 80 端口未被占用
2. 域名必须正确解析到服务器 IP
3. 防火墙必须开放 80 和 443 端口
4. 证书续期需要 nginx 服务正常运行