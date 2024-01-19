 
' Arkanoid Like.
' Code: 17o2!!
' Contact: Clement CORDE, c1702@yahoo.com

' Credits for the material used here:
'
' Some of the graphics were ripped from the ST version.
' Backgrounds taken from the StrategyWiki online arcade screenshots (http://strategywiki.org/wiki/Arkanoid/Walkthrough).
' This means some of the graphics are probably the property of Taito.
' As there is no profit intended, I hope I won´t get sewed.
'
' Font found on Daniel Guldkrans´s website (http://www.algonet.se/~guld1/freefont.htm), and slightly retouched by me.
'
' All additional graphics by me.
'


' ---------------------------------------------- 2024 -------------------------------------------
' ------------  CONVERSION A FREEBASIC POR JOSEBA EPALZA <JEPALZA> GMAIL PUNTO COM --------------
' -----------------------------------------------------------------------------------------------


#include "includes.bi"


' Variables generales
Dim Shared As SGene gVar
Dim Shared As SExg  gExg


#Include "sprites.bas"
#Include "animspr.bas"
#Include "anims.bas"
#Include "breaker.bas"
#Include "monsters.bas"
#Include "menu.bas"
#Include "dust.bas"
#Include "fire.bas"
#Include "font.bas"
#Include "frame.bas"
#Include "mst.bas"
#Include "preca.bas"
#Include "render.bas"
#Include "sfx.bas"




' Gestionnaire d´évènements.
Function EventHandler(nInGame As u32) As Integer

	Dim As SDL_Event event 
	Static As u32 nLastPhase 

	while (SDL_PollEvent(@event))
	 
		Select Case event.type
		 
		case SDL_KEYDOWN 
			if (gVar.pKeys[SDLK_ESCAPE]) Then return (1) 	' Emergency exit.
			' Gestion de la pause.
			if (nInGame = 1) AndAlso (gVar.pKeys[SDLK_p]<>0) Then 
				if (gBreak.nPhase = e_Game_Pause) Then 
					gBreak.nPhase = nLastPhase 			' On sort de la pause.
					SDL_ShowCursor(SDL_DISABLE) 		' Cache le pointeur de la souris.
					' Replace la souris à l´endroit du joueur.
					SDL_WarpMouse(gBreak.nPlayerPosX, gBreak.nPlayerPosY) 		' => Génère un event.
				Else
					' On passe en pause.
					nLastPhase = gBreak.nPhase 
					gBreak.nPhase = e_Game_Pause 

					' Affichage du texte de pause.
					Dim As String pStrPause = "PAUSE" 
					Dim As u32 i = Font_Print(0, 10, pStrPause, FONT_NoDisp) 	' Pour centrage.
					Font_Print((SCR_Width / 2) - (i / 2), 123, pStrPause, 0) 
					SprDisplayAll() 

					SDL_ShowCursor(SDL_ENABLE) 		' Affiche le pointeur de la souris.
				EndIf
			EndIf

		case SDL_KEYUP 
			'nada

		case SDL_MOUSEMOTION 
			gVar.nMousePosX = event.motion.x 
			gVar.nMousePosY = event.motion.y 

		case SDL_MOUSEBUTTONDOWN 
			Select Case  (event.button.button)
			 
				Case SDL_BUTTON_LEFT 
					gVar.nMouseButtons Or= MOUSE_BtnLeft 

			End Select

		case SDL_QUIT_ 
			Return 1 ' salida total
		
		End Select
	
	Wend
    
	return (0) 
End Function


' Création de la palette :
' On recopie dans la palette générale la partie de palette correspondant au décor + la palette des sprites.
Sub SetPalette( pBkg As SDL_Surface Ptr ,  pSprPal As SDL_Color Ptr , nSprPalIdx As u32)

	Dim As u32 i 
	Dim As SDL_Color Ptr pSrcPal = pBkg->format->palette->colors 

	' Couleurs du décor.
	for i = 0 To nSprPalIdx-1       
		gVar.pColors(i) = pSrcPal[i] 
   Next

	' Couleurs des sprites.
	for i=i To 255      
		gVar.pColors(i) = pSprPal[i - SPR_Palette_Idx] 
   Next

	' Palette logique.
	SDL_SetPalette(gVar.pScreen, SDL_LOGPAL, @gVar.pColors(0), 0, 256) 		' Sur gVar.pScreen car c´est la surface de rendu.

