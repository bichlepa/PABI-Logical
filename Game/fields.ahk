
class class_fieldPrototype
{
	;Called once when field is loaded
	__new(type)
	{
		this.type:=type
		;used to find by other fields whether to draw a connection in the direction to this field
		this.conn_r:=false
		this.conn_l:=false
		this.conn_u:=false
		this.conn_d:=false
	}
	
	;called once when game begins
	init()
	{
		
	}
	
	;called on every iteration for each ball which is in the field
	actionAlways(ball)
	{
		
		
	}
	
	;called when a new ball reaches the field
	actionOnEntry(ball)
	{
		
		
	}
	
	;called when a ball is about to leave the field
	actionOnLeave(ball)
	{
		
		
	}
	
	;Called when ball reaches the center of the field
	actionInTheMiddle(ball)
	{
		
	}
	
	;called when user clicks on the field
	actionOnClick(mousebutton, xpos, ypos)
	{
		
		
	}
	
	
	;Used to find out whether the field can send a ball from a certain direction
	canSendBallTo(Dir)
	{
		if (this["conn_" Dir])
		{
			if (Dir = "r")
			{
				return (_allFields[this.neighbor_l].canSendBallTo("r"))
			}
			else if (Dir = "l")
			{
				return (_allFields[this.neighbor_r].canSendBallTo("l"))
			}
			else if (Dir = "u")
			{
				return (_allFields[this.neighbor_d].canSendBallTo("u"))
			}
			else if (Dir = "d")
			{
				return (_allFields[this.neighbor_u].canSendBallTo("d"))
			}
		}
	}
	
	
	;Used to find out whether the field can receive a ball from a certain direction
	canReceiveBallFrom(Dir)
	{
		return this["conn_" Dir]
	}
	;inverted canReceiveBallFrom()
	canReceiveBallTo(Dir)
	{
		if (dir = "r")
			dir:="l"
		else if (dir = "l")
			dir:="r"
		else if (dir = "u")
			dir:="d"
		else if (dir = "d")
			dir:="u"
		return this["conn_" Dir]
	}
	
	;Most of the fields cannot receive balls from balldrop
	canReceiveBallFromBalldrop()
	{
		return false
	}
	
	;Used if the ball needs to be received from balldrop
	receiveFromBalldrop()
	{
		
	}
}


class class_ballDrop extends class_fieldPrototype
{
	__new(type)
	{
		this.type:=type
		this.conn_r:=true
		this.conn_l:=true
		this.conn_u:=false
		this.conn_d:=false
	}
	init()
	{
		background:=criticalObject()
		this.pictures:=criticalObject()
		this.pictures.background:=background
		
		if (this.ColX = 1)
		{
			background.push( "Field_BallDrop_Empty_r")
		}
		else if (this.ColX = _field.ColSizex)
		{
			background.push( "Field_BallDrop_Empty_l")
		}
		else
		{
			background.push( "Field_BallDrop_Empty_rl")
		}
		
		if (_allFields[this.neighbor_d].canReceiveBallFromBalldrop())
		{
			background.push( "Field_BallDrop_Conn_u")
		}
		else
		{
			background.push( "Field_BallDrop_Conn")
		}
	}
	
	actionInTheMiddle(ball)
	{
		;find out whether the ball can be dropped
		if (_allFields[this.neighbor_d].canReceiveBallTo("d"))
		{
			;find out whether the ball can be dropped
			candrop:=false
			if (_allFields[this.neighbor_d].canReceiveBallFromBalldrop() = true) ;Yes, if the receiving field is a rotator
			{
				candrop:=true
				ball.dir := "d" ;ball direction must be changed before call of .actionOnEntry()
				ball.field := _allFields[this.neighbor_d].id
				_allFields[this.neighbor_d].receiveFromBalldrop(ball)
				_play.ballInDrop:=false
			}
		}
		
	}
	
	actionOnLeave(ball)
	{
		;if ball reaches the right or left bound
		if (ball.dir="r")
		{
			if (not _allFields[this.neighbor_r].canReceiveBallTo("r"))
			{
				ball.dir:="l"
				ball.x-=2
			}
		}
		else if (ball.dir="l")
		{
			if (not _allFields[this.neighbor_l].canReceiveBallTo("l"))
			{
				ball.dir:="r"
				ball.x+=2
			}
		}
		else
		{
			d(ball, "error when leaving the balldrop. Ball direction wrong")
		}
		
	}
	
	;Used to find out whether the field can send a ball from a certain direction
	canSendBallTo(Dir)
	{
		return this["conn_" Dir]
	}
}

class class_empty extends class_fieldPrototype
{
	__new(type)
	{
		this.type:=type
		this.conn_r:=false
		this.conn_l:=false
		this.conn_u:=false
		
		background:=criticalObject()
		this.pictures:=criticalObject()
		this.pictures.background:=background
		
		background.push("Field_empty")
	}
}

