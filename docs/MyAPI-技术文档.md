# MyAPI 技术文档

> 基于 [New API](https://github.com/Calcium-Ion/new-api) v1.0.0-rc.7 的私有化部署实例
>
> 本文档仅供内部技术参考，不对任何个人、机构、组织提供任何形式的 API 中转或代理服务

---

## 一、项目概述

MyAPI 是一个**下一代 LLM 网关与 AI 资产管理平台**，基于开源的 New API 项目进行私有化部署。它提供统一的 API 接口来管理和分发多种主流 AI 模型的访问权限，支持多租户、多模型、用量计费、数据看板等企业级功能。

**项目定位**：技术研究与自用，非商业运营

| 属性 | 说明 |
|------|------|
| 上游项目 | [New API](https://github.com/Calcium-Ion/new-api)（原 One API 的重度重构版） |
| 许可证 | AGPLv3 |
| 当前版本 | v1.0.0-rc.7 |
| 部署模式 | 单机 Docker / SQLite 本地模式 |
| 源码地址 | https://github.com/Calcium-Ion/new-api |

---

## 二、技术架构

### 2.1 技术栈总览

| 层级 | 技术选型 | 说明 |
|------|----------|------|
| **后端语言** | Go 1.25 | 高性能编译型语言，单二进制部署 |
| **Web 框架** | Gin v1.9 | 轻量高性能 HTTP 框架 |
| **ORM** | GORM v1.25 | Go 最主流的 ORM，支持多数据库 |
| **前端** | React (内嵌) | Go embed 嵌入，零外部前端服务 |
| **本地数据库** | SQLite (via glebarez/sqlite) | 零依赖，单文件存储，适合小规模部署 |
| **生产数据库** | MySQL 8.0 / PostgreSQL 9.6+ | 高并发场景 |
| **缓存** | Redis 7 (可选) | 提升高并发性能、缓存命中计费 |
| **容器化** | Docker + Docker Compose | 一键部署，环境隔离 |
| **运行环境** | Windows 11 + WSL2 (Linux Kernel 6.6) | 本地开发/测试环境 |

### 2.2 核心依赖

| 依赖 | 版本 | 用途 |
|------|------|------|
| `gin-gonic/gin` | v1.9.1 | HTTP 路由与中间件 |
| `gorm.io/gorm` | v1.25 | 数据库抽象层 |
| `glebarez/sqlite` | v1.9 | SQLite 驱动（纯 Go 实现） |
| `golang-jwt/jwt` | v5.3 | JWT 身份认证 |
| `go-webauthn/webauthn` | v0.14 | WebAuthn / Passkey 无密码登录 |
| `gorilla/websocket` | v1.5 | WebSocket 实时通信 |
| `go-redis/redis` | v8.11 | Redis 客户端 |
| `stripe/stripe-go` | v81.4 | Stripe 支付集成 |
| `go-i18n` | v2.6 | 多语言国际化 |
| `grafana/pyroscope-go` | v1.2 | 性能分析（可选） |

### 2.3 架构图（逻辑）

```
┌─────────────────────────────────────────────────┐
│                   用户 / 客户端                     │
│   Cherry Studio · Lobe Chat · OpenCat · 自定义    │
└─────────────┬───────────────────────────────────┘
              │ HTTPS / API Key
              ▼
┌─────────────────────────────────────────────────┐
│              MyAPI (New API v1.0.0-rc.7)         │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌───────────────┐  │
│  │ 路由鉴权  │  │ 格式转换  │  │ 智能路由/重试  │  │
│  └──────────┘  └──────────┘  └───────────────┘  │
│  ┌──────────┐  ┌──────────┐  ┌───────────────┐  │
│  │ 额度管理  │  │ 用量计费  │  │ 数据看板/日志  │  │
│  └──────────┘  └──────────┘  └───────────────┘  │
│                                                  │
│  Go (Gin + GORM) · React 前端 · SQLite/MySQL     │
└─────────────┬───────────────────────────────────┘
              │ 上游 API
              ▼
┌─────────────────────────────────────────────────┐
│              上游 AI 模型提供商                     │
│  OpenAI · Claude · Gemini · DeepSeek · Qwen ...  │
└─────────────────────────────────────────────────┘
```

---

## 三、核心功能

### 3.1 API 管理与分发

- **多模型统一接入**：一个 API 端点兼容 OpenAI、Claude Messages、Google Gemini 等多种格式
- **渠道管理**：支持批量导入/导出上游 API Key，权重负载均衡
- **模型映射**：自定义模型名称 → 上游模型的路由规则
- **自动重试**：上游失败时自动切换备用渠道（失败重试次数可配）
- **速率限制**：支持用户级别、模型级别的 QPS 限制

### 3.2 格式转换能力

| 源格式 | 目标格式 | 状态 |
|--------|----------|------|
| OpenAI Compatible | Claude Messages | 已支持 |
| OpenAI Compatible | Google Gemini | 已支持 |
| Google Gemini | OpenAI Compatible | 文本已支持，函数调用开发中 |
| OpenAI Compatible | OpenAI Responses | 开发中 |

### 3.3 支持的模型类型

| 模型类型 | 协议格式 | 说明 |
|----------|----------|------|
| OpenAI-Compatible | Chat Completions | 兼容所有 OpenAI 格式模型 |
| OpenAI Responses | Responses API | 新一代响应格式 |
| Claude | Messages API | Anthropic 原生格式 |
| Google Gemini | Gemini API | Google 原生格式 |
| Midjourney | midjourney-proxy | 图像生成 |
| Suno | Suno API | 音乐生成 |
| Rerank | Cohere / Jina | 重排序模型 |
| Embeddings | OpenAI 格式 | 向量嵌入 |
| Realtime | WebSocket | 实时语音/视频对话 |
| Dify | ChatFlow | 工作流集成 |

### 3.4 认证与安全

- 多因素认证：TOTP 两步验证
- Passkey/WebAuthn 无密码登录
- OAuth2/OIDC 统一认证
- 第三方登录：GitHub、Discord、LinuxDO、Telegram、微信
- 用户组与权限管理
- Token 分组与模型访问限制

### 3.5 计费与配额

- 内部充值（E-Pay / Stripe）
- 按量计费、按次计费、缓存命中计费
- 订阅计划管理
- 用户配额分配与消耗统计
- 支持 OpenAI、Azure、Claude、DeepSeek、Qwen 等缓存计费

### 3.6 数据与监控

- 可视化数据看板
- 请求日志与错误日志
- 模型级别的额度消耗统计
- Pyroscope 性能分析（可选）

---

## 四、部署方案

### 4.1 当前部署配置（本地 SQLite 模式）

```yaml
# docker-compose.yml
services:
  new-api:
    image: calciumion/new-api:latest
    container_name: new-api
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - TZ=Asia/Shanghai
    volumes:
      - ./data:/data      # SQLite 数据库 + 业务数据
      - ./logs:/logs      # 日志输出
```

**适用场景**：个人使用、开发测试、小规模部署
**特点**：零外部依赖，数据集中在 `data/one-api.db` 一个文件中，备份只需复制该文件

### 4.2 生产部署方案（云端 MySQL 模式）

```yaml
# docker-compose.yml + docker-compose.prod.yml 合并部署
services:
  new-api:
    environment:
      - SQL_DSN=${MYSQL_USER}:${MYSQL_PASSWORD}@tcp(mysql:3306)/${MYSQL_DATABASE}?charset=utf8mb4&parseTime=True&loc=Local
    depends_on:
      mysql:
        condition: service_healthy

  mysql:
    image: mysql:8.0
    volumes:
      - ./mysql-data:/var/lib/mysql
      - ./mysql-conf:/etc/mysql/conf.d

  # redis:        # 可选：高并发场景启用
  #   image: redis:7-alpine
```

**适用场景**：多用户、高并发、生产环境
**特点**：MySQL 提供更好的并发性能，Redis 提升缓存命中率与响应速度

### 4.3 关键环境变量

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `TZ` | 时区 | Asia/Shanghai |
| `SQL_DSN` | MySQL/PostgreSQL 连接串 | 空（SQLite） |
| `REDIS_CONN_STRING` | Redis 连接串 | 空（不启用） |
| `SESSION_SECRET` | 会话密钥（多机部署必填） | 自动生成 |
| `CRYPTO_SECRET` | 加密密钥（Redis 模式下必填） | 自动生成 |
| `STREAMING_TIMEOUT` | 流式超时（秒） | 300 |
| `MAX_REQUEST_BODY_MB` | 最大请求体（MB） | 32 |

### 4.4 镜像信息

| 属性 | 值 |
|------|------|
| 镜像名 | `calciumion/new-api:latest` |
| 镜像大小 | ~63 MB |
| 基础镜像 | Debian (极小化) |
| 构建方式 | Go 交叉编译 + 前端 embed 打包为单二进制 |

---

## 五、支持的前端客户端

New API 内置了主流 AI 客户端的一键配置入口：

| 客户端 | 平台 | 配置方式 |
|--------|------|----------|
| Cherry Studio | 桌面端 | 一键跳转配置 |
| Lobe Chat | Web 端 | URL Scheme 自动配置 |
| OpenCat | macOS/iOS | Team 链接 |
| AionUI | 桌面端 | 一键跳转配置 |
| AI as Workspace | Web 端 | Provider 自动配置 |
| DeepChat | 桌面端 | 一键跳转配置 |
| 流畅阅读 | 移动端 | 内置集成 |
| AMA 问天 | 桌面端 | 一键跳转配置 |

---

## 六、数据备份

### 6.1 SQLite 模式（当前环境）

```bash
# 备份整个 data 目录
tar -czf backup-$(date +%Y%m%d).tar.gz ./data/

# 恢复
tar -xzf backup-YYYYMMDD.tar.gz
```

### 6.2 MySQL 模式

```bash
# 备份数据库
docker exec new-api-mysql mysqldump -u root -p newapi > backup.sql

# 恢复
docker exec -i new-api-mysql mysql -u root -p newapi < backup.sql
```

---

## 七、上下游项目关系

```
One API (MIT License, songquanpeng)
    │
    └── New API (AGPLv3 License, QuantumNous)
            │
            ├── Midjourney-Proxy (图像生成接口)
            ├── Suno-API (音乐生成接口)
            │
            ├── new-api-key-tool (Key 查询工具)
            └── new-api-horizon (高性能优化版)
```

- **One API**：始祖项目，MIT 协议，奠定了统一 API 网关的基础
- **New API**：在 One API 基础上深度重构，增加了 Claude/Gemini 原生格式支持、响应式 API、Passkey 认证、计费系统等
- **new-api-horizon**：New API 的高性能优化版本

---

## 八、运维常用命令

```bash
# 进入项目目录
cd /path/to/MyAPI

# 启动服务
docker compose up -d

# 停止服务
docker compose down

# 重启服务
docker compose restart

# 查看日志
docker compose logs -f new-api

# 更新镜像
docker compose pull && docker compose up -d

# 查看容器状态
docker ps --filter "name=new-api"

# 进入容器
docker exec -it new-api sh

# 备份数据（SQLite 模式）
cp ./data/one-api.db ./backups/one-api-$(date +%Y%m%d).db
```

---

## 九、许可证与合规声明

- 本项目基于 **New API**（AGPLv3 协议）进行私有化部署
- AGPLv3 要求：如果您修改了本项目并提供网络服务，需要公开您的修改
- 本项目**不对任何个人、机构、组织提供任何形式的 API 中转或代理服务**
- 本项目**不进行任何商业化运营**
- 如需商业使用或避免 AGPLv3 开源义务，可联系上游：support@quantumnous.com

---

## 十、相关链接

| 资源 | 链接 |
|------|------|
| New API 源码 | https://github.com/Calcium-Ion/new-api |
| 官方文档 | https://docs.newapi.pro |
| Docker Hub | https://hub.docker.com/r/calciumion/new-api |
| 上游项目 One API | https://github.com/songquanpeng/one-api |
| 问题反馈 | https://github.com/Calcium-Ion/new-api/issues |

---

> **最后更新**：2026-05-30
>
> **声明**：本文档仅供技术学习与内部参考，项目纯粹为技术自嗨，不对外提供任何服务
