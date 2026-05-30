# ============================================
# New API - Windows 本地一键部署脚本
# 用法: 右键 "使用 PowerShell 运行" 或在终端执行 .\deploy-local.ps1
# ============================================

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  New API - 本地部署脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. 检查 Docker
Write-Host "[1/4] 检查 Docker Desktop..." -ForegroundColor Yellow
$dockerVersion = docker --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "错误: 未检测到 Docker，请先安装 Docker Desktop" -ForegroundColor Red
    Write-Host "下载地址: https://www.docker.com/products/docker-desktop/" -ForegroundColor Red
    Write-Host ""
    Write-Host "安装注意事项:" -ForegroundColor White
    Write-Host "  1. 安装时勾选 'Use WSL 2 instead of Hyper-V'" -ForegroundColor White
    Write-Host "  2. 安装完成后重启电脑" -ForegroundColor White
    Write-Host "  3. 启动 Docker Desktop，等待右下角图标变白" -ForegroundColor White
    pause
    exit 1
}
Write-Host "  OK: $dockerVersion" -ForegroundColor Green

# 2. 检查 WSL2（Docker Desktop 依赖）
Write-Host ""
Write-Host "[2/4] 检查 WSL2..." -ForegroundColor Yellow
$wslVersion = wsl --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "警告: WSL2 未安装，Docker Desktop 可能无法正常工作" -ForegroundColor Yellow
    Write-Host "安装命令: wsl --install" -ForegroundColor White
} else {
    Write-Host "  OK: WSL2 已就绪" -ForegroundColor Green
}

# 3. 创建必要目录
Write-Host ""
Write-Host "[3/4] 创建数据目录..." -ForegroundColor Yellow
$dirs = @("data", "logs")
foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  已创建: $dir/" -ForegroundColor Green
    } else {
        Write-Host "  已存在: $dir/" -ForegroundColor Gray
    }
}

# 4. 启动服务
Write-Host ""
Write-Host "[4/4] 启动 New API 服务..." -ForegroundColor Yellow
docker compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  部署成功!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  访问地址: http://localhost:3000" -ForegroundColor White
    Write-Host "  默认账号: root" -ForegroundColor White
    Write-Host "  默认密码: 123456" -ForegroundColor White
    Write-Host ""
    Write-Host "  常用命令:" -ForegroundColor Gray
    Write-Host "    查看日志: docker compose logs -f new-api" -ForegroundColor Gray
    Write-Host "    停止服务: docker compose down" -ForegroundColor Gray
    Write-Host "    重启服务: docker compose restart" -ForegroundColor Gray
    Write-Host "    备份数据: .\backup.ps1" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "启动失败，请检查 Docker Desktop 是否正在运行" -ForegroundColor Red
}

pause