class class_rotator extends class_fieldPrototype
{
	__new(type)
	{
		this.type:=type
		this.conn_r:=true
		this.conn_l:=true
		this.conn_u:=true
		this.conn_d:=true
		
		;positions of the balls
		this.ball_distanceFromCenterInRotator:=0.3
		this.ball_distanceFromCenterToReachHole:=0.4
		
		;other settings
		this.rotatingStepWidth:=20
		
		this.init()
	}
	init()
	{
		this.ball_r:=""
		this.ball_l:=""
		this.ball_u:=""
		this.ball_d:=""
		this.rotating:=false ;true, while it is rotating
		this.rotatingDir:="" ;r or l. only while it is rotating
		this.rotatingAngle:=0 ;0 - 80 or 0 - -80. only while it is rotating
		this.rotatingDirNext:=""
		this.GoalNotReached:=true ;False after a explosion
		this.exploding:=false ;Exploding when all balls are of same color
		this.explodingStep:=0 ;used to animate the explosion
		this.exploded:=false ;True after a explosion.
		
		this.pictures:=criticalObject()
		this.getpictures()
	}
	getpictures()
	{
		background:=criticalObject()
		foreground:=criticalObject()
		this.pictures.background:=background
		this.pictures.foreground:=foreground
		
		background.push("Field_empty")
		;add connections
		if (_allFields[this.neighbor_r].conn_l)
			background.push("Field_Conn_r")
		if (_allFields[this.neighbor_l].conn_r)
			background.push("Field_Conn_l")
		if (_allFields[this.neighbor_u].conn_d or _allFields[this.neighbor_u].type="d")
			background.push("Field_Conn_u")
		if (_allFields[this.neighbor_d].conn_u)
			background.push("Field_Conn_d")
		;draw the rotator
		if (this.exploded)
		{
			blownstring:="_blown"
		}
		if (this.rotatingAngle=0)
			foreground.push("Field_Rotator" blownstring)
		else
		{
			angle:=this.rotatingAngle
			if (angle<0)
				angle+=90
			foreground.push("Field_Rotator" blownstring "_" angle)
		}
		
		;draw explosion
		if (this.explodingStep)
			foreground.push("Field_Rotator_explode_" this.explodingStep)
		
	}
	
	;the rotator is the most complicated one. So every rotator must check some conditions on every iterations
	actionAlwaysWithoutBall()
	{
		;while the rotator is rotating
		if (this.rotating)
		{
			;rotate it further
			if (this.rotatingDir = "r")
			{
				this.rotatingAngle-=this.rotatingStepWidth
			}
			else if (this.rotatingDir = "l")
			{
				this.rotatingAngle+=this.rotatingStepWidth
			}
			;if rotation is completed
			if (this.rotatingAngle<=-90 or this.rotatingAngle>=90)
			{
				;change the ball positions
				if (this.rotatingDir = "r")
				{
					temp:=this.ball_u
					this.ball_u:=this.ball_l
					this.ball_l:=this.ball_d
					this.ball_d:=this.ball_r
					this.ball_r:=temp
				}
				else if (this.rotatingDir = "l")
				{
					temp:=this.ball_u
					this.ball_u:=this.ball_r
					this.ball_r:=this.ball_d
					this.ball_d:=this.ball_l
					this.ball_l:=temp
				}
				this.rotating:=false
				this.rotatingAngle:=0
				this.rotatingDir:=""
			}
			
			;write the rotation information to the balls
			if (this.ball_u)
			{
				if (this.rotating=False)
					_balls[this.ball_u].posInRotator:="u"
				this.calcBallPos(_balls[this.ball_u])
			}
			if (this.ball_r)
			{
				if (this.rotating=False)
					_balls[this.ball_r].posInRotator:="r"
				this.calcBallPos(_balls[this.ball_r])
			}
			if (this.ball_d)
			{
				if (this.rotating=False)
					_balls[this.ball_d].posInRotator:="d"
				this.calcBallPos(_balls[this.ball_d])
			}
			if (this.ball_l)
			{
				if (this.rotating=False)
					_balls[this.ball_l].posInRotator:="l"
				this.calcBallPos(_balls[this.ball_l])
			}
			
			;if rotation has stopped
			if (this.rotating=False)
			{
				;maybe the condition to explode is fulfilled now
				this.checkWhetherToExplode()
				
				;If user has clicked while it was rotating, rotate again
				if (this.rotatingDirNext)
				{
					playsound("rotate")
					this.rotatingDir:=this.rotatingDirNext
					this.rotatingDirNext:=""
					this.rotating:=True
				}
				
			}
			
			this.getpictures() ;update pictures
			this.NeedRedraw:=true
		}
		
		;if the balls in the rotator are exploding
		if (this.exploding)
		{
			;next step
			this.explodingStep+=1
			if (this.explodingStep>_share.opticalDesignPrefs.AnimationExplodeSteps) ;if explosion has finished
			{
				this.explodingStep:=0
				this.exploding:=false
			}
			if (this.explodingStep=_share.opticalDesignPrefs.AnimationExplodeRemoveBallsStep) ;in the middle of explosion
			{
				;redraw the rotator (it becomes darker)
				this.exploded:=true
				this.NeedRedraw:=true
				
				;remove balls
				_balls.delete(this.ball_d)
				_balls.delete(this.ball_u)
				_balls.delete(this.ball_r)
				_balls.delete(this.ball_l)
				this.ball_l:=""
				this.ball_r:=""
				this.ball_u:=""
				this.ball_d:=""
			}
			this.getpictures() ;Update foreground pictures while exloding
		}
	}
	
