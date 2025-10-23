# IDM Activation Script - Online Installer
# پروژه دانشجویی - نصب‌کننده آنلاین
# نسخه 2.0

# بررسی دسترسی ادمین
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "  این اسکریپت نیاز به دسترسی Administrator دارد" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    Write-Host "در حال راه‌اندازی مجدد با دسترسی ادمین..." -ForegroundColor Cyan
    
    # راه‌اندازی مجدد با دسترسی ادمین
    $scriptUrl = "https://raw.githubusercontent.com/nscl5/IDM-Activation/main/install.ps1"
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm $scriptUrl | iex`""
    exit
}

# تنظیمات اولیه
$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'

# آدرس‌های GitHub
$scriptUrl = "https://raw.githubusercontent.com/nscl5/IDM-Activation/main/IAS-Enhanced.cmd"
$tempPath = "$env:TEMP\IAS-Enhanced.cmd"

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                                   ║" -ForegroundColor Cyan
Write-Host "║        IDM Activation Script - پروژه دانشجویی v2.0              ║" -ForegroundColor Cyan
Write-Host "║                                                                   ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

try {
    Write-Host "▓ در حال دانلود اسکریپت از GitHub..." -ForegroundColor Yellow
    
    # دانلود فایل
    Invoke-WebRequest -Uri $scriptUrl -OutFile $tempPath -UseBasicParsing
    
    Write-Host "✓ دانلود با موفقیت انجام شد" -ForegroundColor Green
    Write-Host ""
    Write-Host "▓ در حال راه‌اندازی اسکریپت..." -ForegroundColor Yellow
    Write-Host ""
    
    # اجرای اسکریپت
    Start-Process cmd.exe -ArgumentList "/c `"$tempPath`"" -Wait
    
    # پاک کردن فایل موقت
    if (Test-Path $tempPath) {
        Remove-Item $tempPath -Force
    }
    
    Write-Host ""
    Write-Host "✓ عملیات با موفقیت انجام شد" -ForegroundColor Green
    
} catch {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "  خطا در دانلود یا اجرای اسکریپت" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    Write-Host "جزئیات خطا: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "لطفا موارد زیر را بررسی کنید:" -ForegroundColor Yellow
    Write-Host "  1. اتصال اینترنت خود را چک کنید" -ForegroundColor White
    Write-Host "  2. آدرس GitHub صحیح باشد" -ForegroundColor White
    Write-Host "  3. فایروال یا آنتی‌ویروس مانع دانلود نشده باشد" -ForegroundColor White
    Write-Host ""
    
    Read-Host "برای خروج Enter را فشار دهید"
    exit 1
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
