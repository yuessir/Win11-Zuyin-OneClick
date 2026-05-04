@echo off
chcp 65001 >nul

:: 檢查是否擁有管理員權限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo 正在請求管理員權限，請在彈出的視窗按「是」...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: 若已取得管理員權限，切換到批次檔所在的目錄
cd /d "%~dp0"

echo ===================================================
echo 準備安裝 Windows 11 繁體注音語言包...
echo ===================================================
echo.

:: 執行同目錄下的 PowerShell 腳本並繞過執行原則
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "Install-Zuyin.ps1"

echo.
echo 批次檔執行完畢。
pause