playInit()
{
	allkeys:=Object()
	for onekey, onevalue in _play
	{
		allkeys.push(onekey)
	}
	for onekey in allkeys
	{
		_play.delete(onekey)
	}
	
	allkeys:=Object()
	for onekey, onevalue in _balls
	{
		allkeys.push(onekey)
	}
	for oneindex, onekey in allkeys
	{
		_balls.delete(onekey)
	}
	
	for onefieldindex, onefield in _allFields
	{
		onefield.init()
		onefield.NeedRedraw:=true
	}
	
	_play.ballcolorChallenge:=_field.ballcolorChallenge.clone()
	_play.rotatorColorChallenge:=_field.rotatorColorChallenge.clone()
	_play.ballInDrop:=""
	_play.insertedBalls:=0
	_play.rotatorColorChallenge:=CriticalObject()
	
	_play.timeleft:=_field.timeForGame_iterations
	_play.timeForBall:=_field.timeForBall_iterations
	_play.rotatorColorChallengeEnabled:=_field.rotatorColorChallengeEnabled
	_play.rotatorColorChallengeActive:=false
	_play.rotatorColorChallengeRenewTimeSpan:=_field.rotatorColorChallengeRenewTime_iterations
	_play.rotatorColorChallengeRenewTimeLeft:=0
	if (_play.rotatorColorChallengeEnabled)
		play_renewRotatorColorChallenge()
	
	_play.nextcolor:=0
	_play.needCheckAllWhetherToExplode:=0
	_play.movingBalls:=0
	_play.showingwhat:=""
	_play.statechangerequest:=""
	if (not play.state)
		_play.state:="menu"
	
}

