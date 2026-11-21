# Restart the lid-open-sound watcher if it is not running.
# install.ps1 registers a scheduled task that runs this file every 3 minutes,
# so the watcher comes back even if something kills it.
#
# Run it manually any time:  powershell -File watchdog.ps1

$ErrorActionPreference = 'SilentlyContinue'

$Dir = $PSScriptRoot
$Vbs = Join-Path $Dir 'run_hidden.vbs'
$Log = Join-Path $Dir 'watchdog.log'

function Write-WatchdogLog {
    param([string]$Text)
    try {
        Add-Content -LiteralPath $Log -Value ("[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Text)
    } catch { }
}

$running = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match 'lid-open-sound\.ps1' })

if ($running.Count -eq 0) {
    Start-Process -FilePath (Join-Path $env:WINDIR 'System32\wscript.exe') `
        -ArgumentList ('//B "{0}"' -f $Vbs) -WindowStyle Hidden
    Write-WatchdogLog "watcher was not running -> restarted"
}
