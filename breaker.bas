 


' Non géré:
' * Espace entre briques indestructible < taille maxi de la balle.
'	Si la balle grossit alors qu´elle est entre, ça pose un pb.
'	=> Graphiquement, ça ne peut pas marcher. => Placer les briques indestructibles en fonction.

'>> reste à faire
'todo: lancer la balle au bout de 5 secondes en début de vie.
'todo: time out après x minutes => les briques indestructibles se transforment en briques cassables.
' (avec un effet d´apparition en diagonale, du haut gauche vers le bas droite)

'todo: les "for (i = 0; i < BALL_MAX_NB; i++)" sont optimisables avec une sortie sur gBreak.nBallsNb;
'<< reste à faire



'=============================================================================

#include "levels.bi"

Declare Sub BallChangeSize(pBall as SBall ptr, nSize As u32) 
Declare Sub BallInit(pBall As SBall Ptr, nPosX As s32, nPosY As s32, nSize As u32, nFlags As u32, nSpeed As s32, nAngle As u8) 

'=============================================================================

' Bonus : Active l´aimant.
Sub BreakerBonusSetAimant()

	if ((gBreak.nPlayerFlags And PLAYER_Flg_Aimant) = 0) Then 
		gBreak.nPlayerFlags Or= PLAYER_Flg_Aimant 
		gBreak.nPlayerAnmBonusM = AnmSet(@gAnm_RaqAimant(0), gBreak.nPlayerAnmBonusM) 
	EndIf
  
End Sub

' Bonus : Active la mitrailleuse.
Sub BreakerBonusSetMitrailleuse()

	if ((gBreak.nPlayerFlags And PLAYER_Flg_Mitrailleuse) = 0) Then 
		gBreak.nPlayerFlags   Or= PLAYER_Flg_Mitrailleuse 
		gBreak.nPlayerAnmBonusD = AnmSet(@gAnm_RaqMitDRepos(0), gBreak.nPlayerAnmBonusD) 
		gBreak.nPlayerAnmBonusG = AnmSet(@gAnm_RaqMitGRepos(0), gBreak.nPlayerAnmBonusG) 
		'todo: dust pour faire dégager les bouts rouges de la raquette.
	EndIf
  
End Sub

' Bonus : Allongement de la raquette.
' Malus : Rétrécissement de la raquette.
' In: + pour grandir, - pour réduire.
Sub BreakerBonusRaquetteSize(nSens As s32)

	Dim As u32 Ptr pRallonge(2) = { @gAnm_RaqRallonge0(0), @gAnm_RaqRallonge1(0), @gAnm_RaqRallonge2(0) } 
	Dim As u32 Ptr pReduit(2)   = { @gAnm_RaqReduit0(0)  , @gAnm_RaqReduit1(0)  , @gAnm_RaqReduit2(0) } 

	if (nSens >= 0) Then 
		' Rallonge.
		if (gBreak.nPlayerRSize < 3) Then 
			AnmSet(pRallonge(gBreak.nPlayerRSize), gBreak.nPlayerAnmNo) 
			gBreak.nPlayerRSize+=1  
		EndIf
	Else
		' Reduit.
		If (gBreak.nPlayerRSize > 0) Then 
			gBreak.nPlayerRSize-=1 
			AnmSet(pReduit(gBreak.nPlayerRSize), gBreak.nPlayerAnmNo) 
		EndIf
	EndIf
  
End Sub

' Bonus : Balle(s) traversante(s).
Sub BreakerBonusBallTraversante()

   Dim As SBall Ptr pBall 
	Dim As u32 i 

	for i = 0 To BALL_MAX_NB-1       
		pBall = @gBreak.pBalls(i) 
		if (pBall->nUsed) Then 
			pBall->nFlags Or= BALL_Flg_Traversante 
			BallChangeSize(pBall, pBall->nSize) 		' Change le sprite.
		EndIf
   Next
   
End Sub

' Bonus : Balle(s) x3.
Sub BreakerBonusBallX3()

	Dim As u8 pUsed(BALL_MAX_NB-1) 
   Dim As SBall Ptr pBall 
	Dim As u32 i , j, nLibre 

	' On flague les balles présentes.
	for i = 0 To BALL_MAX_NB -1
		pUsed(i) = gBreak.pBalls(i).nUsed
	Next
	
	' On récupère ces mêmes balles et on les multiplie !
	nLibre = 0 
	for i = 0 To BALL_MAX_NB -1     
		if (pUsed(i)) Then  
			pBall = @gBreak.pBalls(i) 
			' 2 balles pour chaque balle présente.
			for j = 0 To 1        
				' Recherche d´un slot libre.
				for nLibre=nLibre To BALL_MAX_NB -1       
					If (gBreak.pBalls(nLibre).nUsed = 0) Then Exit For
				Next
				If (nLibre = BALL_MAX_NB) Then Exit For ' Plus de place, on sort.
				' Init balle
				BallInit(@gBreak.pBalls(nLibre), pBall->nPosX, pBall->nPosY, _
					pBall->nSize, pBall->nFlags, pBall->nSpeed, _
					pBall->nAngle + iif(j And 1 , 10 , -10) ) 
			Next
		EndIf
   Next

End Sub

' Bonus : Grossissement balle(s).
' Attention ! Si la balle déborde dans le mur, la recaler de force.
Sub BreakerBonusBallBigger()

	Dim As SBall Ptr pBall 
	Dim As SSprite Ptr pSpr 
	Dim As u32 i 

	for i = 0 To BALL_MAX_NB -1      
	 
		pBall = @gBreak.pBalls(i) 
		if (pBall->nUsed<>0) Then 
			if (pBall->nSize + 1) <= BALL_MAX_SIZE Then 
				' On augmente la taille de la balle.
				BallChangeSize(pBall, pBall->nSize + 1)

				' Dans le mur ? => recalage.
				pSpr = SprGetDesc(pBall->nSpr) 
				if ((pBall->nPosX Shr 8) - pSpr->nPtRefX) < WALL_XMin Then 
					pBall->nPosX = (WALL_XMin + pSpr->nPtRefX) Shl 8 
				EndIf
	  
				if ((pBall->nPosX Shr 8) - pSpr->nPtRefX + pSpr->nLg) > WALL_XMax Then 
					pBall->nPosX = (WALL_XMax - pSpr->nLg + pSpr->nPtRefX) Shl 8 
				EndIf
	  
				if ((pBall->nPosY Shr 8) - pSpr->nPtRefY) < WALL_YMin Then 
					pBall->nPosY = (WALL_YMin + pSpr->nPtRefY) Shl 8 
				EndIf
	
				'todo: Vérifier ici le cas des balles collées sur la raquette.
				'(est-ce que quand le joueur attrape une pill grossissement et que des balles sont collées
				' sur la raquette, pendant 1 frame, les balles ne débordent pas dans la raquette ???).
				' Bon, au pire c´est pendant 1 frame, car ça sera recalé à la frame suivante.
				
			EndIf
		EndIf
		
   Next

End Sub

' Bonus : 1 Up.
Sub BreakerBonus1Up()

	if (gBreak.nPlayerLives + 1) <= PLAYER_Lives_Max Then 
		gBreak.nPlayerLives+=1  
	EndIf
  
	' Sfx.
	Sfx_PlaySfx(e_Sfx_ExtraLife, e_SfxPrio_30) 

End Sub

