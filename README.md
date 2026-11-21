# lid-open-sound

中文 | [English](README.en.md)

合盖睡眠 → 开盖唤醒 → 输密码 → **进桌面那一刻**，播放一声你自己选好的音效。

**不打包、不混淆、没有隐藏实现：源码、构建步骤与日志全部可查。**

![platform](https://img.shields.io/badge/platform-Windows%2010%20%2F%2011-lightgrey)
![powershell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![license](https://img.shields.io/badge/license-MIT-green)

**MIT 许可证，全部源码都在本仓库**——可直接审查、修改、fork。

关键词：Windows 开盖音效 / 笔记本开盖提示音 / 开盖解锁音效 / lid open sound / laptop lid chime / play sound on resume。

> **30 秒版**：下载 → 双击 `install.py` → 把音频文件拖进窗口 → 回车。完。

---

# 📦 第一部分 · 给不想折腾的人

## 这是什么

一个很小的 Windows 小工具：**你合上笔记本、再打开、输完密码进到桌面时，响一声你自己选的音效**。

- 不需要装驱动
- 不需要管理员权限
- 不需要注册账号
- 不联网、不收集任何东西

## 装之前你需要

| 需要 | 说明 |
|---|---|
| 一台 Windows 10 / 11 笔记本 | 台式机不适用（没有"开盖"这个动作） |
| 一段音频文件 | `.wav` 最省事；`mp3 / m4a / ogg` 需要电脑上有 ffmpeg 才能自动转换 |
| Python 3.8+（可选） | 用"方式 A"才需要；没有 Python 就用"方式 B" |

## 安装（两种方式，选一种）

### 方式 A：双击安装器（最省事，推荐）

1. 下载本仓库（右上角 `Code` → `Download ZIP`，解压到任意文件夹）
2. 双击 **`install.py`**
3. 把准备好的音频文件**拖进那个黑色窗口**，按回车
4. 看到这样的输出就好了：

```
✔ 音效已更新：我的音效.wav
✔ 已设置开机自启（登录后隐藏运行）
✔ 监听进程已启动
✔ 监听中（1 个实例）
```

> 双击打不开？右键 →「使用 Python 运行」，或命令行里 `python install.py`。
> 没有 Python？用下面的方式 B。

### 方式 B：PowerShell 脚本

1. 把音频文件改名为 `sound.wav`，放进同一个文件夹
2. 右键 **`install.ps1`** →「使用 PowerShell 运行」
3. 也是一样看到"安装完成"即可

## 换音效

**再运行一次 `install.py`**，把新音频拖进去、回车。

- 旧音效会自动备份成 `sound.wav.bak`
- 不用重启电脑，不用重装

## 它会自己启动吗

会。装好之后每次登录 Windows 它都会自动在后台运行（隐藏窗口，看不到黑框）。

如果哪天被杀毒软件或"优化软件"杀掉了，还有一个看门狗每 1 分钟检查一次，会自动把它拉回来。

## 我该怎么测试它

1. 把笔记本**合上**（让它睡一会儿）
2. **等 5 秒左右**
3. **打开盖子**，输入密码
4. **点进桌面的那一刻**，应该会"咚"一声

## 没声音怎么办（按这个顺序）

1. **看日志**：打开文件夹里的 `events.log`，看最后几行
   - 有 `WAKE detected` → 检测到了，问题在声音播放
   - 连 `WAKE detected` 都没有 → 监听进程没在跑
2. **检查音量**：右下角喇叭有没有静音、音量是不是 0
3. **重新装一次**：再运行一遍 `install.py`（它会自动重启监听进程）

## 怎么卸载

右键 **`uninstall.ps1`** →「使用 PowerShell 运行」，它会：
- 删掉开机自启
- 删掉看门狗任务
- 结束正在运行的监听进程

然后直接删掉这个文件夹即可，不留垃圾。

## 常见问题（普通版）

**Q：需要管理员权限吗？**

不需要。所有操作都在当前用户下完成，不碰系统设置。

**Q：会不会偷我的数据？**

不会。它只做一件事：读你自己指定的 `.wav` 文件并播放。没有网络请求、没有遥测、没有账号。

**Q：为什么是"进桌面"才响，不是"一开盖"就响？**

因为笔记本刚唤醒那几秒，声卡还在初始化——这时候播放，声音会直接丢掉（我们实测过，唤醒后 4 秒、7 秒播放都听不见）。等到解锁进桌面，声卡准备好了，声音才真的能听到。

**Q：台式机 / 只锁屏的电脑能用吗？**

不能。它检测的是"睡眠后恢复"这个动作，台式机没有合盖，只锁屏不睡眠也不会触发。

**Q：装了以后怎么知道它在运行？**

任务管理器里会有一个 `powershell.exe` 进程（命令行里带 `lid-open-sound.ps1`）。它很安静，内存约 60MB，CPU 几乎为 0。

**Q：安全吗？**

你可以让任何人审查：全部源码都在仓库里，4 个脚本加起来约 4KB，没有任何编译产物、没有二进制。它不做任何隐藏操作。

**Q：支持多台电脑吗？**

支持，每台电脑各自装一份即可，互不影响，不收费。

---

---

## 对照记录：LidSound（核查日期 2026-11-22）

同类中另有一个工具 **[LidSound](https://github.com/Jax-DevinLabs/LidSound)**（仓库 [`Jax-DevinLabs/LidSound`](https://github.com/Jax-DevinLabs/LidSound)，.NET，Windows 开盖音效）。

下面每一项都来自**公开的仓库、公开的文档，或它自己发布的安装包**，并标注出处与核查时间；**不评价其设计或动机**。若对方后续调整，以其最新仓库与许可证为准。

### 一、仓库层面

| 项目 | 内容 | 出处 |
|---|---|---|
| 创建 / 最后推送 | 2026-10-09 11:04 / 2026-10-14 03:48（UTC） | GitHub API `/repos/...`，2026-11-22 核查 |
| 文件总数 | **8 个**：`README.md`、`CHANGELOG.md`、`LICENSE`、`docs/用户手册.md`、`docs/隐私说明.md`、`.gitignore`、两个 issue 模板 | `git/trees/HEAD?recursive=1`，2026-11-22 |
| **源码文件** | **0 个**（`.cs` / `.csproj` / `.sln` / `.xaml` 均无；按扩展名查提交历史也均为 0） | 上述文件树 + `commits?path=…`，2026-11-22 |
| 仓库语言识别 | 空（无代码可识别） | GitHub API `/repos/...` |
| 提交数 | **19 个**，全部落在 5 天内（2026-10-09 → 10-14） | `commits?per_page=100` |
| 提交作者 | `Jax-DevinLabs` 2 个、`WorkBuddy-Test` 17 个 | 同上 |
| Star / Fork / Issues | 1 / 0 / 0 | GitHub API，2026-11-22 |

### 二、许可证层面

| 时间 | 文件（提交） | 内容 | 出处 |
|---|---|---|---|
| 2026-10-09 11:14 | `LICENSE`（`2cfc1460`） | **标准 MIT 原文**，1,069 字节 | `contents/LICENSE?ref=2cfc1460` |
| 2026-10-11 01:32 | `LICENSE`（`77b8380e`） | **专有 EULA**，3,106 字节，正文写明"生效日期：2026-10-11" | `contents/LICENSE?ref=77b8380e` |
| 2026-10-09 → 10-14 | `README.md` 的徽章 | 始终是 `license-MIT-green`（首版与最后一版逐字相同） | 首版 `2cfc1460` / 末版 `b3194114` 的 README 原文 |
| 2026-11-22 | GitHub 许可识别 | `NOASSERTION / Other` | GitHub API `/repos/...` 的 `license` 字段 |

> 也就是说：MIT 许可证存在过**约两天**（2026-10-09 11:14 至 2026-10-11 01:32），此后为专有 EULA，而 README 徽章没有同步更新。**两个时期的仓库都没有源代码**，所以 MIT 期间可授权的对象也只是文档本身。

### 三、发布物层面

| 项目 | 内容 | 出处 |
|---|---|---|
| Release | 只有 `v0.3.0`（2026-10-12 00:43）：`LidSound-Setup.exe` 72,579,782 B、`LidSound-Portable.zip` 69,684,837 B、`…-0.3.0-full.nupkg` 69,692,614 B、两个 JSON 清单 | `releases?per_page=10`，2026-11-22 |
| 应用清单 | `assets/manifest.json`：5 段内置音效 `ding-money` 2150ms / `bye-bye` 2000ms / `cat-meow` 1880ms / `boxing-bell` 3000ms / `zhu-kou` 1187ms，合计约 1.8 MB | 官方发布包内的 `assets/manifest.json` |
| 该清单的备注字段 | 原文含："移除 5 个来源不明的网络音效（konan/蜘蛛侠/best-anime-ever/bye-bye-soundbible/mario-jump…）"；并写明替换后的 5 款为"个人收集，无明确商用授权" | 同上（`_readme` 字段） |
| 依赖清单 | `LidSound.deps.json` 列 20 个包：`NAudio` 7 件套（2.2.1）、`Velopack` 1.2.161、`System.Management` 8.0.0、`Microsoft.Win32.Registry` 4.7.0 等；运行时 .NET 8.0.31 自包含 | 官方发布包内的 `LidSound.deps.json` |
| 业务程序集 | `LidSound` / `LidSound.Core` / `LidSound.Bootstrap`（0.3.0） | 同上 |

### 四、文档自述（其 CHANGELOG 原文，逐条可查）

| 版本 | 自述内容 |
|---|---|
| 0.1.0（10-09） | "三段内置音效…全部由程序合成，不含商业音乐或第三方素材，零授权风险" |
| 0.2.7（10-10） | 内置音效换为 `konan-hiramekiyin`（默认）、蜘蛛侠、best-anime-ever、bye-bye-soundbible、马里奥跳跃 |
| 0.3.0（10-12） | "内置音效版权合规整改：移除 5 个来源不明的网络音效…" |
| 0.1.1（10-09） | "自动更新指向正确的公开仓库。初版指向一个不对外开放的仓库…" |
| 0.2.9（10-11） | "许可协议变更：自本版本起采用专有许可协议（EULA）" |

### 五、收费与行为（其 README 自述）

| 项目 | 内容 |
|---|---|
| 免费部分 | 程序本体 + 5 段内置音效 |
| 付费部分 | 换成自己的音频需 **US$19.90 一次性买断**，授权按机器绑定（一机一码） |
| 检测方式 | 基于 Windows 的盖子状态通知；其 CHANGELOG 写明"极少数机型固件不上报开盖状态，功能会静默禁用" |
| 内存占用 | 其 README 自述约 260 MB（含打包 .NET 运行时） |

### 六、与本仓库的对照

| 项目 | LidSound | 本仓库 |
|---|---|---|
| 源码 | 0 个文件 | 12 个文本文件，全部公开 |
| 许可证 | 10-09 至 10-11 为 MIT，之后专有 EULA（徽章未更新） | MIT，LICENSE 与 README 一致 |
| 音效 | 5 段内置，其清单备注称"无明确商用授权" | 不附带任何音频 |
| 检测 | 依赖固件上报盖子状态 | 墙钟间隙，不依赖固件 |
| 播放时机 | 开盖即播 | 解锁进桌面时播 |
| 体积 | 安装包约 30 MB（单文件 exe 约 69 MB） | 脚本合计约 4 KB |
| 内存 | 其自述约 260 MB | 实测约 60 MB |
| 收费 | US$19.90 一次性 + 机器绑定 | 免费 |

> 以上全部核查于 **2026-11-22**，来源为其公开仓库、公开文档与其自行发布的安装包。本仓库不因此获得任何收益，也不对其作出法律判断——只记录公开可查的事实，供读者自行核对。

# 🔧 第二部分 · 给想折腾的人

## 一句话原理

**睡眠时进程会被系统冻结，但墙钟照走**——所以用"两次循环之间的时间间隔突然变大"来判断刚唤醒；再等 `LogonUI.exe` 消失（解锁完成）才播放；播放前等声卡就绪，并用 `PlaySync` 的耗时验证"是不是真的播出去了"。

## 为什么不能用 Windows 电源事件（三条实测结论）

直觉方案是订阅 `SystemEvents.PowerModeChanged`，但在**隐藏窗口运行的 PowerShell** 里完全收不到：

| 方案 | 实测结果 |
|---|---|
| `Register-ObjectEvent SystemEvents.PowerModeChanged` | 日志只有启动行，没有 Suspend/Resume |
| 加隐藏 Form + `[System.Windows.Forms.Application]::Run($form)` 提供消息泵 | 仍然收不到 |
| `Register-WmiEvent Win32_PowerManagementEvent -Action` | 仍然收不到（`while{Start-Sleep}` 死循环时 `-Action` 脚本块不会被调度） |

结论：别在电源事件上浪费时间。这不是配置问题，是隐藏进程没有消息泵 + 死循环阻塞了脚本块调度。

## 最终方案：墙钟间隙检测

核心 20 行：

```powershell
$lastCheck = [DateTime]::UtcNow
while ($true) {
    Start-Sleep -Milliseconds 700
    $now = [DateTime]::UtcNow
    $gap = ($now - $lastCheck).TotalSeconds
    $lastCheck = $now

    if ($gap -ge 2.2) {
        # 进程被冻结过 —— 刚从睡眠恢复
    }
}
```

正常循环间隔 0.7 秒，突然出现 ≥2.2 秒的间隔只可能是进程被冻结过。**不需要任何系统事件、不需要固件上报、与机型和驱动无关。**

> 为什么不读 ACPI 盖子状态？因为不少机型固件根本不上报开盖事件（LidSound 自己的 FAQ 就承认"极少数机型固件不上报开盖状态，功能会静默禁用"）。墙钟方案绕开了这个问题：只要能睡眠恢复，就能用。

## 为什么等到"解锁完成"才播放

Windows 解锁前 `LogonUI.exe` 一直在跑，解锁后进程消失：

```
WAKE 检测到（gap ≥ 2.2s）
  └─ 每 500ms 检查一次 LogonUI.exe 是否存在
       ├─ 见过锁屏 + LogonUI 消失  → 播放（这就是"进桌面那一刻"）
       ├─ 从未出现锁屏（无密码）    → 唤醒后 8 秒兜底播放
       └─ 5 分钟没人解锁            → 放弃本次唤醒
```

这样做的原因：**唤醒后 HDA 声卡要好几秒才真正出声**。实测唤醒后 4 秒、7 秒播放用户完全听不到，但同一文件手动播放正常——`PlaySync()` 返回 1.2 秒**不代表声音到了耳朵**。等到解锁再播，声卡已经就绪。

## 播放可靠性：PlaySync 耗时校验

```powershell
$sw = [Diagnostics.Stopwatch]::StartNew()
$player.PlaySync()
$sw.Stop()
if ($sw.ElapsedMilliseconds -ge 500) { 成功 } else { 设备没就绪，重试 }
```

`PlaySync` 是阻塞调用，正常情况下耗时应约等于音频时长（我们 1.13 秒的文件约 1.2～1.4 秒）。如果耗时远小于该值，说明音频端点根本没接受数据 —— 重试最多 3 次。

## 单实例：命名互斥锁

```powershell
$mutex = New-Object System.Threading.Mutex($false, 'LidOpenSoundSingleInstance')
if (-not $mutex.WaitOne(0)) { exit 0 }   # 已有实例在跑，本实例直接退出
```

> 这个锁是**全局**的（跨进程）。从旧目录升级到新目录时，旧进程还持有锁，新实例会直接退出——所以安装器的进程清理逻辑必须同时匹配旧脚本名 `lidsound.ps1` 和新脚本名 `lid-open-sound.ps1`。

## 自愈：看门狗

监听进程有可能被"优化软件"、病毒扫描或误操作杀掉（我们就遇到过：进程在 17:50 后静默消失，Application 日志里连崩溃记录都没有）。

所以加了一层看门狗：

- `watchdog.ps1`：检查有没有跑 `lid-open-sound.ps1` 的 powershell 进程，没有就用 `wscript` 隐藏拉起
- `watchdog_hidden.vbs`：用 `WScript.Shell.Run(..., 0, False)` 启动，**彻底不显示窗口**
- 计划任务 `LidOpenSound-Watchdog`：每 1 分钟跑一次

> 为什么不用计划任务直接调 `powershell.exe`？因为 `-WindowStyle Hidden` 是进程启动**之后**才生效的，启动瞬间会闪一下黑框。套一层 VBS 的窗口模式 0 才能完全静默。

## 文件结构

| 文件 | 作用 | 大小 |
|---|---|---|
| `lid-open-sound.ps1` | 主程序：墙钟检测 + LogonUI 判定 + 播放重试 + 单实例锁 | 4.7 KB |
| `run_hidden.vbs` | 隐藏启动主程序（登录自启用它） | 0.4 KB |
| `install.ps1` | 安装：写 HKCU 自启 + 注册看门狗任务 + 启动 | 2.9 KB |
| `install.py` | 面向普通人的交互式安装器 / 换音效工具 | 7.6 KB |
| `uninstall.ps1` | 卸载：删自启 + 删任务 + 停进程 | 1.2 KB |
| `watchdog.ps1` | 看门狗：进程没了就拉起 | 1.0 KB |
| `watchdog_hidden.vbs` | 隐藏运行看门狗 | 0.5 KB |
| `test-play.ps1` | 手动试听 + 打印音频服务状态 | 0.8 KB |

运行时产生的文件：`events.log`（启动/唤醒/播放/错误）、`watchdog.log`（只在真正拉起时写一行）。

## 关键常量

| 常量 | 值 | 含义 |
|---|---|---|
| 主循环间隔 | 700 ms | 检测粒度 |
| 唤醒判定阈值 | **2.2 秒** | 间隔超过这个值视为被冻结过 |
| 锁屏轮询 | 500 ms | 检查 `LogonUI.exe` 的频率 |
| 无锁屏兜底 | 8 秒 | 没出现锁屏时的延迟播放 |
| 放弃时间 | 300 秒 | 5 分钟没人解锁就不再等 |
| 播放校验阈值 | 500 ms | `PlaySync` 低于此值视为没真播 |
| 播放重试 | 3 次，间隔 1.5 秒 | 声卡没就绪时 |
| 看门狗间隔 | 1 分钟 | 计划任务最小粒度 |

调参建议：阈值别低于 1.5 秒，老机器偶有卡顿会误触发；想要"开盖就响"可以把 LogonUI 判定逻辑去掉，但会重新遇到声卡没就绪的问题。

## 性能实测（T420 / i5-2520M / Windows 10 19045）

| 指标 | 实测值 |
|---|---|
| 内存（工作集） | 60.2 MB |
| 私有内存 | 57.5 MB |
| CPU（50 分钟累计） | 3.75 秒 |
| 日志增长 | 约 4 KB / 次运行 |
| 主程序体积 | 4.7 KB（无运行时打包） |

## 日志格式

```
[2026-11-21 16:13:10.874] WAKE detected, gap=9.30s
[2026-11-21 16:13:23.518] audio ready=True, playing once (unlocked after wake, 12.6s after wake)
[2026-11-21 16:13:24.788] PLAY open.wav (unlocked after wake) attempt 1 took 1262ms
```

| 行 | 含义 |
|---|---|
| `WAKE detected, gap=Xs` | 检测到唤醒，X 是冻结时长 |
| `audio ready=…` | 音频服务是否就绪 |
| `playing once (…)` | 触发播放，括号里是原因（`unlocked after wake` / `no lock screen after wake`） |
| `PLAY … took Xms` | 实际播放耗时（正常 ≈ 音频时长） |
| `another instance already running` | 互斥锁挡住了重复实例 |
| `ERROR play attempt N: …` | 播放异常及重试次数 |

## 已知限制

- 只对**睡眠/休眠恢复**生效；电源策略设成"合盖不睡眠"就永远不会触发
- 依赖 `LogonUI.exe` 判断锁屏（Windows 10/11 通用）；无密码的机器走 8 秒兜底
- 唤醒后声卡初始化特别慢的机器，可能延迟几秒才响
- 必须运行在用户会话里（做不成系统服务——服务态没有桌面音频会话）
- 进程被杀后最多需要 1 分钟才被看门狗拉起

## 技术 FAQ

**Q：为什么不直接读 ACPI 盖子状态？**

可以，但很多机型固件不上报。`GUID_LIDSWITCH_STATE_CHANGE` 这类通知在部分笔记本上收不到，功能会静默失效。墙钟方案不依赖固件，只要能睡眠恢复就行。

**Q：为什么用 PowerShell 而不是 C# / Python？**

零依赖。Windows 自带 PowerShell 5.1 和 .NET 的 `System.Media.SoundPlayer`，用户不需要装任何运行时。C# 需要打包 .NET（几十 MB），Python 需要用户装解释器。

**Q：为什么不用 NAudio？**

NAudio 功能强大，但对"播放一个 wav"来说太重——它要带 7 个包（NAudio/Core/WinMM/Wasapi/Asio/Midi/WinForms）。`SoundPlayer` 是 .NET 内置的，够用且零依赖。

**Q：能支持"合盖"也响一声吗？**

理论上可以在检测到即将睡眠时抢播，但合盖到睡眠之间只有一两秒，经常播不完、也经常被系统静音。这个项目只做开盖，不做合盖。

**Q：能不能开机就响（不登录）？**

做不到。Windows 登录前的启动声音由 UEFI/系统控制，第三方程序无法在登录界面播放音频（没有用户音频会话）。

**Q：为什么 `PlaySync` 耗时正常却听不到声音？**

唤醒后声卡（HDA codec）需要重新初始化，这期间播放请求可能"成功返回"但没有实际输出。这就是为什么要等解锁、要延迟、要校验耗时。

**Q：能改成监听 `LogonUI` 之外的方式判断解锁吗？**

可以。`WTSQuerySessionInformation` 查会话状态、或订阅 `SessionSwitch` 事件都能判断解锁，但 `LogonUI.exe` 存在性判断最简单且跨版本稳定。

**Q：多条音频能随机播放吗？**

可以自己改：在播放函数里随机挑一个文件即可。当前设计是一段音效，追求"稳定、可预期"。

**Q：会被杀毒软件误报吗？**

纯 `.ps1` / `.vbs` 文本脚本，没有编译产物，误报概率很低。反倒是打包成 exe 的同类工具更容易被误报。

**Q：能跑在 Windows Server 上吗？**

技术上可以（只要有用户会话和 `LogonUI`），但没有合盖场景，意义不大。

## 许可证

MIT 许可证（MIT License）© 2026 maomao1OvO1

本项目只做「播放一个本地 wav」，不上传任何数据、不联网。
