# lid-open-sound

English | [中文](README.md)

Close the lid → open it → type your password → **the moment the desktop appears**, play a sound you chose.

**No packing, no obfuscation, no hidden implementation: source, build steps and logs are all public.**

![platform](https://img.shields.io/badge/platform-Windows%2010%20%2F%2011-lightgrey)
![powershell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![license](https://img.shields.io/badge/license-MIT-green)

**MIT licensed — all source code lives in this repository.** Read it, audit it, modify it, fork it.

Keywords: windows lid sound, laptop lid open sound, lid open chime, play sound on resume, open laptop sound, Windows 10 / 11 lid chime, open source alternative.

> **30-second version**: download → double-click `install.py` → drag your audio file into the window → press Enter. Done.

---

# 📦 Part 1 · For people who just want it to work

## What it is

A tiny Windows utility: **when you close your laptop, open it again and unlock, it plays one sound of your choice as the desktop appears.**

- no driver
- no admin rights
- no account
- no network, no telemetry

## What you need

| Need | Notes |
|---|---|
| A Windows 10 / 11 laptop | Desktops do not apply (there is no "lid") |
| One audio file | `.wav` is easiest; `mp3 / m4a / ogg` need `ffmpeg` installed to be converted |
| Python 3.8+ (optional) | Only for "Option A"; use "Option B" if you do not have Python |

## Install (pick one)

### Option A: the installer (easiest, recommended)

1. Download this repository (`Code` → `Download ZIP`, unzip anywhere)
2. Double-click **`install.py`**
3. **Drag your audio file into the black window** and press Enter
4. You should see:

```
✔ 音效已更新：my-sound.wav
✔ 已设置开机自启（登录后隐藏运行）
✔ 监听进程已启动
✔ 监听中（1 个实例）
```

> Cannot double-click? Right-click → *Run with Python*, or in a terminal: `python install.py`.
> No Python? Use Option B below.

### Option B: the PowerShell script

1. Rename your audio file to `sound.wav` and put it next to the scripts
2. Right-click **`install.ps1`** → *Run with PowerShell*
3. Wait for "Done." — that is it

## Changing the sound

**Run `install.py` again** and give it the new file.

- The old sound is backed up as `sound.wav.bak`
- No reboot, no reinstall

## Does it start automatically?

Yes. After installation it starts on every logon, hidden — you will never see a console window.

If something kills it (an "optimizer", a virus scanner, a mistake), a watchdog checks once a minute and restarts it.

## How to test it

1. Close the lid (let the machine sleep)
2. Wait about 5 seconds
3. Open the lid and type your password
4. **The moment the desktop shows up**, you should hear the sound

## No sound? Check in this order

1. **Read the log**: open `events.log` and look at the last lines
   - `WAKE detected` present → detection works, the problem is audio
   - no `WAKE detected` at all → the watcher is not running
2. **Check volume / mute** in the tray
3. **Reinstall**: run `install.py` again (it restarts the watcher)

## Uninstall

Right-click **`uninstall.ps1`** → *Run with PowerShell*. It removes the autostart entry, the watchdog task and stops the watcher. Then delete the folder.

## FAQ (plain English)

**Q: Do I need admin rights?**

No. Everything runs per-user; nothing system-wide is touched.

**Q: Does it collect my data?**

No. It reads the `.wav` you give it and plays it. No network requests, no telemetry, no account.

**Q: Why does it play when the desktop appears instead of when the lid opens?**

The audio codec needs several seconds to come back after resume. Playing right after wake is silently dropped — we measured playbacks at +4 s and +7 s being completely inaudible. Waiting for the unlock means the codec is ready.

**Q: Does it work on a desktop, or on a PC that only locks the screen?**

No. It detects "resume from sleep"; a desktop has no lid, and a screen lock without sleep produces no wall-clock gap.

**Q: How do I know it is running?**

Task Manager shows a `powershell.exe` whose command line contains `lid-open-sound.ps1`. It is quiet: about 60 MB RAM and almost no CPU.

**Q: Is it safe?**

Everything is plain text: four scripts, about 4 KB in total, no binaries, no compiler. Anyone can read every line.

**Q: Can I use it on several laptops?**

Yes — install it on each one. It is free and there is nothing to activate.

---

---

## Comparison record: LidSound (checked 2026-11-22)

Another tool exists in the same space: **[LidSound](https://github.com/Jax-DevinLabs/LidSound)** (repo [`Jax-DevinLabs/LidSound`](https://github.com/Jax-DevinLabs/LidSound), .NET, Windows lid sound).

Every item below comes from its **public repository, its public docs, or the installer package it publishes**, with source and check date noted. **No judgement is made about its design or intent.** If it changes, its latest repository and licence govern.

### 1. Repository

| Item | Content | Source |
|---|---|---|
| Created / last push | 2026-10-09 11:04 / 2026-10-14 03:48 (UTC) | GitHub API `/repos/...`, checked 2026-11-22 |
| Total files | **8**: `README.md`, `CHANGELOG.md`, `LICENSE`, `docs/用户手册.md`, `docs/隐私说明.md`, `.gitignore`, two issue templates | `git/trees/HEAD?recursive=1`, 2026-11-22 |
| **Source files** | **0** (no `.cs` / `.csproj` / `.sln` / `.xaml`; commit history per extension is also empty) | tree above + `commits?path=…`, 2026-11-22 |
| Detected language | none (nothing to detect) | GitHub API `/repos/...` |
| Commits | **19**, all within 5 days (2026-10-09 → 10-14) | `commits?per_page=100` |
| Commit authors | `Jax-DevinLabs` ×2, `WorkBuddy-Test` ×17 | same |
| Stars / forks / issues | 1 / 0 / 0 | GitHub API, 2026-11-22 |

### 2. Licence

| Date | File (commit) | Content | Source |
|---|---|---|---|
| 2026-10-09 11:14 | `LICENSE` (`2cfc1460`) | **standard MIT text**, 1,069 bytes | `contents/LICENSE?ref=2cfc1460` |
| 2026-10-11 01:32 | `LICENSE` (`77b8380e`) | **proprietary EULA**, 3,106 bytes, effective 2026-10-11 | `contents/LICENSE?ref=77b8380e` |
| 2026-10-09 → 10-14 | `README.md` badge | always `license-MIT-green` (identical in the first and the last version) | README at `2cfc1460` / `b3194114` |
| 2026-11-22 | GitHub licence detection | `NOASSERTION / Other` | `license` field of `/repos/...` |

> In other words: MIT existed for about **two days** (2026-10-09 11:14 → 2026-10-11 01:32), then it became a proprietary EULA and the README badge was not updated. **Neither period contained source code**, so what MIT licensed during those two days was documentation.

### 3. Published artifacts

| Item | Content | Source |
|---|---|---|
| Release | only `v0.3.0` (2026-10-12 00:43): `LidSound-Setup.exe` 72,579,782 B, `LidSound-Portable.zip` 69,684,837 B, `…-0.3.0-full.nupkg` 69,692,614 B, two JSON manifests | `releases?per_page=10`, 2026-11-22 |
| App manifest | `assets/manifest.json`: five sounds `ding-money` 2150 ms / `bye-bye` 2000 ms / `cat-meow` 1880 ms / `boxing-bell` 3000 ms / `zhu-kou` 1187 ms, ~1.8 MB total | `assets/manifest.json` inside the published package |
| Note in that manifest | contains: five "unknown origin" network sounds removed (konan / Spider-Man / best-anime-ever / bye-bye-soundbible / Mario jump …); the five replacements are described as "collected by the owner, no clear commercial licence" | same file (`_readme` field) |
| Dependencies | `LidSound.deps.json` lists 20 packages: `NAudio` (7 packages, 2.2.1), `Velopack` 1.2.161, `System.Management` 8.0.0, `Microsoft.Win32.Registry` 4.7.0, …; self-contained .NET 8.0.31 | `LidSound.deps.json` inside the published package |
| Assemblies | `LidSound` / `LidSound.Core` / `LidSound.Bootstrap` (0.3.0) | same |

### 4. Its own CHANGELOG

| Version | Statement |
|---|---|
| 0.1.0 (10-09) | "three built-in sounds … fully synthesised, no commercial music or third-party assets, zero licensing risk" |
| 0.2.7 (10-10) | built-in sounds replaced with `konan-hiramekiyin` (default), Spider-Man, best-anime-ever, bye-bye-soundbible, Mario jump |
| 0.3.0 (10-12) | "built-in sound copyright compliance: removed 5 network sounds of unknown origin…" |
| 0.1.1 (10-09) | "auto-update points at the correct public repository; the first version pointed at a repository that is not public…" |
| 0.2.9 (10-11) | "licence change: from this version a proprietary licence (EULA) applies" |

### 5. Pricing and behaviour (its README)

| Item | Content |
|---|---|
| Free part | the app plus five built-in sounds |
| Paid part | changing the sound to your own: **US$19.90 one-time**, bound to one machine (`license.dat`, one licence per device) |
| Detection | Windows lid-state notification; its CHANGELOG states that on a few machines whose firmware does not report the lid state the feature is silently disabled |
| Memory | about 260 MB, as stated in its README (bundled .NET runtime) |

### 6. Compared with this repository

| Item | LidSound | This repo |
|---|---|---|
| Source | 0 files | 12 text files, all published |
| Licence | MIT from 10-09 to 10-11, then proprietary EULA (badge unchanged) | MIT, LICENSE and README agree |
| Sounds | five built-in, its own manifest note says "no clear commercial licence" | no audio shipped |
| Detection | relies on firmware lid reports | wall-clock gap, firmware independent |
| Playback moment | plays when the lid opens | plays when the desktop appears |
| Size | installer ~30 MB (single-file exe ~69 MB) | scripts total ~4 KB |
| Memory | ~260 MB (its own README) | measured ~60 MB |
| Price | US$19.90 one-time, machine-bound | free |

> Everything above was checked on **2026-11-22**, from its public repository, public docs and its own published installer. This repo gains nothing from it and makes no legal claim — the facts are simply recorded so readers can verify them.

# 🔧 Part 2 · For people who like to tinker

## How it works in one paragraph

**While the machine sleeps, the process is frozen but the wall clock keeps running** — so a sudden jump in the loop interval means "we just resumed". Then it waits for `LogonUI.exe` to disappear (the unlock), because the audio codec needs several seconds to come back. Before playing it checks that the stream was really delivered, using the duration of `PlaySync()`.

## Why Windows power events don't work (three measured results)

The obvious approach is `SystemEvents.PowerModeChanged`. In a hidden PowerShell process it never arrives:

| Approach | Measured result |
|---|---|
| `Register-ObjectEvent SystemEvents.PowerModeChanged` | only the startup line, no Suspend/Resume |
| Hidden Form + `[System.Windows.Forms.Application]::Run($form)` to pump messages | still nothing |
| `Register-WmiEvent Win32_PowerManagementEvent -Action` | still nothing (the `-Action` block is never scheduled while the script sits in `while { Start-Sleep }`) |

It is not a configuration problem: a hidden process has no message pump, and a blocking loop starves the scheduled script block.

## The actual detection: wall-clock gap

```powershell
$lastCheck = [DateTime]::UtcNow
while ($true) {
    Start-Sleep -Milliseconds 700
    $now = [DateTime]::UtcNow
    $gap = ($now - $lastCheck).TotalSeconds
    $lastCheck = $now

    if ($gap -ge 2.2) {
        # the process was frozen -> we just resumed from sleep
    }
}
```

A normal iteration takes 0.7 s. A gap of 2.2 s or more can only mean the process was frozen. No system events, no firmware reports, no per-machine quirks.

> Why not read the ACPI lid state? Because many firmwares never report lid events — the comparable tool's own FAQ admits "a few machines' firmware does not report the lid state and the feature is silently disabled". The wall-clock approach sidesteps that: if the machine can sleep and resume, it works.

## Why it waits for the unlock

`LogonUI.exe` runs while the machine is locked and exits on unlock:

```
resume detected (gap >= 2.2 s)
  └─ poll LogonUI.exe every 500 ms
       ├─ lock screen seen, then LogonUI gone -> play (the desktop moment)
       ├─ no lock screen ever appeared        -> play 8 s after resume
       └─ nobody unlocked for 5 minutes       -> give up
```

The reason is the **audio codec**: right after resume, playbacks at +4 s and +7 s were inaudible, while the same file played manually worked fine. `PlaySync()` returning after 1.2 s does **not** mean the sound reached the speakers.

## Playback reliability: PlaySync duration check

```powershell
$sw = [Diagnostics.Stopwatch]::StartNew()
$player.PlaySync()
$sw.Stop()
if ($sw.ElapsedMilliseconds -ge 500) { ok } else { endpoint not ready -> retry }
```

`PlaySync` blocks until the whole file has been handed to the endpoint, so its duration should roughly match the file length (a 1.13 s file takes 1.2–1.4 s). A much shorter return means the endpoint accepted nothing — retry, up to 3 times.

## Single instance: named mutex

```powershell
$mutex = New-Object System.Threading.Mutex($false, 'LidOpenSoundSingleInstance')
if (-not $mutex.WaitOne(0)) { exit 0 }   # another copy is already running
```

> The mutex is **global** (cross-process). When upgrading from one folder to another, the old process still holds it and the new instance exits immediately — so any installer cleanup must match **both** the old script name `lidsound.ps1` and the new one `lid-open-sound.ps1`.

## Self-healing: the watchdog

The watcher can be killed by an optimizer, a scanner, or a mistake (we hit this: the process vanished after 17:50 with no crash record in the Application log). Hence:

- `watchdog.ps1` — checks for a powershell process running `lid-open-sound.ps1`; if none, starts `run_hidden.vbs`
- `watchdog_hidden.vbs` — starts it with `WScript.Shell.Run(..., 0, False)`, so **no window is ever shown**
- scheduled task `LidOpenSound-Watchdog` — runs every minute

> Why not point the task directly at `powershell.exe`? Because `-WindowStyle Hidden` applies *after* the process starts, so a console flashes for a moment. Wrapping it in a VBS with window style 0 is the only silent way.

## Files

| File | Purpose | Size |
|---|---|---|
| `lid-open-sound.ps1` | main watcher: gap detection + LogonUI + playback retries + mutex | 4.7 KB |
| `run_hidden.vbs` | starts the watcher hidden (used by autostart) | 0.4 KB |
| `install.ps1` | writes HKCU autostart, registers the watchdog task, starts it | 2.9 KB |
| `install.py` | friendly interactive installer / sound changer | 7.6 KB |
| `uninstall.ps1` | removes autostart + task, stops the watcher | 1.2 KB |
| `watchdog.ps1` | restarts the watcher if it is gone | 1.0 KB |
| `watchdog_hidden.vbs` | runs the watchdog silently | 0.5 KB |
| `test-play.ps1` | manual playback test + audio service status | 0.8 KB |

Runtime files: `events.log` (start / wake / play / errors) and `watchdog.log` (written only when a restart actually happened).

## Key constants

| Constant | Value | Meaning |
|---|---|---|
| loop interval | 700 ms | detection resolution |
| wake threshold | **2.2 s** | a bigger gap means "was frozen" |
| lock poll | 500 ms | how often `LogonUI.exe` is checked |
| no-lock fallback | 8 s | delayed play when no lock screen appears |
| give up | 300 s | stop waiting for an unlock after 5 minutes |
| playback check | 500 ms | shorter `PlaySync` = not really played |
| retries | 3, 1.5 s apart | when the endpoint is not ready |
| watchdog interval | 1 minute | smallest granularity of schtasks |

Tuning notes: do not go below about 1.5 s for the wake threshold (an old machine occasionally stutters); if you want "play on lid open", drop the LogonUI logic, but you will meet the unready-codec problem again.

## Performance measured (T420 / i5-2520M / Windows 10 19045)

| Metric | Measured |
|---|---|
| working set | 60.2 MB |
| private bytes | 57.5 MB |
| CPU over 50 minutes | 3.75 s |
| log growth | ~4 KB per run |
| watcher size | 4.7 KB (no bundled runtime) |

## Log format

```
[2026-11-21 16:13:10.874] WAKE detected, gap=9.30s
[2026-11-21 16:13:23.518] audio ready=True, playing once (unlocked after wake, 12.6s after wake)
[2026-11-21 16:13:24.788] PLAY open.wav (unlocked after wake) attempt 1 took 1262ms
```

| Line | Meaning |
|---|---|
| `WAKE detected, gap=Xs` | resume detected, X = frozen duration |
| `audio ready=…` | whether the audio service answered |
| `playing once (…)` | playback triggered, reason in parentheses |
| `PLAY … took Xms` | actual playback duration (≈ file length when it works) |
| `another instance already running` | mutex rejected a duplicate |
| `ERROR play attempt N: …` | playback exception and retry count |

## Known limitations

- Only reacts to **sleep / hibernation resume**; a "do nothing on lid close" power policy never triggers it
- Uses `LogonUI.exe` to detect the lock screen (works on Windows 10/11); machines without a password use the 8 s fallback
- On machines with a very slow audio codec the first playback may be delayed a few seconds
- Must run in a **user session** (it cannot be a service — services have no desktop audio session)
- After being killed, the watcher may take up to a minute to come back

## Technical FAQ

**Q: Why not read the ACPI lid state?**

Possible, but many firmwares never report it. `GUID_LIDSWITCH_STATE_CHANGE`-style notifications are missed on some laptops and the feature fails silently. The wall-clock approach needs only sleep/resume.

**Q: Why PowerShell instead of C# or Python?**

Zero dependencies. Windows already has PowerShell 5.1 and .NET's `System.Media.SoundPlayer`. C# would mean bundling .NET (tens of MB); Python would mean asking the user to install an interpreter.

**Q: Why not NAudio?**

NAudio is great but heavy for "play one wav" — it pulls seven packages (NAudio/Core/WinMM/Wasapi/Asio/Midi/WinForms). `SoundPlayer` is built in and enough.

**Q: Can it also play when the lid closes?**

In theory you can race the sleep transition, but you only have one or two seconds and the system often mutes audio. This project only does lid-open.

**Q: Can it play before logon (boot sound)?**

No. Third-party processes cannot play audio on the logon screen — there is no user audio session yet.

**Q: Why is `PlaySync` duration normal but still silent?**

The HDA codec re-initialises after resume; during that window a playback call may "succeed" without reaching the speakers. That is why we wait for the unlock, delay, and verify the duration.

**Q: Can I detect the unlock without `LogonUI.exe`?**

Yes — `WTSQuerySessionInformation` or a `SessionSwitch` subscription both work. `LogonUI.exe` presence is the simplest and most version-stable check.

**Q: Can I play a random sound from several files?**

Sure — pick randomly inside the play function. The current design deliberately uses one sound for predictability.

**Q: Will antivirus flag it?**

It is plain `.ps1` / `.vbs` text with no compiled artifact, so false positives are unlikely. Packed exe versions of similar tools are flagged far more often.

**Q: Does it work on Windows Server?**

Technically yes (user session + `LogonUI`), but there is no lid, so it is pointless.

## License

MIT License © 2026 maomao1OvO1

This tool only plays a local wav file. No network, no telemetry.
