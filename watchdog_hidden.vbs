' Launch watchdog.ps1 completely hidden (no console flash at all).
' A scheduled task pointing directly at powershell.exe can still flash a window
' for a fraction of a second; WScript.Shell.Run with window style 0 cannot.

Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
ps1 = scriptDir & "\watchdog.ps1"

Set sh = CreateObject("WScript.Shell")
sh.Run "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & ps1 & """", 0, False