play()
{
	if (_play.statechangerequest)
	{
		_play.state:=_play.statechangerequest
		_play.statechangerequest:=""
	}
	
	if (_play.state="menu")
	{
		_sound.backgroundmusicEnable:=false
		if not (_play.showingwhat = "menu")
		{
			_play.showingwhat:="menu"
			gui_menu_show()
			gui_play_hide()
		}
	}
	else if (_play.state="lost")
	{
		if not (_play.showingwhat = "menu")
		{
			_sound.backgroundmusicEnable:=false
			_play.showingwhat:="menu"
			gui_menu_show()
			gui_play_hide()
		}
	}
	else if (_play.state="won")
	{
		if not (_play.showingwhat = "menu")
		{
			saveAchievement()
			_sound.backgroundmusicEnable:=false
			_play.showingwhat:="menu"
			gui_menu_reloadLevels()
			gui_menu_show()
			gui_play_hide()
		}
	}
	else if (_play.state="start")
	{
		_sound.backgroundmusicEnable:=false
		if not (_play.showingwhat = "play")
		{
			_play.showingwhat:="play"
			gui_play_show()
			gui_menu_hide()
		}
		playInit()
		_play.state:="play"
	}
	else if (_play.state="play")
	{
		if not (_play.showingwhat = "play")
		{
			_sound.backgroundmusicEnable:=true
			_play.showingwhat:="play"
			gui_play_show()
			gui_menu_hide()
		}
		
		if (_share.cheatsActive)
			cheat() ;just for developing
		
		;~ EnterCriticalSection(_field_section)
		
		;handle user input
		if (_userinput.HasKey(1))
		{
			_userinput[1].Field.actionOnClick(_userinput[1].button, _userinput[1].x,_userinput[1].y)
			_userinput.delete(1)
		}
		
		;move balls
		for oneballIndex, oneball in _balls
		{
			if (oneball.dir="r") ;right
			{
				oneball.x+=1
			}
			else if (oneball.dir="l") ;left
			{
				oneball.x-=1
			}
			else if (oneball.dir="u") ;up
			{
				oneball.y-=1
			}
			else if (oneball.dir="d") ;down
			{
				oneball.y+=1
			}
			else if (oneball.dir="s") ;stopped
			{
				;nothing
			}
			else
			{
				MsgBox unknown ball directon!
			}
		}
		
		;detect whether an action has to be done
		for oneballIndex, oneball in _balls
		{
			;ball has left the field
			oneballfield:=_allFields[oneball.field]
			newBallField:=findBallField(oneball, 1)
			if (oneballfield != newBallField)
			{
				if (newBallField.canReceiveBallTo(oneball.dir))
				{
					oneballfield.actionOnLeave(oneball)
					if (oneballfield != newBallField)
					{
						oneball.field:=newBallField.id
						newBallField.actionOnEntry(oneball)
					}
				}
				else
				{
					;move ball back
					if (oneball.dir = "u")
					{
						oneball.dir := "d"
						oneball.y := oneballfield.y+1
					}
					else if (oneball.dir = "d")
					{
						oneball.dir := "u"
						oneball.y := oneballfield.y+oneballfield.h-1
					}
					else if (oneball.dir = "r")
					{
						oneball.dir := "l"
						oneball.x := oneballfield.x+oneballfield.w-1
					}
					else if (oneball.dir = "l")
					{
						oneball.dir := "r"
						oneball.x := oneballfield.x+1
					}
				}
			}
			
			;ball is in the middle of one field
			if ((abs(oneball.x - (_allFields[oneball.field].x + _allFields[oneball.field].w/2)) < 1) and (abs(oneball.y - (_allFields[oneball.field].y + _allFields[oneball.field].h/2)) < 1))
			{
				_allFields[oneball.field].actionInTheMiddle(oneball)
			}
		}
		
		while(_play.needCheckAllWhetherToExplode)
		{
			_play.needCheckAllWhetherToExplode:=false
			for onefieldIndex, onefield in _allFields
			{
				onefield.checkWhetherToExplode()
			}
		}
		
		;do actions which have to be done always 
		for onefieldIndex, onefield in _allFields
		{
			onefield.actionAlwaysWithoutBall()
		}
		
		;do actions which have to be done always with each ball
		for oneballIndex, oneball in _balls
		{
			_allFields[oneball.field].actionAlways(oneball)
		}
		
		;insert balls
		if (not _play.ballInDrop)
		{
			play_insertBall()
		}
		
		;count moving balls
		movingBalls:=-1
		for oneballIndex, oneball in _balls
		{
			if (oneball.dir!="s")
				movingBalls+=1
		}
		_play.movingBalls:=movingBalls
		
		;~ LeaveCriticalSection(_field_section)
		
		;check whether we have won
		goalReached:=true
		for onefieldIndex, onefield in _allFields
		{
			if (onefield.GoalNotReached)
			{
				goalReached:=false
			}
		}
		if goalReached
		{
			_share.menuHint:="You won!"
			_play.state:="won"
			return
		}
		
		if (_play.timeleft != "forever")
		{
			_play.timeleft-=1
			if (_play.timeleft<0)
			{
				_share.menuHint:="Game timeout!"
				_play.state:="lost"
				return
			}
		}
		if (_play.rotatorColorChallengeEnabled and not _play.rotatorColorChallengeActive)
		{
			if (_play.rotatorColorChallengeRenewTimeLeft != "forever")
			{
				_play.rotatorColorChallengeRenewTimeLeft-=1
				
				if (_play.rotatorColorChallengeRenewTimeLeft<0)
				{
					play_renewRotatorColorChallenge()
					return
				}
			}
		}
		if (_play.timeForBall != "forever")
		{
			_play.timeForBall-=1
			if (_play.timeForBall<0)
			{
				_share.menuHint:="Ball timeout!"
				_play.state:="lost"
				return
			}
		}
	}
	
}

findBallField(ball, ignoreifnotfound=false)
{
	for onefieldindex, onefield in _allFields
	{
		if (ball.x >= onefield.x and ball.x <= onefield.x + onefield.w and ball.y >= onefield.y and ball.y <= onefield.y + onefield.h)
			return onefield
	}
	if not ignoreifnotfound
		d(ball, "error. Cannot find out the field of the ball")
}