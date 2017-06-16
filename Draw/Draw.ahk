gdip_Init()
{
	global
	
	; Thanks to tic (Tariq Porter) for his GDI+ Library
	; http://www.autohotkey.com/forum/viewtopic.php?t=32238
	; Start gdi+
	If !pToken := Gdip_Startup()
	{
		MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
		ExitApp
	}


	Font:="Arial"

	; Create some brushes
	pPenBlack := Gdip_CreatePen("0xff000000",2) ;Black pen
	brushs:=Object()
	brushs["background"] := Gdip_BrushCreateSolid("0xFFeaf0ea") ;Almost white brush for background
	brushs["balldropWarn0"] := Gdip_BrushCreateSolid("0x55aaffaa") ;
	brushs["balldropWarn1"] := Gdip_BrushCreateSolid("0x55cceeaa") ;
	brushs["balldropWarn2"] := Gdip_BrushCreateSolid("0x55ddddaa") ;
	brushs["balldropWarn3"] := Gdip_BrushCreateSolid("0x55eeccea") ;
	brushs["balldropWarn4"] := Gdip_BrushCreateSolid("0x55ffaaea") ;

	
	_share.opticalDesignPrefs:=criticalObject()
	_share.MainGuiDC := GetDC(_share.MainGuiHWND)
	
}

