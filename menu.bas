 ' Menus.



#define	MENU_Bkg_Mvt	1

#define	FX_Menu_Move	e_Sfx_MenuClic
#define	FX_Menu_Clic	e_Sfx_BatMagnet

Enum
	MENU_State_FadeIn = 0,
	MENU_State_Input,
	MENU_State_FadeOut
End Enum

#define	FADE_Step	8

#define HISC_Nb	10
#define HISC_NameLg (16+1)
#define HISC_Filename "high.scr"

Type SScore 
	As String*HISC_NameLg pName
	As u16	nRound 
	As u32	nScore 
End Type
Dim Shared As SScore gpHighScores(HISC_Nb) 


#define CURS_Acc &h200

Type SMenuGen 
	As u32	nChoix 
	As s32	nOldMousePosX, nOldMousePosY 		' Ancienne position de la souris.
	As u32	nState 
	As s32	nFadeVal 

	As s16	nCursPos 		' Pour faire bouger le curseur.
	As s16	nCursAccel 

	' As Variables pour saisie du nom.
	As u32	nScIdx 				' Pos dans la chaîne. / Pas remis à 0 !
	As String*HISC_NameLg pScName 	' Nom saisi. / Pas remis à 0 !
	As u8		nRank 
	As u8		nKeyDown 
End Type
Dim Shared As SMenuGen gMenu

'=============================================================================

' Inits de trucs généraux, appelé une fois en début de programme.
Sub MenuInit Cdecl()
	gMenu.nScIdx = 0 		' RAZ entrée du nom pour High Score.
End Sub


' Curseur - Init.
Sub CursorInit()
	gMenu.nCursPos = 0 
	gMenu.nCursAccel = CURS_Acc 
End Sub

' Curseur - Déplacement.
Sub CursorMove()
	gMenu.nCursAccel -= &h20 		' Gravité.
	gMenu.nCursPos += gMenu.nCursAccel 
	if (gMenu.nCursPos < 0) Then CursorInit() 
End Sub

'=============================================================================

Dim Shared As SDL_Color gpCurPal(255) 

' Fade.
Sub Fade(nFadeVal As s32)

	if (nFadeVal < 0) Then return 

	Dim As SDL_Color Ptr pSrc = @gVar.pColors(0) 
	Dim As u32	i, nNbColors 

	nNbColors = 256 
	if (nFadeVal > 255) Then nFadeVal = 255 
	for i = 0 To nNbColors-1       
	 
		gpCurPal(i).r = (pSrc->r * nFadeVal) / 255 
		gpCurPal(i).g = (pSrc->g * nFadeVal) / 255 
		gpCurPal(i).b = (pSrc->b * nFadeVal) / 255 
		pSrc+=1  
	
	Next
	
	SDL_SetPalette(Render_GetRealVideoSurfPtr(), SDL_PHYSPAL, @gpCurPal(0), 0, nNbColors) 		' Pour le fade, c´est bien la palette PHYSIQUE de la surface écran réelle.

End Sub

' Init du fader. Appelé dans les Init de chaque menu.
Sub MenuInitFade()

	' Fader.
	gMenu.nState = MENU_State_FadeIn 
	gMenu.nFadeVal = 0 

	' Replace la souris au milieu de l´écran.
	gMenu.nOldMousePosX = SCR_Width / 2 
	gMenu.nOldMousePosY = SCR_Height / 2 
	SDL_WarpMouse(SCR_Width / 2, SCR_Height / 2) 

End Sub

'=============================================================================

#define	MENU_Main_StartLn	160


Type SMenuItm 
	As u32	 nMenuVal 
	As u32	 nLg 		' Largeur en pixels du texte (pour centrage).
	As String pTxt 
End Type 
Dim Shared As SMenuItm gpMenuItems_Main(2)
With gpMenuItems_Main(0)
	.nMenuVal=MENU_Game
	.nLg=0
	.pTxt="START"
End with
With gpMenuItems_Main(1)
	.nMenuVal=MENU_HallOfFame
	.nLg=0
	.pTxt="HALL OF FAME"
End With
With gpMenuItems_Main(2)
	.nMenuVal=MENU_Quit
	.nLg=0
	.pTxt="QUIT"
