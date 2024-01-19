


#define FPS_Default 1000 / 70
Dim Shared As u32 gnTimer1 

' Init timers.
Sub FrameInit()
	gnTimer1 = SDL_GetTicks() 
End Sub

' Attente de la frame.
Sub FrameWait()

	Dim As u32	gnTimer2 
	' S´assurer qu´on ne va pas trop vite...
	while (1)
		gnTimer2 = SDL_GetTicks() - gnTimer1 
		if (gnTimer2 >= FPS_Default) Then Exit While 
		SDL_Delay(3) 		' A revoir, granularité de 10 ms...
	Wend
    
	gnTimer1 = SDL_GetTicks() 
End Sub




