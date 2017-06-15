
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
	
	gui,MainMenu:default
	gui,-dpiscale
	gui,+HwndMainGuiHWND
	gui,font,s30
	gui,add,text, xm ym, PABI Logical
	gui,font,s12
	gui,add,text, xm Y+10, Level set
	gui,add,DropDownList, X+10 yp vGUIMainMenuLevelSet gGUIMainMenuLevelSet
	guicontrol,,GUIMainMenuLevelSet,%GUIMainMenuLevelSet%
	guicontrol,ChooseString,GUIMainMenuLevelSet,%lastSelectedLevelSet%
	gui,add,text, xm Y+10, Level
	gui,add,DropDownList, X+10 yp vGUIMainMenuLevel gGUIMainMenuLevel
	gui_menu_reloadLevels(lastSelectedLevel)
	gui,font,s30
	gui,add,button,xm0 Y+20 w300 h100 gGUIMainMenubuttonStart default,Start
	gui,font,s10
	gui,add,button,x200 Y+20 w100 h30 gGUIMainMenubuttonExit, Exit
	gui,show,hide, PABI Logical
	return
	
	GUIMainMenubuttonStart:
	gui_menu_start()
	return
	
	GUIMainMenubuttonExit:
	MainMenuGUIClose:
	ExitApp
	return
	
	GUIMainMenuLevelSet:
	gui_menu_reloadLevels()
	return
	
	GUIMainMenuLevel:
	
	return
}
goto jumpoverasdf
f5::
loop 5
{
	ToolTip % 5 - A_Index
	sleep 1000
}
	ToolTip 
gui_menu_start()
return
jumpoverasdf:
temp=
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
		guicontrol,choosestring,GUIMainMenuLevel, % _levels.levelsets[GUIMainMenuLevelSet].lastUnlockedLevelID
}

gui_menu_show()
{
	global
	gui,MainMenu:show
	
}

gui_menu_hide()
{
	global
	gui,MainMenu:hide
}