End With

' Menu main : Init.
Sub MenuMain_Init Cdecl()

	Dim As u32 i 

	MenuInitFade() 

	' Récupère les longueurs des phrases.
	for i = 0 To NBELEM(gpMenuItems_Main)       
		gpMenuItems_Main(i).nLg = Font_Print(0, 0, gpMenuItems_Main(i).pTxt, FONT_NoDisp) 
	Next

	gMenu.nChoix = 0 

	CursorInit() 

	' Décor.
	gVar.pBackground = gVar.pBkg(0) 
#ifdef MENU_Bkg_Mvt
	gVar.pBkgRect = @gVar.sBkgRect 
	gVar.sBkgRect.w = SCR_Width 
	gVar.sBkgRect.h = SCR_Height 
#endif

End Sub

' Menu main : Main.
Function MenuMain_Main cdecl() As u32

	Dim As u32	nRetVal = MENU_Null 
	Dim As u32	i 
	Dim As s32	nDiff 
	static As u8	nWait = 0 

#ifdef MENU_Bkg_Mvt
	Static As u8	nSinIdx1 = 0 
	' Déplacement du décor (ligne).
	gVar.sBkgRect.x = nSinIdx1 And 31 
	gVar.sBkgRect.y = 0 
	nSinIdx1+=1  
#endif

	' Selon l´état.
	Select Case  (gMenu.nState)
	 
	case MENU_State_FadeIn  
		gMenu.nFadeVal += FADE_Step 
		if (gMenu.nFadeVal > 256) Then 
			gMenu.nState = MENU_State_Input 
			gMenu.nFadeVal = -1 
		EndIf

	case MENU_State_FadeOut  
		gMenu.nFadeVal -= FADE_Step 
		if (gMenu.nFadeVal < 0) Then 
			nWait = 0 
			nRetVal = gpMenuItems_Main(gMenu.nChoix).nMenuVal 
		EndIf

	case MENU_State_Input  
		' Déplacement du curseur.
		if (nWait) Then nWait-=1  
		if (nWait = 0) Then 
			nDiff = gVar.nMousePosY - gMenu.nOldMousePosY 
			if (ABS(nDiff) > 8) Then 
				Dim As u32	nLastChoix = gMenu.nChoix 
				if (nDiff < 0) Then 
					if (gMenu.nChoix > 0) Then gMenu.nChoix-=1    
				Else
					if gMenu.nChoix < NBELEM(gpMenuItems_Main) Then gMenu.nChoix+=1
				EndIf
				if (nLastChoix <> gMenu.nChoix) Then 
					CursorInit() 	' Slt parce que c´est plus joli.
					nWait = 12 
					' Sfx.
					Sfx_PlaySfx(FX_Menu_Move, e_SfxPrio_10) 
				EndIf
			EndIf
		EndIf

		' Clic souris ? => Validation.
		if (gVar.nMouseButtons And MOUSE_BtnLeft) Then 
			gMenu.nFadeVal = 256 
			gMenu.nState = MENU_State_FadeOut 
			' Sfx.
			Sfx_PlaySfx(FX_Menu_Clic, e_SfxPrio_10) 
		EndIf

	End Select

	' Replace la souris au milieu de l´écran.
	SDL_WarpMouse(SCR_Width / 2, SCR_Height / 2) 

	CursorMove() 

	'>>> Affichage.

	' Logo qui bouge.
	Dim As s32	pOfs(7) = { 0, 26, 48, 73, 99, 127, 158, 166 } 
	static As u8 nSin = 0 
	for i = 0 To 7       
		Dim As s32 nMul = 8 
		SprDisplay(e_Spr_Logo8 + i, _
			(SCR_Width / 2) -96 + pOfs(i) + (gVar.pCos[(nSin + (i * nMul)) And &hFF] / 8), _
			90 - (gVar.pSin[(nSin + (i * nMul)) And &hFF] / 16), 220+i) 
	Next
	nSin -= 2 

	' Menu.
	for i = 0 To NBELEM(gpMenuItems_Main)      
		Font_Print((SCR_Width / 2) - (gpMenuItems_Main(i).nLg / 2), MENU_Main_StartLn + (i * 12), gpMenuItems_Main(i).pTxt, 0) 
		' Selecteur.
		if (i = gMenu.nChoix) Then 
			Font_Print((SCR_Width / 2) - (gpMenuItems_Main(i).nLg / 2) - 18+4 - (gMenu.nCursPos Shr 8), MENU_Main_StartLn + (i * 12), ">", 0) 
			Font_Print((SCR_Width / 2) + (gpMenuItems_Main(i).nLg / 2) + 10-4 + (gMenu.nCursPos Shr 8), MENU_Main_StartLn + (i * 12), "<", 0) 
		EndIf
	Next

	gVar.nFadeVal = gMenu.nFadeVal 
	return (nRetVal) 