#define	BALL_Speed_Min	 &h200
#define	BALL_Speed_Max	 &h380
#define	BALL_Speed_Step &h080
' Bonus : Slow down.
' Malus : Speed up.
' In: + pour accélérer, - pour ralentir les balles.
Sub BreakerBonusSpeedUp(nSens As s32)

	Dim As SBall Ptr pBall 
	Dim As u32	i 

	for i = 0 To BALL_MAX_NB -1      
		pBall = @gBreak.pBalls(i) 
		if (pBall->nUsed) Then 
			if (nSens >= 0) Then 
				' Accélération.
				pBall->nSpeed += BALL_Speed_Step 
				if (pBall->nSpeed > BALL_Speed_Max) Then pBall->nSpeed = BALL_Speed_Max 
			Else
				' Décélération.
				pBall->nSpeed -= BALL_Speed_Step 
				if (pBall->nSpeed < BALL_Speed_Min) Then pBall->nSpeed = BALL_Speed_Min 
			EndIf
		EndIf
	Next

End Sub


'todo: Autres bonus possibles...
' Malus : Toutes les briques se transforment en briques à frapper 2 fois.
' Bonus : Plusieurs niveaux de mitrailleuse, faire des missiles qui détruisent les briques
' 			indestructibles / Une explosion qui détruit toutes les briques dans son rayon (retirer le flag indestructible des briques !).
' Malus : Inverse des bonus, perte de l´aimant...

'=============================================================================


' Init level.
Sub InitLevel(nLevel As u32)

	Dim As u32	i 
	Dim As s8	Ptr pLev = gpLevels(nLevel) 	' Sur le level en cours.
	Dim As u16	pScores(...) = { 50, 60, 70, 80, 90, 100, 110, 120, 100, 100,   100, 100, 0 } 


	' Initialisation de la table des briques.
	gBreak.nRemainingBricks = 0 
	gBreak.nBricksComingBackNbCur = 0 
	gBreak.nBricksComingBackTotal = 0 
	for i = 0 To (TABLE_Width * TABLE_Height) -1      
	 
		if *(pLev + i) <> -1 Then 
		 
			' Une brique.
			gBreak.pLevel(i).nPres = 1 		' Brique présente ou pas.
			gBreak.pLevel(i).nCnt = 1 		' Nb de touches restantes avant la destruction.
			gBreak.pLevel(i).nFlags = 0 	' Flags : Voir liste.
			gBreak.pLevel(i).nResetCnt = 0 	' Compteur pour retour de la brique.

			gBreak.pLevel(i).nSprNo = e_Spr_Bricks + *(pLev + i) 	' Sprite par défaut.
			gBreak.pLevel(i).nScore = pScores(*(pLev + i)) 			' Score.
			gBreak.pLevel(i).nAnmNo = -1 	' Remplacé par l´anim si != -1.

			gBreak.pLevel(i).pAnmExplo = @gAnm_BrickExplo(0) 	' Anim à utiliser pour la disparition.
			gBreak.pLevel(i).pAnmHit   = @gAnm_Brick2Hit(0) 	' Anim à utiliser pour le hit. Ne sert à rien pour les briques normales.

			gBreak.nRemainingBricks+=1  

			' Cas particuliers.
			Select Case  (*(pLev + i))
			 
			case e_Spr_BricksSpe 			' Brique à toucher 2 fois.
				gBreak.pLevel(i).nCnt = 2 		' Nb de touches restantes avant la destruction.
				gBreak.pLevel(i).pAnmExplo = @gAnm_Brick2HitExplo(0) 	' Anim à utiliser pour la disparition.
				gBreak.pLevel(i).pAnmHit   = @gAnm_Brick2Hit(0) 	' Anim à utiliser pour le hit.

			case e_Spr_BricksSpe + 1 		' Brique qui revient.
				gBreak.pLevel(i).nCnt = 2 		' Nb de touches restantes avant la destruction.
				gBreak.pLevel(i).nResetCnt = BRICK_ComingBackCnt 	' Compteur pour retour de la brique.
				gBreak.pLevel(i).nFlags Or = BRICK_Flg_ComingBack 
				gBreak.nBricksComingBackTotal+=1  
				gBreak.pLevel(i).pAnmExplo = @gAnm_BrickCBExplo(0) 	' Anim à utiliser pour la disparition.
				gBreak.pLevel(i).pAnmHit   = @gAnm_BrickCBHit(0) 	' Anim à utiliser pour le hit.

			case e_Spr_BricksSpe + 2 		' Brique indestructible.
				gBreak.pLevel(i).nFlags Or= BRICK_Flg_Indestructible 
				gBreak.nRemainingBricks-=1  	' Celles la, elles ne comptent pas.
				gBreak.pLevel(i).pAnmHit   = @gAnm_BrickIndesHit(0) 	' Anim à utiliser pour le hit.

         End Select

		Else

			' Pas de brique.
			gBreak.pLevel(i).nPres = 0 		' Brique présente ou pas.
			gBreak.pLevel(i).nFlags = 0 	' Flags : Voir liste.
			'gBreak.pLevel[i].nResetCnt = 0;	// Compteur pour retour de la brique.
			
		EndIf
		
	Next

	if (gBreak.nLevel = LEVEL_Max - 1) Then 

		' Boss de fin.

		' Pointeur sur le décor.
		gVar.pLevel = gVar.pLev(4) 
		' Rajoute Doh !
		MstAdd(e_Mst_Doh, SCR_Width / 2, 98) 
		gBreak.nRemainingBricks = 1 	' Quand on tuera le boss, il décrémentera le nb de briques.
	 
	Else
	 
		' Niveaux normaux.

		' Pointeur sur le décor.
		gVar.pLevel = gVar.pLev(gBreak.nLevel And 3) 
		' Rajoute un générateur de monstres.
		MstAdd(e_Mst_Generateur, 0, 0) 
	EndIf
  
	' Rajoute une porte à droite.
	MstAdd(e_Mst_DoorR, WALL_XMax, SCR_Height - 13 - 6) 

End Sub




' Changement de la taille d´une balle.
Sub BallChangeSize(  pBall As SBall Ptr , nSize As u32)

	Dim As SSprite Ptr pSpr 
	Dim As u32	i, j 

	' Sprite, suivant la taille.
'todo: Si balle animée, faire une table avec les anims dans l´ordre et recupérer pAnm[size].
'todo: Si trop lent, on peut sortir l´init de l´anim, ça évitera de refaire le masque.
	pBall->nSize = nSize 
	pBall->nSpr = IIf(pBall->nFlags And BALL_Flg_Traversante , e_Spr_BallTrav , e_Spr_Ball) + pBall->nSize 
	pSpr = SprGetDesc(pBall->nSpr) 
	pBall->nRayon = pSpr->nLg / 2 	' Offset du centre. / Note : lg impaires.
	pBall->nDiam  = pSpr->nHt 			' Hauteur.

	' Cleare le masque.
	for i = 0 To (BALL_GfxLg * BALL_GfxLg)-1
		pBall->pBallMask(i) = 0
   Next
	' Copie du masque.
	for j = 0 To pSpr->nHt-1       
		for i = 0 To pSpr->nLg-1       
			pBall->pBallMask((j * BALL_GfxLg) + i) =  INV( pSpr->pMask[(j * pSpr->nHt) + i] )
		Next
	Next
	
End Sub

