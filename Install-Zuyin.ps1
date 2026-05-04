# =====================================================================
# 設定區：請填入你實際從 ISO 取出的 CAB 檔案名稱
# =====================================================================
$cabFile_24H2 = "2425h2.cab" # 替換成 24H2/25H2 的檔名
$cabFile_22H2 = "2223h2.cab" # 替換成 22H2/23H2 的檔名

# =====================================================================
# 1. 檢查管理員權限
# =====================================================================
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Warning "權限不足！請對此腳本點擊右鍵 -> 「以系統管理員身分執行」，或在系統管理員的 PowerShell 視窗中執行。"
    Pause
    Exit
}

# =====================================================================
# 2. 偵測 Windows 版本
# =====================================================================
Write-Host "正在偵測 Windows 11 版本..." -ForegroundColor Cyan
$osVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
$targetCab = ""

if ($osVersion -eq "24H2" -or $osVersion -eq "25H2") {
    Write-Host "偵測到版本: $osVersion"
    $targetCab = $cabFile_24H2
} elseif ($osVersion -eq "22H2" -or $osVersion -eq "23H2") {
    Write-Host "偵測到版本: $osVersion"
    $targetCab = $cabFile_22H2
} else {
    Write-Error "無法識別的 Windows 版本 ($osVersion) 或不支援此版本。"
    Pause
    Exit
}

# =====================================================================
# 3. 組合路徑並確認檔案存在
# =====================================================================
# $PSScriptRoot 是系統內建變數，代表這個腳本當前所在的資料夾路徑
$scriptPath = $PSScriptRoot
$fullCabPath = Join-Path -Path $scriptPath -ChildPath $targetCab

if (-not (Test-Path $fullCabPath)) {
    Write-Error "找不到指定的 CAB 檔案！"
    Write-Host "預期路徑: $fullCabPath" -ForegroundColor Yellow
    Write-Host "請確認已將對應的 CAB 檔案與本腳本放在同一個資料夾，且檔名設定正確。"
    Pause
    Exit
}

# =====================================================================
# 4. 執行安裝 (使用 DISM cmdlet)
# =====================================================================
Write-Host "準備安裝語言包: $targetCab" -ForegroundColor Cyan
Write-Host "這可能需要幾分鐘的時間，請稍候..."

try {
    # Add-WindowsPackage 等同於 dism.exe /Online /Add-Package
    Add-WindowsPackage -Online -PackagePath $fullCabPath -NoRestart -ErrorAction Stop
    Write-Host "`n安裝成功！" -ForegroundColor Green
    Write-Host "部分功能可能需要重新啟動電腦才會完全生效。" -ForegroundColor Yellow
} catch {
    Write-Error "`n安裝過程中發生錯誤："
    Write-Error $_.Exception.Message
}

Write-Host "`n腳本執行完畢。"
Pause