End Function






'=============================================================================
' Scores - Check si un score entre au Hall of Fame.
' Out : -1, pas dedans / >= 0, rang.
Function Scr_CheckHighSc(nScorePrm As u32) As s32

	Dim As s32	i, nRank 

	nRank = -1 
	for  i = (HISC_Nb - 1) To 0 Step -1      
		if (nScorePrm >= gpHighScores(i).nScore) Then  nRank = i 
	Next
	return (nRank) 

End Function

' Insère un nom dans la table.
Sub Scr_PutNameInTable( pName As string , nRound As u32 , nScore As u32)

	Dim As s32	nRank = Scr_CheckHighSc(nScore) 
	Dim As s32	i 

	if (nRank < 0) Then Exit Sub 		' Ne devrait pas arriver.

	' Décalage de la table.
	for  i = (HISC_Nb - 2) To nRank Step -1      
	 
		gpHighScores(i + 1).pName  = gpHighScores(i).pName 
		gpHighScores(i + 1).nRound = gpHighScores(i).nRound 
		gpHighScores(i + 1).nScore = gpHighScores(i).nScore 
	
   Next
	' Le score à insérer.
	gpHighScores(nRank).pName  = pName
	gpHighScores(nRank).nRound = nRound 
	gpHighScores(nRank).nScore = nScore 

End Sub


' RAZ de la table des high scores.
Sub Scr_RazTable()

	Dim As string pDefault  = "----------------" 
	Dim As u32 i 

	for i = 0 To HISC_Nb -1    
		gpHighScores(i).pName  = pDefault
		gpHighScores(i).nRound = 0 
		gpHighScores(i).nScore = 0 
	Next

End Sub

' Calcule le checksum de la table des scores.
Function Scr_CalcChecksum() As u32

	Dim As u32	i, j 
	Dim As u32	nChk = 0 

	for i = 0 To HISC_Nb -1      
		nChk += gpHighScores(i).nScore 
		nChk += gpHighScores(i).nRound 
		for j = 1 To HISC_NameLg
			nChk += Asc(Mid(gpHighScores(i).pName,j,1)) Shl (8 * ((j-1) And 3))
		Next
	Next
	
	return (nChk) 
End Function

' Lecture du fichier des high scores.
Sub Scr_Load()

	Dim As FILE	Ptr pFile 
	Dim As u32	nChk 

	pFile = fopen(HISC_Filename, "rb")
	if (pFile <> NULL) Then 
		' Le fichier existe, lecture.
		fread(@gpHighScores(0), SizeOf(SScore), HISC_Nb, pFile) 
		fread(@nChk, sizeof(u32), 1, pFile) 
		fclose(pFile) 
		' Checksum ok ?
		if (nChk <> Scr_CalcChecksum()) Then 
			' Wrong checksum, RAZ table.
			Print "Scr_Load: Wrong checksum! Resetting table." 
			Scr_RazTable() 
		EndIf
	Else
		' Le fichier n´existe pas, RAZ table.
		Scr_RazTable()
	EndIf

End Sub

' Sauvegarde du fichier des high scores.
Sub Scr_Save()

	Dim As FILE	Ptr pFile 
	Dim As u32	nChk 

	pFile = fopen(HISC_Filename, "wb")
	if (pFile = NULL) Then 
		Print "Unable to save highscores table"
		Exit sub 
	EndIf
  
	' Sauvegarde des enregistrements.
	fwrite(@gpHighScores(0), sizeof(SScore), HISC_Nb, pFile) 
	' Checksum.
	nChk = Scr_CalcChecksum() 
	fwrite(@nChk, sizeof(u32), 1, pFile) 
	fclose(pFile) 