draw_initDesign()
{
	global
	local onename, onebitmap, designpath
	_share.needInitDesign:=false
	
	designpath:= A_ScriptDir "\Pictures\" _share.opticalDesign 
	
	allkeys:=Object()
	for onekey, onevalue in _share.opticalDesignPrefs
	{
		allkeys.push(onekey)
	}
	for onekey in allkeys
	{
		_share.opticalDesignPrefs.delete(onekey)
	}
	
	
	IniRead,temp,%designpath%\design.ini,animations,AnimationExplodeSteps
	_share.opticalDesignPrefs.AnimationExplodeSteps:=temp
	IniRead,temp,%designpath%\design.ini,animations,AnimationExplodeRemoveBallsStep
	_share.opticalDesignPrefs.AnimationExplodeRemoveBallsStep:=temp
	
	for onename, onebitmap in bitmaps
	{
		Gdip_DisposeImage(onebitmap)
	}
	
	;colors: 1:red, 2:yellow, 3:green, 4:blue
	bitmaps:=Object() 
	loop 4
	{
		bitmaps["Ball" a_index] := Gdip_CreateBitmapFromFile(designpath "\Ball_" _colors[A_Index] ".png")
		bitmaps["Field_blocker_" a_index] := Gdip_CreateBitmapFromFile(designpath "\Field_blocker_" _colors[A_Index] ".png")
		bitmaps["Field_paint_" a_index] := Gdip_CreateBitmapFromFile(designpath "\Field_paint_" _colors[A_Index] ".png")
	}
	bitmaps["Ball0"] := Gdip_CreateBitmapFromFile(designpath "\Ball_exploded.png")
	bitmaps["Field_Empty"] := Gdip_CreateBitmapFromFile(designpath "\Field_Empty.png")
	bitmaps["Field_BallDrop_Empty_r"] := Gdip_CreateBitmapFromFile(designpath "\Field_BallDrop_Empty_r.png")
	bitmaps["Field_BallDrop_Empty_l"] := Gdip_CreateBitmapFromFile(designpath "\Field_BallDrop_Empty_l.png")
	bitmaps["Field_BallDrop_Empty_rl"] := Gdip_CreateBitmapFromFile(designpath "\Field_BallDrop_Empty_rl.png")
	bitmaps["Field_Rotator"] := Gdip_CreateBitmapFromFile(designpath "\Field_Rotator.png")
	bitmaps["Field_Rotator_blown"] := Gdip_CreateBitmapFromFile(designpath "\Field_Rotator_blown.png")
	loop 8
	{
		bitmaps["Field_Rotator_" A_Index*10] := Gdip_CreateBitmapFromFile(designpath "\Field_Rotator_" A_Index*10 ".png")
		bitmaps["Field_Rotator_blown_" A_Index*10] := Gdip_CreateBitmapFromFile(designpath "\Field_Rotator_blown_" A_Index*10 ".png")
	}
	bitmaps["Field_Conn_r"] := Gdip_CreateBitmapFromFile(designpath "\Field_Conn_r.png")
	bitmaps["Field_Conn_l"] := Gdip_CreateBitmapFromFile(designpath "\Field_Conn_l.png")
	bitmaps["Field_Conn_u"] := Gdip_CreateBitmapFromFile(designpath "\Field_Conn_u.png")
	bitmaps["Field_Conn_d"] := Gdip_CreateBitmapFromFile(designpath "\Field_Conn_d.png")
	bitmaps["Field_Conn_rl"] := Gdip_CreateBitmapFromFile(designpath "\Field_Conn_rl.png")
	bitmaps["Field_Conn_lr"] := bitmaps["Field_Conn_rl"]
	bitmaps["Field_Conn_ud"] := Gdip_CreateBitmapFromFile(designpath "\Field_Conn_ud.png")
	bitmaps["Field_Conn_du"] := bitmaps["Field_Conn_ud"]
	bitmaps["Field_Conn_ld"] := Gdip_CreateBitmapFromFile(designpath "\Field_Conn_ld.png")
	bitmaps["Field_Conn_dl"] := bitmaps["Field_Conn_ld"]
	bitmaps["Field_Conn_lu"] := Gdip_CreateBitmapFromFile(designpath "\Field_Conn_lu.png")
	bitmaps["Field_Conn_ul"] := bitmaps["Field_Conn_lu"]
	bitmaps["Field_Conn_rd"] := Gdip_CreateBitmapFromFile(designpath "\Field_Conn_rd.png")
	bitmaps["Field_Conn_dr"] := bitmaps["Field_Conn_rd"]
	bitmaps["Field_Conn_ru"] := Gdip_CreateBitmapFromFile(designpath "\Field_Conn_ru.png")
	bitmaps["Field_Conn_ur"] := bitmaps["Field_Conn_ru"]
	bitmaps["Field_Conn_rlu"] := Gdip_CreateBitmapFromFile(designpath "\Field_Conn_rlu.png")
	bitmaps["Field_Conn_rul"] := bitmaps["Field_Conn_rlu"]
	bitmaps["Field_Conn_lru"] := bitmaps["Field_Conn_rlu"]
	bitmaps["Field_Conn_lur"] := bitmaps["Field_Conn_rlu"]
	bitmaps["Field_Conn_url"] := bitmaps["Field_Conn_rlu"]
	bitmaps["Field_Conn_ulr"] := bitmaps["Field_Conn_rlu"]
	bitmaps["Field_Conn_rld"] := Gdip_CreateBitmapFromFile(designpath "\Field_Conn_rld.png")
	bitmaps["Field_Conn_rdl"] := bitmaps["Field_Conn_rld"]
	bitmaps["Field_Conn_lrd"] := bitmaps["Field_Conn_rld"]
	bitmaps["Field_Conn_ldr"] := bitmaps["Field_Conn_rld"]
	bitmaps["Field_Conn_drl"] := bitmaps["Field_Conn_rld"]
	bitmaps["Field_Conn_dlr"] := bitmaps["Field_Conn_rld"]
	bitmaps["Field_Conn_rdu"] := Gdip_CreateBitmapFromFile(designpath "\Field_Conn_rud.png")
	bitmaps["Field_Conn_rud"] := bitmaps["Field_Conn_rdu"]
	bitmaps["Field_Conn_urd"] := bitmaps["Field_Conn_rdu"]
	bitmaps["Field_Conn_udr"] := bitmaps["Field_Conn_rdu"]
	bitmaps["Field_Conn_dru"] := bitmaps["Field_Conn_rdu"]
	bitmaps["Field_Conn_dur"] := bitmaps["Field_Conn_rdu"]
	bitmaps["Field_Conn_ldu"] := Gdip_CreateBitmapFromFile(designpath "\Field_Conn_lud.png")
	bitmaps["Field_Conn_lud"] := bitmaps["Field_Conn_ldu"]
	bitmaps["Field_Conn_uld"] := bitmaps["Field_Conn_ldu"]
	bitmaps["Field_Conn_udl"] := bitmaps["Field_Conn_ldu"]
	bitmaps["Field_Conn_dlu"] := bitmaps["Field_Conn_ldu"]
	bitmaps["Field_Conn_dul"] := bitmaps["Field_Conn_ldu"]
	bitmaps["Field_Conn_rlud"] := Gdip_CreateBitmapFromFile(designpath "\Field_Conn_rlud.png")
	bitmaps["Field_Conn_rldu"] := bitmaps["Field_Conn_rlud"]
	bitmaps["Field_Conn_lrud"] := bitmaps["Field_Conn_rlud"]
	bitmaps["Field_Conn_lrdu"] := bitmaps["Field_Conn_rlud"]
	bitmaps["Field_Conn_udrl"] := bitmaps["Field_Conn_rlud"]
	bitmaps["Field_Conn_udlr"] := bitmaps["Field_Conn_rlud"]
	bitmaps["Field_Conn_durl"] := bitmaps["Field_Conn_rlud"]
	bitmaps["Field_Conn_dulr"] := bitmaps["Field_Conn_rlud"]
	bitmaps["Field_Conn_uldr"] := bitmaps["Field_Conn_rlud"]
	bitmaps["Field_Conn_ulrd"] := bitmaps["Field_Conn_rlud"]
	bitmaps["Field_Conn_ludr"] := bitmaps["Field_Conn_rlud"]
	bitmaps["Field_Conn_lurd"] := bitmaps["Field_Conn_rlud"]
	bitmaps["Field_Conn_rdlu"] := bitmaps["Field_Conn_rlud"]
	bitmaps["Field_Conn_rdul"] := bitmaps["Field_Conn_rlud"]
	bitmaps["Field_Conn_drlu"] := bitmaps["Field_Conn_rlud"]
	bitmaps["Field_Conn_drul"] := bitmaps["Field_Conn_rlud"]
	bitmaps["Field_Arrow_r"] := Gdip_CreateBitmapFromFile(designpath "\Field_Arrow_r.png")
	bitmaps["Field_Arrow_l"] := Gdip_CreateBitmapFromFile(designpath "\Field_Arrow_l.png")
	bitmaps["Field_Arrow_u"] := Gdip_CreateBitmapFromFile(designpath "\Field_Arrow_u.png")
	bitmaps["Field_Arrow_d"] := Gdip_CreateBitmapFromFile(designpath "\Field_Arrow_d.png")
	bitmaps["Field_Teleporter_h"] := Gdip_CreateBitmapFromFile(designpath "\Field_Teleporter_h.png")
	bitmaps["Field_Teleporter_v"] := Gdip_CreateBitmapFromFile(designpath "\Field_Teleporter_v.png")
	bitmaps["Field_Teleporter_b"] := Gdip_CreateBitmapFromFile(designpath "\Field_Teleporter_b.png")
	bitmaps["Field_BallDrop_Conn"] := Gdip_CreateBitmapFromFile(designpath "\Field_BallDrop_Conn.png")
	bitmaps["Field_BallDrop_Conn_u"] := Gdip_CreateBitmapFromFile(designpath "\Field_BallDrop_Conn_u.png")
	bitmaps["Field_info_Time_display"] := Gdip_CreateBitmapFromFile(designpath "\Field_info_Time_display.png")
	bitmaps["Field_info_NextBall"] := Gdip_CreateBitmapFromFile(designpath "\Field_info_NextBall.png")
	bitmaps["Field_info_ballColorChallenge"] := Gdip_CreateBitmapFromFile(designpath "\Field_info_ballColorChallenge.png")
	bitmaps["Field_info_rotatorColorChallenge"] := Gdip_CreateBitmapFromFile(designpath "\Field_info_rotatorColorChallenge.png")
	loop 5
	{
		bitmaps["Field_info_movableBalls_" A_Index-1] := Gdip_CreateBitmapFromFile(designpath "\Field_info_movableBalls_" A_Index-1 ".png")
	}
		
	loop 9
		bitmaps["Field_Rotator_explode_" a_index] := Gdip_CreateBitmapFromFile(designpath "\Field_Rotator_explode_" A_Index ".png")
	
}

