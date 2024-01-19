 

Type SSfxGene 
	As u8	nInit 		' Son initialisé (1) ou pas (0).
	As SDL_AudioSpec	sAudioSpec 
   As SDL_AudioCVT	pCvt(e_Sfx_LAST) 
End Type
Dim Shared As SSfxGene gSfx

#define SFX_MAX_SOUNDS	2
Type SSample
	As u8	Ptr pData 
	As u32	 nDPos 
	As u32	 nDLen 
	As u8		 nPrio 	' Priorité du son en cours.
End Type
Dim Shared As SSample gpSounds(SFX_MAX_SOUNDS) 

' Mixer, appelé par SDL.
' Callback segun "SDL_AudioCallback(void*  userdata, Uint8* stream, int Len)"
Sub Sfx_MixAudio cdecl(unused As any Ptr , stream As u8 Ptr , lens As Integer)

    Dim As u32	i 
    Dim As u32	amount 

    for i = 0 To SFX_MAX_SOUNDS -1      
        amount = (gpSounds(i).nDLen - gpSounds(i).nDPos) 
        if (amount > lens) Then amount = lens 
  
        SDL_MixAudio(stream, @gpSounds(i).pData[gpSounds(i).nDPos], amount, SDL_MIX_MAXVOLUME) 
        gpSounds(i).nDPos += amount 
    Next
End Sub

' Nettoyage des canaux.
Sub Sfx_ClearChannels()

	Dim As u32	i 

    for i = 0 To SFX_MAX_SOUNDS-1       
		gpSounds(i).nDPos = 0 
		gpSounds(i).nDLen = 0 
    Next

End Sub


' Sound, initialisation. A appeler 1 fois.
Sub Sfx_SoundInit()

	gSfx.nInit = 0 

	' Set 16-bit stereo audio at 22Khz.
	gSfx.sAudioSpec.freq = 22050 
	gSfx.sAudioSpec.format = AUDIO_S16 
	gSfx.sAudioSpec.channels = 2 
	gSfx.sAudioSpec.samples = 512         ' A good value for games.
	gSfx.sAudioSpec.callback = Cast(Any ptr,@Sfx_MixAudio) 
	gSfx.sAudioSpec.userdata = NULL 

	' Open the audio device and start playing sound!
	if (SDL_OpenAudio(@gSfx.sAudioSpec, NULL) < 0) Then 
		Print "Problemas al iniciar el Audio: "; SDL_GetError() 
		Print "Funcionando sin sonido"
		Exit Sub 
	EndIf

	gSfx.nInit = 1 		' Ok.

	Sfx_ClearChannels() 	' Nettoyage des structures.

End Sub

' Sound on.
Sub Sfx_SoundOn()

	if gSfx.nInit=0 Then Exit Sub 
	SDL_PauseAudio(0) 

End Sub

' Sound off.
Sub Sfx_SoundOff()

	if gSfx.nInit=0 Then Exit Sub 
	SDL_CloseAudio() 

End Sub


' Chargement de tous les fichiers WAV.
Sub Sfx_LoadWavFiles()

	Dim As u32 i 

   Dim As SDL_AudioSpec sWave 
   Dim As u8 Ptr pData 
   Dim As u32 nDLen 

	Dim As string pSfxFilenames(e_Sfx_LAST-1) = { _
		"sfx/_pill_bonus.wav", "sfx/_pill_malus.wav", "sfx/_shot.wav", "sfx/_door_through.wav", _
		"sfx/_menu_click.wav", "sfx/_brick_bounce.wav", "sfx/_ball_bounce.wav", "sfx/_explosion1.wav", _
		"sfx/_explosion2.wav", "sfx/_brick_dissolve.wav", "sfx/_extra_life.wav", "sfx/_bat_ping.wav", _
		"sfx/_bat_magnet.wav" _
	} 

	if gSfx.nInit=0 Then Exit Sub 

	for  i = 0 To  e_Sfx_LAST -1  
		' Load the sound file and convert it to 16-bit stereo at 22kHz
		if (SDL_LoadWAV(pSfxFilenames(i), @sWave, @pData, @nDLen) = NULL) Then 
			Print "Couldn't load "; pSfxFilenames(i)
			Sleep:End
		EndIf
  
		SDL_BuildAudioCVT(@gSfx.pCvt(i), sWave.format, sWave.channels, sWave.freq,_
			gSfx.sAudioSpec.format, gSfx.sAudioSpec.channels, gSfx.sAudioSpec.freq) 

		gSfx.pCvt(i).buf = Cast (u8 Ptr,Callocate(nDLen * gSfx.pCvt(i).len_mult)) 
		memcpy(gSfx.pCvt(i).buf, pData, nDLen) 
		gSfx.pCvt(i).len = nDLen 
		SDL_ConvertAudio(@gSfx.pCvt(i)) 
		SDL_FreeWAV(pData) 

	Next

End Sub

' Libère les ressources occupées par les fichiers WAV.
Sub Sfx_FreeWavFiles()

	Dim As u32	i 

	if gSfx.nInit=0 Then Exit sub 

	for i = 0 To e_Sfx_LAST -1      
		Delete (gSfx.pCvt(i).buf) 
	Next

End Sub


' Joue un son.
' Le minimum :
' On commence par chercher un canal vide.
' Si il n´y en a pas, on note celui qui à la priorité la plus faible.
' Si plusieurs ont la même priorité, on note celui qui est le plus proche de la fin.
' Enfin, si la prio du son à jouer est ok, on le joue dans le canal noté.
Sub Sfx_PlaySfx(nSfxNo As u32 , nSfxPrio As u32)

	Dim As u32	index 

	Dim As u8	nPrioMinVal = 255 
	Dim As u32	nPrioMinPos = 0 
	Dim As u32	nPrioMinDiff = -1 

	if (nSfxNo >= e_Sfx_LAST) Then Exit Sub 	' Sécurité.

    ' Look for an empty (or finished) sound slot.
    for index = 0 To SFX_MAX_SOUNDS  -1     
        if (gpSounds(index).nDPos = gpSounds(index).nDLen) Then  Exit For
  
        if (gpSounds(index).nPrio < nPrioMinVal) Then 
			nPrioMinVal = gpSounds(index).nPrio 
			nPrioMinPos = index 
        	nPrioMinDiff = gpSounds(index).nDLen - gpSounds(index).nDPos 
        ElseIf  (gpSounds(index).nPrio = nPrioMinVal) Then
				if (gpSounds(index).nDLen - gpSounds(index).nDPos < nPrioMinDiff) Then 
					'nPrioMinVal = sounds[index].nPrio;
					nPrioMinPos = index 
					nPrioMinDiff = gpSounds(index).nDLen - gpSounds(index).nDPos 
				EndIf
        EndIf
     Next

	' On a trouvé un emplacement libre ?
    if (index = SFX_MAX_SOUNDS) Then 
    	' Non, la prio demandée est > ou == à la prio mini en cours ?
		if (nSfxPrio < nPrioMinVal) Then Exit Sub 
		index = nPrioMinPos 
    EndIf
  
    ' Put the sound data in the slot (it starts playing immediately).
    SDL_LockAudio() 
    gpSounds(index).pData = gSfx.pCvt(nSfxNo).buf 
    gpSounds(index).nDLen = gSfx.pCvt(nSfxNo).len_cvt 
    gpSounds(index).nDPos = 0 
    gpSounds(index).nPrio = nSfxPrio 
    SDL_UnlockAudio() 

End Sub


