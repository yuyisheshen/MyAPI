# ============================================
# New API - Windows 数据备份脚本
# 备份内容: SQLite 数据库 + 日志 + 配置
# ============================================

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$backupDir = "$PSScriptRoot\backups"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "$backupDir\newapi-backup-$timestamp.zip"

Write-Host "正在备份 New API 数据..." -ForegroundColor Yellow

# 创建备份目录
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

# 打包关键数据
Compress-Archive -Path "data" -DestinationPath $backupFile -Force

Write-Host "备份完成: $backupFile" -ForegroundColor Green
Write-Host ""
Write-Host "还原命令: Expand-Archive -Path '$backupFile' -DestinationPath '.' -Force" -ForegroundColor Gray