	;the rotator is the most complicated one. So every rotator must check some conditions on every iterations
	actionAlways(ball)
	{
		;Detect whether a ball is moving towards the rotator and it reaches the hole
		if (ball.dir="r")
		{
			if ((ball.x < (this.mx)) and (ball.x > (this.mx - this.w*this.ball_distanceFromCenterToReachHole)))
			{
				if (this.rotating=False and not this.ball_l)
				{
					if (ball.x > (this.x + this.w*0.20))
					{
						this.addball(ball,"l")
					}
				}
				else
				{
					playsound("dirchange")
					ball.x := this.x + this.w*0.10
					ball.dir := "l"
				}
			}
		}
		if (ball.dir="l")
		{
			if (ball.x > (this.mx) and ball.x < (this.mx + this.w*this.ball_distanceFromCenterToReachHole))
			{
				if (this.rotating=False and not this.ball_r)
				{
					if (ball.x < (this.x + this.w*0.80))
					{
						this.addball(ball,"r")
					}
				}
				else
				{
					playsound("dirchange")
					ball.x := this.x + this.w*0.90
					ball.dir := "r"
				}
			}
		}
		if (ball.dir="u")
		{
			if (ball.y > (this.my) and ball.y < (this.my + this.h*this.ball_distanceFromCenterToReachHole))
			{
				if (this.rotating=False and not this.ball_d)
				{
					if (ball.y < (this.y + this.h*0.80))
					{
						this.addball(ball,"d")
					}
				}
				else
				{
					playsound("dirchange")
					ball.y := this.y + this.h*0.90
					ball.dir := "d"
				}
			}
		}
		else if (ball.dir="d")
		{
			if (ball.y < (this.my) and ball.y > (this.my - this.h*this.ball_distanceFromCenterToReachHole))
			{
				if (this.rotating=False and not this.ball_u)
				{
					if (ball.y > (this.y + this.h*0.20))
					{
						this.addball(ball,"u")
					}
				}
				else
				{
					playsound("dirchange")
					ball.y := this.y + this.h*0.10
					ball.dir := "u"
				}
			}
		}
	}
	
	receiveFromBalldrop(ball)
	{
		;if the ball comes from the balldrop, put it immediately in the hole
		this.addball(ball,"u")
	}
	
	;handle user input
	actionOnClick(mousebutton, xpos, ypos)
	{
		if (mousebutton="left") ;user wants to send a ball
		{
			;this is only possible, if not too many balls are moving and the rotator is not rotating or exploding
			if (_play.movingBalls < _field.maxMovingBalls and this.rotating= false and this.exploding= false)
			{
				;Check the four positions. If there is a ball...
				if (this.ball_r)
				{
					;... check whether the user has clicked on this ball
					if (Sqrt((_balls[this.ball_r].x - xpos)**2  + (_balls[this.ball_r].y  - ypos)**2) < _balls[this.ball_r].w/2)
					{
						;if ball can be sent to that direction
						if (_allFields[this.neighbor_r].canReceiveBallFrom("r"))
						{
							;send the ball
							_balls[this.ball_r].posInRotator:=""
							_balls[this.ball_r].dir:="r"
							_balls[this.ball_r].needRedraw:=True
							_balls[this.ball_r].needAlwaysRedraw:=True
							this.ball_r:=""
							this.needRedraw:=true ;redraw element. otherwise the ball will not be visible removed
							playsound("go")
						}
						return
					}
				}
				if (this.ball_l)
				{
					if (Sqrt((_balls[this.ball_l].x - xpos)**2  + (_balls[this.ball_l].y  - ypos)**2) < _balls[this.ball_l].w/2)
					{
						if (_allFields[this.neighbor_l].canReceiveBallFrom("l"))
						{
							_balls[this.ball_l].posInRotator:=""
							_balls[this.ball_l].dir:="l"
							_balls[this.ball_l].needRedraw:=True
							_balls[this.ball_l].needAlwaysRedraw:=True
							this.ball_l:=""
							this.needRedraw:=true
							playsound("go")
						}
						return
					}
				}
				if (this.ball_u)
				{
					if (Sqrt((_balls[this.ball_u].x - xpos)**2  + (_balls[this.ball_u].y  - ypos)**2) < _balls[this.ball_u].w/2)
					{
						if (_allFields[this.neighbor_u].canReceiveBallFrom("u"))
						{
							_balls[this.ball_u].posInRotator:=""
							_balls[this.ball_u].dir:="u"
							_balls[this.ball_u].needAlwaysRedraw:=True
							this.ball_u:=""
							this.needRedraw:=true
							playsound("go")
						}
						return
					}
				}
				if (this.ball_d)
				{
					if (Sqrt((_balls[this.ball_d].x - xpos)**2  + (_balls[this.ball_d].y  - ypos)**2) < _balls[this.ball_d].w/2)
					{
						if (_allFields[this.neighbor_d].canReceiveBallFrom("d"))
						{
							_balls[this.ball_d].posInRotator:=""
							_balls[this.ball_d].dir:="d"
							_balls[this.ball_d].needAlwaysRedraw:=True
							this.ball_d:=""
							this.needRedraw:=true
							playsound("go")
						}
						return
					}
				}
				
			}
		}
		else if (mousebutton="right") ;user wants to rotate the rotator
		{
			if (this.rotating= false) ;if no rotating
			{
				;Start rotating
				this.rotating:=true
				this.rotatingDir:="l"
				this.rotatingAngle:=0 ;angle is 0, because the function actionAlwaysWithoutBall() will be called in the same iteration
				playsound("rotate")
			}
			else ;if already rotating
			{
				;rotate later
				this.rotatingDirNext:="l"
			}
		}
		
	}
	
