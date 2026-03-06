#!/bin/bash

# 数据库备份脚本
# 用法：./backup.sh

# 配置
BACKUP_DIR="/opt/tutome/backups"
POSTGRES_USER="${POSTGRES_USER:-george_guo}"
POSTGRES_DB="${POSTGRES_DB:-george_guo}"
CONTAINER_NAME="postgres_db_prod"
RETENTION_DAYS=7

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 生成备份文件名
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/db_backup_$DATE.sql"
COMPRESSED_FILE="$BACKUP_FILE.gz"

echo "开始数据库备份: $DATE"

# 备份数据库
docker exec "$CONTAINER_NAME" pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" > "$BACKUP_FILE" 2>/dev/null

if [ $? -eq 0 ]; then
    # 压缩备份文件
    gzip "$BACKUP_FILE"
    
    # 获取文件大小
    SIZE=$(du -h "$COMPRESSED_FILE" | cut -f1)
    echo "备份成功: $COMPRESSED_FILE ($SIZE)"
    
    # 清理旧备份
    find "$BACKUP_DIR" -name "db_backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete
    echo "已清理 $RETENTION_DAYS 天前的旧备份"
else
    echo "备份失败！"
    rm -f "$BACKUP_FILE"
    exit 1
fi