draw()
{
	global bitmaps, brushs, brushs
	global g_background_G, g_background_hbm, g_background_hdc, g_background_obm
	global g_foreground_G, g_foreground_hbm, g_foreground_hdc, g_foreground_obm
	global hbm, hdc, obm, G
	static oldGUI_W
	static oldGUI_H
	
	Font:="Arial"
	TextOptions:=" s" 30 " Center vCenter cffffffff  Bold"
	
	if (oldGUI_W!=_share.widthofguipic or oldGUI_H!=_share.heightofguipic)
	{
		oldGUI_W:=_share.widthofguipic
		oldGUI_H:=_share.heightofguipic
		needToRedrawEverything:=true
		
		;delete old bitmaps
		if (g_background_G)
		{
			DeleteObject(g_background_hbm)
			DeleteDC(g_background_hdc)
			Gdip_DeleteGraphics(g_background_G)
			g_background_G:=""
		}		
		if (g_foreground_G)
		{
			DeleteObject(g_foreground_hbm)
			DeleteDC(g_foreground_hdc)
			Gdip_DeleteGraphics(g_foreground_G)
			g_foreground_G:=""
		}
	}
	
	if not g_background_G
	{
		g_background_hbm := CreateDIBSection(_share.widthofguipic, _share.heightofguipic)
		g_background_hdc := CreateCompatibleDC()
		g_background_obm := SelectObject(g_background_hdc, g_background_hbm)
		g_background_G := Gdip_GraphicsFromHDC(g_background_hdc)
		Gdip_SetSmoothingMode(g_background_G, 4) ;We will also set the smoothing mode of the graphics to 4 (Antialias) to make the shapes we use smooth
		Gdip_FillRectangle(g_background_G, brushs["background"], 0, 0, _share.widthofguipic,_share.heightofguipic)
	}
	
	if not g_foreground_G
	{
		g_foreground_hbm := CreateDIBSection(_share.widthofguipic, _share.heightofguipic)
		g_foreground_hdc := CreateCompatibleDC()
		g_foreground_obm := SelectObject(g_foreground_hdc, g_foreground_hbm)
		g_foreground_G := Gdip_GraphicsFromHDC(g_foreground_hdc)
		Gdip_SetSmoothingMode(g_foreground_G, 4) ;We will also set the smoothing mode of the graphics to 4 (Antialias) to make the shapes we use smooth
	}
	
	if (_share.needInitDesign)
	{
		draw_initDesign()
	}
	
	if (_play.state!="menu")
	{
		;some calculation
		widthOfField:=_Field.w
		heightOfField:=_field.h
		if(_share.heightofguipic/heightOfField>_share.widthofguipic/widthOfField)
		{
			factor:=_share.widthofguipic/widthOfField
		}
		else
		{
			factor:=_share.heightofguipic/heightOfField
		}
		_field.factor:=factor
		
		;Make a copy of all fields
		;~ EnterCriticalSection(_field_section)
		fieldCopy:=_field
		;~ LeaveCriticalSection(_field_section)
		
		
		
		
		for oneRowIndex, onelementrow in fieldCopy.elements
		{
			for oneColIndex, onelement in onelementrow
			{
				if (onelement.needRedraw or needToRedrawEverything)
				{
		;~ d(onelement, "aiphipo")
					onelement.wasredrawn:=true
					onelement.needRedraw:=false
					pictures:=onelement.pictures
					for oneindex, onebackground in pictures.background
					{
						Gdip_DrawImage(g_background_G, bitmaps[onebackground], onelement.x*factor -1, onelement.y*factor - 1, onelement.w*factor +2, onelement.h*factor + 2)
					}
					
					;Draw info: current time
					if (onelement = fieldCopy.info_TimeLeft)
					{
						Gdip_TextToGraphics(g_background_G, fieldCopy.info_TimeLeft.timetoShow, "x" ((fieldCopy.info_TimeLeft.x ) * factor) " y" ((fieldCopy.info_TimeLeft.y) * factor) " w" ((fieldCopy.info_TimeLeft.w )* factor) "h" ((fieldCopy.info_TimeLeft.h ) * factor)   TextOptions, Font)
					}
					;Draw info: next ball color
					else if (onelement = fieldCopy.info_NextBall)
					{
						Gdip_DrawImage(g_background_G, bitmaps["Ball" fieldCopy.info_NextBall.colorToShow], (fieldCopy.info_NextBall.x + fieldCopy.info_NextBall.w/2 - fieldCopy.LogicSizeBall*1.3/2) * factor, (fieldCopy.info_NextBall.y +fieldCopy.info_NextBall.h/2 - fieldCopy.LogicSizeBall*1.3/2) * factor, fieldCopy.LogicSizeBall*1.3*factor,fieldCopy.LogicSizeBall*1.3*factor)
					}
					;Draw info: Ball Color Challenge
					else if (onelement = fieldCopy.info_colorChallenge)
					{
						Gdip_DrawImage(g_background_G, bitmaps["Ball" _play.ballColorChallenge[1]], (fieldCopy.info_colorChallenge.mx - fieldCopy.LogicSizeBall/2*0.7) * factor, (fieldCopy.info_colorChallenge.my - fieldCopy.info_colorChallenge.h*0.3 - fieldCopy.LogicSizeBall/2*0.7) * factor, fieldCopy.LogicSizeBall*0.7*factor,fieldCopy.LogicSizeBall*0.7*factor)
						Gdip_DrawImage(g_background_G, bitmaps["Ball" _play.ballColorChallenge[2]], (fieldCopy.info_colorChallenge.mx - fieldCopy.LogicSizeBall/2*0.7) * factor, (fieldCopy.info_colorChallenge.my - fieldCopy.LogicSizeBall/2*0.7) * factor, fieldCopy.LogicSizeBall*0.7*factor,fieldCopy.LogicSizeBall*0.7*factor)
						Gdip_DrawImage(g_background_G, bitmaps["Ball" _play.ballColorChallenge[3]], (fieldCopy.info_colorChallenge.mx - fieldCopy.LogicSizeBall/2*0.7) * factor, (fieldCopy.info_colorChallenge.my + fieldCopy.info_colorChallenge.h*0.3 - fieldCopy.LogicSizeBall/2*0.7) * factor, fieldCopy.LogicSizeBall*0.7*factor,fieldCopy.LogicSizeBall*0.7*factor)
					}
					;Draw info: Rotator Color Challenge
					else if (onelement = fieldCopy.info_rotatorChallenge)
					{
						Gdip_DrawImage(g_background_G, bitmaps["Ball" _play.rotatorColorChallenge.ball_u], (fieldCopy.info_rotatorChallenge.mx - fieldCopy.LogicSizeBall/2*0.7) * factor, (fieldCopy.info_rotatorChallenge.my - fieldCopy.info_rotatorChallenge.h*0.3 - fieldCopy.LogicSizeBall/2*0.7) * factor, fieldCopy.LogicSizeBall*0.7*factor,fieldCopy.LogicSizeBall*0.7*factor)
						Gdip_DrawImage(g_background_G, bitmaps["Ball" _play.rotatorColorChallenge.ball_r], (fieldCopy.info_rotatorChallenge.mx + fieldCopy.info_rotatorChallenge.w*0.3 - fieldCopy.LogicSizeBall/2*0.7) * factor, (fieldCopy.info_rotatorChallenge.my  - fieldCopy.LogicSizeBall/2*0.7) * factor, fieldCopy.LogicSizeBall*0.7*factor,fieldCopy.LogicSizeBall*0.7*factor)
						Gdip_DrawImage(g_background_G, bitmaps["Ball" _play.rotatorColorChallenge.ball_d], (fieldCopy.info_rotatorChallenge.mx - fieldCopy.LogicSizeBall/2*0.7) * factor, (fieldCopy.info_rotatorChallenge.my + fieldCopy.info_rotatorChallenge.h*0.3 - fieldCopy.LogicSizeBall/2*0.7) * factor, fieldCopy.LogicSizeBall*0.7*factor,fieldCopy.LogicSizeBall*0.7*factor)
						Gdip_DrawImage(g_background_G, bitmaps["Ball" _play.rotatorColorChallenge.ball_l], (fieldCopy.info_rotatorChallenge.mx - fieldCopy.info_rotatorChallenge.w*0.3 - fieldCopy.LogicSizeBall/2*0.7) * factor, (fieldCopy.info_rotatorChallenge.my  - fieldCopy.LogicSizeBall/2*0.7) * factor, fieldCopy.LogicSizeBall*0.7*factor,fieldCopy.LogicSizeBall*0.7*factor)
					}
				}
				else
				{
					onelement.wasredrawn:=false
				}
				
			}
		}
		
		;Draw balls
		for oneballIndex, oneball in _balls
		{
			if (oneball.dir = "s") ;only if it is stopped
			{
				if (_allfields[oneball.field].wasredrawn)
				{
					ballColor:=oneball.color
					ballx:=(oneball.x-(oneball.w/2))*factor
					bally:=(oneball.y-(oneball.h/2))*factor
					Gdip_DrawImage(g_background_G, bitmaps["Ball" ballColor], ballx, bally, oneball.w*factor, oneball.h*factor)
				}
			}
		}
		
		g_background_bitmap:=Gdip_CreateBitmapFromHBITMAP(g_background_hbm)
		Gdip_DrawImage(g_foreground_G, g_background_bitmap, 0,0,_share.widthofguipic, _share.heightofguipic)
		Gdip_DisposeImage(g_background_bitmap)
		
		
		;draw info: the transparent bar which shows how many time left for the ball
		percent:=100-(_play.timeForBall/fieldCopy.timeForBall_iterations)*100
		if percent<50
			warnlevel:=0
		else if percent<70
			warnlevel:=1
		else if percent<80
			warnlevel:=2
		else if percent<90
			warnlevel:=3
		else
			warnlevel:=4
		if (fieldCopy.ballEntryPoint = "r")
		{
			Gdip_FillRectangle(g_foreground_G, brushs["balldropWarn" warnlevel], fieldCopy.w * (1-percent/100)*factor, fieldCopy.elements[0][1].y*factor, fieldCopy.w * (percent/100)*factor, fieldCopy.elements[0][1].h*factor)
		}
		else
		{
			Gdip_FillRectangle(g_foreground_G, brushs["balldropWarn" warnlevel], fieldCopy.elements[0][1].x*factor, fieldCopy.elements[0][1].y*factor, fieldCopy.w * (percent/100)*factor, fieldCopy.elements[0][1].h*factor)
		}
			
		
		;Draw balls
		for oneballIndex, oneball in _balls
		{
			if (oneball.needAlwaysRedraw or oneball.needRedraw or needToRedrawEverything) ;only if it is not stopped
			{
				oneball.needRedraw:=false
				ballColor:=oneball.color
				ballx:=(oneball.x-(oneball.w/2))*factor
				bally:=(oneball.y-(oneball.h/2))*factor
				Gdip_DrawImage(g_foreground_G, bitmaps["Ball" ballColor], ballx, bally, oneball.w*factor, oneball.h*factor)
			}
		}
		
		;draw foregrounds of the elements
		for oneRowIndex, onelementrow in fieldCopy.elements
		{
			for oneColIndex, onelement in onelementrow
			{
				pictures:=onelement.pictures
				for oneindex, oneforeground in pictures.foreground
				{
					Gdip_DrawImage(g_foreground_G, bitmaps[oneforeground], onelement.x*factor, onelement.y*factor, onelement.w*factor, onelement.h*factor)
				}
			}
		}
		
		
	;~ ;Show the image
		BitBlt(_share.MainGuiDC, 0, 0, _share.widthofguipic, _share.heightofguipic, g_foreground_hdc, 0, 0)
	}
	else
	{
		sleep 10
	}
	
	
}