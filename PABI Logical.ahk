#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;~ #Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

run,autohotkey\autohotkey_h.exe "%A_ScriptDir%\main.ahk" "%1%" "%2%" "%3%" "%4%" "%5%" "%6%" "%7%" "%8%" "%9%" "%10%"

BaseFrame_About:
return