	canReceiveBallTo(Dir)
	{
		;if the rotator asks it, only allow while the rotator is not rotating
		if (dir = "d")
			if (_allFields[this.neighbor_u].type="d")
				if (this.rotating or this.ball_u)
					return false
		;otherwise as usual
		return this["conn_" Dir]
	}
	
	canReceiveBallFromBalldrop()
	{
		return true
	}
	
	canSendBallTo(Dir)
	{
		return this["conn_" Dir]
	}
	
	;adds a ball to the rotator
	addball(ball, dir)
	{
		if (this["ball_" dir] != "")
		{
			d(this, "ERROR. cannot add ball to hole " dir " it is already occupied")
			return
		}
		else
		{
			this["ball_" dir] := ball.id
			ball.posInRotator:=dir
			ball.dir:="s"
			
			this.needRedraw:=true ;redraw element. otherwise the ball will not be visible removed
			ball.needAlwaysRedraw:=False
			ball.needRedraw:=True
			
			this.calcBallPos(ball)
			playsound("dock")
			
			;after a ball was added, check wheter the condition is fulfilled to explode
			this.checkWhetherToExplode()
		}
	}
	
	;calculates the ball positions
	calcBallPos(ball)
	{
		angletoradian:= 0.01745329252
		if (ball.posInRotator = "u")
		{
			angle:=0
		}
		else if (ball.posInRotator = "l")
		{
			angle:=90
		}
		else if (ball.posInRotator = "d")
		{
			angle:=180
		}
		else if (ball.posInRotator = "r")
		{
			angle:=270
		}
		angle+=this.rotatingAngle
		
		ball.x:=this.mx - this.w*this.ball_distanceFromCenterInRotator*sin(angle*angletoradian)
		ball.y:=this.my - this.h*this.ball_distanceFromCenterInRotator*cos(angle*angletoradian)
	}
	
	;check whether the condition is fulfilled and the balls can explode
	checkWhetherToExplode()
	{
		if (_play.rotatorColorChallenge.ball_r)  ;if there is a rotator challenge, which means that currently only a specific color combination can explode
		{
			if (_play.rotatorColorChallenge.ball_r = _balls[this.ball_r].color and _play.rotatorColorChallenge.ball_l = _balls[this.ball_l].color and _play.rotatorColorChallenge.ball_d = _balls[this.ball_d].color and _play.rotatorColorChallenge.ball_u = _balls[this.ball_u].color)
			{
				won:=true
				_play.rotatorColorChallenge.ball_r:=0
				_play.rotatorColorChallenge.ball_l:=0
				_play.rotatorColorChallenge.ball_u:=0
				_play.rotatorColorChallenge.ball_d:=0
				_play.needCheckAllWhetherToExplode:=true ;after that we need to check wheter other fields can explode now
				_play.rotatorColorChallengeActive:=false
			}
			
		}
		else
		{
			;mostly it is fulfilled, if all balls have the same color
			won:=true
			color:=_balls[this.ball_u].color
			won:=!!color
			if won
				won:=(color = _balls[this.ball_d].color)
			if won
				won:=(color = _balls[this.ball_r].color)
			if won
				won:=(color = _balls[this.ball_l].color)
			if (won) ;all balls have same color
			{
				
				if (_play.ballcolorChallenge.MaxIndex()) ;if there is a color challenge, which means that currently only a specific color can explode
				{
					;Find out whether the right ball color is in this rotator
					for oneindex, oneColorChallenge in _play.ballcolorChallenge
					{
						if (oneColorChallenge= 0)
							continue
						else 
						{
							if (oneColorChallenge=color) ;if the color is correct
							{
								;remove that color from the challenge
								_play.ballcolorChallenge[oneindex] := 0
								
								_play.needCheckAllWhetherToExplode:=true ;after that we need to check wheter other fields can explode now
							}
							else
							{
								won:=false
							}
							break
						}
					}
					
				}
			}
		}
		
		if (won)
		{
			if (this.GoalNotReached)
			{
				this.GoalNotReached:=false
			}
			playsound("explode")
			this.exploding:=true
			this.explodingStep:=1
			this.NeedRedraw:=true
		}
	}
	