End Sub
' end high scores
'=============================================================================






Type SBouffonerie1 
	As u32	nWait 
	As s32	nSpdMax 
	As s32	nSpd 
	As s32	nPosX 
End Type
Dim Shared As SBouffonerie1 gpBouf1(HISC_Nb-1) 

Type SBouffonerie2 
	As s32	nAnmNo 
	As u32	nSens 	' 0:Bas / 1:Haut / 2:Droite / 3:Gauche.
	As u32	nWait, nWait2 
	As s32	nSpd 
	As s32	nPosX, nPosY 
End Type 

#define	BOUF2_Nb	8
Dim Shared As SBouffonerie2 gpBouf2(BOUF2_Nb-1) 

' Menu des high-scores : Init.
Sub MenuHighScores_Init()

	Dim As u32	i 

	MenuInitFade() 
	AnmInitEngine() 	' Pour monstres.

	' Décor.
	gVar.pBackground = gVar.pBkg(1) 
#ifdef MENU_Bkg_Mvt
	gVar.pBkgRect   = @gVar.sBkgRect 
	gVar.sBkgRect.w = SCR_Width 
	gVar.sBkgRect.h = SCR_Height 
#endif

	' Init effet des lignes.
	for i = 0 To HISC_Nb -1      
		gpBouf1(i).nSpdMax = -&h800 '(i & 1 ? -1 : 1) * 0x800;
		gpBouf1(i).nSpd  = gpBouf1(i).nSpdMax 
		gpBouf1(i).nPosX = SCR_Width Shl 8 '(i & 1 ? SCR_Width : -SCR_Width) << 8;
		gpBouf1(i).nWait = (HISC_Nb - i) * 8 
	Next

	' Init des monstres (init réelle quand nWait = 0).
	for i = 0 To BOUF2_Nb-1       
		gpBouf2(i).nAnmNo = AnmSet(@gAnm_Mst1(0), -1) 	' Réserve un slot.
		gpBouf2(i).nWait  = (rand() And 63) Or 16 		' Attente mini.
	Next

End Sub

' Menu des high-scores : Main.
#define	MENU_HiSc_Interligne	19
Function MenuHighScores_Main Cdecl() As u32

	Dim As u32	nRetVal = MENU_Null 
	Dim As u32	i 
	Dim As s32  nPosX, nPosY 

#Ifdef MENU_Bkg_Mvt
	static As u8	nSinIdx1 = 0 

	' Déplacement du décor (scroll vertical).
	gVar.sBkgRect.x = 0 
	gVar.sBkgRect.y = nSinIdx1 And &h0F 
	nSinIdx1+=1  
