
gui_play_init()
{
	global
	gui,MainGUI:default
	gui,-dpiscale
	;~ gui,add,picture,vPicFlow hwndPicFlowHWND x0 y0 0xE hidden gclickOnPicture ;No picture needed anymore
	;~ gui,add,StatusBar,hwndStatusbarHWND
	;~ _share.hwnds["editGUIStatusbar" FlowID] := StatusbarHWND
	;~ _share.hwnds["editGUIStatusbar" Global_ThisThreadID] := StatusbarHWND
	;~ gui,add,hotkey,hidden hwndEditControlHWND ;To avoid error sound when user presses keys while this window is open
	;~ _share.hwnds["editGUIEditControl" FlowID] := EditControlHWND
	;~ _share.hwnds["editGUIEditControl" Global_ThisThreadID] := EditControlHWND
	gui +resize

	;This is needed by GDI+
	gui +lastfound
	gui,+HwndMainGuiHWND
	
	widthofguipic:=0.9*A_ScreenWidth
	heightofguipic:=0.9*A_ScreenHeight
	gui,show, hide w%widthofguipic% h%heightofguipic%
	
	_share.MainGuiHWND := MainGuiHWND
	_share.widthofguipic := widthofguipic
	_share.heightofguipic := heightofguipic
	return
	MainGUIGUIClose:
	_share.menuHint:="Game aborted!"
	_play.statechangerequest := "menu"
	return
	
}

MainGUIGuiSize(GuiHwnd, EventInfo, Width, Height)
{
	global guiresizedfromguisizecorrect
	if (guiresizedfromguisizecorrect)
	{
		guiresizedfromguisizecorrect:=false
	}
	else
	{
		_share.widthofguipic := Width
		_share.heightofguipic := Height
		SetTimer,guisizecorrect,100
	}
}

guisizecorrect()
{
	global
	local factor
	if (not getkeystate("lbutton"))
	{
		if(_share.heightofguipic/_Field.h>_share.widthofguipic/_Field.w)
		{
			factor:=_share.widthofguipic/_Field.w
		}
		else
		{
			factor:=_share.heightofguipic/_Field.h
		}
		if factor
		{
			_share.widthofguipic :=_Field.w*factor
			_share.heightofguipic :=_Field.h*factor
			guiresizedfromguisizecorrect:=true
			gui,MainGUI:show,% "w" _share.widthofguipic " h" _share.heightofguipic
		}
		SetTimer,guisizecorrect,off
	}
}

gui_play_show()
{
	global
	static firstcall := true
	if firstcall
	{
		gui,MainGUI:show, % "w" _share.widthofguipic+1 " h" _share.heightofguipic
		gui,MainGUI:show, % "w" _share.widthofguipic " h" _share.heightofguipic,% _field.name
		firstcall:=false
	}
	else
	{
		gui,MainGUI:show, ,% "PABI Logical - "_field.name
	}
	
}

gui_play_hide()
{
	global
	gui,MainGUI:hide
}