	winanimation_init()
	{
	}
	winanimation()
	{
		if (not this.exploding)
		{
			random,randomvar,1,30
			if (randomvar=1)
			{
				playsound("explode")
				this.exploding:=true
				this.explodingStep:=1
				this.NeedRedraw:=true
			}
		}
		this.actionAlwaysWithoutBall()
	}	
	looseanimation_init()
	{
		
	}
	looseanimation()
	{
		if (this.rotating= false) ;if no rotating
		{	
			random,randomvar,1,20
			if (randomvar=1)
			{
				random,randomdir,1,2
				if randomdir = 1
					randomdir = l
				else 
					randomdir=r
				;Start rotating
				this.rotating:=true
				this.rotatingDir:=randomdir
				this.rotatingAngle:=0 ;angle is 0, because the function actionAlwaysWithoutBall() will be called in the same iteration
			}
		}
		random,randomvar,1,10
		if (randomvar=1)
			this.actionAlwaysWithoutBall()
	}
}

class class_pass extends class_fieldPrototype
{
	__new(type)
	{
		this.type:=type
		
		if (substr(this.type,2,1)="v")  ;vertical
		{
			this.conn_r:=false
			this.conn_l:=false
			this.conn_u:=true
			this.conn_d:=true
		}
		else if (substr(this.type,2,1)="h") ;horizontal
		{
			this.conn_r:=true
			this.conn_l:=true
			this.conn_u:=false
			this.conn_d:=false
		}
		else if (substr(this.type,2,1)="b")  ;both
		{
			this.conn_r:=true
			this.conn_l:=true
			this.conn_u:=true
			this.conn_d:=true
		}
		else
		{
			d(this, "ERROR. Cannot detect the directions of the connection")
		}
		
	}
	init()
	{
		background:=criticalObject()
		this.pictures:=criticalObject()
		this.pictures.background:=background
		
		if (substr(this.type,2,1)="v")  ;vertical
		{
			background.push("Field_empty", "Field_Conn_ud")
		}
		else if (substr(this.type,2,1)="h") ;horizontal
		{
			background.push("Field_empty", "Field_Conn_rl")
		}
		else if (substr(this.type,2,1)="b")  ;both
		{
			dirs:=""
			if (_allFields[this.neighbor_r].canReceiveBallTo("r") and (_allFields[this.neighbor_r].canSendBallTo("l") or this.canSendBallTo("r")))
				dirs.="r"
			if (_allFields[this.neighbor_l].canReceiveBallTo("l") and (_allFields[this.neighbor_l].canSendBallTo("r") or this.canSendBallTo("l")))
				dirs.="l"
			if (_allFields[this.neighbor_d].canReceiveBallTo("d") and (_allFields[this.neighbor_d].canSendBallTo("u") or this.canSendBallTo("d")))
				dirs.="d"
			if (_allFields[this.neighbor_u].canReceiveBallTo("u") and (_allFields[this.neighbor_u].canSendBallTo("d") or this.canSendBallTo("u")))
				dirs.="u"
			if dirs
				background.push("Field_empty", "Field_Conn_" dirs)
		}
	}
	
	canReceiveBallFromBalldrop()
	{
		if (this.ColY = 1 and (substr(this.type,2,1)="v" or substr(this.type,2,1)="b"))
		{
			if (_play.state!="play" or ((_play.movingBalls + 1) < _field.maxMovingBalls))
				return true
		}
		else
			return false
	}
	
	canSendBallTo(Dir)
	{
		if (this["conn_" Dir])
		{
			if (Dir = "r")
			{
				return (_allFields[this.neighbor_l].canSendBallTo("r"))
			}
			else if (Dir = "l")
			{
				return (_allFields[this.neighbor_r].canSendBallTo("l"))
			}
			else if (Dir = "u")
			{
				return (_allFields[this.neighbor_d].canSendBallTo("u"))
			}
			else if (Dir = "d")
			{
				return (_allFields[this.neighbor_u].canSendBallTo("d") or this.canReceiveBallFromBalldrop())
			}
		}
	}
	
	receiveFromBalldrop(ball)
	{
		this.addball(ball,"u")
		
		playsound("dock")
		ball.x:=this.mx
		ball.y:=this.y+1
		ball.dir:="d"
		ball.needAlwaysRedraw:=true ;might be not nessecary
			
	}
}

class class_teleporter extends class_fieldPrototype
{
	__new(type)
	{
		this.type:=type
		
		foreground:=criticalObject()
		this.pictures:=criticalObject()
		this.pictures.foreground:=foreground
		
		if (substr(this.type,2,1)="v")  ;vertical
		{
			this.conn_r:=false
			this.conn_l:=false
			this.conn_u:=true
			this.conn_d:=true
			foreground.push("Field_Teleporter_v")
		}
		else if (substr(this.type,2,1)="h") ;horizontal
		{
			this.conn_r:=true
			this.conn_l:=true
			this.conn_u:=false
			this.conn_d:=false
			foreground.push("Field_Teleporter_h")
		}
		else if (substr(this.type,2,1)="b")  ;both
		{
			this.conn_r:=true
			this.conn_l:=true
			this.conn_u:=true
			this.conn_d:=true
			foreground.push("Field_Teleporter_b")
		}
	}
	