' Init d´une nouvelle balle.
Sub BallInit(  pBall As SBall Ptr , nPosX As s32 , nPosY As s32 , nSize As u32 , nFlags As u32 , nSpeed As s32 , nAngle As u8)

	pBall->nUsed = 1 
	gBreak.nBallsNb+=1  

	pBall->nFlags = nFlags 
	pBall->nPosX  = nPosX 
	pBall->nPosY  = nPosY 
	pBall->nSpeed = nSpeed 
	pBall->nAngle = nAngle 

	BallChangeSize(pBall, nSize) 

	pBall->nOffsRaq = 0 

End Sub

' Init d´une balle sur la raquette.
Sub BallInitOnPlayer()

   Dim As SBall Ptr pBall 

	pBall = @gBreak.pBalls(0) 
	' Vitesse : Tous les 4 niveaux, ça part un peu plus vite.
	BallInit(pBall, gBreak.nPlayerPosX Shl 8, gBreak.nPlayerPosY Shl 8, 0, BALL_Flg_Aimantee, _
		BALL_Speed_Min + ((gBreak.nLevel Shr 2) * &h18), 48) 
	pBall->nPosY -= (pBall->nRayon + 1) Shl 8 

End Sub

' Init des slots des balles. (1 utilisée, les autres à vide).
Sub BallsInitSlots()

	Dim As u32	i 

	gBreak.nBallsNb = 0 
	for i = 0 To BALL_MAX_NB -1      
		gBreak.pBalls(i).nUsed = 0 
	Next

End Sub

' Les balles disparaissent avec un dust.
Sub BallsKill()

 	Dim As SBall Ptr pBall 
	Dim As u32	i 

	for i = 0 To BALL_MAX_NB -1      
		pBall = @gBreak.pBalls(i) 
		if (pBall->nUsed) Then 
'todo: faire une anim de disparition de balle.
			DustSet(@gAnm_MstExplo1(0), pBall->nPosX Shr 8, pBall->nPosY Shr 8) 
			pBall->nUsed = 0: gBreak.nBallsNb-=1  	' Nombre de balles en jeu.
		EndIf
	Next

End Sub




' Init life, reset de la raquette.
Sub Brk_PlyrInitLife()

	' Reset des flags.
	gBreak.nPlayerFlags And=  INV(PLAYER_Flg_Aimant Or PLAYER_Flg_Mitrailleuse) 	' Armes.
	gBreak.nPlayerFlags And=  INV(PLAYER_Flg_NoKill) 		' NoKill.
	gBreak.nPlayerFlags And=  INV(PLAYER_Flg_DoorR) 		' Door Right.
	' Taille de la raquette.
	gBreak.nPlayerRSize = 1 
	' Raquette normale.
'	gBreak.nPlayerAnmNo = AnmSet(@gAnm_Raquette(0), gBreak.nPlayerAnmNo);
	gBreak.nPlayerAnmNo 		= AnmSet(@gAnm_RaqAppear(0), gBreak.nPlayerAnmNo) 
	gBreak.nPlayerAnmClignG = AnmSet(@gAnm_RaqClignG(0), gBreak.nPlayerAnmClignG) 
	gBreak.nPlayerAnmClignD = AnmSet(@gAnm_RaqClignD(0), gBreak.nPlayerAnmClignD) 
	' Positionnement au centre.
	gBreak.nPlayerPosX = SCR_Width / 2 
	gBreak.nPlayerPosY = SCR_Height - 17 
	' Replace la souris à l´endroit du joueur.
	SDL_WarpMouse(gBreak.nPlayerPosX, gBreak.nPlayerPosY) 

	gBreak.nTimerLevelDisplay = TIMER_DisplayLevel 	' Compteur pour affichage du n° de level.

End Sub


' Init pour une partie, récupère/initialise les paramètres de gExg.
Sub ExgBrkInit()

	gBreak.nLevel = 0 'LEVEL_Max-1;//0;//
	gBreak.nPlayerLives = PLAYER_Lives_Start 
	gBreak.nPlayerScore = 0 

	gExg.nExitCode = 0 
	BreakerInit() 

End Sub

' Prépare la structure gExg pour sortie de la partie.
Sub ExgExit(nExitCode As u32)

	gExg.nExitCode = nExitCode 			' Code de sortie.
	gExg.nLevel = gBreak.nLevel 		' Level atteint au game over.
	gExg.nScore = gBreak.nPlayerScore 	' Score au game over.

End Sub

' Initialisation (appelée à chaque début de niveau (pas de vie, de niveau)).
Sub BreakerInit()

	MstInitEngine() 
	AnmInitEngine() 
	FireInitEngine() 
	DustInitEngine() 
	InitLevel(gBreak.nLevel) 

	Randomize timer 		' Init hasard.

	gBreak.nPhase 			 = e_Game_SelectLevel 'e_Game_Normal;
	gBreak.nTimerGameOver = TIMER_GameOver 	 ' Countdown pour game over.

	' Taille de la raquette.
	gBreak.nPlayerRSize = 1 
	' Réservation des anims (l´anim n´est PAS importante, on les réaffectera plus tard. C´est juste pour réserver un slot).
	gBreak.nPlayerAnmNo 		= AnmSet(@gAnm_Raquette(0), -1) 
	gBreak.nPlayerAnmBonusM = AnmSet(@gAnm_RaqAimant(0), -1) 
	gBreak.nPlayerAnmBonusD = AnmSet(@gAnm_RaqMitDRepos(0), -1) 
	gBreak.nPlayerAnmBonusG = AnmSet(@gAnm_RaqMitGRepos(0), -1) 
	gBreak.nPlayerAnmClignG = AnmSet(@gAnm_RaqClignG(0), -1) 
	gBreak.nPlayerAnmClignD = AnmSet(@gAnm_RaqClignD(0), -1) 

	gBreak.nPlayerFlags = 0 
	if gBreak.nLevel = (LEVEL_Max - 1) Then 
		' Le patch. 1 fois à l´init du level, pas de la vie.
		gBreak.nPlayerFlags Or= PLAYER_Flg_BossWait 	' Le joueur attendra que le boss soit prêt.
	EndIf

	Brk_PlyrInitLife() 

	BallsInitSlots() 
	BallInitOnPlayer() 

End Sub


' Tableau de bord.
Sub BreakerHUD()

	Dim As u32	i 

	' Le nombre de vies restantes.
	for i = 0 To gBreak.nPlayerLives-1       
		SprDisplay(e_Spr_HUDRaquette, WALL_XMin + (i * 16), SCR_Height - 7, e_Prio_HUD) 
	Next

	' Affichage du score. Note pour le centrage : Les chiffres sont en 8x8.
	Dim As String pScore = "00000000" 
	MyItoA(gBreak.nPlayerScore,pScore) 
	Font_Print((SCR_Width / 2) - ((Len(pScore) * 8) / 2), 7, pScore, 0) 

End Sub

