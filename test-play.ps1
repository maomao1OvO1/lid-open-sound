# Play sound.wav once so you can check volume, output device and the file itself.
# Run this before blaming the watcher.

$Wav = Join-Path $PSScriptRoot 'sound.wav'

if (-not (Test-Path -LiteralPath $Wav)) {
    Write-Host ("missing: {0}" -f $Wav)
    Write-Host 'Put a .wav file named sound.wav next to this script.'
    exit 1
}

$svc = Get-Service -Name 'Audiosrv' -ErrorAction SilentlyContinue
Write-Host ("audio service: {0}" -f $svc.Status)
Write-Host ("file: {0} ({1} bytes)" -f $Wav, (Get-Item -LiteralPath $Wav).Length)

$sw = [System.Diagnostics.Stopwatch]::StartNew()
$player = New-Object System.Media.SoundPlayer($Wav)
$player.Load()
$player.PlaySync()
$sw.Stop()

Write-Host ("played in {0} ms (a real file usually takes about its own duration)" -f $sw.ElapsedMilliseconds)