End Sub



' Le Menu (générique).
Function Menu(pFctInit As any Ptr , pFctMain As any Ptr) As u32

	Dim As u32 nMenuVal = MENU_Null 
	Dim llamadaINIT As Sub()=Cast(Any Ptr,pFctInit)
	Dim llamadaMAIN As function() As s32=Cast( Any Ptr,pFctMain)

	SDL_FillRect(gVar.pScreen, NULL, 7) 	' Clear screen.
	RenderFlip(0) 
	Fade(0) 

	gVar.pBackground = gVar.pBkg(0) 		' Décor par défaut.
	gVar.pBkgRect = NULL 					' Par défaut, NULL (toute la surface).

	llamadaINIT() 		' Menu, Init fct. (ojo, llamada con punteros)
	
	' Sets up palette.
	SetPalette(gVar.pBackground, @gVar.pSprColors(0), SPR_Palette_Idx) 

	' Main loop.
	FrameInit() 
	while (nMenuVal = MENU_Null)
	 
		' Gestion des évenements.
		gVar.nMouseButtons = 0 		' Raz mouse buttons.

		if (EventHandler(0) <> 0) Then nMenuVal = MENU_Quit: Exit While

		SDL_BlitSurface(gVar.pBackground, gVar.pBkgRect, gVar.pScreen, NULL) 	' Recopie le décor.
		nMenuVal = llamadaMAIN() ' Menu, Main fct.
		
		SprDisplayAll()

		RenderFlip(1) 		' Wait for frame, Flip.
		Fade(gVar.nFadeVal) 
	
	Wend

	return (nMenuVal) 
End Function

' La boucle de jeu.
Sub Game()

	' Cinématique d´intro.
'todo:...

	SDL_FillRect(gVar.pScreen, NULL, 7) 	' Clear screen.
	RenderFlip(0) 
	Fade(0) 

	' Init.
	ExgBrkInit() 
	
	' Sets up palette (Même palette pour tous les niveaux).
	SetPalette(gVar.pLev(0), @gVar.pSprColors(0), SPR_Palette_Idx) 
	'>> (Mettre le fader ?)
		gVar.nFadeVal = 256 
		Fade(gVar.nFadeVal) ' Remet la palette physique.
	'<<

	' Main loop.
	FrameInit() 
	while gExg.nExitCode = 0
	 
		' Gestion des évenements.
		gVar.nMouseButtons = 0 		' Raz mouse buttons.

		if (EventHandler(1) <> 0) Then Exit While 

		if (gBreak.nPhase <> e_Game_Pause) Then 
			SDL_BlitSurface(gVar.pLevel, NULL, gVar.pScreen, NULL) 		' Copie de l´image de fond.
			Breaker() 
			SprDisplayAll() 
		EndIf
  
		RenderFlip(1) 	' Wait for frame, Flip.
	
   Wend
    
	SDL_ShowCursor(SDL_DISABLE) 		' Cache le pointeur de la souris, au cas ou on quitte pendant la pause.


	' Si jeu terminé, cinématique de fin.
'	if (gExg.nExitCode == e_Game_AllClear) {}
'todo:...


	' High score ?
	if (gExg.nExitCode = e_Game_GameOver) OrElse (gExg.nExitCode = e_Game_AllClear) Then 
		if (Scr_CheckHighSc(gExg.nScore) >= 0) Then 
			' Saisie du nom.
			Menu(@MenuGetName_Init, @MenuGetName_Main) 
			' Affichage de la table des high scores.
			Menu(@MenuHighScores_Init, @MenuHighScores_Main) 
		EndIf
	EndIf
  
