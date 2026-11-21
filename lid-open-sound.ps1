<#
.SYNOPSIS
    lid-open-sound: play a sound when the lid is opened and the desktop is unlocked.

.DESCRIPTION
    Detects resume from sleep with a wall-clock gap (power events are not delivered
    to hidden PowerShell processes), waits until the lock screen disappears
    (LogonUI.exe gone), then plays sound.wav once.

    Works on Windows 10/11 with Windows PowerShell 5.1. No admin rights needed.
    See README.md for the full story behind the design.
#>

param(
    [string]$WavPath = (Join-Path $PSScriptRoot 'sound.wav')
)

$ErrorActionPreference = 'SilentlyContinue'
$LogPath = Join-Path $PSScriptRoot 'events.log'

function Write-Log {
    param([string]$Text)
    try {
        Add-Content -LiteralPath $LogPath -Value ("[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'), $Text)
    } catch { }
}

function Wait-AudioReady {
    param([int]$MaxMs = 6000)
    $waited = 0
    while ($waited -lt $MaxMs) {
        $svc = Get-Service -Name 'Audiosrv' -ErrorAction SilentlyContinue
        if ($svc -and $svc.Status -eq 'Running') { return $true }
        Start-Sleep -Milliseconds 300
        $waited += 300
    }
    return $false
}

function Test-Locked {
    $logonUi = @(Get-Process -Name LogonUI -ErrorAction SilentlyContinue)
    return ($logonUi.Count -gt 0)
}

# PlaySync blocks until the whole file has been handed to the audio endpoint, so a
# normal duration means the stream was really delivered. A too-short return means
# the endpoint was not ready yet (common in the first seconds after resume).
function Play-Sound {
    param([string]$Reason)
    for ($try = 1; $try -le 3; $try++) {
        try {
            $player = New-Object System.Media.SoundPlayer($WavPath)
            $player.Load()
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            $player.PlaySync()
            $sw.Stop()
            $ms = $sw.ElapsedMilliseconds
            Write-Log ("PLAY sound.wav ({0}) attempt {1} took {2}ms" -f $Reason, $try, $ms)
            if ($ms -ge 500) { return $true }
            Write-Log "  -> returned too fast, audio endpoint probably not ready, retry"
            Start-Sleep -Milliseconds 1200
        } catch {
            Write-Log ("ERROR play attempt {0}: {1}" -f $try, $_.Exception.Message)
            Start-Sleep -Milliseconds 1500
        }
    }
    return $false
}

# a second copy would play the sound twice
$mutex = New-Object System.Threading.Mutex($false, 'LidOpenSoundSingleInstance')
$isOwner = $false
try { $isOwner = $mutex.WaitOne(0) } catch { $isOwner = $true }
if (-not $isOwner) {
    Write-Log "another instance already running, this one exits"
    exit 0
}

Write-Log ("lid-open-sound started, wav={0}" -f $WavPath)

if (-not (Test-Path -LiteralPath $WavPath)) {
    Write-Log "ERROR: sound file not found, watcher stays alive but cannot play"
}

# preload once so the first real play after resume is faster
$preload = New-Object System.Media.SoundPlayer($WavPath)
$preload.Load()

$lastCheck = [DateTime]::UtcNow
$pendingWake = $null

while ($true) {
    Start-Sleep -Milliseconds 500

    $nowUtc = [DateTime]::UtcNow
    $gap = ($nowUtc - $lastCheck).TotalSeconds
    $lastCheck = $nowUtc

    # the process is frozen by system sleep but the wall clock keeps running,
    # so a gap far larger than the loop interval means we just resumed
    if ($gap -ge 2.2) {
        Write-Log ("WAKE detected, gap={0:N2}s" -f $gap)
        $pendingWake = @{ At = $nowUtc; SawLock = $false; Played = $false }
    }

    if ($pendingWake -and -not $pendingWake.Played) {
        $elapsed = ($nowUtc - $pendingWake.At).TotalSeconds
        $locked = Test-Locked
        if ($locked) { $pendingWake.SawLock = $true }

        $playReason = $null
        if ($pendingWake.SawLock -and -not $locked) {
            # lock screen was seen and is gone -> the user just reached the desktop
            $playReason = "unlocked after wake"
        } elseif (-not $pendingWake.SawLock -and $elapsed -ge 8) {
            # no lock screen appeared (no password), fall back to a short delay
            $playReason = "no lock screen after wake"
        } elseif ($elapsed -gt 300) {
            # nobody unlocked for five minutes, drop it
            $pendingWake.Played = $true
        }

        if ($playReason) {
            $ready = Wait-AudioReady -MaxMs 6000
            Write-Log ("audio ready={0}, playing once ({1}, {2:N1}s after wake)" -f $ready, $playReason, $elapsed)
            [void](Play-Sound $playReason)
            $pendingWake.Played = $true
            # playing blocks this thread, reset the baseline to avoid a false second wake
            $lastCheck = [DateTime]::UtcNow
        }
    }
}
