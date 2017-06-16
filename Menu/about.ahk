GUI_About()
{
	global
	
	AboutText=
	(
PABI Logical
Written by Paul Bichler
Email: autohotflow@arcor.de
License: GNU General Public License Version 3 (see below)

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public
License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any
later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

Special thanks to 
- AutoHotkey developter Chris Mallett, Steve Gray and other contributors.
- Tariq Porter (tic) for the "GDI+" library. It allows to render the game.
- Boris Mudrinić (Learning One) for the "String-object-file" library.
- Fortadelis for the music track "fade" which is the backgound music of the game.
	)
	
	
	Gui, About:destroy
	gui, About:+owner
	AboutWidth:=round(A_ScreenWidth*0.6)
	Gui, About:Add,edit, vAboutText w%AboutWidth% readonly, %AboutText%

	Gui, About:Add, Button, gAboutButtonClose  +default w100 h30 , Close
	Gui, About:Add, Button, gAboutButtonLicense yp xp+110 w100 h30 , Show license
	Gui, About:Show,, About



	send,{right} ;Workaround to unselect everything
	return

	AboutButtonClose:
	AboutGuiClose:
	Gui, About:destroy
	return

	AboutButtonLicense:
	run,Notepad.exe "%A_ScriptDir%\License"
	return
}