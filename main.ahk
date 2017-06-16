#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;~ #Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, -1

menu,tray,icon,pictures\icon.ico

CoordMode,mouse,client
OnExit,exit

#include lib\Object to file\String-object-file.ahk
#include game\loadfield.ahk
#include game\play.ahk
#include game\playTasks.ahk
#include game\fields.ahk
#include game\userInput.ahk
#include game\gui.ahk
#include menu\menu_gui.ahk
#include menu\achievements.ahk
#include menu\about.ahk
#include debug\debug.ahk

global MainGuiHWND, MainGuiDC
global _field:=CriticalObject()
global _field_section:=CriticalSection()
global _allFields:=CriticalObject()
global _play:=CriticalObject()
global _userinput:=CriticalObject()
global _balls:=CriticalObject()
global _share:=CriticalObject()
global _colors:=CriticalObject()
global _sound:=CriticalObject()
global _sound_section:=CriticalSection()
global _levels:=CriticalObject()
_sound.toplay:=CriticalObject()
_colors.push("red","green","blue", "yellow")
global_AllThreads := CriticalObject()

if 1=cheat
{
	_share.cheatsActive:=true
}

FileCreateDir,%a_appdata%\PABI Logical

loadLevelSets()
gui_menu_init()
gui_play_init()
userInputInit()
Thread_StartDraw()
loop 10
	Thread_StartSound()

playInit()

_share.IterationTimer:=20
_share.IterationIndex:=0
longSleepAdder:=10

;~ Loop
	;~ playtimer()

startticks:=A_TickCount
iterationindex2:=0
ControlafterTicks:=10


settimer,playtimer,% -_share.IterationTimer

filluntillongsleep:=0
;~ Loop
;~ {
	;~ playtimer()
;~ }
playtimer()
{
	global
	
	if (_share.cheatsActive)
	{
		while (GetKeyState("f12"))
		{
			play()
		}
	}
	if (filluntillongsleep > _share.IterationTimer)
	{
		filluntillongsleep-=_share.IterationTimer
		settimer,playtimer,% - _share.IterationTimer
		;~ sleep 50
	}
	else
	{
		settimer,playtimer,% - 10
		;~ sleep 10
	}
	filluntillongsleep+=longSleepAdder
	
	
	passedTicks:=A_TickCount - startticks
	
	ratio := iterationindex2 * _share.IterationTimer / (passedTicks)
	if (iterationindex2 > ControlafterTicks)
	{
		if (ratio < 0.95)
		{
			longSleepAdder--
		}
		else if (ratio > 1.05)
		{
			longSleepAdder++
		}
		else
		{
			ControlafterTicks:=100
		}
		;~ ToolTip % ratio " - " passedTicks " # " iterationindex2* _share.IterationTimer " - " longSleepAdder " # " filluntillongsleep
		iterationindex2:=0
		startticks:=A_TickCount
	}
	_share.IterationIndex++
	iterationindex2++
	play()
}
return


Thread_StartDraw()
{
	global
	local ExecutionThreadCode
	local threadID
	threadID := "Draw"
	FileRead,ExecutionThreadCode,% a_ScriptDir "\Draw\DrawThread.ahk"
	ExecutionThreadCode:="global _field := CriticalObject(" (&_field) ") `n global _allFields := CriticalObject(" (&_allFields) ") `n global _play := CriticalObject(" (&_play) ") `n global _userinput := CriticalObject(" (&_userinput) ") `n global _balls := CriticalObject(" (&_balls) ") `n global _share := CriticalObject(" (&_share) ")`n global _colors := CriticalObject(" (&_colors) ")`n global _sound := CriticalObject(" (&_sound) ")`n global _field_section := " _field_section "`n global _ahkThreadID := """ threadID """`n" ExecutionThreadCode
	AhkThread%threadID% := AhkThread(ExecutionThreadCode)
	global_AllThreads[threadID] := {permanent: true, type: "Draw"}
}

Thread_StartSound()
{
	global
	static index:=0
	local ExecutionThreadCode
	local threadID
	threadID := "Sound" index
	FileRead,ExecutionThreadCode,% a_ScriptDir "\Music\MusicThread.ahk"
	ExecutionThreadCode:="global _field := CriticalObject(" (&_field) ") `n global _allFields := CriticalObject(" (&_allFields) ") `n global _play := CriticalObject(" (&_play) ") `n global _userinput := CriticalObject(" (&_userinput) ") `n global _balls := CriticalObject(" (&_balls) ") `n global _share := CriticalObject(" (&_share) ")`n global _colors := CriticalObject(" (&_colors) ")`n global _sound := CriticalObject(" (&_sound) ")`n global _sound_section := " _sound_section "`n global _ahkThreadID := """ threadID """`n" ExecutionThreadCode
	AhkThread%threadID% := AhkThread(ExecutionThreadCode)
	global_AllThreads[threadID] := {permanent: true, type: "Draw"}
	index++
}

Thread_StoppAll()
{
	global
	local threadsCopy
	threadsCopy := global_Allthreads.clone()
	for threadID, threadpars in threadsCopy
	{
		global_Allthreads.delete(threadID)
		if (AhkThread%threadID%.ahkReady())
			AhkThread%threadID%.ahkterminate(-1)
	}
}



exit:
global _exitingNow

if (_exitingNow!=true)
{
	_exitingNow:=true
	
	Thread_StoppAll()
}
ExitApp
