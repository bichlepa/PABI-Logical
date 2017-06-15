sound()
{
	entercriticalsection(_sound_section)
	if (_sound.toplay.haskey(1))
	{
		singlesound:=_sound.toplay[1]
		_sound.toplay.removeat(1)
		leavecriticalsection(_sound_section)
		playOneSound(singlesound)
	}
	else
	{
		leavecriticalsection(_sound_section)
	}
}

playOneSound(soundname)
{
	SoundPlay,Sounds\%soundname%.wav,wait
}

playBackgroundMusic(soundname)
{
	if (soundname = "")
	{
		soundplay Sounds\Background Music\nonexistentMusicFileToStopMusic
	}
	else
	{
		soundpath=Sounds\Background Music\%soundname%
		Loop
			soundplay %soundpath%,wait
	}
}