	init()
	{
		background:=criticalObject()
		this.pictures.background:=background
		
		background.push("Field_empty")
		
		conn:=""
		if (substr(this.type,2,1)="h" or (substr(this.type,2,1)="b"))
		{
			if (_allFields[this.neighbor_r].canReceiveBallTo("r") and this.canSendBallTo("r") or _allFields[this.neighbor_r].canSendBallTo("l"))
			{
				conn.="r"
			}
			if (_allFields[this.neighbor_l].canReceiveBallTo("l") and this.canSendBallTo("l") or _allFields[this.neighbor_l].canSendBallTo("r"))
			{
				conn.="l"
			}
		}
		if (substr(this.type,2,1)="v" or (substr(this.type,2,1)="b"))
		{
			if (_allFields[this.neighbor_u].canReceiveBallTo("u") and this.canSendBallTo("u") or _allFields[this.neighbor_u].canSendBallTo("d"))
			{
				conn.="u"
			}
			if (_allFields[this.neighbor_d].canReceiveBallTo("d") and this.canSendBallTo("d") or _allFields[this.neighbor_d].canSendBallTo("u"))
			{
				conn.="d"
			}
		}
		background.push( "Field_Conn_" conn)
	}
	
	actionInTheMiddle(ball)
	{
		for onefieldIndex, onefield in _allFields
		{
			if (ball.dir = "r")
			{
				if (onefield!=this and (substr(onefield.type,1,2)="th" or substr(onefield.type,1,2)="tb"))
				{
					playsound("teleport")
					ball.x:=onefield.x + onefield.w/2 +2
					ball.y:=onefield.y + onefield.h/2
				}
			}
			else if (ball.dir = "l")
			{
				if (onefield!=this and (substr(onefield.type,1,2)="th" or substr(onefield.type,1,2)="tb"))
				{
					playsound("teleport")
					ball.x:=onefield.x + onefield.w/2 -2
					ball.y:=onefield.y + onefield.h/2
				}
			}
			else if (ball.dir = "d")
			{
				if (onefield!=this and (substr(onefield.type,1,2)="tv" or substr(onefield.type,1,2)="tb"))
				{
					playsound("teleport")
					ball.x:=onefield.x + onefield.w/2
					ball.y:=onefield.y + onefield.h/2 +2
				}
			}
			else if (ball.dir = "u")
			{
				if (onefield!=this and (substr(onefield.type,1,2)="tv" or substr(onefield.type,1,2)="tb"))
				{
					playsound("teleport")
					ball.x:=onefield.x + onefield.w/2
					ball.y:=onefield.y + onefield.h/2 -2
				}
			}
			
		}
	}
	
	canSendBallTo(Dir)
	{
		
		for onefieldIndex, onefield in _allFields
		{
			if (Dir = "r" and this.conn_r)
			{
				if (onefield!=this and (substr(onefield.type,1,2)="th" or substr(onefield.type,1,2)="tb") and _allFields[onefield.neighbor_l].canSendBallTo("r"))
				{
					return true
				}
			}
			else if (Dir = "l" and this.conn_l)
			{
				if (onefield!=this and (substr(onefield.type,1,2)="th" or substr(onefield.type,1,2)="tb") and _allFields[onefield.neighbor_r].canSendBallTo("l"))
				{
					return true
				}
			}
			else if (Dir = "d" and this.conn_d)
			{
				if (onefield!=this and (substr(onefield.type,1,2)="tv" or substr(onefield.type,1,2)="tb") and _allFields[onefield.neighbor_u].canSendBallTo("d"))
				{
					return true
				}
			}
			else if (Dir = "u" and this.conn_u)
			{
				if (onefield!=this and (substr(onefield.type,1,2)="tv" or substr(onefield.type,1,2)="tb") and _allFields[onefield.neighbor_d].canSendBallTo("u"))
				{
					return true
				}
			}
			
		}
		return false
	}
	
}