' Dessin du jeu.
Sub BreakerDraw()

	Dim As u32	i, j, k 

	' Dessin des briques.
	k = 0 
	for j = 0 To TABLE_Height-1      
		for i = 0 To TABLE_Width-1      
			' Brique présente ?
			if (gBreak.pLevel(k).nPres) Then 

				Dim As u32	nSpr 
				Dim As s32	nTmp 

				nSpr = gBreak.pLevel(k).nSprNo 
				if (gBreak.pLevel(k).nAnmNo <> -1) Then  
					nTmp = AnmGetImage(gBreak.pLevel(k).nAnmNo) 
					if (nTmp = -1) Then 
						gBreak.pLevel(k).nAnmNo = -1 
					Else
						nSpr = nTmp 
					EndIf
				EndIf
  
				' Faut-il de l´ombre sur la brique ? (Pas si une à droite, une en dessous et une en dessous à droite. A ce moment là, l´ombre est cachée).
				if j = (TABLE_Height-1) Then 
					nSpr Or= SPR_Flag_Shadow
				ElseIf  i = (TABLE_Width-1) Then
					if (gBreak.pLevel(k + TABLE_Width).nPres = 0) Then nSpr Or= SPR_Flag_Shadow
				ElseIf (gBreak.pLevel(k + 1).nPres=0) AndAlso (gBreak.pLevel(k + TABLE_Width).nPres<>0) AndAlso (gBreak.pLevel(k + TABLE_Width + 1).nPres<>0) Then
					nSpr Or= SPR_Flag_Shadow 	
				EndIf
				SprDisplay(nSpr, WALL_XMin + (i * BRICK_Width), WALL_YMin + (j * BRICK_Height), e_Prio_Briques) 
			EndIf ' end of -> if (gBreak.pLevel[k].nPres)
			k+=1  
		Next
	Next
	
	
	' Le cache des ombres qui débordent à droite.
	SprDisplay(e_Spr_CacheDroit, 309, 15, 1) 


	' Dessin du joueur.

	' Dessin de la raquette.
	i = AnmGetImage(gBreak.nPlayerAnmNo) 
	SprDisplay(i Or SPR_Flag_Shadow, gBreak.nPlayerPosX, gBreak.nPlayerPosY, e_Prio_Raquette) 

	' Si pas en mort ou en apparition...
	if (AnmGetKey(gBreak.nPlayerAnmNo) = e_AnmKey_Null) Then 
		' Les clignotants sur les côtés.
		Dim As SSprite Ptr pSpr = SprGetDesc(i) 
		SprDisplay(AnmGetImage(gBreak.nPlayerAnmClignG) Or SPR_Flag_Shadow, gBreak.nPlayerPosX - pSpr->nPtRefX - 1, gBreak.nPlayerPosY, e_Prio_Raquette) 
		SprDisplay(AnmGetImage(gBreak.nPlayerAnmClignD) Or SPR_Flag_Shadow, gBreak.nPlayerPosX + pSpr->nLg - pSpr->nPtRefX, gBreak.nPlayerPosY, e_Prio_Raquette) 
		' Aimant ?
		if (gBreak.nPlayerFlags And PLAYER_Flg_Aimant) Then 
			SprDisplay(AnmGetImage(gBreak.nPlayerAnmBonusM), gBreak.nPlayerPosX, gBreak.nPlayerPosY, e_Prio_Raquette + 1) 
		EndIf
		' Mitrailleuse ?
		if (gBreak.nPlayerFlags And PLAYER_Flg_Mitrailleuse) Then 
			SprDisplay(AnmGetImage(gBreak.nPlayerAnmBonusG), gBreak.nPlayerPosX - pSpr->nPtRefX, gBreak.nPlayerPosY, e_Prio_Raquette + 1) 
			SprDisplay(AnmGetImage(gBreak.nPlayerAnmBonusD), gBreak.nPlayerPosX - pSpr->nPtRefX + pSpr->nLg - 1, gBreak.nPlayerPosY, e_Prio_Raquette + 1) 
		EndIf
	EndIf

	' Dessin des balles.
	for i = 0 To BALL_MAX_NB-1       
		if (gBreak.pBalls(i).nUsed) Then 
			SprDisplay(gBreak.pBalls(i).nSpr Or SPR_Flag_Shadow, gBreak.pBalls(i).nPosX Shr 8, gBreak.pBalls(i).nPosY Shr 8, e_Prio_Raquette)
		EndIf
	Next

	' Tableau de bord.
	BreakerHUD() 

End Sub


' Met l´anim de mort au joueur (en fct de la taille de la raquette).
Sub PlayerSetDeath()

	' Mort du joueur, sauf si flag (passage de la porte, boss tué...).
	if (gBreak.nPlayerFlags And PLAYER_Flg_NoKill) = 0 Then 
		' Joueur: Anim de mort.
		Dim As u32 Ptr pDeath(3) = { @gAnm_RaqDeath0(0), @gAnm_RaqDeath1(0), @gAnm_RaqDeath2(0), @gAnm_RaqDeath3(0) } 
		AnmSetIfNew(pDeath(gBreak.nPlayerRSize), gBreak.nPlayerAnmNo) 
	EndIf
  
End Sub


' Collisions balle-murs.
Function CollWalls(  pBall As SBall Ptr) As u32', s32 *pnOldX, s32 *pnOldY)

	Dim As u32 RetVal = 0 

	' Mur droit.
	if pBall->nPosX Shr 8 > (WALL_XMax - clng(pBall->nRayon)) Then 
		pBall->nAngle = 128 - pBall->nAngle 
		RetVal = 1 
	EndIf
  
	' Mur gauche.
	if pBall->nPosX Shr 8 < (WALL_XMin + CLng(pBall->nRayon)) Then 
		pBall->nAngle = 128 - pBall->nAngle 
		RetVal = 1 
	EndIf

	' Mur Haut.
	if pBall->nPosY Shr 8 < (WALL_YMin + CLng(pBall->nRayon)) Then 
		pBall->nAngle = -pBall->nAngle 
		RetVal = 1 
	EndIf
  
	return (RetVal) 
End Function


' Traitement d´une brique (relachement d´items, etc...).
' Renvoie les flags de la brique. -1 si pas de choc.
Function BrickHit(nBx As u32 , nBy As u32 , nBallFlags As u32) As u32

	Dim As u32	nRetVal = -1 

	if (nBx < TABLE_Width) AndAlso (nBy < TABLE_Height) AndAlso ((gBreak.pLevel((nBy * TABLE_Width) + nBx).nPres)<>0) Then 
		Dim As SBrique Ptr pBrick = @gBreak.pLevel((nBy * TABLE_Width) + nBx) 

		' Décrémentation du compteur de touchés. Si tombe à 0, la brique disparaît.
		if (pBrick->nFlags And BRICK_Flg_Indestructible) = 0 Then 

			pBrick->nCnt-=1  
			' Balle traversante, on force le compteur à 0.
			if (nBallFlags And BALL_Flg_Traversante) Then pBrick->nCnt = 0 
			if (pBrick->nCnt = 0) Then 

				pBrick->nPres = 0 
				AnmReleaseSlot(pBrick->nAnmNo) 
				pBrick->nAnmNo = -1 	' Spécial pour les briques qui reviennent.

				' Dust.
				DustSet(pBrick->pAnmExplo, WALL_XMin + (nBx * BRICK_Width), WALL_YMin + (nBy * BRICK_Height)) 

				' Génération item.
				if ((rand() And 7) = 0) Then 
					Dim As u8 Ptr pBon = gpBonuses(gBreak.nLevel) 
					MstAdd(e_Mst_Pill_0 + pBon[rand() Mod 32], _
						WALL_XMin + (nBx * BRICK_Width) + (BRICK_Width / 2), WALL_YMin + (nBy * BRICK_Height) + (BRICK_Height / 2)) 
				EndIf
  
				' Score.
				gBreak.nPlayerScore += pBrick->nScore 

				gBreak.nRemainingBricks-=1  	' Une brique de moins.

				if (pBrick->nFlags And BRICK_Flg_ComingBack) Then gBreak.nBricksComingBackNbCur+=1  	' Nb de briques qui doivent revenir.
			 
			else

				' Anim de hit.
				pBrick->nAnmNo = AnmSet(pBrick->pAnmHit, pBrick->nAnmNo) 
			EndIf
		 
		else

			' Anim de hit de brique indestructible.
			pBrick->nAnmNo = AnmSet(pBrick->pAnmHit, pBrick->nAnmNo) 
		
		EndIf
  
		' Flags.
		nRetVal = CULng(pBrick->nFlags) 
	
	EndIf
  

	return (nRetVal) 
