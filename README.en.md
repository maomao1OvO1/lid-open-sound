# lid-open-sound

Plays a custom sound **the moment you reach the desktop** after opening your laptop lid.

**MIT licensed — all source code lives in this repository.** Read it, audit it, modify it, fork it.

Keywords: windows lid sound, laptop lid open sound, lid open chime, play sound on resume, open laptop sound, Windows 10 / 11 lid chime, open source alternative.

![platform](https://img.shields.io/badge/platform-Windows%2010%20%2F%2011-lightgrey)
![powershell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![license](https://img.shields.io/badge/license-MIT-green)

[中文](README.md) | English

---

## Why this exists

A similar tool exists: [LidSound](https://github.com/Jax-DevinLabs/LidSound) — a .NET Windows lid sound app. It ships five built-in sounds for free; **changing the sound to your own costs US$19.90, one-time, bound to one machine** (`license.dat`, one license per device — price and licensing as stated in its README).

It does not need drivers, admin rights or an installer — one PowerShell script plus a wav is enough. But there are a few pitfalls to understand first; this repo documents them along with the final design.

Facts about that repository, as of 2026-11:

1. **No source code is published.** The repo contains 8 files — `README.md`, `CHANGELOG.md`, `LICENSE`, two files under `docs/`, `.gitignore`, and two issue templates — and **zero source files** (`.cs` / `.csproj` / `.sln` count: 0). Binaries are distributed through Releases (`LidSound-Setup.exe`, `LidSound-Portable.zip`).
2. **Its LICENSE has been a proprietary EULA since 2026-10-11** (versions published under MIT before that date keep their MIT terms). That EULA prohibits redistribution, resale and reverse engineering. Its README still embeds an MIT license badge, while the GitHub API reports `NOASSERTION / Other`.
3. **It plays on lid open**, driven by Windows power events; it does not wait for the unlock.

Source: its repository file tree (`git/trees/HEAD?recursive=1`), the `LICENSE` text and its commit history; if anything changes, the repository as it stands then governs.

This repo differs in one concrete way: the full source is here, MIT, readable and modifiable. Changing the sound is free, and it plays when the desktop appears.

## What it does

| Situation | Behaviour |
|---|---|
| Close lid → open lid → type password → desktop appears | one sound, right as the desktop shows |
| Close lid → open lid (no password set) | one sound, 8 s after resume |
| Lid open, never unlocked | no sound (gives up after 5 minutes) |
| User logon | starts automatically, hidden window, no console flash |

Features:

- Pure PowerShell + VBS: **no admin rights, no driver, no installer**
- Single-instance mutex — never double-plays
- `events.log` records every wake / play attempt with timings
- Change the sound by replacing `sound.wav` — no code edits

## How it works (the three pitfalls are the interesting part)

### Pitfall 1: Windows power events never arrive in a hidden process

The obvious approach is `SystemEvents.PowerModeChanged`. Measured on a hidden PowerShell process, it does not work at all:

| Approach | Result |
|---|---|
| `Register-ObjectEvent SystemEvents.PowerModeChanged` | only the startup log line, no Suspend/Resume |
| Hidden Form + `[Windows.Forms.Application]::Run($form)` to pump messages | still nothing |
| `Register-WmiEvent Win32_PowerManagementEvent -Action` | still nothing (the `-Action` block is never scheduled while the script sits in `while { Start-Sleep }`) |

Don't waste time on power events. Use a different signal.

### Pitfall 2: the audio codec is dead for several seconds after resume

The HDA codec is powered down during sleep and needs to be reinitialised. In practice, playing 4 s and 7 s after resume produced **no audible sound**, while the same file played manually works fine. A `PlaySync()` call returning after ~1.2 s does **not** mean the sound reached the speakers.

### Pitfall 3: the process is frozen → use a wall-clock gap

While the machine is in S3, the process is frozen but the wall clock keeps running:

```powershell
Start-Sleep -Milliseconds 500
$gap = ([DateTime]::UtcNow - $lastCheck).TotalSeconds
if ($gap -ge 2.2) { <just resumed> }
```

A normal iteration takes 0.5 s. A sudden gap of 2.2 s or more can only mean the process was frozen — the most reliable "just woke up" signal there is, no system events required.

### Final timing: wait for the lock screen to disappear

`LogonUI.exe` runs while the machine is locked and exits the moment you unlock:

```
resume detected
  └─ poll LogonUI every 500 ms
       ├─ lock screen seen, then LogonUI gone → play once (the desktop moment)
       ├─ no lock screen ever appeared        → play 8 s after resume
       └─ nobody unlocked for 5 minutes       → give up
```

Before playing it also waits for `Audiosrv`, and uses the `PlaySync()` duration as a sanity check (under 500 ms = audio endpoint not ready, retry up to 3 times).

## Install

1. Download or clone this repo to any folder, e.g. `D:\tools\lid-open-sound`
2. Put a `sound.wav` next to the scripts. **No audio is shipped in this repo** (`.gitignore` excludes `sound.wav`): record your own, or use a CC0 / public-domain sound (e.g. CC0 samples on freesound.org)
3. Right-click `install.ps1` → *Run with PowerShell* (no admin needed)

`install.ps1` will:

- add a per-user autostart entry `LidOpenSound` under `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`
- start the watcher immediately
- print the current state and the log path

> Only HKCU is touched. Nothing system-wide, uninstalls cleanly.

## Uninstall

Run `uninstall.ps1`: removes the autostart entry and stops the watcher.

## Test / troubleshoot

- `test-play.ps1` — plays `sound.wav` once, so you can verify volume, output device and the file itself
- `events.log` — startup, wake detection, audio readiness and play durations
  - `PLAY` present but silent → audio device / volume issue
  - no `WAKE detected` at all → the watcher is not running
- Sensitivity: change `2.2` (seconds) in the script. 2–3 s suits most laptops; lower values may be triggered by system hiccups

## Known limitations

- Only reacts to **sleep/hibernate resume**; a "do nothing on lid close" power policy never triggers it
- Uses `LogonUI.exe` to detect the lock screen (works on Windows 10/11); machines without a password use the 8 s fallback
- On machines with a slow audio codec the first playback may be delayed a few seconds
- If the watcher is killed (some "optimizer" tools do this), it comes back on next logon

## Compatibility

- Windows 10 / 11, Windows PowerShell 5.1 (built in — PowerShell 7 not required)
- Must run in a **user session** (not as a service — services cannot play audio to the desktop)

## FAQ

**Q: Which laptops are supported?**

A: Any laptop that actually sleeps on lid close (S3 or modern standby). This tool does not read ACPI lid state and does not depend on firmware lid events: it detects "the process was frozen and resumed", so it is machine- and firmware-independent. The only case that never triggers is a power policy where closing the lid does nothing — the machine never sleeps, so there is nothing to resume from.

**Q: Why play when the desktop appears instead of the moment the lid opens?**

A: Audio hardware. Measured right after resume, playbacks at +4 s and +7 s were inaudible (the same file plays fine manually): the HDA codec needs several seconds to come back. Playing once the lock screen is gone is both reliable and audible — this is by design, not lag.

**Q: How much memory does it use?**

A: One resident PowerShell process (Windows 5.1, runtime not bundled). Measured on this machine: about **60 MB** working set, about 58 MB private; roughly 4 s of CPU over 50 minutes. The log only grows on start/wake/play (~4 KB per run).

**Q: Does it need admin rights or touch system settings?**

A: Neither. It writes one per-user autostart value under `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`. No HKLM, no driver, no service, no power-policy changes.

**Q: Can it play twice, or race with a second copy?**

A: No. A named mutex (`LidOpenSoundSingleInstance`) keeps it single-instance; each wake plays once; the play call is blocking and the timing baseline is reset afterwards, so the block is not mistaken for a second wake.

**Q: Does it send any data?**

A: No. It reads a local `sound.wav` and plays it: no network, no telemetry, no account.

**Q: Why not use the Windows power events?**

A: Because hidden processes never receive them. All three approaches tested (`SystemEvents.PowerModeChanged`, adding a hidden Form to pump messages, `Register-WmiEvent Win32_PowerManagementEvent`) failed — see "Pitfall 1".

**Q: How does it compare to similar tools?**

A: Facts only: LidSound's app and its five built-in sounds are free, but **changing the sound to your own costs US$19.90, one-time and machine-bound**; its repo contains 8 files with no source code, and its `LICENSE` has been a proprietary EULA since 2026-10-11 (no redistribution, resale or reverse engineering) while the README still shows an MIT badge. This project publishes all of its source under MIT and changing the sound is free. Its own FAQ states that a few machines whose firmware does not report the lid state fall back to playing on resume; this project does not depend on firmware reports.

**Q: How do I uninstall?**

A: Run `uninstall.ps1` (removes the autostart entry and stops the watcher), then delete the folder. No registry leftovers.

**Q: Does it work on desktops, or on machines that only lock the screen?**

A: No. It detects resume from sleep; a desktop has no lid, and a screen lock without sleep produces no wall-clock jump.

## Cheat sheet

| Need | How | Why |
|---|---|---|
| Know "we just woke up" | wall-clock gap ≥ 2.2 s | power events don't arrive in hidden processes |
| Wait for audio | `Wait-AudioReady` + `PlaySync` duration check | first streams after resume get swallowed |
| Know "desktop is up" | `LogonUI.exe` disappeared | it lives until unlock |
| Never double-play | named Mutex + reset baseline after blocking play | multi-instance / blocking both cause repeats |

## License

MIT © 2026 maomao1OvO1

This tool only plays a local wav file. No network, no telemetry.