class class_blocker extends class_fieldPrototype
{
	__new(type)
	{
		this.type:=type
		this.color:=substr(A_LoopField,3)
		
		
		if (substr(this.type,2,1)="v")  ;vertical
		{
			this.conn_r:=false
			this.conn_l:=false
			this.conn_u:=true
			this.conn_d:=true
		}
		else if (substr(this.type,2,1)="h") ;horizontal
		{
			this.conn_r:=true
			this.conn_l:=true
			this.conn_u:=false
			this.conn_d:=false
		}
		else if (substr(this.type,2,1)="b")  ;both
		{
			this.conn_r:=true
			this.conn_l:=true
			this.conn_u:=true
			this.conn_d:=true
		}
	}
	
	
	init()
	{
		background:=criticalObject()
		foreground:=criticalObject()
		this.pictures:=criticalObject()
		this.pictures.background:=background
		this.pictures.foreground:=foreground
		
		background.push("Field_empty")
		foreground.push("Field_Blocker_" this.color)
		
		if (substr(this.type,2,1)="v")  ;vertical
		{
			this.conn_d:=true
			background.push("Field_Conn_ud")
		}
		else if (substr(this.type,2,1)="h") ;horizontal
		{
			background.push("Field_Conn_rl")
		}
		else if (substr(this.type,2,1)="b")  ;both
		{
			dirs:=""
			if (_allFields[this.neighbor_r].canReceiveBallTo("r") and (_allFields[this.neighbor_r].canSendBallTo("l")) or this.canSendBallTo("r"))
				dirs.="r"
			if (_allFields[this.neighbor_l].canReceiveBallTo("l") and (_allFields[this.neighbor_l].canSendBallTo("r")) or this.canSendBallTo("l"))
				dirs.="l"
			if (_allFields[this.neighbor_d].canReceiveBallTo("d") and (_allFields[this.neighbor_d].canSendBallTo("u")) or this.canSendBallTo("d"))
				dirs.="d"
			if (_allFields[this.neighbor_u].canReceiveBallTo("u") and (_allFields[this.neighbor_u].canSendBallTo("d")) or this.canSendBallTo("u"))
				dirs.="u"
			if dirs
				background.push("Field_empty", "Field_Conn_" dirs)
		}
		
	}
	
	actionInTheMiddle(ball)
	{
		;if ball has not the same color, reject it and move it back
		if (ball.color != this.color)
		{
			playsound("dirchange")
			if (ball.dir = "d")
			{
				ball.dir := "u"
				ball.x:=this.x + this.w/2 
				ball.y:=this.y + this.h/2-2
			}
			else if (ball.dir = "u")
			{
				ball.dir := "d"
				ball.x:=this.x + this.w/2
				ball.y:=this.y + this.h/2 +2
			}
			if (ball.dir = "r")
			{
				ball.dir := "l"
				ball.x:=this.x + this.w/2 -2
				ball.y:=this.y + this.h/2
			}
			else if (ball.dir = "l")
			{
				ball.dir := "r"
				ball.x:=this.x + this.w/2+2
				ball.y:=this.y + this.h/2 
			}
		}
	}
}

class class_paint extends class_fieldPrototype
{
	__new(type)
	{
		this.type:=type
		this.color:=substr(A_LoopField,3)
		
		background:=criticalObject()
		foreground:=criticalObject()
		this.pictures:=criticalObject()
		this.pictures.background:=background
		this.pictures.foreground:=foreground
		
		background.push("Field_empty")
		foreground.push("Field_Paint_" this.color)
		
		if (substr(this.type,2,1)="v")  ;vertical
		{
			this.conn_r:=false
			this.conn_l:=false
			this.conn_u:=true
			this.conn_d:=true
			background.push("Field_Conn_ud")
		}
		else if (substr(this.type,2,1)="h") ;horizontal
		{
			this.conn_r:=true
			this.conn_l:=true
			this.conn_u:=false
			this.conn_d:=false
			background.push("Field_Conn_rl")
		}
		else if (substr(this.type,2,1)="b")  ;both
		{
			this.conn_r:=true
			this.conn_l:=true
			this.conn_u:=true
			this.conn_d:=true
			background.push("Field_Conn_rlud")
		}
	}
	
	actionInTheMiddle(ball)
	{
		;if ball has not the same color, color it
		if (ball.color != this.color)
		{
			playsound("colorize")
			ball.color:=this.color
		}
	}
}


class class_arrow extends class_fieldPrototype
{
	__new(type)
	{
		this.type:=type
		this.conn_r:=true
		this.conn_l:=true
		this.conn_u:=true
		this.conn_d:=true
		this.dir:=substr(this.type,2,1)
	}
	
	init()
	{
		background:=criticalObject()
		foreground:=criticalObject()
		this.pictures:=criticalObject()
		this.pictures.background:=background
		this.pictures.foreground:=foreground
		background.push("Field_empty")
		
		;add connections
		dirs:=""
		if (_allFields[this.neighbor_r].canReceiveBallTo("r") and (_allFields[this.neighbor_r].canSendBallTo("l") or this.canSendBallTo("r")))
			dirs.="r"
		if (_allFields[this.neighbor_l].canReceiveBallTo("l") and (_allFields[this.neighbor_l].canSendBallTo("r") or this.canSendBallTo("l")))
			dirs.="l"
		if (_allFields[this.neighbor_u].canReceiveBallTo("u") and (_allFields[this.neighbor_u].canSendBallTo("d") or this.canSendBallTo("u")))
			dirs.="u"
		if (_allFields[this.neighbor_d].canReceiveBallTo("d") and (_allFields[this.neighbor_d].canSendBallTo("u") or this.canSendBallTo("d")))
			dirs.="d"
		if not instr(dirs,this.dir)
			dirs.=this.dir
		if dirs
			background.push("Field_Conn_" dirs)
		foreground.push("Field_Arrow_" substr(this.type,2,1))
	}
	