End Function


' Collisions balle-briques.
' Renvoie 1 et retourne l´angle quand choc sur une brique.
Function CollBricks(pBall As SBall Ptr ,  pnOldX As s32 Ptr ,  pnOldY As s32 Ptr) As u32

	Dim As u32	RetVal = 0 

	Dim As s32	vx1, vx2, vy1, vy2 
	Dim As s32	nBXMin, nBXMax, nBYMin, nBYMax 
	Dim As s32	i, j 
	Dim As u32	x, y 
	Dim As s32	nX, nY 
	Dim As s32	dx = 0, dy = 0 

	Dim As u32	cxx, cyy, coin 
	Dim As u32	nBFlags 


	' Numéros des briques extrêmes à tester.
	vx1 = ((pBall->nPosX Shr 8) - WALL_XMin - pBall->nRayon) / BRICK_Width 		' Note: testé avec une table à la place du div, on ne gagne rien !
	vx2 = ((pBall->nPosX Shr 8) - WALL_XMin + pBall->nRayon) / BRICK_Width 
	vy1 = ((pBall->nPosY Shr 8) - WALL_YMin - pBall->nRayon) / BRICK_Height 
	vy2 = ((pBall->nPosY Shr 8) - WALL_YMin + pBall->nRayon) / BRICK_Height 

	cxx = 0: cyy = 0: coin = 0 
	' Boucle dans les briques potentielles.
	for j = vy1 To vy2       
	 
		' Coordonnées min et max de la brique en pixels.
		nBYMin = (j * BRICK_Height) + WALL_YMin 
		nBYMax = (j * BRICK_Height) + WALL_YMin + BRICK_Height - 1 

		for i = vx1 To vx2       
		 
			' Une brique présente ?
			if (CULng(i) < TABLE_Width) AndAlso (CULng(j) < TABLE_Height) AndAlso (gBreak.pLevel((j * TABLE_Width) + i).nPres<>0) Then 
				' Test de la col.
				' Coordonnées min et max de la brique en pixels.
				nBXMin = (i * BRICK_Width) + WALL_XMin 
				nBXMax = (i * BRICK_Width) + WALL_XMin + BRICK_Width - 1 

				' Test avec chaque pixel du masque de la balle.
				nY = (pBall->nPosY Shr 8) - pBall->nRayon 
				for y = 0 To pBall->nDiam-1       
					nX = (pBall->nPosX Shr 8) - pBall->nRayon 
					for x = 0 To  pBall->nDiam -1      
						' Pixel à tester ?
						if (pBall->pBallMask((y * BALL_GfxLg) + x)) Then 
							if (nX >= nBXMin) AndAlso (nX <= nBXMax) AndAlso (nY >= nBYMin) AndAlso (nY <= nBYMax) Then 
								Dim As u32 nFlg = 1 	' b0

								' Gestion du choc sur la brique.
								nBFlags = BrickHit(i, j, pBall->nFlags) 
								if (nBFlags And BRICK_Flg_Indestructible) Then nFlg = 2 	' b1

								' Choc.
								if ((pBall->nPosX Shr 8) >= nBXMin) AndAlso ((pBall->nPosX Shr 8) <= nBXMax) Then 
									cyy Or= nFlg 
								ElseIf ((pBall->nPosY Shr 8) >= nBYMin) AndAlso ((pBall->nPosY Shr 8) <= nBYMax) Then
									cxx Or= nFlg 
								Else
									coin Or= nFlg 
									dx = (pBall->nPosX Shr 8) - (nBXMin + (BRICK_Width / 2)) 
									dy = (pBall->nPosY Shr 8) - (nBYMin + (BRICK_Height / 2)) 
								EndIf
								'y = 1000: x = 1000 ' Sortie des boucles.
								Exit For , For
							EndIf
						EndIf
						nX+=1  
					Next ' for (x = 0; x < pBall->nDiam; x++)
					nY+=1  
				Next ' for (y = 0; y < pBall->nDiam; y++)
			EndIf ' if brique présente
		Next ' for (i = vx1; i <= vx2; i++)
	Next ' for (j = vy1; j <= vy2; j++)

	' Balle traversante ?
	if (pBall->nFlags And BALL_Flg_Traversante) Then 
		' On cleare les b0 => On ne garde que les chocs forcés.
		cxx  And=  INV(1) 
		cyy  And=  INV(1) 
		coin And=  INV(1) 
	EndIf
  
	' Coin ?
	if (cxx = 0) AndAlso (cyy = 0) AndAlso (coin<>0) Then 
		RetVal = 1 				' Et avec ça ? Ca coince encore ???
		if (dx >= 0) AndAlso (dy >= 0) Then 			' Bas droite.
			if (CByte(pBall->nAngle) >= -32) AndAlso (CByte(pBall->nAngle) < 64+32) Then
				pBall->nAngle -= 64 
			Else
				pBall->nAngle += 64 
			EndIf
		ElseIf  (dx >= 0 AndAlso dy <= 0) Then 	' Haut droite.
			if (pBall->nAngle >= 32 AndAlso pBall->nAngle < 128+32) Then
				pBall->nAngle -= 64 
			Else
				pBall->nAngle += 64 
			EndIf
		ElseIf  (dx <= 0 AndAlso dy <= 0) Then 	' Haut gauche.
			if (pBall->nAngle >= 64+32 AndAlso pBall->nAngle < 192+32) Then
				pBall->nAngle -= 64 
			Else
				pBall->nAngle += 64 
			EndIf
		ElseIf  (dx <= 0 AndAlso dy >= 0) Then  ' Bas gauche.
			if (CByte(pBall->nAngle) >= -64-32) AndAlso (CByte(pBall->nAngle) < 32) Then 
				pBall->nAngle -= 64 
			Else
				pBall->nAngle += 64 
			EndIf
		EndIf

		' En y, on empêche les rebonds trop "horizontaux".
		if (CByte(pBall->nAngle) > -16) AndAlso (CByte(pBall->nAngle) < 16) Then 
			pBall->nAngle = IIf(CByte(pBall->nAngle) >= 0 , 16 , -16) 
		ElseIf  (pBall->nAngle > 128-16) AndAlso (pBall->nAngle < 128+16) Then
			pBall->nAngle = IIf(pBall->nAngle >= 128 , 128+16 , 128-16) 
		EndIf
	EndIf
  
	' Col X.
	if (cxx) Then 
		pBall->nAngle = 128 - pBall->nAngle 
		RetVal = 1 
		' En x, on empêche les rebonds trop "verticaux". (Pour éviter de longer les briques en montant, etc...).
		if (pBall->nAngle > 64-16) AndAlso (pBall->nAngle < 64+16) Then 
			pBall->nAngle = IIf(pBall->nAngle >= 64 , 64+16 , 64-16) 
		ElseIf  (pBall->nAngle > 192-16) AndAlso (pBall->nAngle < 192+16) Then
			pBall->nAngle = iif(pBall->nAngle >= 192 , 192+16 , 192-16) 
		EndIf
	EndIf
  
	' Col Y.
	if (cyy) Then 
		pBall->nAngle = -pBall->nAngle 
		RetVal = 1 
		' En y, on empêche les rebonds trop "horizontaux".
		if (CByte(pBall->nAngle) > -16) AndAlso (CByte(pBall->nAngle) < 16) Then 
			pBall->nAngle = iif(CByte(pBall->nAngle) >= 0 , 16 , -16) 
		ElseIf  (pBall->nAngle > 128-16) AndAlso (pBall->nAngle < 128+16) Then
			pBall->nAngle = IIf(pBall->nAngle >= 128 , 128+16 , 128-16) 
		EndIf
	EndIf
  
	return (RetVal) 