#EndIf



	' Selon l´état.
	Select Case (gMenu.nState)
	 
	case MENU_State_FadeIn  
		gMenu.nFadeVal += FADE_Step 
		if (gMenu.nFadeVal > 256) Then 
			gMenu.nState = MENU_State_Input 
			gMenu.nFadeVal = -1 
		EndIf

	case MENU_State_FadeOut  
		gMenu.nFadeVal -= FADE_Step 
		if (gMenu.nFadeVal < 0) Then 
			nRetVal = MENU_Main 	' Sortie.
		EndIf

	case MENU_State_Input  
		' Clic souris ? => Validation.
		if (gVar.nMouseButtons And MOUSE_BtnLeft) Then 
			gMenu.nFadeVal = 256 
			gMenu.nState = MENU_State_FadeOut 
			' Sfx.
			Sfx_PlaySfx(FX_Menu_Clic, e_SfxPrio_10) 
		EndIf

	End Select



	' Replace la souris au milieu de l´écran.
	SDL_WarpMouse(SCR_Width / 2, SCR_Height / 2) 



	if (gMenu.nState <> MENU_State_FadeIn) Then 
		' Effet des lignes.
		for i = 0 To HISC_Nb -1      
			if gpBouf1(i).nWait = 0 Then 
				if gpBouf1(i).nSpdMax<>0 Then 
					Dim As s32 nLastPosX = gpBouf1(i).nPosX 
					gpBouf1(i).nPosX += gpBouf1(i).nSpd 
				   If (ABS(gpBouf1(i).nSpdMax) = &h200) AndAlso ((gpBouf1(i).nPosX Shr 8) <> 0) Then
						' Stop.
						gpBouf1(i).nSpdMax = 0 
					Else
						If SGN(gpBouf1(i).nPosX) <> SGN(nLastPosX) Then 
							' Retourne la vitesse max.
							gpBouf1(i).nSpdMax = -gpBouf1(i).nSpdMax / 2
						EndIf
						if ( (SGN(gpBouf1(i).nSpd) <> SGN(gpBouf1(i).nSpdMax)) OrElse _
							 ((SGN(gpBouf1(i).nSpd)  = SGN(gpBouf1(i).nSpdMax)) AndAlso _
							  (Abs(gpBouf1(i).nSpd)  < ABS(gpBouf1(i).nSpdMax))) ) Then
									 gpBouf1(i).nSpd + = SGN(gpBouf1(i).nSpdMax) Shl 6 
						EndIf
					EndIf
				EndIf
			Else
				gpBouf1(i).nWait-=1 
			EndIf
		Next

		' Les monstres.
		for i = 0 To HISC_Nb-1       	' Slt pour tester la fin de l´effet de lignes. 
			if ( (gpBouf1(i).nWait=0) AndAlso (gpBouf1(i).nSpdMax=0) )=0 Then Exit For 
		Next
		if (i = HISC_Nb) Then  ' Effet des lignes fini ?
			for i = 0 To BOUF2_Nb-1       
				if (gpBouf2(i).nWait = 0) Then  
					' Déplacement.
					Select Case  (gpBouf2(i).nSens)
					 
					case 0 	' 0:Bas.
						gpBouf2(i).nPosY += gpBouf2(i).nSpd 
						if (gpBouf2(i).nPosY Shr 8 >= SCR_Height +16) Then gpBouf2(i).nWait = (rand() And 63) Or 16 
						 
					case 1 	' 1:Haut.
						gpBouf2(i).nPosY -= gpBouf2(i).nSpd 
						if (gpBouf2(i).nPosY Shr 8 <= -16) Then gpBouf2(i).nWait = (rand() And 63) Or 16 
						 
					case 2 	' 2:Droite.
						gpBouf2(i).nPosX += gpBouf2(i).nSpd 
						if (gpBouf2(i).nPosX Shr 8 >= SCR_Width +16) Then gpBouf2(i).nWait = (rand() And 63) Or 16 
						 
					case 3 	' 3:Gauche.
						gpBouf2(i).nPosX -= gpBouf2(i).nSpd 
						if (gpBouf2(i).nPosX Shr 8 <= -16) Then gpBouf2(i).nWait = (rand() And 63) Or 16 

					End Select
					
					SprDisplay(AnmGetImage(gpBouf2(i).nAnmNo), gpBouf2(i).nPosX Shr 8, gpBouf2(i).nPosY Shr 8, 50+i) 
					' Changement de direction ?
					 gpBouf2(i).nWait2-=1
					if gpBouf2(i).nWait2 = 0 Then 
						gpBouf2(i).nSens = IIf(gpBouf2(i).nSens And 2 , 0 , 2) 
						gpBouf2(i).nSens += (rand() And 1) 
						'gpBouf2[i].nSens &= 3;
						gpBouf2(i).nWait2 = (rand() And 63) Or 64 
					EndIf
					
				Else

					gpBouf2(i).nWait-=1 
					if (gpBouf2(i).nWait = 0) Then 
						' Init.
						Dim As u32 Ptr pAnm(3) = {@gAnm_Mst1(0), @gAnm_Mst2(0), @gAnm_Mst3(0), @gAnm_Mst4(0)} 

						AnmSet(pAnm(rand() And 3), gpBouf2(i).nAnmNo) 	' Anim.
						gpBouf2(i).nSens = rand() And 3 
						Select Case  (gpBouf2(i).nSens)
						 
						case 0 	' 0:Bas.
							gpBouf2(i).nPosX = (rand() mod (SCR_Width - 32)) + 16 
							gpBouf2(i).nPosY = -16 

						case 1 	' 1:Haut.
							gpBouf2(i).nPosX = (rand() Mod (SCR_Width - 32)) + 16 
							gpBouf2(i).nPosY = SCR_Height +16 

						case 2 	' 2:Droite.
							gpBouf2(i).nPosY = (rand() Mod (SCR_Height - 32)) + 16 
							gpBouf2(i).nPosX = -16 

						case 3 	' 3:Gauche.
							gpBouf2(i).nPosY = (rand() Mod (SCR_Height - 32)) + 16 
							gpBouf2(i).nPosX = SCR_Width +16 
						
	               End Select
	
						gpBouf2(i).nPosX Shl = 8 
						gpBouf2(i).nPosY Shl = 8 
						gpBouf2(i).nSpd = &h200 
						gpBouf2(i).nWait2 = (rand() And 63) Or 64 
					
					EndIf	
				EndIf
	      Next
      EndIf
   EndIf
  

	'>>> Affichage.

	' Titre.
	Dim As string	pTitle = "- HALL OF FAME -" 
	Dim As u32	nLg = Font_Print(0, 8, pTitle, FONT_NoDisp) 
	Font_Print((SCR_Width - nLg) / 2, 24, pTitle, 0) 

	' Affichage des lignes.
	nPosY = 48 
	for i = 0 To HISC_Nb -1       
		Dim As string	pStrs '= "00000000"
		Dim As s32	nOfs 

		nPosX = 8+16 + (gpBouf1(i).nPosX Shr 8) 		' L´effet.

		' Pos.
		pStrs="00"
		MyItoA(i + 1, pStrs) 
		Font_Print(nPosX, nPosY + (i * MENU_HiSc_Interligne), pStrs, 0) 
		' Nom.
		Font_Print(nPosX + (8 * 3) + 4+4 , nPosY + (i * MENU_HiSc_Interligne), gpHighScores(i).pName, 0) 
		' Round.
		nOfs = 0 
		if (gpHighScores(i).nRound + 1 > LEVEL_Max) Then 
			strcpy(pStrs, "ALL") 
			nOfs = -4 
		Else
			pStrs="00" 
			MyItoA(gpHighScores(i).nRound + 1, pStrs) 
		EndIf
  
		Font_Print(nPosX + (8 * 20) + 8+8 + nOfs, nPosY + (i * MENU_HiSc_Interligne), pStrs, 0) 
		' Score.
		pStrs="00000000"
		MyItoA(gpHighScores(i).nScore, pStrs)
		Font_Print(nPosX + (8 * 23) + 12+12, nPosY + (i * MENU_HiSc_Interligne), pStrs, 0) 
	Next

	gVar.nFadeVal = gMenu.nFadeVal 
	return (nRetVal) 

