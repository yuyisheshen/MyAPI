<div align="center">

<img src="./logo.svg" alt="MyAPI" width="120" />

# MyAPI

🍥 **新一代大模型网关与 AI 资产管理平台**

<p align="center">
  <a href="#-快速开始">快速开始</a> •
  <a href="#-主要特性">主要特性</a> •
  <a href="#-项目结构">项目结构</a> •
  <a href="#-部署">部署</a> •
  <a href="#-架构">架构</a> •
  <a href="#-文档">文档</a>
</p>

<p align="center">
  <a href="https://github.com/Calcium-Ion/new-api/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/yuyisheshen/MyAPI?color=brightgreen" alt="license">
  </a>
  <a href="https://github.com/yuyisheshen/MyAPI/releases">
    <img src="https://img.shields.io/github/v/release/yuyisheshen/MyAPI?color=brightgreen&include_prereleases" alt="release">
  </a>
  <a href="https://hub.docker.com/r/calciumion/new-api">
    <img src="https://img.shields.io/badge/docker-calciumion%2Fnew--api-blue" alt="docker">
  </a>
  <a href="https://goreportcard.com/report/github.com/Calcium-Ion/new-api">
    <img src="https://goreportcard.com/badge/github.com/Calcium-Ion/new-api" alt="GoReportCard">
  </a>
</p>

</div>

---

## 📝 项目说明