End Function


#define	BALL_DEPL_MAX	&h300		' Pas plus grand que le rayon mini d´une balle !
' Déplacement de la balle.
Sub Brk_MoveBall()

	Dim As s32	nAddX, nAddY 
	Dim As s32	nOldX, nOldY 

	Dim As s32	nRemSpd 
	Dim As s32	nSpd 

	Dim As SBall Ptr pBall 
	Dim As u32	i 

	for i = 0 To BALL_MAX_NB-1       
	 
		pBall = @gBreak.pBalls(i) 
		if (pBall->nUsed) Then 
		 
			' La balle est-elle collée à la raquette ?
			if (pBall->nFlags And BALL_Flg_Aimantee) Then 
			 
				' Balle collée sur la raquette.
				pBall->nPosX = (gBreak.nPlayerPosX + pBall->nOffsRaq) Shl 8 
				pBall->nPosY = (gBreak.nPlayerPosY - pBall->nRayon - 1) Shl 8 

				' Recalage si la balle passe dans les murs.
				' Mur droit.
				if (pBall->nPosX Shr 8) > (WALL_XMax - CLng(pBall->nRayon)) Then 
					pBall->nOffsRaq -= (pBall->nPosX Shr 8) - (WALL_XMax - CLng(pBall->nRayon)) 
					pBall->nPosX = (gBreak.nPlayerPosX + pBall->nOffsRaq) Shl 8 
				EndIf
  
				' Mur gauche.
				if (pBall->nPosX Shr 8) < (WALL_XMin + clng(pBall->nRayon)) Then 
					pBall->nOffsRaq -= (pBall->nPosX Shr 8) - (WALL_XMin + CLng(pBall->nRayon)) 
					pBall->nPosX = (gBreak.nPlayerPosX + pBall->nOffsRaq) Shl 8 
				EndIf
				
			Else ' Balle en mouvement.
			
				nRemSpd = pBall->nSpeed
				while (nRemSpd)
					if (nRemSpd > BALL_DEPL_MAX) Then  
						' En cours.
						nSpd = BALL_DEPL_MAX 
						nRemSpd -= BALL_DEPL_MAX 
					Else
						' Dernier tour.
						nSpd = nRemSpd 
						nRemSpd = 0 
					EndIf
					' Déplacement.
					nOldX = pBall->nPosX 
					nOldY = pBall->nPosY 
					nAddX = (gVar.pCos[pBall->nAngle] * nSpd) Shr 8 
					nAddY = (gVar.pSin[pBall->nAngle] * nSpd) Shr 8 
					pBall->nPosX += nAddX 
					pBall->nPosY += nAddY 
			
					' Si col, on repart de l´ancienne pos.
					if (CollBricks(pBall, @nOldX, @nOldY)) Then 
						pBall->nPosX = nOldX 
						pBall->nPosY = nOldY 
					EndIf
			  
					if (CollWalls(pBall)) Then
						pBall->nPosX = nOldX 
						pBall->nPosY = nOldY 
						' Sfx.
						Sfx_PlaySfx(e_Sfx_BallBounce, e_SfxPrio_10) 
					EndIf
			  
					' Collision avec la raquette ?
					if (pBall->nAngle >= 128) AndAlso  (pBall->nPosY >= (gBreak.nPlayerPosY     - CLng(pBall->nRayon)) Shl 8) AndAlso  (pBall->nPosY <= (gBreak.nPlayerPosY + 4 - CLng(pBall->nRayon)) Shl 8) Then 
				
						if (SprCheckColBox(AnmGetLastImage(gBreak.nPlayerAnmNo), gBreak.nPlayerPosX, gBreak.nPlayerPosY, pBall->nSpr, pBall->nPosX Shr 8, pBall->nPosY Shr 8)) Then 
	
							Dim As SSprite Ptr pSpr = SprGetDesc(AnmGetLastImage(gBreak.nPlayerAnmNo))  
							Dim As s32	nXMin, nXMax 
							Dim As u32	nBatSfx = e_Sfx_BatPing 	' Sfx par défaut.
				
							nXMin = gBreak.nPlayerPosX - pSpr->nPtRefX 
							nXMax = nXMin + pSpr->nLg - 1 
							nXMin -= 4 		' Pour être un peu plus permissif.
							nXMax += 4 
				
							' Balle tape sur le côté de la raquette ?
							if ((pBall->nPosX Shr 8) < nXMin) OrElse ((pBall->nPosX Shr 8) > nXMax) Then 
							 
								if (pBall->nPosX Shr 8) < gBreak.nPlayerPosX Then 
									' Sur la gauche de la raquette.
									if (pBall->nAngle > 192) Then pBall->nAngle = 128 - pBall->nAngle 
								Else
									' Sur la droite de la raquette.
									if (pBall->nAngle < 192) Then pBall->nAngle = 128 - pBall->nAngle 
								EndIf
	
							Else
	
								' La balle tape sur la raquette.
								Dim As s32	dx 
								Dim As s32	ang 
				
								pBall->nPosX = nOldX 
								pBall->nPosY = nOldY 
				
								' Selon la position où la balle tombe sur la raquette, on renvoie la balle où il faut.
								dx = (pBall->nPosX Shr 8) - gBreak.nPlayerPosX 
				
								' Renvoi à la Arkanoid, on ne prend pas en compte l´angle d´arrivée.
								ang = (-32 * dx) / (CLng(pSpr->nLg) / 2) 
								ang += 64 
								pBall->nAngle = ang 
				
								' Raquette aimantée ?
								if (gBreak.nPlayerFlags And PLAYER_Flg_Aimant) Then 
									pBall->nOffsRaq = dx 
									pBall->nFlags Or= BALL_Flg_Aimantee 	' Balle collée sur la raquette.
									'pBall->nSpeed = 0;	// No nO No ! La balle conserve sa vitesse.
									nRemSpd = 0 	' Balle collée, on arrête la boucle de déplacement.
									nBatSfx = e_Sfx_BatMagnet 	' Sfx d´aimantation.
								EndIf
								
								' sfx
								Sfx_PlaySfx(nBatSfx, e_SfxPrio_10) 
							EndIf ' end if côté
						EndIf ' end if collision raquette
					EndIf
				Wend ' end while déplacement
			
				' La balle est tombée ?
				if pBall->nPosY > ( (SCR_Height + CLng(pBall->nRayon)) Shl 8) Then 
					' ? Mettre une constante à la place du rayon ?
					pBall->nUsed = 0
					gBreak.nBallsNb-=1  	' Nombre de balles en jeu.
				EndIf
	
			EndIf ' end else balle aimantée
			
		EndIf ' end ball used
	
	Next ' end for slots

	' Reste-t´il des balles en jeu ?
	if (gBreak.nBallsNb = 0) Then 
		PlayerSetDeath() 
	EndIf

End Sub


