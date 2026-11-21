' Launch lid-open-sound.ps1 without a visible console window.
' Usage: wscript.exe //B "path\to\run_hidden.vbs"

Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
ps1 = scriptDir & "\lid-open-sound.ps1"

Set sh = CreateObject("WScript.Shell")
sh.Run "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & ps1 & """", 0, False
