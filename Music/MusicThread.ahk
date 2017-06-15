#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;~ #Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, -1
#NoTrayIcon
#Persistent

#include music\music.ahk
#include lib\Object to file\String-object-file.ahk
#include lib\ObjFullyClone\ObjFullyClone.ahk
#include debug\debug.ahk
;~ d(_field, "ihöi")

if _ahkThreadID = sound1 ;this is the music thread
{
	currentlyPlayingMusic:=""
	settimer, stopmusicIfChanged,100
	Loop
	{
		if (_sound.music !=currentlyPlayingMusic)
		{
			currentlyPlayingMusic:=_sound.music
			playBackgroundMusic(currentlyPlayingMusic)
		}
	}
}



Loop
{
	sleep 10
	sound()
}
return

stopmusicIfChanged:
if (_sound.music !=currentlyPlayingMusic)
{
	SoundPlay,aödfihasio
}
return