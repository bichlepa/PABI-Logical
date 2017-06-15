userInputInit()
{
	OnMessage(0x201,"leftmousebuttonclick",1)
	OnMessage(0x204,"rightmousebuttonclick",1)
	OnMessage(0x203,"leftmousebuttonclick",1)
	OnMessage(0x206,"rightmousebuttonclick",1)
	_userinput:=Object()

	hotkey,IfWinActive,% "ahk_id " MainGuiHWND
	
	hotkey,esc,gui_play_esc
	
}

leftmousebuttonclick(wParam, lParam, msg, hwnd)
{
	if (hwnd != _share.MainGuiHWND)
		return
	MouseGetPos,mx,my ;Get the mouse position
	factor:=_field.factor
	mx/=factor
	my/=factor
	clickedField:=getClickedField(mx,my)
	if clickedField
		_userinput.push({field: clickedField, button: "left", x: mx,y: my})
}

rightmousebuttonclick(wParam, lParam, msg, hwnd)
{
	if (hwnd != _share.MainGuiHWND)
		return
	MouseGetPos,mx,my ;Get the mouse position
	factor:=_field.factor
	mx/=factor
	my/=factor
	clickedField:=getClickedField(mx,my)
	if clickedField
		_userinput.push({field: clickedField, button: "right", x: mx,y: my})
}

getClickedField(mx,my)
{
	for onefieldindex, onefield in _allFields
	{
		if (mx >= onefield.x and mx <= onefield.x + onefield.w and my >= onefield.y and my <= onefield.y + onefield.h)
		{
			;~ d(onefield)
			return onefield
		}
	}
	
}


gui_play_esc()
{
	_share.menuHint:="Game aborted!"
	_play.statechangerequest:="lost"
}