' Relache les balles aimantées à la raquette.
Sub Aimant_ReleaseBalls()

	Dim As SBall Ptr pBall 
	Dim As u32  i 
	Dim As u32  nRel = 0 	' Slt pour le son.

	for i = 0 To BALL_MAX_NB-1       
		pBall = @gBreak.pBalls(i) 
		if (pBall->nUsed) Then 
			if (pBall->nFlags And BALL_Flg_Aimantee) Then  ' Test seulement pour le son ! Argh !
				pBall->nFlags And= INV(BALL_Flg_Aimantee)' Coupe l´aimant sur la balle.
				nRel = 1 	' Slt pour le son.
			EndIf
		EndIf
	Next

	' Sfx.
	if (nRel) Then Sfx_PlaySfx(e_Sfx_BatPing, e_SfxPrio_10) 

End Sub

' Déplacement de la raquette du joueur.
Sub Brk_MovePlayer()

	Dim As s32	i 
	Dim As SSprite Ptr pSpr = SprGetDesc(AnmGetLastImage(gBreak.nPlayerAnmNo)) 
	Dim As s32	nXMin, nXMax 

	' Dans le passage à droite ?
	if (gBreak.nPlayerFlags And PLAYER_Flg_DoorR) Then 
		' On lache les balles tout le temps. On ne s´occupe pas du flag => Ca simplifie la gestion.
		Aimant_ReleaseBalls() 

		' On force le déplacement.
		gBreak.nPlayerPosX+=1  

		' Complètement passé ?
		if (gBreak.nPlayerPosX - pSpr->nPtRefX) > (WALL_XMax + 8) Then 
			gBreak.nPhase = e_Game_LevelCompleted 
		EndIf
  
		' Dans le passage, plus de clics possibles.
		gVar.nMouseButtons = 0 

		Exit Sub 
	EndIf
  
	' Mort.
	if (AnmGetKey(gBreak.nPlayerAnmNo) = e_AnmKey_PlyrDeath) Then 
		' Explosion finie ?
		if (AnmCheckEnd(gBreak.nPlayerAnmNo)) Then 
			' Il reste des vies ?
			if (gBreak.nPlayerLives) Then 
				' Oui.
				gBreak.nPlayerLives-=1  
				' Reset joueur.
				Brk_PlyrInitLife() 

				BallInitOnPlayer() 		' balle, à faire apparaitre après l´anim d´apparition.
				' ou alors, pendant l´anim d´apparition, ne pas afficher de balle.
			Else
				' Game over. (ou continue ?)
				gBreak.nPhase = e_Game_GameOver 
			EndIf
		EndIf
		' On ne bouge pas pendant la mort.
		gVar.nMouseButtons = 0 		' Empèche les clics (tirs...).
		Exit Sub 
	EndIf

	' On se prend un tir ? (Seulement dans le niveau du boss, c´est pour ça qu´on utilise la même routine que pour les monstres !).
	if gBreak.nLevel = (LEVEL_Max - 1) Then 
		if (MstCheckFire(AnmGetLastImage(gBreak.nPlayerAnmNo), gBreak.nPlayerPosX, gBreak.nPlayerPosY)) Then 
			PlayerSetDeath() 
			BallsInitSlots() 	'todo: Revoir, comme ça pour éviter le bug du mort avec balle collée,
									'      reinit et gBreak.nNbBalles == 2, et on ne meurt plus quand on perd la balle.
		EndIf
  
		' Si en attente du boss, pas de clics.
		if (gBreak.nPlayerFlags And PLAYER_Flg_BossWait) Then 
			gVar.nMouseButtons = 0 
		EndIf
	EndIf

'todo: éventuellement, faire une vitesse de dépl max. / si last - pos > vit max, pos = last pos +- vmax.

	' Déplacement de la raquette.
	'gBreak.nPlayerLastPosX = gBreak.nPlayerPosX;	// Finalement, on ne s´en sert pas.

	i = gVar.nMousePosX 
	nXMin = i - pSpr->nPtRefX 
	nXMax = nXMin + pSpr->nLg 
	if (nXMin < WALL_XMin) Then i = WALL_XMin + pSpr->nPtRefX 
	if (nXMax > WALL_XMax) Then i = WALL_XMax - pSpr->nLg + pSpr->nPtRefX 
	gBreak.nPlayerPosX = i 

End Sub


' Teste si une balle se trouve dans un rectangle (pour retour des briques qui reviennent).
Function BallsCheckRectangle(nXMin As s32 , nXMax As s32 , nYMin As s32 , nYMax As s32) As u32

	Dim As u32	i 
	Dim As SBall Ptr pBall 

	for i = 0 To BALL_MAX_NB-1       
		pBall = @gBreak.pBalls(i) 
		if (pBall->nUsed) Then 
			if (pBall->nPosX >= nXMin) _
				 AndAlso (pBall->nPosX <= nXMax) _
				 AndAlso (pBall->nPosY >= nYMin) _
				 AndAlso (pBall->nPosY <= nYMax) Then 
			 return (1) 
			EndIf
		EndIf
	Next

	return (0) 
End Function

#define	BCB_Offset	16
' Gestion des briques qui reviennent.
Sub Brk_BricksComingBack()

	Dim As u32 i, j, k, nb 

	if (gBreak.nBricksComingBackTotal = 0) Then return 	' Si pas de briques qui reviennent dans le niveau.
	if (gBreak.nRemainingBricks + gBreak.nBricksComingBackNbCur) <= gBreak.nBricksComingBackTotal Then return 	' S´il ne reste que des briques invisibles.

	k = 0 
	nb = 0 
	for j = 0 To TABLE_Height -1   
		for i = 0 To TABLE_Width -1    
			if (nb >= gBreak.nBricksComingBackNbCur) Then Exit For,For 'GoTo _Skip 
			if (gBreak.pLevel(k).nPres = 0) AndAlso ((gBreak.pLevel(k).nFlags And BRICK_Flg_ComingBack)<>0) Then 
				' On a trouvé une brique qui doit revenir. Countdown.
				gBreak.pLevel(k).nResetCnt-=1
				if (gBreak.pLevel(k).nResetCnt = 0) Then 
					Dim As s32 nXMin, nYMin, nXMax, nYMax 
					' Coordonées à tester. Avec l´offset, englobe les rectangles de col des monstres et des balles. Ca permet de ne tester qu´un point.
					nXMin = ((i * BRICK_Width ) + WALL_XMin - BCB_Offset) Shl 8 
					nXMax = ((i * BRICK_Width ) + WALL_XMin + BRICK_Width - 1 + BCB_Offset) Shl 8 
					nYMin = ((j * BRICK_Height) + WALL_YMin - BCB_Offset) Shl 8 
					nYMax = ((j * BRICK_Height) + WALL_YMin + BRICK_Height - 1 + BCB_Offset) Shl 8 
					if (MstCheckRectangle(nXMin, nXMax, nYMin, nYMax) = 0) AndAlso _
							(BallsCheckRectangle(nXMin, nXMax, nYMin, nYMax) = 0) Then 
						' Tout est ok, la brique revient.
						gBreak.pLevel(k).nPres = 1 		' La brique revient.
						gBreak.nRemainingBricks+=1  		' Une brique en plus.
						'
						gBreak.pLevel(k).nCnt = 2 		' Nb de touches restantes avant la destruction.
						gBreak.pLevel(k).nResetCnt = BRICK_ComingBackCnt 	' Compteur pour retour de la brique.
						nb+=1  
					Else
						' La brique ne peut pas revenir tout de suite. On réésayera plus tard.
						gBreak.pLevel(k).nResetCnt = 8 
					EndIf
				EndIf
			EndIf
			k+=1  	' idx
		Next
	Next
	
