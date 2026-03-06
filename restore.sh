#!/bin/bash

# 数据库恢复脚本
# 用法：./restore.sh <备份文件名>

if [ -z "$1" ]; then
    echo "用法: $0 <备份文件名>"
    echo "示例: $0 db_backup_20240306_020000.sql.gz"
    echo ""
    echo "可用的备份文件："
    ls -lh /opt/tutome/backups/*.sql.gz 2>/dev/null || echo "未找到备份文件"
    exit 1
fi

# 配置
BACKUP_DIR="/opt/tutome/backups"
BACKUP_FILE="$BACKUP_DIR/$1"
TEMP_FILE="/tmp/db_restore_temp.sql"
POSTGRES_USER="${POSTGRES_USER:-george_guo}"
POSTGRES_DB="${POSTGRES_DB:-george_guo}"
CONTAINER_NAME="postgres_db_prod"

# 检查备份文件是否存在
if [ ! -f "$BACKUP_FILE" ]; then
    echo "错误: 备份文件不存在: $BACKUP_FILE"
    exit 1
fi

echo "警告: 这将覆盖当前数据库！"
read -p "确认恢复？(yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "取消恢复"
    exit 0
fi

# 解压备份文件
echo "解压备份文件..."
gunzip -c "$BACKUP_FILE" > "$TEMP_FILE"

if [ $? -ne 0 ]; then
    echo "解压失败！"
    exit 1
fi

# 恢复数据库
echo "恢复数据库..."
docker exec -i "$CONTAINER_NAME" psql -U "$POSTGRES_USER" "$POSTGRES_DB" < "$TEMP_FILE"

if [ $? -eq 0 ]; then
    echo "数据库恢复成功！"
    rm -f "$TEMP_FILE"
else
    echo "数据库恢复失败！"
    rm -f "$TEMP_FILE"
    exit 1
fi