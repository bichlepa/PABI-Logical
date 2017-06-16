
gui_menu_init()
{
	global
	
	;find all level sets
	GUIMainMenuLevelSet:=
	for onelevelsetID, oneLevelSet in _levels.levelsets
	{
		GUIMainMenuLevelSet.="|" onelevelsetID
	}
	
	IniRead,lastSelectedLevelSet,%a_appdata%\PABI Logical\settings.ini,menu,lastSelectedLevelSet, %A_Space%
	IniRead,lastSelectedLevel,%a_appdata%\PABI Logical\settings.ini,menu,lastSelectedLevel, %A_Space%
	IniRead,backgroundMusic,%a_appdata%\PABI Logical\settings.ini,menu,backgroundMusic, %A_Space%
	IniRead,SoundPack,%a_appdata%\PABI Logical\settings.ini,menu,SoundPack, %A_Space%
	IniRead,opticalDesign,%a_appdata%\PABI Logical\settings.ini,menu,opticalDesign, %A_Space%
	
	gui,MainMenu:default
	gui,-dpiscale
	gui,+HwndMainGuiHWND
	gui,font,s30
	gui,add,text, xm ym w300, PABI Logical
	gui,font,s20
	gui,add,text, xm Y+10 w300 vGUIMainMenuHint, Hello
	gui,font,s12
	gui,add,text, xm Y+10 w150, Level set
	gui,add,DropDownList, x150 yp w150 vGUIMainMenuLevelSet gGUIMainMenuLevelSet
	guicontrol,,GUIMainMenuLevelSet,%GUIMainMenuLevelSet%
	if (lastSelectedLevelSet)
		guicontrol,ChooseString,GUIMainMenuLevelSet,%lastSelectedLevelSet%
	else
		guicontrol,Choose,GUIMainMenuLevelSet,1
	gui,add,text, xm Y+10 w150, Level
	gui,add,DropDownList, x150 yp w150 vGUIMainMenuLevel gGUIMainMenuLevel
	gui_menu_reloadLevels(lastSelectedLevel)
	gui,font,s30
	gui,add,button,xm0 Y+20 w300 h100 gGUIMainMenubuttonStart default,Start
	
	;Settings
	gui,font,s8
	gui,add,text, xm Y+30 w150, Background music
	availableMusic:=""
	supportedMusicFormats:=["mp3", "wav"]
	for oneidx, onemusicFormat in supportedMusicFormats
	{
		loop, files, sounds\background music\*.%onemusicFormat%
		{
			availableMusic.="|"A_LoopFileName
			if not backgroundMusic
			{
				backgroundMusic:=A_LoopFileName
			}
		}
	}
	
	gui,add,DropDownList, x150 yp w150 vGUIMainMenuBackgroundMusic gGUIMainMenuBackgroundMusic
	guicontrol,,GUIMainMenuBackgroundMusic,% "|off" availableMusic
	guicontrol,choosestring,GUIMainMenuBackgroundMusic,%backgroundMusic%
	_sound.backgroundmusic:=backgroundMusic
	
	gui,add,text, xm Y+10 w150, Sound pack
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
	
	gui,add,DropDownList, x150 yp w150 vGUIMainMenuSoundPack gGUIMainMenuSoundPack
	guicontrol,,GUIMainMenuSoundPack,% "|off" availableSoundPacks
	guicontrol,choosestring,GUIMainMenuSoundPack,%SoundPack%
	_sound.SoundPack:=SoundPack
	
	gui,add,text, xm Y+10 w150, Design
	availableopticalDesigns:=""
	loop, files, pictures\*,D
	{
		availableopticalDesigns.="|"A_LoopFileName
		if not opticalDesign
		{
			opticalDesign:=A_LoopFileName
		}
	}
	
	gui,add,DropDownList, x150 yp w150 vGUIMainMenuopticalDesign gGUIMainMenuopticalDesign
	guicontrol,,GUIMainMenuopticalDesign,% availableopticalDesigns
	guicontrol,choosestring,GUIMainMenuopticalDesign,%opticalDesign%
	_share.opticalDesign:=opticalDesign
	_share.needInitDesign:=true
	
	gui,add,button,xm Y+10 w100 h25 gGUI_About,About
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
	Iniwrite,%GUIMainMenuBackgroundMusic%,%a_appdata%\PABI Logical\settings.ini,menu,backgroundMusic
	
	_sound.backgroundmusic:=GUIMainMenuBackgroundMusic
	return
	
	GUIMainMenuSoundPack:
	gui,MainMenu:default
	gui,submit,nohide
	Iniwrite,%GUIMainMenuSoundPack%,%a_appdata%\PABI Logical\settings.ini,menu,SoundPack
	
	_sound.SoundPack:=GUIMainMenuSoundPack
	return
	
	GUIMainMenuopticalDesign:
	gui,MainMenu:default
	gui,submit,nohide
	Iniwrite,%GUIMainMenuopticalDesign%,%a_appdata%\PABI Logical\settings.ini,menu,opticalDesign
	
	_share.opticalDesign:=GUIMainMenuopticalDesign
	_share.needInitDesign:=true
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
	
	
	IniWrite,%GUIMainMenuLevelSet%,%a_appdata%\PABI Logical\settings.ini,menu,lastSelectedLevelSet
	IniWrite,%GUIMainMenuLevel%,%a_appdata%\PABI Logical\settings.ini,menu,lastSelectedLevel
	
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
