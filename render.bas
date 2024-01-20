 
'
' Routines d´affichage : 1x / 2x
'



Dim Shared As SRender gRender

' Scaling 2x.
Sub Render_Scale2x( pSDL_Src As SDL_Surface Ptr , pSDL_Dst As SDL_Surface Ptr)

	SDL_LockSurface(pSDL_Src) 
	SDL_LockSurface(pSDL_Dst) 

	Dim As u32	y, x 
	Dim As u8	Ptr pSrc = pSDL_Src->pixels 
	Dim As u8	Ptr pDst = pSDL_Dst->pixels 
	Dim As u16	nClr 

	Dim As u8	Ptr pSrc2 
	Dim As u16	Ptr pDst2a
	Dim As u16	Ptr pDst2b 

	for y = 0 To SCR_Height -1      
		pSrc2  = Cast(u8  Ptr,pSrc) 
		pDst2a = Cast(u16 Ptr,pDst) 
		pDst2b = Cast(u16 Ptr,pDst + pSDL_Dst->pitch)
		for x = 0 To SCR_Width-1       
			nClr = *pSrc2 : pSrc2+=1  
			nClr = nClr Or (nClr Shl 8) 
			*pDst2a = nClr : pDst2a+=1 
			*pDst2b = nClr : pDst2b+=1
		Next
		pSrc += pSDL_Src->pitch 
		pDst += pSDL_Dst->pitch * 2 
	Next

	SDL_UnlockSurface(pSDL_Src) 
	SDL_UnlockSurface(pSDL_Dst) 
End Sub


' Renvoie un ptr sur la surface écran réelle (pour les palettes).
Function Render_GetRealVideoSurfPtr() As SDL_Surface Ptr
	return iif(gRender.nRenderMode = e_RenderMode_Normal , gVar.pScreen , gRender.pScreen2x) 
End Function

type pRenderFct As Sub (pSDL_Src As SDL_Surface ptr, pSDL_Dst As SDL_Surface ptr) 

' Rendu + Flip.
Sub RenderFlip(nSync As u32)
	Dim As pRenderFct	pFctTb(e_RenderMode_MAX-1) = { NULL, @Render_Scale2x } 

	if (pFctTb(gRender.nRenderMode) <> NULL) Then pFctTb(gRender.nRenderMode)(gVar.pScreen, gRender.pScreen2x) 

	if (nSync) Then FrameWait() 
 
	SDL_Flip( Render_GetRealVideoSurfPtr() )
End Sub

' Set video mode.
Function VideoModeSet(nScrWidth As u32 , nScrHeight As u32 , nSDL_Flags As u32) As SDL_Surface Ptr
	Dim As SDL_Surface Ptr pSurf 

	pSurf = SDL_SetVideoMode(nScrWidth, nScrHeight, 8, SDL_SWSURFACE Or nSDL_Flags) 

	if (pSurf = NULL) Then 
		Print "VideoModeSet(): Couldn't set video mode: ";SDL_GetError()
		'exit(1);
	Else
		' Sous Windows, SDL_SetVideoMode génère un event SDL_VIDEOEXPOSE. 
		' Comme on gère F9 dans les events, ça évite le flash rose (0 = rose / 7 = noir).
		SDL_FillRect(pSurf, NULL, 7)
	EndIf
  		
  	' jepalza: para centrar la ventana SDL (en SDL2 existe un comando, pero en SDL1 debemos hacerlo asi)	
  	Dim As HWND hwnd_
	Dim As SDL_SysWMInfo info
	SDL_GetWMInfo(@info)
	hwnd_ = info.Window
  	SetWindowPos(hwnd_,NULL , 1200,10, -1, -1, SWP_NOSIZE) ' SWP_NOSIZE=conservar ancho y alto actuales
  	
	return (pSurf) 
End Function

' Met le mode video qui va bien.
Sub Render_SetVideoMode()

	Select Case  gRender.nRenderMode
	 
	case e_RenderMode_Scale2x ' modo escalado 2x
		gRender.pScreen2x = VideoModeSet(SCR_Width * 2, SCR_Height * 2, 0) 
		gVar.pScreen = gRender.pScreenBuf2 
		if (gRender.pScreen2x <> NULL) Then 
			' ok
			SDL_SetPalette(gRender.pScreen2x, SDL_PHYSPAL Or SDL_LOGPAL, @gVar.pColors(0), 0, 256) 
			SDL_SetPalette(gRender.pScreenBuf2, SDL_LOGPAL, @gVar.pColors(0), 0, 256) 
			Exit Sub 
		EndIf
  
		' Erreur => On repasse en mode Normal et Windowed.
		gRender.nRenderMode = e_RenderMode_Normal 
		gRender.nFullscreenMode = 0 
		' ... et pas de break.
	'Case e_RenderMode_Normal 
		' vacio? 
	Case else 
		' modo normal 320x200
		gVar.pScreen = VideoModeSet(SCR_Width, SCR_Height, 0) 
		gRender.pScreen2x = NULL 
		if (gVar.pScreen = NULL) Then Print "Error VideoModeSet":Sleep:End ' Message d´erreur dans VideoModeSet.
		SDL_SetPalette(gVar.pScreen, SDL_PHYSPAL Or SDL_LOGPAL, @gVar.pColors(0), 0, 256) 

  End Select

End Sub


' Init de la vidéo.
Sub Render_InitVideo()

	gRender.nRenderMode = e_RenderMode_Normal 

	gRender.pScreen2x   = NULL ' En mode 2x, ptr sur la surface écran.
	gRender.pScreenBuf2 = NULL ' Buffer de rendu pour le jeu en mode 2x (à la place de la surface écran réelle).

	' On initialise d´abord un écran en mode e_RenderMode_Normal. 
	' Important, car on fait un CreateRGBSurface à partir de cette surface.
	gVar.pScreen = VideoModeSet(SCR_Width, SCR_Height,0) 
	if (gVar.pScreen = NULL) Then Print "error 1 en 'Render_InitVideo'":Sleep:End 
	' On créé un buffer de la taille de l´écran.
	' => En mode 2x, on switche le ptr pScreen sur cette surface, les rendus du jeu se font donc dedans. 
	' Puis on fait le scale/filtre du buffer vers la vraie surface écran.
	gRender.pScreenBuf2 = SDL_CreateRGBSurface(SDL_SWSURFACE, SCR_Width, SCR_Height, 8, _
						gVar.pScreen->format->Rmask, gVar.pScreen->format->Gmask, gVar.pScreen->format->Bmask, 0) 
	If (gRender.pScreenBuf2 = NULL) Then 
		Print "error 2 en 'Render_InitVideo'":Sleep:End 
	EndIf

End Sub

' Libère les ressources du rendu. (1 fois !).
Sub RenderRelease()
	SDL_FreeSurface(gRender.pScreenBuf2) 
End Sub