	actionInTheMiddle(ball)
	{
		;if ball has not the direction, turn it
		if (ball.dir != this.dir)
		{
			playsound("dirchange")
			ball.dir:=this.dir
			
			if (this.dir = "u")
			{
				ball.x:=this.x + this.w/2 
				ball.y:=this.y + this.h/2-2
			}
			else if (this.dir = "d")
			{
				ball.x:=this.x + this.w/2
				ball.y:=this.y + this.h/2 +2
			}
			if (this.dir = "l")
			{
				ball.x:=this.x + this.w/2 -2
				ball.y:=this.y + this.h/2
			}
			else if (this.dir = "r")
			{
				ball.x:=this.x + this.w/2+2
				ball.y:=this.y + this.h/2 
			}
		}
	}
	
	;Used to find out whether the field can send a ball from a certain direction
	canSendBallTo(Dir)
	{
		return (this.dir = Dir)
	}
}

class class_info_nextBall extends class_fieldPrototype
{
	__new(type)
	{
		this.type:=type
		this.conn_r:=false
		this.conn_l:=false
		this.conn_u:=false
		this.conn_d:=false
		
		background:=criticalObject()
		this.pictures:=criticalObject()
		this.pictures.background:=background
		
		background.push("Field_empty", "Field_info_NextBall")
	}
	
	init()
	{
		this.colorToShow:=0
	}
	
	ActionAlwaysWithoutBall()
	{
		if (this.colorToShow != _play.nextcolor)
		{
			this.colorToShow:=_play.nextcolor
			this.NeedRedraw:=true
		}
	}
}

class class_info_TimeLeft extends class_fieldPrototype
{
	__new(type)
	{
		this.type:=type
		this.conn_r:=false
		this.conn_l:=false
		this.conn_u:=false
		this.conn_d:=false
		
		background:=criticalObject()
		this.pictures:=criticalObject()
		this.pictures.background:=background
		
		background.push("Field_empty", "Field_info_Time_display")
	}
	
	init()
	{
		this.timetoShow:=0
	}
	
	actionAlwaysWithoutBall()
	{
		timetoShow:=round(_play.timeleft * _share.IterationTimer / 1000)
		if (timetoShow != this.timetoShow)
		{
			this.timetoShow:=timetoShow
			this.NeedRedraw:=true
		}
	}
}

class class_info_movableBalls extends class_fieldPrototype
{
	__new(type)
	{
		this.type:=type
		this.conn_r:=false
		this.conn_l:=false
		this.conn_u:=false
		this.conn_d:=false
		
		background:=criticalObject()
		this.pictures:=criticalObject()
		this.pictures.background:=background
		
		background.push("Field_empty", "Field_info_movableBalls_4")
	}
	
	init()
	{
		this.LastMovingballs:=0
	}
	
	actionAlwaysWithoutBall()
	{
		if (_play.movingBalls != this.LastMovingballs)
		{
			background:=criticalObject()
			background.push("Field_empty", "Field_info_movableBalls_" _field.maxMovingBalls - _play.movingBalls)
			this.pictures.background:=background
		
			this.LastMovingballs:=_play.movingBalls
			this.NeedRedraw:=true
		}
	}
}

class class_info_colorChallenge extends class_fieldPrototype
{
	__new(type)
	{
		this.type:=type
		this.conn_r:=false
		this.conn_l:=false
		this.conn_u:=false
		this.conn_d:=false
		
		background:=criticalObject()
		this.pictures:=criticalObject()
		this.pictures.background:=background
		
		background.push("Field_empty", "Field_info_ballColorChallenge")
	}
	
	init()
	{
		this.ballColorChallenge:=_play.ballColorChallenge.clone()
	}
	
	actionAlwaysWithoutBall()
	{
		for oneindex, onechallenge in _play.ballColorChallenge
		{
			if (onechallenge != this.ballColorChallenge[oneindex])
			{
				this.ballColorChallenge:=_play.ballColorChallenge.clone()
				this.NeedRedraw:=true
				
				break
			}
			
		}
	}
}

class class_info_rotatorChallenge extends class_fieldPrototype
{
	__new(type)
	{
		this.type:=type
		this.conn_r:=false
		this.conn_l:=false
		this.conn_u:=false
		this.conn_d:=false
		
		background:=criticalObject()
		this.pictures:=criticalObject()
		this.pictures.background:=background
		
		background.push("Field_empty", "Field_info_rotatorColorChallenge")
	}
	
	init()
	{
		this.rotatorColorChallenge:=_play.rotatorColorChallenge.clone()
	}
	
	actionAlwaysWithoutBall()
	{
		for onedir, onechallenge in _play.rotatorColorChallenge
		{
			if (onechallenge != this.rotatorColorChallenge[onedir])
			{
				this.rotatorColorChallenge:=_play.rotatorColorChallenge.clone()
				this.NeedRedraw:=true
				
				break
			}
			
		}
	}
}