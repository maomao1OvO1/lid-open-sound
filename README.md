# lid-open-sound

中文 | [English](README.en.md)

Windows 笔记本「合盖睡眠 → 开盖唤醒 → 输密码 → **进桌面那一刻**」播放一声自定义音效。

**MIT 许可证，全部源码都在本仓库**——可直接审查、修改、fork。

关键词：Windows 开盖音效 / 笔记本开盖提示音 / 开盖解锁音效 / lid open sound / laptop lid chime / play sound on resume / Windows lid sound open source。

![platform](https://img.shields.io/badge/platform-Windows%2010%20%2F%2011-lightgrey)
![powershell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![license](https://img.shields.io/badge/license-MIT-green)

---

## 为什么写这个

同类工具中有一个 [LidSound](https://github.com/Jax-DevinLabs/LidSound)（.NET，Windows 开盖音效）：内置 5 段音效免费，**换成自己的音频需 US$19.90 一次性买断**，授权按机器绑定（一机一码，以上价格与授权方式出自其 README）。本仓库免费、MIT，音效可自行替换，并在「解锁进桌面」那一刻播放。

它其实不需要驱动、不需要管理员权限、不需要安装包，一个 PowerShell 脚本 + 一个 wav 就能做完——但有几个坑得先踩明白。这个仓库把踩过的坑和最终方案都写下来了，MIT 协议，随便用。

> 一个需要说明的事实：截至 2026-11，它的 GitHub 仓库共 8 个文件（`README.md`、`CHANGELOG.md`、`LICENSE`、`docs/用户手册.md`、`docs/隐私说明.md`、`.gitignore`、两个 issue 模板），**没有源码文件**（`.cs` / `.csproj` / `.sln` 数量为 0）；对外发布的是 Releases 里的编译产物（`LidSound-Setup.exe`、`LidSound-Portable.zip`）。
>
> 其 `LICENSE` 自 **2026-10-11 起为专有 EULA**（此前以 MIT 发布的版本仍适用 MIT），条款包含禁止再分发、倒卖与逆向；而 README 里内嵌的 license 徽章目前仍显示 MIT，GitHub API 对该仓库的识别结果为 `NOASSERTION / Other`。
>
> 以上信息取自其仓库文件树（`git/trees/HEAD?recursive=1`）、`LICENSE` 原文与提交记录；若对方后续调整，以最新仓库为准。
>
> 本仓库的源码全部在仓库里，可直接阅读与修改。

## 它做什么

| 场景 | 行为 |
|---|---|
| 合盖 → 开盖 → 输密码 → 进桌面 | 进桌面瞬间响一声 |
| 合盖 → 开盖（没设密码） | 唤醒后 8 秒响一声 |
| 开盖后一直不输密码 | 不响（最多等 5 分钟后放弃） |
| 开机登录 | 自动启动，隐藏窗口，无黑框 |

特点：

- 纯 PowerShell + VBS，**无需管理员权限、无驱动、无安装包**
- 单实例互斥锁，不会重复响
- 日志 `events.log` 记录每次唤醒/播放耗时，方便排错
- 换音效 = 替换 `sound.wav`，不用改代码

## 原理（这三个坑才是重点）

### 坑 1：Windows 电源事件在隐藏进程里收不到

直觉方案是订阅 `SystemEvents.PowerModeChanged`，但实测在隐藏窗口运行的 PowerShell 里**完全收不到**：

| 方案 | 结果 |
|---|---|
| `Register-ObjectEvent SystemEvents.PowerModeChanged` | 只有启动日志，没有 Suspend/Resume |
| 加隐藏 Form + `[Windows.Forms.Application]::Run($form)` 提供消息泵 | 仍然收不到 |
| `Register-WmiEvent Win32_PowerManagementEvent -Action` | 仍然收不到（`while{Start-Sleep}` 死循环时 `-Action` 脚本块根本不会被调度） |

所以别在电源事件上浪费时间，换思路。

### 坑 2：唤醒后声卡要好几秒才真正出声

睡眠时 HDA codec 断电，唤醒后需要重新初始化。实测唤醒后 4 秒、7 秒播放**用户完全听不到**，但同一文件手动播放正常——`PlaySync()` 耗时正常（≈1.2 秒）并不代表声音真的到了耳朵里。

### 坑 3：进程被冻结 → 用「墙钟间隙」判断唤醒

S3 睡眠时整个进程被系统冻结，但**墙钟照走**。所以：

```powershell
Start-Sleep -Milliseconds 500
$gap = ([DateTime]::UtcNow - $lastCheck).TotalSeconds
if ($gap -ge 2.2) { <刚唤醒> }
```

正常循环间隔 0.5 秒，突然出现 2.2 秒以上的间隔只可能是进程被冻结过——这就是最可靠的「刚睡醒」信号，不需要任何系统事件。

### 最终播放时机：等锁屏消失

Windows 解锁前 `LogonUI.exe` 一直在运行，解锁后消失。所以：

```
WAKE 检测到
  └─ 每 500ms 检查 LogonUI 是否还在
       ├─ 见过锁屏 + LogonUI 消失  → 播一声（就是「进桌面那一刻」）
       ├─ 从未见锁屏（无密码）      → 唤醒后 8 秒兜底播一声
       └─ 5 分钟没人解锁            → 放弃
```

播放前还会等 `Audiosrv` 服务就绪，并用 `PlaySync()` 的耗时判断是否真播（低于 500ms 视为音频端点没准备好，自动重试 3 次）。

## 安装

1. 下载本仓库（或 `git clone`），放到任意目录，例如 `D:\tools\lid-open-sound`
2. 准备一个音效文件，命名为 `sound.wav`，放到同一目录（任意 wav 都行）
3. 右键 `install.ps1` → 使用 PowerShell 运行（不需要管理员）

`install.ps1` 会做三件事：

- 在 `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` 写入 `LidOpenSound` 自启项（登录后隐藏启动）
- 立刻启动一次监听进程
- 打印当前状态与日志位置

> 只写入当前用户（HKCU），不碰系统级设置，卸载干净。

## 卸载

运行 `uninstall.ps1`：删除自启项 + 结束监听进程。

## 试听 / 排错

- `test-play.ps1`：手动播放一次 `sound.wav`，确认音量、设备、文件都正常
- `events.log`：每次启动、检测到唤醒、音频服务就绪、播放耗时都会记录
  - 有 `PLAY` 但听不到 → 音频设备/音量问题
  - 连 `WAKE detected` 都没有 → 监听进程没在跑（`uninstall` 过 / 被杀）
- 想调灵敏度：改脚本里的 `2.2`（秒）。笔记本一般 2～3 秒合适，太小会被系统卡顿误触发

## 已知限制

- 只对**睡眠/休眠恢复**生效；如果电源策略是「合盖不睡眠」，就不会触发
- 依赖 `LogonUI.exe` 判断锁屏（Windows 10/11 通用）；无密码直接进桌面的机器走 8 秒兜底
- 唤醒后声卡初始化慢的机器，第一次可能延迟几秒才响
- 进程被杀（如某些「优化软件」）后要重新登录才会自启

## 兼容性

- Windows 10 / 11（Windows PowerShell 5.1 自带，无需装 PowerShell 7）
- 必须运行在**用户会话**里（不能做系统服务，服务态播放不出声音）

## 常见问题（Q&A）

**Q：我的笔记本支持吗？**

A：只要合盖会进入睡眠（S3 / 现代待机）就支持。本方案不读 ACPI 盖子状态、不依赖固件上报开盖事件，检测的是「进程被冻结后恢复」这个事实，因此与机型、固件无关。唯一不触发的情况是电源策略把合盖设成「不睡眠」——那样机器根本没睡，也就没有「唤醒」。

**Q：为什么是进桌面才响，而不是一开盖就响？**

A：声卡问题。实测唤醒后 4 秒、7 秒播放都听不到（同一文件手动播放正常），说明唤醒后 HDA 编解码器需要数秒重新初始化。等锁屏消失（解锁完成）再播，既稳定又能听见。这是刻意设计，不是延迟。

**Q：占用多少资源？**

A：一个常驻 PowerShell 进程（Windows 自带 5.1，不打包运行时）。实测：工作集约 **60 MB**、私有内存约 58 MB；运行 50 分钟累计 CPU 约 4 秒。日志只在启动/唤醒/播放时写入（一次运行约 4 KB）。

**Q：需要管理员权限吗？会改系统设置吗？**

A：都不需要。只往 `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` 写一条当前用户的启动项，不碰 HKLM、不装驱动、不注册服务、不改电源策略。

**Q：会不会响两次，或者多个进程抢着响？**

A：不会。脚本开头用命名互斥锁（`LidOpenSoundSingleInstance`）保证单实例；每次唤醒只播一次；播放是阻塞调用，播完会重置计时基线，避免把阻塞误判成第二次唤醒。

**Q：会上传我的数据吗？**

A：不会。只读本地 `sound.wav` 并播放，无网络、无遥测、无账号、无崩溃上报。

**Q：为什么不用 Windows 的电源事件？**

A：因为在隐藏进程里收不到。三个方案（`SystemEvents.PowerModeChanged`、加隐藏 Form 提供消息泵、`Register-WmiEvent Win32_PowerManagementEvent`）实测全部失败，详见上文「坑 1」。

**Q：和其他同类工具比呢？**

A：只说事实：LidSound 程序本体免费、内置 5 段音效免费，但**换成自己的音频要 US$19.90 一次性买断、按机器绑定**；其仓库共 8 个文件、没有源码，`LICENSE` 自 2026-10-11 起为专有 EULA（禁止再分发、倒卖与逆向），而 README 徽章仍显示 MIT。本项目源码全部公开、MIT、换音效免费；另外它的 Q&A 自述「极少数机型因固件不上报开盖状态会退回到唤醒时播放」，本方案不依赖固件上报。

**Q：怎么卸载？**

A：运行 `uninstall.ps1`（删除自启项并结束进程），然后删掉文件夹即可，不留注册表残留。

**Q：能用在台式机，或者只锁屏不休眠的机器上吗？**

A：不能。本方案检测的是「睡眠后恢复」，台式机没有合盖动作，只锁屏不休眠也不会产生时间跳变。

## 原理速查表

| 需求 | 怎么做 | 为什么 |
|---|---|---|
| 知道「刚睡醒」 | 墙钟间隔 ≥ 2.2s | 系统事件在隐藏进程里收不到 |
| 等声卡就绪 | `Wait-AudioReady` + `PlaySync` 耗时校验 | 唤醒后前几秒音频被吞 |
| 知道「进桌面了」 | `LogonUI.exe` 消失 | 解锁前它一直存在 |
| 防重复响 | 命名 Mutex + 播放后重置基线 | 多实例/阻塞都会导致重复 |

## License

MIT © 2026 maomao1OvO1

本项目只做「播放一个本地 wav」，不上传任何数据、不联网。