End Sub









 '----------------------------- MAIN -----------------------------------
	Dim As u32	nLoop 
	Dim As u32	nMenuVal 
	Dim As u32	i 


	' SDL Init.
	if (SDL_Init(SDL_INIT_VIDEO) < 0) Then 
		print "Unable to init SDL: ";SDL_GetError()
		Sleep:End
	EndIf


	' Video mode init.
	Render_InitVideo() 
	SDL_WM_SetCaption("Arkanoid by 17o2!!", NULL) 	' Nom de la fenêtre.
	gRender.nRenderMode = e_RenderMode_Scale2x 
	Render_SetVideoMode() 

	gVar.pKeys = SDL_GetKeyState(NULL) 		' Init ptr kb.

	' Preca Sinus et Cosinus.
	PrecaSinCos() 

	' Load sprites.
	SprInitEngine() 
	SprLoadBMP(StrPtr("gfx/bricks.bmp"), @gVar.pSprColors(0), SPR_Palette_Idx) 
	SprLoadBMP(StrPtr("gfx/font_small.bmp"), NULL, 0) 

	' Load levels backgound pictures.
	Dim As String pBkgLevFilenames(GFX_NbBkg) = { "gfx/lev1.bmp", "gfx/lev2.bmp", "gfx/lev3.bmp", "gfx/lev4.bmp", "gfx/levdoh.bmp" } 
	
	For i = 0 To GFX_NbBkg-1     
		gVar.pLev(i) = SDL_LoadBMP(pBkgLevFilenames(i))
		if gVar.pLev(i) = NULL Then 
			print "Error cargando BMP (MAIN 1):"; pBkgLevFilenames(i)
			Sleep:end
		EndIf
	Next
	
	gVar.pLevel = gVar.pLev(0) 

	' Load menus backgound pictures.
	Dim As String pBkgMenFilenames(MENU_NbBkg) = { "gfx/bkg1.bmp", "gfx/bkg2.bmp" } 
	for i = 0 To MENU_NbBkg -1      
		gVar.pBkg(i) = SDL_LoadBMP(pBkgMenFilenames(i))
		if gVar.pBkg(i) = NULL Then 
			print "Error cargando BMP (MAIN 2):"; pBkgMenFilenames(i)
			Sleep:End
		EndIf
	Next
	gVar.pBackground = gVar.pBkg(0) 


	' Init sound.
	Sfx_SoundInit() 
	Sfx_LoadWavFiles() 
	Sfx_SoundOn() 	' Starts playback.


	' Menu Init
	MenuInit() 
	
	
	' Lecture de la table des high-scores.
	Scr_Load() 


	SDL_ShowCursor(SDL_DISABLE) 	' Cache le pointeur de la souris.





   ' -------------------------- PRINCIPAL --------------------------

	' Boucle infinie.
	nMenuVal = MENU_Main 'MENU_Game;
	nLoop = 1 
	while (nLoop)
	 
		Select Case  (nMenuVal)
		 
		case MENU_Main  	' Main menu.
			nMenuVal = Menu(@MenuMain_Init, @MenuMain_Main) 

		case MENU_Game  	' Jeu.
			Game() 
			nMenuVal = MENU_Main 

		case MENU_HallOfFame  	' High scores.
			Menu(@MenuHighScores_Init, @MenuHighScores_Main) 
			nMenuVal = MENU_Main 

		case MENU_Quit  	' Sortie.
			nLoop = 0 
		
		End Select
	Wend





   ' ------------------ FIN --------------------

	SDL_ShowCursor(1) 

	Sfx_SoundOff() 	' Stops playback.
	Sfx_FreeWavFiles() 	' Libère les ressources des fx.

	' Libère les ressources des sprites.
	SprRelease() 

	' Free the allocated surfaces.
	for  i = 0 To GFX_NbBkg -1      
		SDL_FreeSurface(gVar.pLev(i)) 
	Next
	for  i = 0 To MENU_NbBkg -1      
		SDL_FreeSurface(gVar.pBkg(i)) 
	Next

	' Libère les ressources de rendu.
	RenderRelease() 




