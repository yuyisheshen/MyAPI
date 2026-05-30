#!/bin/bash
# ============================================
# New API - Linux 数据备份脚本
# 备份内容: SQLite 数据 + MySQL 数据库 + 配置
# ============================================

set -e
cd "$(dirname "$0")"

BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/newapi-backup-$TIMESTAMP.tar.gz"

echo "正在备份 New API 数据..."

mkdir -p "$BACKUP_DIR"

# 备份 SQLite 数据（本地模式）
if [ -d "./data" ]; then
    tar -czf "$BACKUP_FILE" ./data .env docker-compose*.yml 2>/dev/null
# 备份 MySQL（云端模式）
elif docker compose -f docker-compose.yml -f docker-compose.prod.yml ps mysql &>/dev/null 2>&1; then
    docker compose -f docker-compose.yml -f docker-compose.prod.yml exec -T mysql \
        mysqldump -u root -p"${MYSQL_ROOT_PASSWORD}" newapi > "$BACKUP_DIR/newapi-db-$TIMESTAMP.sql"
    tar -czf "$BACKUP_FILE" "$BACKUP_DIR/newapi-db-$TIMESTAMP.sql" .env docker-compose*.yml
    rm -f "$BACKUP_DIR/newapi-db-$TIMESTAMP.sql"
fi

echo ""
echo "备份完成: $BACKUP_FILE"
echo ""
echo "还原命令: tar -xzf $BACKUP_FILE -C /目标目录/"
