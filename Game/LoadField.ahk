loadField(levelset, levelID)
{
	filepath=%a_scriptdir%\levels\%levelset%.ini
	allkeys:=Object()
	for onekey, onevalue in _field
	{
		allkeys.push(onekey)
	}
	for oneindex, onekey in allkeys
	{
		_field.delete(onekey)
	}
	allkeys:=Object()
	for onekey, onevalue in _allFields
	{
		allkeys.push(onekey)
	}
	for oneindex, onekey in allkeys
	{
		_allFields.delete(onekey)
	}
	
	
	;read file content
	_field.levelset:=levelset
	_field.levelID:=levelID
	IniRead,temp,%filepath%,%levelID%,name, % levelID
	_field.name:=temp
	IniRead,temp,%filepath%,%levelID%,ballEntryPoint,r
	_field.ballEntryPoint:=temp
	IniRead,temp,%filepath%,%levelID%,ballcount,0
	_field.ballcount:=temp
	IniRead,temp,%filepath%,%levelID%,ballcolorCount, 4
	_field.ballcolorCount:=temp
	
	IniRead,temp,%filepath%,%levelID%,timeForGame, 1000
	if (not temp)
	{
		_field.timeForGame:="Forever"
		_field.timeForGame_iterations:="Forever"
	}
	else
	{
		_field.timeForGame:=temp
		_field.timeForGame_iterations:=round(_field.timeForGame * 1000 / _share.IterationTimer)
	}
	IniRead,temp,%filepath%,%levelID%,timeForBall, 50
	if (not temp)
	{
		_field.timeForBall:="forever"
		_field.timeForBall_iterations:="forever"
	}
	else
	{
		_field.timeForBall:=temp
		_field.timeForBall_iterations:=round(_field.timeForBall * 1000 / _share.IterationTimer)
	}
	
	IniRead,temp,%filepath%,%levelID%,rotatorColorChallengeRenewTime, 0
	if (not temp)
	{
		_field.rotatorColorChallengeRenewTime:="forever"
		_field.rotatorColorChallengeRenewTime_iterations:="forever"
	}
	else
	{
		_field.rotatorColorChallengeRenewTime:=temp
		_field.rotatorColorChallengeRenewTime_iterations:=round(_field.rotatorColorChallengeRenewTime * 1000 / _share.IterationTimer)
	}
	IniRead,temp,%filepath%,%levelID%,maxMovingBalls, 4
	_field.maxMovingBalls:=temp
	IniRead,sizex,%filepath%,%levelID%,sizex
	_field.ColSizex:=sizex
	IniRead,sizey,%filepath%,%levelID%,sizey
	_field.ColSizey:=sizey
	IniRead,temp,%filepath%,%levelID%,ballcolorChallenge, %A_Space%
	if temp
	{
		_field.ballcolorChallenge:=CriticalObject()
		loop,parse,temp,`,
		{
			_field.ballcolorChallenge.push(A_LoopField)
		}
	}
	IniRead,temp,%filepath%,%levelID%,rotatorcolorChallenge, %A_Space%
	if temp
	{
		_field.rotatorColorChallengeEnabled:=true
		
	}
	IniRead,temp,%filepath%,%levelID%,TimeForPassingAField, 0.7
	_field.TimeForPassingAField:=temp
	
	;some calculation
	_field.LogicSizeField:=round(_field.TimeForPassingAField*1000/_share.IterationTimer)
	_field.LogicSizeBall:=11/35*_field.LogicSizeField
	
	_field.LogicHeightBallDrop:=_field.LogicSizeField*0.5
	
	_Field.x:=0
	_Field.y:=0
	_Field.w:=_field.LogicSizeField*_field.ColSizex
	_Field.h:=_field.LogicHeightBallDrop + _field.LogicSizeField*_field.ColSizeY
	
	_field.LogicYBallDrop:=_Field.y
	
	_field.StartElementsY:=_field.LogicYBallDrop + _field.LogicHeightBallDrop
	_field.StartElementsX:=0
	
	
	;Generate field
	_field.elements:=CriticalObject()
	_field.elements[0]:=CriticalObject()
	loop %sizey%
	{
		rowindex:=a_index
		_field.elements[rowindex]:=CriticalObject()
	}
	
	;add balldrop fields
	loop %sizex%
	{
		rowindex:=0
		colindex:=a_index
		_field.elements[rowindex][colindex]:=new class_ballDrop("d")
		_field.elements[rowindex][colindex].ColX:=colindex
		_field.elements[rowindex][colindex].ColY:=rowindex
		_field.elements[rowindex][colindex].X:=_field.StartElementsX + _field.LogicSizeField * (colindex-1)
		_field.elements[rowindex][colindex].Y:=_field.LogicYBallDrop
		_field.elements[rowindex][colindex].W:=_field.LogicSizeField
		_field.elements[rowindex][colindex].H:=_field.LogicHeightBallDrop
		_field.elements[rowindex][colindex].ID:=rowindex "_" colindex
		_allFields[_field.elements[rowindex][colindex].ID]:=_field.elements[rowindex][colindex]
		
	}
	
	;add remaining fields
	loop %sizey%
	{
		
		rowindex:=a_index
		IniRead,row%rowindex%,%filepath%,%levelID%,row%rowindex%
		loop,parse,row%rowindex%,`,,%a_space%%a_tab%
		{
			colindex:=a_index
			if (A_LoopField="r")
			{
				_field.elements[rowindex][colindex]:=new class_rotator(A_LoopField)
			}
			else if (A_LoopField="e" or A_LoopField="")
			{
				_field.elements[rowindex][colindex]:=new class_empty(A_LoopField)
			}
			else if (substr(A_LoopField,1,1)="p")
			{
				_field.elements[rowindex][colindex]:=new class_pass(A_LoopField)
			}
			else if (substr(A_LoopField,1,1)="t")
			{
				_field.elements[rowindex][colindex]:=new class_teleporter(A_LoopField)
			}
			else if (substr(A_LoopField,1,1)="b")
			{
				_field.elements[rowindex][colindex]:=new class_blocker(A_LoopField)
			}
			else if (substr(A_LoopField,1,1)="c")
			{
				_field.elements[rowindex][colindex]:=new class_paint(A_LoopField)
			}
			else if (substr(A_LoopField,1,1)="a")
			{
				_field.elements[rowindex][colindex]:=new class_arrow(A_LoopField)
			}
			else if (substr(A_LoopField,1,1)="i")
			{
				if (substr(a_loopfield,2,1)="c")
				{
					_field.elements[rowindex][colindex]:=new class_info_nextBall(A_LoopField)
					_field.info_NextBall:=_field.elements[rowindex][colindex]
				}
				else if (substr(a_loopfield,2,1)="t")
				{
					_field.elements[rowindex][colindex]:=new class_info_TimeLeft(A_LoopField)
					_field.info_TimeLeft:=_field.elements[rowindex][colindex]
				}
				else if (substr(a_loopfield,2,1)="m")
				{
					_field.elements[rowindex][colindex]:=new class_info_movableBalls(A_LoopField)
					_field.info_MovableBalls:=_field.elements[rowindex][colindex]
				}
				else if (substr(a_loopfield,2,1)="l")
				{
					_field.elements[rowindex][colindex]:=new class_info_colorChallenge(A_LoopField)
					_field.info_colorChallenge:=_field.elements[rowindex][colindex]
				}
				else if (substr(a_loopfield,2,1)="r")
				{
					_field.elements[rowindex][colindex]:=new class_info_rotatorChallenge(A_LoopField)
					_field.info_rotatorChallenge:=_field.elements[rowindex][colindex]
				}
				else 
				{
					MsgBox Error. Unknown info field type: %a_loopfield%
				 return -1
				}
			}
			else
			{
				MsgBox Error. Unknown field type: %a_loopfield%
				return -1
			}
			_field.elements[rowindex][colindex].type:=A_LoopField
			_field.elements[rowindex][colindex].ID:=rowindex "_" colindex
			_field.elements[rowindex][colindex].ColX:=colindex
			_field.elements[rowindex][colindex].ColY:=rowindex
			_field.elements[rowindex][colindex].X:=_field.StartElementsX+_field.LogicSizeField*(colindex-1)
			_field.elements[rowindex][colindex].Y:=_field.StartElementsY+_field.LogicSizeField*(rowindex-1)
			_field.elements[rowindex][colindex].W:=_field.LogicSizeField
			_field.elements[rowindex][colindex].H:=_field.LogicSizeField
			_field.elements[rowindex][colindex].mx:=_field.elements[rowindex][colindex].X + _field.elements[rowindex][colindex].W*0.5
			_field.elements[rowindex][colindex].my:=_field.elements[rowindex][colindex].Y + _field.elements[rowindex][colindex].H*0.5
			_allFields[_field.elements[rowindex][colindex].ID]:=(_field.elements[rowindex][colindex])
		}
	}
	
	
	
	
	;do some field diagnostics
	
	;find neighbors
	for oneRowIndex, onelementrow in _field.elements
	{
		for oneColIndex, onelement in onelementrow
		{
			if (oneRowIndex=0)
			{
				onelement.neighbor_u:=""
			}
			else
			{
				onelement.neighbor_u:=_field.elements[oneRowIndex-1][oneColIndex].id
			}
			if (oneRowIndex = sizeY)
			{
				onelement.neighbor_d:=""
			}
			else
			{
				onelement.neighbor_d:=_field.elements[oneRowIndex+1][oneColIndex].id
			}
			if (oneColIndex = 1)
			{
				onelement.neighbor_l:=""
			}
			else
			{
				onelement.neighbor_l:=_field.elements[oneRowIndex][oneColIndex-1].id
			}
			if (oneColIndex = sizeX)
			{
				onelement.neighbor_r:=""
			}
			else
			{
				onelement.neighbor_r:=_field.elements[oneRowIndex][oneColIndex+1].id
			}
			
		}
	}
	
	for onefieldindex, onefield in _allFields
	{
		if (onefield.type="r")
		{
			;~ if (_allFields[onefield.neighbor_u].type = 
		}
		onefield.getpictures()
	}
}

