#!/bin/bash
# ============================================
# MyAPI - 云端 MySQL 模式一键部署脚本 (Linux)
# 用法: chmod +x deploy-cloud.sh && ./deploy-cloud.sh
# ============================================

set -e
cd "$(dirname "$0")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  New API - 云端部署脚本${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# 1. 检查 Docker
echo -e "${YELLOW}[1/5] 检查 Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker 未安装，正在安装...${NC}"
    curl -fsSL https://get.docker.com | bash
    systemctl enable docker
    systemctl start docker
    echo -e "${GREEN}  Docker 安装完成${NC}"
else
    echo -e "${GREEN}  OK: $(docker --version)${NC}"
fi

# 2. 检查 Docker Compose
echo ""
echo -e "${YELLOW}[2/5] 检查 Docker Compose...${NC}"
if ! docker compose version &> /dev/null; then
    echo -e "${RED}Docker Compose 未安装，正在安装...${NC}"
    apt-get update && apt-get install -y docker-compose-plugin
    echo -e "${GREEN}  Docker Compose 安装完成${NC}"
else
    echo -e "${GREEN}  OK: $(docker compose version)${NC}"
fi

# 3. 检查 .env 并提示修改密码
echo ""
echo -e "${YELLOW}[3/5] 检查配置...${NC}"
if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${YELLOW}  已从 .env.example 创建 .env，请编辑 .env 修改默认密码！${NC}"
else
    if grep -q "ChangeMe123" .env 2>/dev/null; then
        echo -e "${YELLOW}  警告: .env 中仍为默认密码，建议修改！${NC}"
    else
        echo -e "${GREEN}  .env 配置就绪${NC}"
    fi
fi

# 4. 创建目录
echo ""
echo -e "${YELLOW}[4/5] 创建数据目录...${NC}"
mkdir -p data logs mysql-data mysql-conf redis-data backups
echo -e "${GREEN}  目录就绪${NC}"

# 5. 拉取镜像并启动
echo ""
echo -e "${YELLOW}[5/5] 拉取镜像并启动服务...${NC}"
docker compose -f docker-compose.yml -f docker-compose.prod.yml pull
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  部署成功!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "  访问地址: http://$(curl -s ifconfig.me 2>/dev/null || echo '你的服务器IP'):3000"
echo -e "  默认账号: ${CYAN}root${NC}"
echo -e "  默认密码: ${CYAN}123456${NC}"
echo -e "  ${RED}首次登录后请立即修改密码！${NC}"
echo ""
echo -e "  常用命令:"
echo -e "    查看日志: docker compose logs -f new-api"
echo -e "    停止服务: docker compose down"
echo -e "    数据备份: ./backup.sh"
echo -e "    更新镜像: docker compose pull && docker compose up -d"
echo ""