End Function

'=============================================================================

Dim Shared As SMenuItm gpMenuItems_GetName(2)
With gpMenuItems_GetName(0)
	.nMenuVal=0
	.nLg=0
	.pTxt="CONGRATULATIONS!"
End with
With gpMenuItems_GetName(1)
	.nMenuVal=0
	.nLg=0
	.pTxt="YOU RANKED #0@"
End With
With gpMenuItems_GetName(2)
	.nMenuVal=0
	.nLg=0
	.pTxt="ENTER YOUR NAME:"
End With


' Init.
Sub MenuGetName_Init Cdecl()

	Dim As u32	i 

	MenuInitFade() 

	' Rank atteint.
	gMenu.nRank = Scr_CheckHighSc(gExg.nScore) 
	' Calcul de la longueur des chaînes.
	for i = 0 To NBELEM(gpMenuItems_GetName)       
		gpMenuItems_GetName(i).nLg = Font_Print(0, 8, gpMenuItems_GetName(i).pTxt, FONT_NoDisp) 
	Next
	'
	gMenu.nKeyDown = 0 

End Sub

' Saisie du nom quand high-score.
Function MenuGetName_Main Cdecl() As u32

	Dim As u32	nRet = MENU_Null 
	Dim As u32	i 
	static As u32	nCligno = 0 

	' Selon l´état.
	Select Case  (gMenu.nState)
	 
	case MENU_State_FadeIn  
		gMenu.nFadeVal += FADE_Step 
		if (gMenu.nFadeVal > 256) Then 
			gMenu.nState = MENU_State_Input 
			gMenu.nFadeVal = -1 
		EndIf

	case MENU_State_FadeOut  
		gMenu.nFadeVal -= FADE_Step 
		if (gMenu.nFadeVal < 0) Then 
			' Si pas de nom, mettre John Doe.
			Dim As string	pDefName = "JOHN DOE" 
			if (gMenu.nScIdx = 0) Then 
				gMenu.pScName = pDefName
				gMenu.nScIdx  = Len(pDefName) 
			EndIf
  
			' Rajoute le nom dans les High-scores.
			Scr_PutNameInTable(gMenu.pScName, gExg.nLevel, gExg.nScore) 
			Scr_Save() 				' Sauvegarde du fichier des scores.

			nRet = MENU_Main 		' Sortie.
		EndIf

	case MENU_State_Input  
		' Gestion du clavier.
		if (gVar.pKeys[SDLK_RETURN]) Then 
			gMenu.nState = MENU_State_FadeOut 
			gMenu.nFadeVal = 256 
			' Sfx.
			Sfx_PlaySfx(FX_Menu_Clic, e_SfxPrio_10) 
		EndIf
  
		' On regarde quelle touche est enfoncée.
		Dim As u32 nChr = 0 

		if (gVar.pKeys[SDLK_SPACE]) Then nChr = Asc(" ") 
		for  i = SDLK_a To  SDLK_z       
			if (gVar.pKeys[i]) Then 
				nChr = i - SDLK_a + asc("A")
			EndIf
		Next
		
		for  i = SDLK_0 To SDLK_9       
			if (gVar.pKeys[i]) Then 
				nChr = i - SDLK_0 + Asc("0") 
			EndIf
		Next
		
		if (gVar.pKeys[SDLK_BACKSPACE]) Then 
			nChr = SDLK_BACKSPACE 
		EndIf
  
		' Pseudo trigger.
		if (gMenu.nKeyDown = 0 AndAlso nChr) Then 
			if (nChr = SDLK_BACKSPACE) Then
				if (gMenu.nScIdx) Then gMenu.nScIdx-=1:mid(gMenu.pScName,gMenu.nScIdx,1) = " "
			ElseIf  (gMenu.nScIdx < HISC_NameLg - 1) Then 'strlen(gMenu.pScName))
				Mid(gMenu.pScName,gMenu.nScIdx,1) = Chr(nChr) 
				gMenu.nScIdx+=1
				Mid(gMenu.pScName,gMenu.nScIdx,1) = " " 
			EndIf
  
			gMenu.nKeyDown = 1 
			' Sfx.
			Sfx_PlaySfx(FX_Menu_Move, e_SfxPrio_10) 
		 
		ElseIf  (gMenu.nKeyDown = 1 AndAlso nChr = 0) Then 
			gMenu.nKeyDown = 0 		' Release.
		EndIf
	
   End Select



	' Replace la souris au milieu de l´écran.
	SDL_WarpMouse(SCR_Width / 2, SCR_Height / 2) 

	' Affichage.

	' On rajoute le rank dans sa ligne.
	Dim As string pRank 
	pRank=gpMenuItems_GetName(1).pTxt
	Dim As string pPtr = "@"
	if (pPtr <> "") Then 
		MyItoA(gMenu.nRank + 1, Left(pPtr,Len(pPtr)-1)) 
	EndIf
  

	' Lignes.
	for  i = 0 To NBELEM(gpMenuItems_GetName)      
		Font_Print((SCR_Width - gpMenuItems_GetName(i).nLg) / 2, 80 + (i*32), iif(i = 1 , pRank , gpMenuItems_GetName(i).pTxt), 0) 
	Next
	' Nom en cours.
	i = Font_Print(0, 0, gMenu.pScName, FONT_NoDisp) 
	Font_Print((SCR_Width - i) / 2, 80+64+16, gMenu.pScName, 0) 
	' Curseur au bout du nom.

	nCligno+=1
	if (nCligno And 8) Then 
		Font_Print(((SCR_Width - i) / 2) + i, 80+64+16, "_", 0) 
	EndIf
  

	gVar.nFadeVal = gMenu.nFadeVal 
	return (nRet) 

End Function




