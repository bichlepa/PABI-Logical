play_insertBall()
{
	static ballcount:=0
	static randomcolor:=0
	if (_field.ballcount > 0 and _field.ballcount >= ballcount)
		return
	
	ballcount+=1
	if (not _play.nextcolor)
		random,randomcolor,1,% _field.ballcolorCount
	else
		randomcolor:=_play.nextcolor
	;colors: 1:red, 2:yellow, 3:green, 4:blue
	;directions: r, l, u, d
	ball:=Object()
	ball.y:=_field.elements[0][1].y+(_field.elements[0][1].h/2)
	if (_field.ballEntryPoint = "r")
	{
		ball.field:=_field.elements[0][_field.ColSizex].id
		ball.x:=_field.elements[0][_field.ColSizex].x + _field.elements[0][_field.ColSizex].w - 1
		ball.dir:="l"
	}
	else
	{
		ball.field:=_field.elements[0][1].id
		ball.x:=_field.elements[0][1].x + 1
		ball.dir:="r"
	}
	ball.w:=_field.LogicSizeBall
	ball.h:=_field.LogicSizeBall
	ball.color:=randomcolor
	ball.id:="ball_" ballcount
	ball.needAlwaysRedraw:=true
	_balls[ball.id]:=ball
	_play.ballInDrop:=ball
	_play.timeForBall:=_field.timeForBall_iterations
	
	random,randomcolor,1,% _field.ballcolorCount
	_play.nextcolor:=randomcolor
}


play_renewRotatorColorChallenge()
{
	_play.rotatorColorChallengeRenewTimeLeft:=_play.rotatorColorChallengeRenewTimeSpan
	_play.rotatorColorChallengeActive:=true
	rotatorColorChallengedirs:=["u", "l", "d", "r"]
	loop 4
	{
		random, rotatorColorChallengeColor, 1, % _field.ballcolorCount
		_play.rotatorColorChallenge["ball_" rotatorColorChallengedirs[A_Index]] := rotatorColorChallengeColor
	}
}

colorName2Number(name)
{
	if name=red
		return 1
	if name=green
		return 2
	if name=blue
		return 3
	if name=yellow
		return 4
}
colorNumber2Name(number)
{
	colors:=["red","green","blue", "yellow"]
	if number=0
		return "exploded"
	if number=1
		return "red"
	if number=2
		return "red"
	if number=3
		return "red"
	if number=4
		return "red"
}

;just for developing
cheat()
{
	if (getkeystate("numpad1"))
		_play.nextcolor:=1
	if (getkeystate("numpad2"))
		_play.nextcolor:=2
	if (getkeystate("numpad3"))
		_play.nextcolor:=3
	if (getkeystate("numpad4"))
		_play.nextcolor:=4
	if (getkeystate("f9"))
		_play.statechangerequest:="won"
	
}
