# Install lid-open-sound for the current user (no admin rights required).
# It registers a per-user autostart entry and starts the watcher right away.

$ErrorActionPreference = 'Stop'

$Dir = $PSScriptRoot
$Ps1 = Join-Path $Dir 'lid-open-sound.ps1'
$Vbs = Join-Path $Dir 'run_hidden.vbs'
$Wav = Join-Path $Dir 'sound.wav'
$RunKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'

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
$Value = '"{0}" //B "{1}"' -f (Join-Path $env:WINDIR 'System32\wscript.exe'), $Vbs
New-ItemProperty -Path $RunKey -Name 'LidOpenSound' -Value $Value -PropertyType String -Force | Out-Null
Write-Host ("autostart registered: LidOpenSound = {0}" -f $Value)

# stop an older instance, then start the new one hidden
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match 'lid-open-sound\.ps1' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 1
Start-Process -FilePath (Join-Path $env:WINDIR 'System32\wscript.exe') -ArgumentList ('//B "{0}"' -f $Vbs) -WindowStyle Hidden
Start-Sleep -Seconds 3

$running = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match 'lid-open-sound\.ps1' })
Write-Host ("watcher instances running: {0}" -f $running.Count)
Write-Host ("log file: {0}" -f (Join-Path $Dir 'events.log'))
Write-Host ''
Write-Host 'Done. Close the lid for a few seconds, open it, and unlock the PC.'