MyAPI 是基于开源项目 [New API](https://github.com/Calcium-Ion/new-api)（36K+ ⭐）的私有化部署实例，提供统一的 API 接口来管理和分发多种主流 AI 模型的访问权限，支持多租户、多模型、用量计费、数据看板等企业级功能。

> [!IMPORTANT]
> - 本项目仅面向合法授权的 **AI API 网关**、**组织内部鉴权**、**多模型管理**、**用量统计** 和 **私有化部署** 场景。
> - 使用者必须合法取得上游 API Key、账号、模型服务或接口权限，并遵守上游服务条款及适用法律法规。
> - 本项目**不对任何个人、机构、组织提供任何形式的 API 中转或代理服务**，不进行任何商业化运营。

---

## 🚀 快速开始

### Docker Compose 一键启动

```bash
# 克隆项目
git clone https://github.com/yuyisheshen/MyAPI.git
cd MyAPI

# 复制环境变量
cp .env.example .env

# 启动服务（SQLite 本地模式，零外部依赖）
docker compose up -d
```

🎉 部署完成后，访问 **http://localhost:3000** 即可使用！

<details>
<summary><strong>切换到 MySQL 生产模式</strong></summary>

```bash
# 编辑 .env，将 DEPLOY_MODE 改为 cloud
# 然后合并生产配置启动
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

</details>

> [!WARNING]
> 将本项目作为面向公众的生成式 AI 服务运营时，使用者应先完成备案、内容安全、实名、日志留存、税务和上游授权等合规义务。

---

## ✨ 主要特性

### 🎨 核心功能

| 特性 | 说明 |
|------|------|
| 🎨 现代化 UI | 内置 React 前端，响应式设计 |
| 🌍 多语言 | 支持中文、英文、法语、日语 |
| 🔄 数据兼容 | 完全兼容原版 One API 数据库 |
| 📈 数据看板 | 可视化控制台与统计分析 |
| 🔒 权限管理 | 令牌分组、模型限制、用户管理 |

### 💰 计费与配额

- ✅ 内部充值与额度分配（易支付、Stripe）
- ✅ 按量计费、按次计费、缓存命中计费
- ✅ 支持 OpenAI、Azure、Claude、DeepSeek、Qwen 等模型的缓存计费统计
- ✅ 面向内部管理或企业客户的灵活计费策略

### 🔐 认证与安全

- 🔑 OIDC 统一认证
- 🔐 TOTP 两步验证 + Passkey/WebAuthn 无密码登录
- 📱 GitHub / Discord / LinuxDO / Telegram / 微信 授权登录

### 🚀 高级功能

**多格式 API 支持：**
- ⚡ OpenAI Chat Completions & Responses
- ⚡ OpenAI Realtime API（含 Azure）
- ⚡ Claude Messages 原生格式
- ⚡ Google Gemini 原生格式
- 🔄 Rerank 模型（Cohere、Jina）
- 🎨 Midjourney-Proxy 图像生成 / 🎵 Suno 音乐生成

**智能路由：**
- ⚖️ 渠道加权随机
- 🔄 失败自动重试
- 🚦 用户级别模型限流

**格式转换：**
- 🔄 OpenAI Compatible ⇄ Claude Messages
- 🔄 OpenAI Compatible → Google Gemini
- 🔄 Google Gemini → OpenAI Compatible（文本）

---

## 🤖 模型支持

| 模型类型 | 协议格式 | 上游 |
|---------|----------|------|
| OpenAI-Compatible | Chat Completions | OpenAI / DeepSeek / Qwen / 自定义 |
| Claude | Messages API | Anthropic |
| Gemini | Gemini API | Google |
| Midjourney | midjourney-proxy | Midjourney |
| Suno | Suno API | Suno |
| Rerank | Cohere / Jina | Cohere / Jina |
| Embeddings | OpenAI 格式 | 各 Embedding 提供商 |
| Realtime | WebSocket | OpenAI / Azure |

---

## 📂 项目结构

| 文件 | 用途 |
|------|------|
| `docker-compose.yml` | 本地 SQLite 部署（个人/开发），零外部依赖一键启动 |
| `docker-compose.prod.yml` | 生产环境叠加配置（MySQL + Redis 多用户高并发） |
| `.env.example` | 环境变量配置模板，复制为 `.env` 后填入实际值 |
| `.env` | 私有环境变量（含密码等敏感信息，Git 忽略） |
| `backup.sh` | Linux/macOS 数据备份脚本 |
| `backup.ps1` | Windows PowerShell 数据备份脚本 |
| `deploy-cloud.sh` | 云端 MySQL 模式一键部署脚本 |
| `deploy-local.ps1` | Windows 本地 SQLite 模式一键部署脚本 |
| `logo.svg` | 项目 Logo 图标 |
| `VERSION` | 当前版本号标识文件 |
| `LICENSE` | AGPLv3 开源许可证全文 |
| `docs/` | 技术文档目录 |
| `data/` | SQLite 数据库 + 运行时数据（Git 忽略） |
| `logs/` | 日志输出目录（Git 忽略） |
| `mysql-conf/` | MySQL 自定义配置文件目录 |
| `.github/` | Issue 模板、PR 模板等社区协作配置 |

---

## 🏗️ 架构

```
┌─────────────────────────────────────────────────┐
│                   用户 / 客户端                     │
│   Cherry Studio · Lobe Chat · OpenCat · 自定义    │
└─────────────┬───────────────────────────────────┘
              │ HTTPS / API Key
              ▼
┌─────────────────────────────────────────────────┐
│                    MyAPI                          │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌───────────────┐  │
│  │ 路由鉴权  │  │ 格式转换  │  │ 智能路由/重试  │  │
│  └──────────┘  └──────────┘  └───────────────┘  │
│  ┌──────────┐  ┌──────────┐  ┌───────────────┐  │
│  │ 额度管理  │  │ 用量计费  │  │ 数据看板/日志  │  │
│  └──────────┘  └──────────┘  └───────────────┘  │
│                                                  │
│  Go (Gin + GORM) · React 前端 · SQLite / MySQL   │
└─────────────┬───────────────────────────────────┘
              │ 上游 API
              ▼
┌─────────────────────────────────────────────────┐
│         上游 AI 模型提供商                          │
│  OpenAI · Claude · Gemini · DeepSeek · Qwen ...  │
└─────────────────────────────────────────────────┘
```

---

## 🚢 部署

### 部署模式对比

| 模式 | 数据库 | 适用场景 | 启动命令 |
|------|--------|----------|----------|
| **本地模式** | SQLite | 个人/开发/小规模 | `docker compose up -d` |
| **云端模式** | MySQL + Redis | 多用户/高并发 | `docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d` |

### 环境变量

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `DEPLOY_MODE` | 部署模式（`local` / `cloud`） | `local` |
| `NEW_API_PORT` | 服务端口 | `3000` |
| `SQL_DSN` | MySQL 连接串（cloud 模式） | - |
| `REDIS_CONN_STRING` | Redis 连接串（可选） | - |
| `SESSION_SECRET` | 会话密钥（多机部署必须） | 自动生成 |
| `TZ` | 时区 | `Asia/Shanghai` |

完整配置参见 [.env.example](./.env.example)。

### 数据备份

```bash
# SQLite 模式（备份单文件）
cp ./data/one-api.db ./backups/one-api-$(date +%Y%m%d).db

# MySQL 模式
docker exec mysql mysqldump -u root -p newapi > backup.sql
```

---

## 📚 文档

| 资源 | 链接 |
|------|------|
| 📘 技术文档 | [docs/MyAPI-技术文档.md](./docs/MyAPI-技术文档.md) |
| 📖 上游官方文档 | [docs.newapi.pro](https://docs.newapi.pro) |
| 📖 上游 DeepWiki | [DeepWiki](https://deepwiki.com/QuantumNous/new-api) |
| 🐛 上游问题反馈 | [GitHub Issues](https://github.com/Calcium-Ion/new-api/issues) |

---

## 🔗 相关项目

| 项目 | 说明 |
|------|------|
| [New API](https://github.com/Calcium-Ion/new-api) | 上游项目（36K+ ⭐） |
| [One API](https://github.com/songquanpeng/one-api) | 始祖项目（MIT 协议） |
| [Midjourney-Proxy](https://github.com/novicezk/midjourney-proxy) | Midjourney 接口支持 |
| [new-api-horizon](https://github.com/Calcium-Ion/new-api-horizon) | New API 高性能优化版 |

---

## 📜 许可证

本项目基于 [New API](https://github.com/Calcium-Ion/new-api)（[AGPLv3](./LICENSE)）进行私有化部署。

> 本项目不对任何个人、机构、组织提供任何形式的 API 中转或代理服务，不进行任何商业化运营。

---

<div align="center">

### 💖 感谢上游项目

**[New API](https://github.com/Calcium-Ion/new-api)** by QuantumNous · **[One API](https://github.com/songquanpeng/one-api)** by songquanpeng

</div>
