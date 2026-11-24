# Автоматический запрос прав администратора при запуске двойным кликом или через PowerShell
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$TaskName = "Claude_VPN_Guard"
$ScriptDir = "C:\Scripts"
$ScriptPath = "$ScriptDir\claude_guard.ps1"

Clear-Host
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "   Claude Code Kill Switch (Защита по VPN)    " -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Установить / Обновить защиту (с выбором страны)" -ForegroundColor Green
Write-Host "2. Полностью удалить защиту и убрать из автозапуска" -ForegroundColor Red
Write-Host "3. Выход" -ForegroundColor Gray
Write-Host ""

$choice = Read-Host "Выберите действие (1, 2 или 3)"

if ($choice -eq "1") {
    Write-Host ""
    $countryInput = Read-Host "Введите двухбуквенный код разрешенной страны (например, NL, DE, US, UA) [по умолчанию NL]"
    if ([string]::IsNullOrWhiteSpace($countryInput)) {
        $AllowedCountry = "NL"
    } else {
        $AllowedCountry = $countryInput.Trim().ToUpper()
    }

    $vpnInput = Read-Host "Введите имя процесса VPN без .exe [по умолчанию Happ]"
    if ([string]::IsNullOrWhiteSpace($vpnInput)) {
        $VpnProcessName = "Happ"
    } else {
        $VpnProcessName = $vpnInput.Trim() -replace '\.exe$', ''
    }

    New-Item -ItemType Directory -Force -Path $ScriptDir | Out-Null

    # Сборка URL по частям для защиты от искажений при копировании
    $p1 = "http"; $p2 = "ip-api"; $p3 = "com"; $p4 = "json"
    $CheckUrl = "${p1}://${p2}.${p3}/${p4}"

    $guardCode = @"
`$AllowedCountry = "$AllowedCountry"
`$VpnProcessName = "$VpnProcessName"
`$TargetProcesses = @("claude", "claude-code")
`$CheckUrl = "$CheckUrl"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-Toast {
    param([string]`$Title, [string]`$Message)
    `$notify = New-Object System.Windows.Forms.NotifyIcon
    `$notify.Icon = [System.Drawing.SystemIcons]::Warning
    `$notify.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
    `$notify.BalloonTipTitle = `$Title
    `$notify.BalloonTipText = `$Message
    `$notify.Visible = `$true
    `$notify.ShowBalloonTip(5000)
    Start-Sleep -Seconds 5
    `$notify.Dispose()
}

function Kill-Claude {
    `$killed = `$false
    foreach (`$proc in `$TargetProcesses) {
        `$running = Get-Process -Name `$proc -ErrorAction SilentlyContinue
        if (`$running) {
            Stop-Process -Name `$proc -Force -ErrorAction SilentlyContinue
            `$killed = `$true
        }
    }
    if (`$killed) {
        Start-Job -ScriptBlock `${function:Show-Toast} -ArgumentList "Kill Switch сработал!", "VPN (`$VpnProcessName) отключен или IP не `$AllowedCountry. Claude Code закрыт." | Out-Null
    }
}

`$checkCounter = 0
`$isIpValid = `$false

while (`$true) {
    `$vpnRunning = Get-Process -Name `$VpnProcessName -ErrorAction SilentlyContinue
    if (-not `$vpnRunning) {
        Kill-Claude
        `$isIpValid = `$false
        Start-Sleep -Seconds 1
        continue
    }

    if (`$checkCounter -le 0) {
        try {
            `$country = (Invoke-RestMethod -Uri `$CheckUrl -TimeoutSec 4).countryCode
            `$isIpValid = (`$country -eq `$AllowedCountry)
        } catch {
            `$isIpValid = `$false
        }
        `$checkCounter = 5
    }

    if (-not `$isIpValid) {
        Kill-Claude
    }

    `$checkCounter--
    Start-Sleep -Seconds 1
}
"@

    Set-Content -Path $ScriptPath -Value $guardCode -Encoding UTF8

    # Регистрация в Планировщике заданий Windows
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`""
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Days 3650)

    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings | Out-Null
    Start-ScheduledTask -TaskName $TaskName

    Write-Host ""
    Write-Host "[OK] Защита установлена для страны: $AllowedCountry (VPN: $VpnProcessName)" -ForegroundColor Green
    Write-Host "[OK] Скрипт добавлен в автозапуск и уже работает в фоне." -ForegroundColor Green
}
elseif ($choice -eq "2") {
    Write-Host ""
    Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
    if (Test-Path $ScriptPath) {
        Remove-Item -Path $ScriptPath -Force -ErrorAction SilentlyContinue
    }
    Write-Host "[OK] Защита остановлена, удалена из автозапуска, а файл скрипта стерт." -ForegroundColor Yellow
}
else {
    Write-Host "Выход..." -ForegroundColor Gray
}

Write-Host ""
Read-Host "Нажмите Enter, чтобы закрыть окно"
