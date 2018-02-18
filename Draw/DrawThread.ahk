#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;~ #Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, -1
#NoTrayIcon
#Persistent

#include draw\draw.ahk
#include lib\gdip.ahk
#include lib\Object to file\String-object-file.ahk
#include debug\debug.ahk
;~ d(_field, "ihöi")
gdip_Init()

Loop
	draw()
return

