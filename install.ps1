# Install lid-open-sound for the current user (no admin rights required).
# It registers a per-user autostart entry, an optional watchdog task, and starts the watcher.

$ErrorActionPreference = 'Stop'

$Dir = $PSScriptRoot
$Ps1 = Join-Path $Dir 'lid-open-sound.ps1'
$Vbs = Join-Path $Dir 'run_hidden.vbs'
$Watchdog = Join-Path $Dir 'watchdog.ps1'
$Wav = Join-Path $Dir 'sound.wav'
$RunKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$Wscript = Join-Path $env:WINDIR 'System32\wscript.exe'
$TaskName = 'LidOpenSound-Watchdog'

Write-Host '=== lid-open-sound installer ==='
Write-Host ("folder : {0}" -f $Dir)

foreach ($f in @($Ps1, $Vbs)) {
    if (-not (Test-Path -LiteralPath $f)) { throw ("missing file: {0}" -f $f) }
}

if (-not (Test-Path -LiteralPath $Wav)) {
    Write-Host ''
    Write-Host "WARNING: sound.wav not found in this folder."
    Write-Host "         Put any .wav there (name it sound.wav) before testing."
    Write-Host ''
}

# autostart on user logon (HKCU only, nothing system-wide is touched)
$Value = '"{0}" //B "{1}"' -f $Wscript, $Vbs
New-ItemProperty -Path $RunKey -Name 'LidOpenSound' -Value $Value -PropertyType String -Force | Out-Null
Write-Host ("autostart registered: LidOpenSound = {0}" -f $Value)

# watchdog: re-create the scheduled task (every 1 minute) so a killed watcher comes back
if (Test-Path -LiteralPath $Watchdog) {
    $tr = 'powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "{0}"' -f $Watchdog
    $out = & schtasks.exe /Create /TN $TaskName /TR $tr /SC MINUTE /MO 1 /F 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host ("watchdog task registered: {0} (every 1 minute)" -f $TaskName)
    } else {
        Write-Host ("watchdog task could NOT be registered: {0}" -f ($out -join ' '))
        Write-Host '  (the watcher still works; it just will not auto-restart)'
    }
} else {
    Write-Host 'watchdog.ps1 not found - skipping auto-restart task'
}

# stop an older instance, then start the new one hidden
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match 'lid-open-sound\.ps1' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 1
Start-Process -FilePath $Wscript -ArgumentList ('//B "{0}"' -f $Vbs) -WindowStyle Hidden
Start-Sleep -Seconds 3

$running = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match 'lid-open-sound\.ps1' })
Write-Host ("watcher instances running: {0}" -f $running.Count)
Write-Host ("log files: {0} , {1}" -f (Join-Path $Dir 'events.log'), (Join-Path $Dir 'watchdog.log'))
Write-Host ''
Write-Host 'Done. Close the lid for a few seconds, open it, and unlock the PC.'
