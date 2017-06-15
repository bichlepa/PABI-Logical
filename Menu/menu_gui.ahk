
gui_menu_init()
{
	global
	
	;find all level sets
	GUIMainMenuLevelSet:=
	for onelevelsetID, oneLevelSet in _levels.levelsets
	{
		GUIMainMenuLevelSet.="|" onelevelsetID
	}
	
	IniRead,lastSelectedLevelSet,settings.ini,menu,lastSelectedLevelSet, %A_Space%
	IniRead,lastSelectedLevel,settings.ini,menu,lastSelectedLevel, %A_Space%
	IniRead,backgroundMusic,settings.ini,menu,backgroundMusic, %A_Space%
	IniRead,SoundPack,settings.ini,menu,SoundPack, %A_Space%
	
	gui,MainMenu:default
	gui,-dpiscale
	gui,+HwndMainGuiHWND
	gui,font,s30
	gui,add,text, xm ym, PABI Logical
	gui,font,s20
	gui,add,text, xm Y+10 w300 vGUIMainMenuHint, Hello
	gui,font,s12
	gui,add,text, xm Y+10, Level set
	gui,add,DropDownList, X+10 yp vGUIMainMenuLevelSet gGUIMainMenuLevelSet
	guicontrol,,GUIMainMenuLevelSet,%GUIMainMenuLevelSet%
	if (lastSelectedLevelSet)
		guicontrol,ChooseString,GUIMainMenuLevelSet,%lastSelectedLevelSet%
	else
		guicontrol,Choose,GUIMainMenuLevelSet,1
	gui,add,text, xm Y+10, Level
	gui,add,DropDownList, X+10 yp vGUIMainMenuLevel gGUIMainMenuLevel
	gui_menu_reloadLevels(lastSelectedLevel)
	gui,font,s30
	gui,add,button,xm0 Y+20 w300 h100 gGUIMainMenubuttonStart default,Start
	gui,font,s10
	
	;Settings
	gui,add,text, xm Y+10, Background music
	availableMusic:=""
	loop, files, sounds\background music\*
	{
		availableMusic.="|"A_LoopFileName
		if not backgroundMusic
		{
			backgroundMusic:=A_LoopFileName
		}
	}
	
	gui,add,DropDownList, X+10 yp vGUIMainMenuBackgroundMusic gGUIMainMenuBackgroundMusic
	guicontrol,,GUIMainMenuBackgroundMusic,% availableMusic
	guicontrol,choosestring,GUIMainMenuBackgroundMusic,%backgroundMusic%
	_sound.backgroundmusic:=backgroundMusic
	
	gui,add,text, xm Y+10, Sound pack
	availableSoundPacks:=""
	loop, files, sounds\*,D
	{
		if A_LoopFileName = background music
			continue
		
		availableSoundPacks.="|"A_LoopFileName
		if not SoundPack
		{
			SoundPack:=A_LoopFileName
		}
	}
	
	gui,add,DropDownList, X+10 yp vGUIMainMenuSoundPack gGUIMainMenuSoundPack
	guicontrol,,GUIMainMenuSoundPack,% availableSoundPacks
	guicontrol,choosestring,GUIMainMenuSoundPack,%SoundPack%
	_sound.SoundPack:=SoundPack
	
	gui,show,hide, PABI Logical
	return
	
	GUIMainMenubuttonStart:
	gui_menu_start()
	return
	
	GUIMainMenubuttonExit:
	MainMenuGUIClose:
	ExitApp
	return
	
	GUIMainMenuBackgroundMusic:
	gui,MainMenu:default
	gui,submit,nohide
	Iniwrite,%GUIMainMenuBackgroundMusic%,settings.ini,menu,backgroundMusic
	
	_sound.backgroundmusic:=GUIMainMenuBackgroundMusic
	return
	
	GUIMainMenuSoundPack:
	gui,MainMenu:default
	gui,submit,nohide
	Iniwrite,%GUIMainMenuSoundPack%,settings.ini,menu,SoundPack
	
	_sound.SoundPack:=GUIMainMenuSoundPack
	return
	
	GUIMainMenuLevelSet:
	gui_menu_reloadLevels()
	return
	
	GUIMainMenuLevel:
	
	return
}

gui_menu_start()
{
	global
	gui,MainMenu:default
	gui,submit,nohide
	
	if (not GUIMainMenuLevelSet)
	{
		MsgBox select level set
		return
	}
	if (not GUIMainMenuLevel)
	{
		MsgBox select level
		return
	}
	
	
	IniWrite,%GUIMainMenuLevelSet%,settings.ini,menu,lastSelectedLevelSet
	IniWrite,%GUIMainMenuLevel%,settings.ini,menu,lastSelectedLevel
	
	if (loadField(GUIMainMenuLevelSet, GUIMainMenuLevel) != -1)
		_play.state:="start"
	return
}
gui_menu_reloadLevels(toSelectLevel="")
{
	global
	gui,MainMenu:default
	gui,submit,nohide
	levels:=""
	for onelevelIndex, oneLevel in _levels.levelsets[GUIMainMenuLevelSet].levelsSorted
	{
		levels.="|" onelevel.ID
		if (oneLevel.won != true)
			break
	}
	guicontrol,,GUIMainMenuLevel,%levels%
	if (toSelectLevel!="")
		guicontrol,choosestring,GUIMainMenuLevel,%toSelectLevel%
	else
	{
		guicontrol,choosestring,GUIMainMenuLevel, % _levels.levelsets[GUIMainMenuLevelSet].lastUnlockedLevelID
	}
}

gui_menu_show()
{
	global
	gui,MainMenu:default
	guicontrol,,GUIMainMenuHint, % _share.menuHint
	gui,show
	
}

gui_menu_hide()
{
	global
	gui,MainMenu:default
	gui,hide
}