'_Skip:
	gBreak.nBricksComingBackNbCur -= nb 	' Décrémentation APRES la boucle.

End Sub


' Game.
Sub BreakerGame()

	Dim As SSprite Ptr pSpr 
	Dim As u32	i 
	Dim As s32	nDiff 
	static As u8	nWait = 0 

	Select Case  (gBreak.nPhase)
	 
	case e_Game_SelectLevel 	' Selection du niveau.
		if (nWait) Then nWait-=1  
		if (nWait = 0) Then 
			nDiff = gVar.nMousePosX - gBreak.nPlayerPosX 
			if (ABS(nDiff) > 8) Then 
				i = 0 
				if (nDiff < 0) Then 
					if (gBreak.nLevel > 0) Then  gBreak.nLevel-=1 : i = 1   
				Else
					if (gBreak.nLevel < LEVEL_SELECT_Max) Then gBreak.nLevel+=1 : i = 1  
				EndIf
				if (i) Then 
					BreakerInit() 
					gBreak.nPhase = e_Game_SelectLevel 
					nWait = 12 
				EndIf
			EndIf
		EndIf
  

		' Affichage de la phrase de selection.
		Dim As string	pStrSel = "SELECT STARTING LEVEL : 00" 
		MyItoA(gBreak.nLevel + 1,pStrSel) 
		i = Font_Print(0, 10, pStrSel, FONT_NoDisp) 	' Pour centrage.
		Font_Print((SCR_Width / 2) - (i / 2), 200, pStrSel, 0) 
		
		' Clic souris ? => Selection du level.
		if (gVar.nMouseButtons And MOUSE_BtnLeft) Then 
			nWait = 0 
			gBreak.nPhase = e_Game_Normal 
		EndIf

	case e_Game_Normal 			' Jeu.
		' Affichage de la phrase "Level xx" en début de vie.
		if (gBreak.nTimerLevelDisplay) Then 
			Dim As String pStrSel = "LEVEL 00" 
			MyItoA(gBreak.nLevel + 1,pStrSel)
			i = Font_Print(0, 10, pStrSel, FONT_NoDisp) 	' Pour centrage.
			Font_Print((SCR_Width / 2) - (i / 2), 200, pStrSel, 0) 
			gBreak.nTimerLevelDisplay-=1  
			if (gVar.nMouseButtons And MOUSE_BtnLeft) Then gBreak.nTimerLevelDisplay = 0 	' On coupe.
		EndIf

		' Déplacement du joueur.
		Brk_MovePlayer() 

		' Clic souris ?
		if (gVar.nMouseButtons And MOUSE_BtnLeft) Then 
			' Aimant ? (Sert aussi au lancement initial de la balle).
			Aimant_ReleaseBalls() 
			' Mitrailleuse ?
			if (gBreak.nPlayerFlags And PLAYER_Flg_Mitrailleuse) Then 
				gBreak.nPlayerAnmBonusD = AnmSetIfNew(@gAnm_RaqMitDShoot(0), gBreak.nPlayerAnmBonusD) 
				gBreak.nPlayerAnmBonusG = AnmSetIfNew(@gAnm_RaqMitGShoot(0), gBreak.nPlayerAnmBonusG) 
				' Balance les tirs.
				pSpr = SprGetDesc(AnmGetLastImage(gBreak.nPlayerAnmNo)) 
				FireAdd(0, gBreak.nPlayerPosX - pSpr->nPtRefX + 2, gBreak.nPlayerPosY - 2, -1) 
				FireAdd(0, gBreak.nPlayerPosX - pSpr->nPtRefX + pSpr->nLg - 1 - 2, gBreak.nPlayerPosY - 2, -1) 
				' Sfx.
				Sfx_PlaySfx(e_Sfx_Shot, e_SfxPrio_20) 	' (pas dans l´anim car pas forcément remise à zéro).
			EndIf
		EndIf ' clic
		
		Brk_MoveBall() 
		
		' Gestion des briques qui reviennent.
		Brk_BricksComingBack() 

		' Plus de briques dans le niveau ?
		if (gBreak.nRemainingBricks = 0) Then 
			' On déclenche l´ouverture de la porte.
			MstDoorROpen() 
			' Le joueur peut continuer pour buter les monstres si ça le chante, mais ne peut plus mourir.
			gBreak.nPlayerFlags Or= PLAYER_Flg_NoKill 
		EndIf

	case e_Game_GameOver 		' Game Over.
		' Affichage du Game Over.
		Dim As String	pGameOver = "GAME OVER" 
		i = Font_Print(0, 10, pGameOver, FONT_NoDisp) 	' Pour centrage.
		Font_Print((SCR_Width / 2) - (i / 2), 200, pGameOver, 0) 

		' On quitte après x secondes || Clic, on quitte tout de suite.
		gBreak.nTimerGameOver-=1
		if (gBreak.nTimerGameOver = 0) OrElse ((gVar.nMouseButtons And MOUSE_BtnLeft)<>0) Then 
			ExgExit(e_Game_GameOver) 
		EndIf

	case e_Game_LevelCompleted 		' Niveau terminé.
		Dim tmp As Byte=0 ' jepalza
		if gBreak.nLevel  < (LEVEL_Max - 1) Then 
			gBreak.nLevel+=1:tmp=1 ' jepalza
			' Niveau suivant.
			BreakerInit() 
			gBreak.nPhase = e_Game_Normal 
		Else
			' Jeu terminé. Sortie.
			ExgExit(e_Game_AllClear) 
		EndIf
		If tmp=0 Then gBreak.nLevel+=1 ' jepalza

	case e_Game_Pause 			' Pause.
		' Normalement, on ne passe jamais ici...
		' vacio

	End Select

	' Replace la souris à l´endroit du joueur.
	SDL_WarpMouse(gBreak.nPlayerPosX, gBreak.nPlayerPosY) 

End Sub


' +1 vie à certains scores.
#define	SC_EVERY	100000
Sub CheckSpecialScore(nLastScore As u32)

	Dim As u32	pScores(2) = { 20000, 50000, 100000 } 
	static As u32	nNextScore 		' Pour les scores au dela de 100000.
	Dim As u32	i 

	' Au delà du score bonus max ? Alors 1 vie tous les x points.
	if (nLastScore >= pScores(NBELEM(pScores) - 1)) Then 
		if (gBreak.nPlayerScore >= nNextScore) Then 
			BreakerBonus1Up() 
			' Sfx.
			Sfx_PlaySfx(e_Sfx_PillBonus, e_SfxPrio_30) 
			' Le score suivant.
			nNextScore += SC_EVERY 
		EndIf
		Exit Sub 
	EndIf
  
	' Recherche dans le tableau.
	i = 0 
	while (nLastScore >= pScores(i)) AndAlso (i < NBELEM(pScores)) 
		i+=1 
   Wend
     
	' +1 vie ?
	if (nLastScore < pScores(i)) AndAlso (gBreak.nPlayerScore >= pScores(i)) Then 
		BreakerBonus1Up() 
	EndIf
  
	' Premier score en dehors du tableau.
	nNextScore = pScores(NBELEM(pScores)-2) + SC_EVERY 

End Sub


' Breaker.
Sub Breaker()

	Dim As u32	nLastScore = gBreak.nPlayerScore 

	' En pause ?
	if (gBreak.nPhase = e_Game_Pause) Then Exit Sub 

	BreakerGame() 
	FireManage() 
	MstManage() 
	CheckSpecialScore(nLastScore) 
	DustManage() 
	BreakerDraw() 

End Sub






