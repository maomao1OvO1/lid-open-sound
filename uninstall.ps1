# Remove the autostart entry and stop the watcher.

$ErrorActionPreference = 'SilentlyContinue'

$RunKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$Value = (Get-ItemProperty -Path $RunKey -Name 'LidOpenSound' -ErrorAction SilentlyContinue).LidOpenSound

if ($Value) {
    Remove-ItemProperty -Path $RunKey -Name 'LidOpenSound' -Force
    Write-Host 'autostart entry removed: LidOpenSound'
} else {
    Write-Host 'autostart entry was not present'
}

$killed = 0
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match 'lid-open-sound\.ps1' } |
    ForEach-Object {
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
        $killed++
    }
Write-Host ("watcher instances stopped: {0}" -f $killed)
Write-Host 'Uninstalled. Files are left in place; delete the folder if you want them gone.'
