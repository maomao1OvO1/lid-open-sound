#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
开盖音效 —— 一键安装 / 更换音效（傻瓜版）

用法：
  双击运行（或 python install.py）
  按提示把音频文件拖进窗口，回车
  装好后：合盖 → 开盖 → 输密码 → 进桌面响一声
  想换音效：再运行一次，给个新路径就行

不带参数时进入交互模式；也支持：
  python install.py "D:\\music\\ding.wav"    直接指定音频
"""

import os
import sys
import shutil
import subprocess
import wave

HERE = os.path.dirname(os.path.abspath(__file__))
WAV = os.path.join(HERE, "sound.wav")
VBS = os.path.join(HERE, "run_hidden.vbs")
PS1 = os.path.join(HERE, "lid-open-sound.ps1")
WSCRIPT = os.path.join(os.environ.get("WINDIR", r"C:\Windows"), "System32", "wscript.exe")
RUN_KEY = r"Software\Microsoft\Windows\CurrentVersion\Run"
VALUE_NAME = "LidOpenSound"
TITLE = "开盖音效 · 一键安装 / 更换音效"


def line(text=""):
    print(text)


def wav_info(path):
    """返回 (声道, 采样率, 秒数)；不是合法 wav 返回 None"""
    try:
        with wave.open(path, "rb") as w:
            frames = w.getnframes()
            rate = w.getframerate()
            if not rate or not frames:
                return None
            return w.getnchannels(), rate, frames / float(rate)
    except Exception:
        return None


def convert_to_wav(src):
    """用 ffmpeg 把 mp3/m4a/ogg 等转成 mono 44.1kHz 16bit wav；没有 ffmpeg 返回 None"""
    ffmpeg = shutil.which("ffmpeg")
    if not ffmpeg:
        return None
    out = os.path.join(HERE, "_converted.wav")
    try:
        r = subprocess.run(
            [ffmpeg, "-y", "-i", src, "-ac", "1", "-ar", "44100", "-sample_fmt", "s16", out],
            capture_output=True,
        )
        if r.returncode == 0 and os.path.exists(out):
            return out
    except Exception:
        pass
    return None


def ask_path():
    line("请把音频文件拖进这个窗口（或粘贴完整路径），然后回车：")
    line("  · 支持 .wav；mp3/m4a/ogg 需要电脑上有 ffmpeg 才能自动转换")
    line("  · 直接回车 = 不改音效，只修复安装")
    while True:
        try:
            raw = input("> ").strip()
        except (EOFError, KeyboardInterrupt):
            return None
        if not raw:
            return None
        p = raw.strip().strip('"').strip("'")
        if os.path.isfile(p):
            return p
        line("  找不到这个文件，再试一次（或直接回车跳过）：")


def kill_watcher():
    """结束所有跑 lid-open-sound.ps1 的 powershell 进程（排除自己）"""
    try:
        subprocess.run(
            [
                "powershell.exe", "-NoProfile", "-Command",
                "Get-CimInstance Win32_Process -Filter \"Name='powershell.exe'\" | "
                "Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -match '(lid-open-sound|lidsound)\\.ps1' } | "
                "ForEach-Object { Stop-Process -Id $_.ProcessId -Force }",
            ],
            capture_output=True,
        )
    except Exception:
        pass


def start_watcher():
    try:
        subprocess.Popen([WSCRIPT, "//B", VBS], creationflags=0x08000000)
    except Exception as e:
        line("  启动监听失败：%s" % e)


def set_autostart():
    import winreg
    key = winreg.CreateKeyEx(winreg.HKEY_CURRENT_USER, RUN_KEY, 0, winreg.KEY_SET_VALUE)
    winreg.SetValueEx(key, VALUE_NAME, 0, winreg.REG_SZ, '"%s" //B "%s"' % (WSCRIPT, VBS))
    winreg.CloseKey(key)


def main():
    line("=" * 46)
    line("  " + TITLE)
    line("=" * 46)
    line()

    if not os.path.exists(PS1) or not os.path.exists(VBS):
        line("× 没找到程序文件（lid-open-sound.ps1 / run_hidden.vbs）")
        line("  请把本脚本放在解压后的同一个文件夹里再运行。")
        return 1

    cur = wav_info(WAV) if os.path.exists(WAV) else None
    if cur:
        line("当前音效：sound.wav（%.2f 秒）" % cur[2])
    else:
        line("当前还没有设置音效。")
    line()

    src = sys.argv[1].strip('"') if len(sys.argv) > 1 else None
    if src and not os.path.isfile(src):
        line("× 命令行给的路径不存在：%s" % src)
        src = None
    if not src and not (len(sys.argv) > 1):
        src = ask_path()

    backup_done = False
    if src:
        ext = os.path.splitext(src)[1].lower()
        converted = None
        if ext == ".wav":
            info = wav_info(src)
            if not info:
                line("× 这个 .wav 打不开（文件损坏或不是标准 wav）")
                return 1
        else:
            line("  非 wav 格式，正在用 ffmpeg 转换……")
            converted = convert_to_wav(src)
            if not converted:
                line("× 转换失败：电脑上没有 ffmpeg，或这个文件无法解码。")
                line("  请自己转成 wav 后再来（可以用格式工厂 / Audacity / 在线转换）。")
                return 1
            info = wav_info(converted)
            if not info:
                line("× 转换出来的文件不是有效 wav")
                return 1

        channels, rate, seconds = info
        if seconds > 5:
            line("  提示：这段音频有 %.1f 秒，开盖音效建议 1~2 秒内，太长了会吵。" % seconds)
        if rate < 22050:
            line("  提示：采样率 %d Hz 偏低，可能不太好听。" % rate)

        if os.path.exists(WAV):
            try:
                shutil.copy2(WAV, WAV + ".bak")
                backup_done = True
            except Exception:
                pass
        try:
            if converted:
                shutil.move(converted, WAV)
            else:
                shutil.copy2(src, WAV)
        except Exception as e:
            line("× 复制失败：%s" % e)
            return 1
        line("✔ 音效已更新：%s" % os.path.basename(src))
        if backup_done:
            line("  旧音效备份在 sound.wav.bak")
    else:
        if not cur:
            line("× 你还没有音效文件，也没给新路径 —— 不装。")
            return 1
        line("· 保持当前音效不变。")

    line()
    line("正在安装……")
    set_autostart()
    line("✔ 已设置开机自启（登录后隐藏运行）")
    kill_watcher()
    import time
    time.sleep(0.5)
    start_watcher()
    line("✔ 监听进程已启动")

    # 等一会儿确认起来了
    time.sleep(2)
    out = ""
    try:
        r = subprocess.run(
            ["powershell.exe", "-NoProfile", "-Command",
             "@(Get-CimInstance Win32_Process -Filter \"Name='powershell.exe'\" | "
             "Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -match '(lid-open-sound|lidsound)\\.ps1' }).Count"],
            capture_output=True, text=True,
        )
        out = (r.stdout or "").strip()
    except Exception:
        pass
    if out and out.isdigit() and int(out) > 0:
        line("✔ 监听中（%s 个实例）" % out)
    else:
        line("! 监听进程似乎没起来，请重新运行一次本脚本")

    line()
    line("=" * 46)
    line("  装好了！合盖 → 开盖 → 输密码 → 进桌面，应该会响一声。")
    line("  想换音效：再运行一遍本脚本，给个新路径就行。")
    line("  日志：events.log（排错用）")
    line("=" * 46)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        line()
        line("已取消。")
        sys.exit(130)
