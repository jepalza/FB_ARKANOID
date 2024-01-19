


'=============================================================================
Dim Shared As SMstTb gpMstTb(...) _  '14*3) _
={_
	Type(Cast(u32,@MstInit_Pill), Cast(u32,@MstMain_Pill), @gAnm_Itm1(0) , 100 ),_		' Pill: Aimant.
	Type(Cast(u32,@MstInit_Pill), Cast(u32,@MstMain_Pill), @gAnm_Itm2(0) , 100 ),_		' Pill: Mitrailleuse.
	Type(Cast(u32,@MstInit_Pill), Cast(u32,@MstMain_Pill), @gAnm_Itm3(0) , 100 ),_		' Pill: Balle traversante.
	Type(Cast(u32,@MstInit_Pill), Cast(u32,@MstMain_Pill), @gAnm_Itm4(0) , 100 ),_		' Pill: Balle bigger.
	Type(Cast(u32,@MstInit_Pill), Cast(u32,@MstMain_Pill), @gAnm_Itm5(0) , 100 ),_		' Pill: Balle x3
	Type(Cast(u32,@MstInit_Pill), Cast(u32,@MstMain_Pill), @gAnm_Itm6(0) , 100 ),_		' Pill: Raquette bigger.
	Type(Cast(u32,@MstInit_Pill), Cast(u32,@MstMain_Pill), @gAnm_Itm7(0) , 0   ),_		' Pill: Raquette smaller.
	Type(Cast(u32,@MstInit_Pill), Cast(u32,@MstMain_Pill), @gAnm_Itm8(0) , 100 ),_		' Pill: 1Up.
	Type(Cast(u32,@MstInit_Pill), Cast(u32,@MstMain_Pill), @gAnm_Itm9(0) , 100 ),_		' Pill: Porte à droite.
	Type(Cast(u32,@MstInit_Pill), Cast(u32,@MstMain_Pill), @gAnm_Itm10(0), 100 ),_		' Pill: Speed Up.
	Type(Cast(u32,@MstInit_Pill), Cast(u32,@MstMain_Pill), @gAnm_Itm11(0), 100 ),_		' Pill: Speed Down.
	Type(Cast(u32,@MstInit_Generateur), Cast(u32,@MstMain_Generateur), @gAnm_MstDoorWait(0), 0 ),_
	Type(Cast(u32,@MstInit_Mst1), Cast(u32,@MstMain_Mst1), @gAnm_Mst1(0) , 100 ),_		' Monstres basiques des niveaux.
	Type(Cast(u32,@MstInit_DoorR),Cast(u32,@MstMain_DoorR),@gAnm_MstDoorRight(0), 0 ),_	' Porte à droite.
	Type(Cast(u32,@MstInit_Doh),  Cast(u32,@MstMain_Doh),  @gAnm_MstDohAppears(0), 10000 ) _	' Doh.
}


'=============================================================================
' Variables générales spécifiques.
Type SMstMisc 
	As u32 nNbMstLev 		' Pour compter le nombre de monstres présents. (3 max).
	' Pas dans la struct du générateur, parce que les autres monstres accèdent aussi à la variable.

   As u8	nMstDoorR:1 	' Flag pour déclencher l´ouverture de la porte.
	' Déclenchement quand on attrape la pillule.

End Type
Dim Shared As SMstMisc gMstMisc

'=============================================================================
' Monstre pillule (bonus).

' Init pour pillules.
Sub MstInit_Pill(pMst As SMstCommon Ptr)


End Sub

' Routine commune à toutes les pillules.
Function MstMain_Pill(pMst As SMstCommon Ptr) As s32

	Dim As s32 nSpr 

	' Déplacement.
	pMst->nPosY += &h100 
	' Sortie de l´écran ?
	if (pMst->nPosY Shr 8) > (SCR_Height + 8) Then 
		' Tuage de l´ennemi.
		return (-1) 
	EndIf
  
	' Contact avec le joueur ?
	nSpr = AnmGetImage(pMst->nAnm) 
	if (AnmGetKey(gBreak.nPlayerAnmNo) <> e_AnmKey_PlyrDeath) Then 
		if (SprCheckColBox(AnmGetLastImage(gBreak.nPlayerAnmNo), gBreak.nPlayerPosX, gBreak.nPlayerPosY, _
			nSpr, pMst->nPosX Shr 8, pMst->nPosY Shr 8)) Then 
				 
				Dim As u32	nSfx = e_Sfx_PillBonus
		  		' Fx par défaut, bonus.
		
				' Bonus.
				Select Case  (pMst->nMstNo)
				 
				case e_Mst_Pill_Aimant 
					BreakerBonusSetAimant() 
		
				case e_Mst_Pill_Mitrailleuse 
					BreakerBonusSetMitrailleuse() 
		
				case e_Mst_Pill_BallTraversante 
					BreakerBonusBallTraversante() 
		
				case e_Mst_Pill_BallBigger 
					BreakerBonusBallBigger() 
		
				case e_Mst_Pill_BallX3 
					BreakerBonusBallX3() 
		
				case e_Mst_Pill_RaqRallonge 
					BreakerBonusRaquetteSize(1) 
		
				case e_Mst_Pill_RaqReduit 
					nSfx = e_Sfx_PillMalus 
					BreakerBonusRaquetteSize(-1) 
		
				case e_Mst_Pill_1Up 
					nSfx = -1 	' No sound, sfx lancé par le bonus.
					BreakerBonus1Up() 
		
				case e_Mst_Pill_DoorR 
					MstDoorROpen() 
		
				case e_Mst_Pill_SpeedUp 
					nSfx = e_Sfx_PillMalus 
					BreakerBonusSpeedUp(1) 
		
				case e_Mst_Pill_SpeedDown 
					BreakerBonusSpeedUp(-1) 
				
				End Select
		
				' Score.
				gBreak.nPlayerScore += gpMstTb(pMst->nMstNo).nPoints 
				' Sfx.
				Sfx_PlaySfx(nSfx, e_SfxPrio_30) 
		
				' (dust, éventuellement).
		
				' Tuage de l´ennemi.
				return (-1) 
		End If
	EndIf

	' Affichage du bonus.
	SprDisplay(nSpr Or SPR_Flag_Shadow, pMst->nPosX Shr 8, pMst->nPosY Shr 8, e_Prio_Briques + gnMstPrio) 'e_Prio_Briques + 1);
	return (0) 
End Function

'=============================================================================
' Monstre qui fait apparaitre les monstres.

' Phases.
enum
	e_MstGenerateur_PhaseWait = 0,
	e_MstGenerateur_PhaseOuverture,
	e_MstGenerateur_PhaseSortie,
	e_MstGenerateur_PhaseFermeture
End Enum

#define	MSTLEV_Max	3

' Structure spécifique.
Type SMstGenerateur 
	As u16 nCnt 
	As u8	 nSortieNo 
End Type 

Sub MstInit_Generateur(pMst As SMstCommon Ptr)

	Dim As SMstGenerateur Ptr pSpe = Cast(SMstGenerateur Ptr,@pMst->pData(0)) 

	pMst->nPhase = e_MstGenerateur_PhaseWait 
	pSpe->nCnt = 60 
	gMstMisc.nNbMstLev = 0 		' Pour compter le nombre de monstres présents. (3 max).

End Sub

Function MstMain_Generateur(pMst As SMstCommon Ptr) As s32

	Dim As SMstGenerateur Ptr pSpe = Cast(SMstGenerateur Ptr,@pMst->pData(0))
	Dim As u16	nSortiesPosXY(7) = { 64,12,  159,12,  253,12,  159,12 } 	' Offsets des sorties.

	Select Case  (pMst->nPhase)
	 
	case e_MstGenerateur_PhaseWait 
		if (gBreak.nRemainingBricks = 0) Then return (0) 	' On ne génère plus de monstres une fois un niveau terminé. (Pour éviter le scoring).

		pSpe->nCnt-=1
		if ( pSpe->nCnt <> 0) Then return (0) 
		' Nb de monstres max atteint ?
		if (gMstMisc.nNbMstLev >= MSTLEV_Max) Then 
			pSpe->nCnt = 60 	' On rééssaye dans une seconde.
			return (0) 
		EndIf
  
		' Passage à la phase suivante.
		pMst->nPhase = e_MstGenerateur_PhaseOuverture 
		AnmSet(@gAnm_MstDoorOpen(0), pMst->nAnm) 	' Anim réservée à la création du monstre, pas de pb d´allocation.
		' Choix de la sortie.
		pSpe->nSortieNo = rand() And 3 
		pMst->nPosX = nSortiesPosXY(pSpe->nSortieNo * 2) 
		pMst->nPosY = nSortiesPosXY((pSpe->nSortieNo * 2) + 1) 
		'reak 

	case e_MstGenerateur_PhaseOuverture 
		if (AnmGetKey(pMst->nAnm) = 1) Then 
			pMst->nPhase = e_MstGenerateur_PhaseSortie 
			' Génération du monstre.
			if (MstAdd(e_Mst_Mst1, pMst->nPosX, pMst->nPosY - 8) <> -1) Then 
				gMstMisc.nNbMstLev+=1  		' Pour compter le nombre de monstres présents.
			EndIf
		EndIf


	case e_MstGenerateur_PhaseSortie 
		if (AnmGetKey(pMst->nAnm) = 2) Then 
			pMst->nPhase = e_MstGenerateur_PhaseFermeture 
		EndIf
		' Cache en plus, pour masquer le monstre.
		SprDisplay(e_Spr_SortieMstCache, pMst->nPosX, pMst->nPosY, e_Prio_Monstres + MSTPRIO_AND + 1) 

	case e_MstGenerateur_PhaseFermeture 
		' Anim terminée ?
		if (AnmGetKey(pMst->nAnm) = e_AnmKey_Null) Then 
			pMst->nPhase = e_MstGenerateur_PhaseWait 
			pSpe->nCnt = 60 
		EndIf
	
  End Select

	' Affichage.
	SprDisplay(AnmGetImage(pMst->nAnm), pMst->nPosX, pMst->nPosY, e_Prio_Monstres - 1) 

	return (0) 
End Function

'=============================================================================
' Monstre 1.

' Phases.
enum 
	e_Mst1_PhaseWait = 0,
	e_Mst1_PhaseArrivee,
	e_Mst1_PhaseMove,
	e_Mst1_PhaseCircle
End Enum

' Structure spécifique.
Type SMstMst1 
	As u8	nCnt 	' Nb de frames avant changement de direction.
End Type 

' Sous routine pour déplacement du monstre.
Function Mst1Move(pMst As SMstCommon Ptr) As u32

	Dim As s32	nDestX, nDestY 
	Dim As s32	nDestX2, nDestY2 
	Dim As s32	nBx, nBy 

	' Position de destination.
	nDestX = pMst->nPosX + gVar.pCos[pMst->nAngle] 	' * spd
	nDestY = pMst->nPosY + gVar.pSin[pMst->nAngle] 	' * spd
	if (pMst->nPhase = e_Mst1_PhaseCircle) Then nDestY += &h10 	' Cercles, on descend petit à petit.
	nDestX2 = nDestX + (8 * gVar.pCos[pMst->nAngle]) 	' Pour tester plus loin que le pt de ref du sprite.
	nDestY2 = nDestY + (8 * gVar.pSin[pMst->nAngle]) 
	' Dans le mur ?
	if (nDestX2 <= (WALL_XMin Shl 8)) OrElse (nDestX2 >= (WALL_XMax Shl 8)) OrElse (nDestY2 <= (WALL_YMin Shl 8)) Then 
		return (1) 
	EndIf
  
	' Dans les briques ? (Si pas trop bas !)
	nBx = ((nDestX2 Shr 8) - WALL_XMin) / BRICK_Width 
	nBy = ((nDestY2 Shr 8) - WALL_YMin) / BRICK_Height 
	if (nBy < TABLE_Height) AndAlso (gBreak.pLevel((nBy * TABLE_Width) + nBx).nPres) Then 
		return (1) 
	EndIf
  
	' Déplacement sur coord finales.
	pMst->nPosX = nDestX 
	pMst->nPosY = nDestY 
	return (0) 

End Function

' Init.
Sub MstInit_Mst1(pMst As SMstCommon Ptr)

	Dim As u32 Ptr pAnm(3) = { @gAnm_Mst1(0), @gAnm_Mst2(0), @gAnm_Mst3(0), @gAnm_Mst4(0) } 

	pMst->nPhase = e_Mst1_PhaseWait
	pMst->nAnm = AnmSet(pAnm(gBreak.nLevel And 3), pMst->nAnm)

End sub

' Main.
Function MstMain_Mst1(pMst As SMstCommon Ptr) As s32

	Dim As SMstMst1 Ptr pSpe = Cast(SMstMst1 Ptr,@pMst->pData(0)) 
	Dim As s32	nSpr 
	Dim As SBall Ptr pBall 
	Dim As u32	i, n 

	Select Case  (pMst->nPhase)
	 
	case e_Mst1_PhaseWait 
		pMst->nPhase = e_Mst1_PhaseArrivee 
		return (0) 

	case e_Mst1_PhaseArrivee 		' Descente de la porte.
		pMst->nPosY += &h100 
		if (pMst->nPosY Shr 8) > (WALL_YMin + BRICK_Height + (BRICK_Height / 2)) Then 
			pSpe->nCnt = 16 
			pMst->nAngle = 192 
			pMst->nPhase = e_Mst1_PhaseMove 
		EndIf

	case e_Mst1_PhaseMove 			' Déplacement normal.
		' Changement de direction ?
		pSpe->nCnt-=1
		if (pSpe->nCnt = 0) Then 
			' On passe en cercles ?
			if (pMst->nPosY > (WALL_YMin + 64) Shl 8) Then 
				pMst->nPhase = e_Mst1_PhaseCircle 
			Else
				pMst->nAngle = (rand() And 3) Shl 6 
				pSpe->nCnt = rand() Or 16 			' 16 : Au minimum, 16 frames avant le chgt de dir.
			EndIf
		EndIf
  
		' Déplacement.
		if (Mst1Move(pMst)) Then 
			' Pb, on change de dir.
			pMst->nAngle = (rand() And 3) Shl 6 
		EndIf

	case e_Mst1_PhaseCircle 		' Cercles.
		pMst->nAngle += 2 
		' Déplacement.
		if (Mst1Move(pMst)) Then 
			' Pb, on revient en lignes.
			pMst->nAngle = (rand() And 3) Shl 6 
			pMst->nPhase = e_Mst1_PhaseMove 
			pSpe->nCnt = 128 
		EndIf
	
   End Select

	' Sortie de l´écran ?
	if (pMst->nPosY >= (SCR_Height + 16) Shl 8) Then 
		' Tuage de l´ennemi.
		gMstMisc.nNbMstLev-=1  		' Pour compter le nombre de monstres présents.
		return (-1) 
	EndIf

	nSpr = AnmGetImage(pMst->nAnm) 

	' Le monstre se prend un tir ?
	if MstCheckFire(nSpr, pMst->nPosX Shr 8, pMst->nPosY Shr 8) Then 
		' Score.
		gBreak.nPlayerScore += gpMstTb(pMst->nMstNo).nPoints 
		' Le monstre disparaît.
		DustSet(@gAnm_MstExplo1(0), pMst->nPosX Shr 8, pMst->nPosY Shr 8) 
		' Tuage de l´ennemi.
		gMstMisc.nNbMstLev-=1  		' Pour compter le nombre de monstres présents.
		return (-1) 
	EndIf
  
	' Contact avec le joueur ?
	if AnmGetKey(gBreak.nPlayerAnmNo) <> e_AnmKey_PlyrDeath Then 
		if (SprCheckColBox(AnmGetLastImage(gBreak.nPlayerAnmNo), _
			gBreak.nPlayerPosX, gBreak.nPlayerPosY,_
			nSpr, pMst->nPosX Shr 8, pMst->nPosY Shr 8)) Then 
				' Score.
				if (gBreak.nPhase <> e_Game_SelectLevel) Then 
					gBreak.nPlayerScore += gpMstTb(pMst->nMstNo).nPoints
				EndIf
				' Le monstre disparaît.
				DustSet(@gAnm_MstExplo1(0), pMst->nPosX Shr 8, pMst->nPosY Shr 8) 
				' Tuage de l´ennemi.
				gMstMisc.nNbMstLev-=1  		' Pour compter le nombre de monstres présents.
				return (-1) 
		EndIf
	EndIf
  

	' Contact avec la balle ?
	i = 0
	n = 0
	While (i < BALL_MAX_NB) AndAlso (n < gBreak.nBallsNb)       
		pBall = @gBreak.pBalls(i) 
		if (pBall->nUsed) Then 
			if (SprCheckColBox(pBall->nSpr, pBall->nPosX Shr 8, pBall->nPosY Shr 8, nSpr, pMst->nPosX Shr 8, pMst->nPosY Shr 8)) Then 
			 
				' Score.
				if (gBreak.nPhase <> e_Game_SelectLevel) Then 
					gBreak.nPlayerScore += gpMstTb(pMst->nMstNo).nPoints
				EndIf
  
				' Le monstre disparaît.
				DustSet(@gAnm_MstExplo1(0), pMst->nPosX Shr 8, pMst->nPosY Shr 8) 
				' La balle change de direction, sauf si elle est aimantée.
				if ((pBall->nFlags And BALL_Flg_Aimantee) = 0) Then 
					pBall->nAngle = CUByte(((rand() And 15) Shl 4) + 8) 	' Pour éviter des angles foireux (0, 128).
				EndIf
  
				' Tuage de l´ennemi.
				gMstMisc.nNbMstLev-=1  		' Pour compter le nombre de monstres présents.
				return (-1) 
			
			EndIf
			n+=1  
		EndIf
		i+=1
	Wend

	' Affichage.
	SprDisplay(nSpr Or SPR_Flag_Shadow, pMst->nPosX Shr 8, pMst->nPosY Shr 8, e_Prio_Monstres + gnMstPrio) 

	return (0) 
End Function

'=============================================================================
' Monstre Porte à droite.

' Phases.
enum 
	e_MstDoorR_PhaseClosed = 0,
	e_MstDoorR_PhaseOpened,
	e_MstDoorR_PhaseSuckingIn
End Enum

' Déclenche l´ouverture de la porte.
Sub MstDoorROpen()

	gMstMisc.nMstDoorR = 1 		' On tente de déclencher l´ouverture.

End Sub

' Init.
Sub MstInit_DoorR(pMst As SMstCommon Ptr)

	pMst->nPhase = e_MstDoorR_PhaseClosed 
	gMstMisc.nMstDoorR = 0 		' RAZ interrupteur.

End Sub

' Main.
Function MstMain_DoorR(pMst As SMstCommon Ptr) As s32

	Dim As s32	nSpr 
	
	nSpr = AnmGetImage(pMst->nAnm) 

	Select Case  (pMst->nPhase)
	 
	case e_MstDoorR_PhaseClosed 
		' Interrupteur ?
		if (gMstMisc.nMstDoorR) Then 
			pMst->nPhase = e_MstDoorR_PhaseOpened 
			gMstMisc.nMstDoorR = 0 		' RAZ interrupteur.
		EndIf
		return (0) 

	case e_MstDoorR_PhaseOpened 
		' Contact avec le joueur ?
		if (SprCheckColBox(AnmGetLastImage(gBreak.nPlayerAnmNo),_
			gBreak.nPlayerPosX, gBreak.nPlayerPosY,_
			nSpr, pMst->nPosX Shr 8, pMst->nPosY Shr 8)) Then 
				' Le joueur sera aspiré.
				gBreak.nPlayerFlags Or= PLAYER_Flg_DoorR 
				' Le joueur ne peut plus exploser.
				gBreak.nPlayerFlags Or= PLAYER_Flg_NoKill 
				' Sfx.
				Sfx_PlaySfx(e_Sfx_DoorThrough, e_SfxPrio_40) 
				' Phase monstre.
				pMst->nPhase = e_MstDoorR_PhaseSuckingIn 
		EndIf

	case e_MstDoorR_PhaseSuckingIn 		' On aspire la raquette à l´intérieur (fait au niveau du joueur).
		' vacio
		
	End Select

	' Affichage.
	SprDisplay(nSpr, pMst->nPosX Shr 8, pMst->nPosY Shr 8, e_Prio_Monstres) 
	' Cache pour le joueur si nécessaire.
	if (pMst->nPhase = e_MstDoorR_PhaseSuckingIn) Then 
		SprDisplay(nSpr + 1, pMst->nPosX Shr 8, pMst->nPosY Shr 8, e_Prio_Raquette + 5) 
	EndIf
  
	return (0) 
End Function


'=============================================================================
' Doh !

#define	DOH_LifePts	20

' Phases.
enum 
	e_MstDoh_Appear = 0,
	e_MstDoh_Idle,
	e_MstDoh_Shoot,
	e_MstDoh_Death1,	' Avec les explosions.
	e_MstDoh_Death2	' Disparition.
End Enum 

' Structure spécifique.
Type SMstDoh 
	As u8		nLifePts 	' Points de vie.
	As u8		nDeath1 	' Compteur pour pendant combien de temps on balance des explosions.

	As u16	nCntIdle 	' Pause en idle.

	As u16	nCntAttk 	' Pause entre les tirs.
	As u16	nCntAttkInit 	' Durée de la pause entre les tirs pour reset.
	As u16	nNbAttk 	' Nb de tirs.

	As u8		nNoCol 		' Quand la balle touche, pour ne pas retoucher tant qu´il y a collision.

	As u16	nLastBallPosX(2) 
	As u16	nLastBallPosY(2) 
End Type 

#define	DOH_PauseIdle_Long	100
#define	DOH_PauseIdle_Avg	80
#define	DOH_PauseIdle_Short	60
#define	DOH_PauseShoot	16
' Initialise les timers des différentes phases.
Sub DohInitTimers(pSpe As SMstDoh Ptr)

	Select Case  (pSpe->nLifePts Shr 2)
	 
	case 0 			' Très excité. 1 pause courte et 3 tirs.
		pSpe->nCntIdle = DOH_PauseIdle_Short 
		pSpe->nNbAttk  = 3 
		pSpe->nCntAttk = 1 

	case 1 			' Bien excité. 1 pause courte et 2 tirs.
		pSpe->nCntIdle = DOH_PauseIdle_Short 
		pSpe->nNbAttk  = 2 
		pSpe->nCntAttk = 1 

	case 2 			' Un peu plus excité. 1 pause courte et 1 tir.
		pSpe->nCntIdle = DOH_PauseIdle_Short 
		pSpe->nNbAttk  = 1 
		pSpe->nCntAttk = 1 

	case 3 			' Un peu excité. 1 pause moyenne et 1 tir.
		pSpe->nCntIdle = DOH_PauseIdle_Avg 
		pSpe->nNbAttk  = 1 
		pSpe->nCntAttk = 1 

	case else 		' Pas excité. 1 longue pause et 1 tir.
		pSpe->nCntIdle = DOH_PauseIdle_Long 
		pSpe->nNbAttk  = 1 
		pSpe->nCntAttk = 1 		' Premier shoot : -1 et on tire.
	
  End Select

	pSpe->nCntAttkInit = DOH_PauseShoot 

End Sub

' Init.
Sub MstInit_Doh(pMst As SMstCommon Ptr)

	Dim as SMstDoh Ptr pSpe = Cast(SMstDoh Ptr,@pMst->pData(0)) 

	pMst->nPhase = e_MstDoh_Appear 
	pSpe->nLifePts = DOH_LifePts 
	pSpe->nNoCol = 0 

	DohInitTimers(pSpe) 

End Sub

' Test de collision au pixel (pas bien du tout).
' Note : Vu comme c´est pas bien, envoyer le plus petit sprite en 1, le plus gros en 2.
Function SprCheckColPix(nSpr1 As u32 , nPosX1 As s32 , nPosY1 As s32 , nSpr2 As u32 , nPosX2 As s32 , nPosY2 As s32) As u32

	Dim As s32	nXMin1, nXMax1, nYMin1, nYMax1 
	Dim As s32	nXMin2, nXMax2, nYMin2, nYMax2 
	Dim As SSprite Ptr pSpr1 = SprGetDesc(nSpr1) 
	dim as SSprite Ptr pSpr2 = SprGetDesc(nSpr2) 

	nXMin1 = nPosX1 - pSpr1->nPtRefX 
	nXMax1 = nXMin1 + pSpr1->nLg 
	nYMin1 = nPosY1 - pSpr1->nPtRefY 
	nYMax1 = nYMin1 + pSpr1->nHt 

	nXMin2 = nPosX2 - pSpr2->nPtRefX 
	nXMax2 = nXMin2 + pSpr2->nLg 
	nYMin2 = nPosY2 - pSpr2->nPtRefY 
	nYMax2 = nYMin2 + pSpr2->nHt 

	' Collisions entre les rectangles ?
	if (nXMax1 >= nXMin2) AndAlso (nXMin1 <= nXMax2) AndAlso (nYMax1 >= nYMin2) AndAlso (nYMin1 <= nYMax2) Then 
	 
		' Oui, on va tester au pixel.
		Dim As s32	ix, iy 
		For iy = nYMin1 To nYMax1-1       
			if (iy >= nYMin2) AndAlso (iy < nYMax2) Then 
				for ix = nXMin1 To nXMax1-1       
					if (ix >= nXMin2) AndAlso (ix < nXMax2) Then 
						if ( pSpr1->pGfx[((iy - nYMin1) * pSpr1->nLg) + (ix - nXMin1)] <>0) AndAlso _
							( pSpr2->pGfx[((iy - nYMin2) * pSpr2->nLg) + (ix - nXMin2)] <>0) Then 
							return (1) 
						EndIf
					EndIf
				Next
			EndIf
		Next
		
	EndIf
  
	return (0) 
End Function

' Affichage de la barre de vie du boss.
#define	DohBar_X	250
#define	DohBar_Y	9
Sub DisplayDohLifeBar(nNbLifePts As u32)

	Dim As u32	nLev 
	Dim As u32	nPosX 

	' La barre.
	SprDisplay(e_Spr_BossBar, DohBar_X, DohBar_Y, e_Prio_HUD) 
	SprDisplay(e_Spr_BossBarTop, DohBar_X, DohBar_Y, e_Prio_HUD+2) 

	' Les pts de vie.
	nLev = (32 * nNbLifePts) / DOH_LifePts 
	nPosX = DohBar_X 
	while (nLev >= 8)
		SprDisplay(e_Spr_BossBarPts + 7, nPosX, DohBar_Y, e_Prio_HUD + 1) 
		nPosX += 8 
		nLev -= 8 
	Wend
    
	if (nLev) Then 
		SprDisplay(e_Spr_BossBarPts + nLev - 1, nPosX, DohBar_Y, e_Prio_HUD + 1) 
	EndIf

End Sub

' Main.
Function MstMain_Doh(pMst As SMstCommon Ptr) As s32

	Dim As SMstDoh Ptr pSpe = Cast(SMstDoh Ptr,@pMst->pData(0)) 
	Dim as SBall Ptr pBall 
	Dim As s32	nSpr 
	Dim As u32	rVal 

	' Affichage de la barre de vie du boss.
	DisplayDohLifeBar(pSpe->nLifePts) 

	' En hit ? On affiche le spr et on sort.
	'todo: Si on a une anim d´ouverture/fermeture, on peut mettre un compteur pour le hit au lieu
	' d´une anim et faire continuer l´anim an mettant les sprites en blanc pendant la durée du compteur.
	if (AnmGetKey(pMst->nAnm) = e_AnmKey_MstDohHit) Then 
	' Sauf quand en ´hit´. En plus, ça laisse à la balle le temps de dégager.
		nSpr = AnmGetImage(pMst->nAnm) 
		SprDisplay(nSpr, pMst->nPosX Shr 8, pMst->nPosY Shr 8, e_Prio_Briques) 
		' Last pos de la balle.
		pSpe->nLastBallPosX(2) = pSpe->nLastBallPosX(1) 
		pSpe->nLastBallPosY(2) = pSpe->nLastBallPosY(1) 
		pSpe->nLastBallPosX(1) = pSpe->nLastBallPosX(0) 
		pSpe->nLastBallPosY(1) = pSpe->nLastBallPosY(0) 
		pSpe->nLastBallPosX(0) = gBreak.pBalls(0).nPosX Shr 8 
		pSpe->nLastBallPosY(0) = gBreak.pBalls(0).nPosY Shr 8 
		return (0) 
	EndIf
  
	Select Case  (pMst->nPhase)
	 
	case e_MstDoh_Appear 	' Apparition.
		' Pas pendant la selection du level (Même si on ne devrait pas laisser le choix jusque là...).
		if (gBreak.nPhase <> e_Game_Normal) Then return (0) 

		' Tant que clef != Null
		if (AnmGetKey(pMst->nAnm) <> e_AnmKey_Null) Then Exit select
		' Si Null, c´est que l´apparition est terminée, on passe en Idle.
		pMst->nPhase = e_MstDoh_Idle 
		gBreak.nPlayerFlags And= INV(PLAYER_Flg_BossWait) 	' Signal pour le joueur.
		' En on ne breake pas ! (Même si ça ne serait pas grave).

	case e_MstDoh_Idle 		' Phase d´attente.
		AnmSetIfNew(@gAnm_MstDohIdle(0), pMst->nAnm) 

		' Pas de décompte pendant l´apparition ou la mort du joueur.
		if (AnmGetKey(gBreak.nPlayerAnmNo) <> e_AnmKey_Null) Then Exit Select

		' On passe en phase de tir ?
		pSpe->nCntIdle-=1
		if (pSpe->nCntIdle = 0) Then 
			AnmSetIfNew(@gAnm_MstDohMouthOpens(0), pMst->nAnm) 
			pMst->nPhase = e_MstDoh_Shoot 
			DohInitTimers(pSpe) 	' On change de vitesse si nécessaire.
		EndIf

	case e_MstDoh_Shoot 	' Phase de tir.
		AnmSetIfNew(@gAnm_MstDohShoot(0), pMst->nAnm) 

		' Si ouverture de la bouche pas terminée, stop.
		if (AnmGetKey(pMst->nAnm) <> e_AnmKey_Null) Then Exit Select 

		' Tir ?
		pSpe->nCntAttk-=1
		if (pSpe->nCntAttk = 0) Then 

			' Tir.
			'todo: Calculer une table de SCR_Width éléments. (pour éviter le gros calcul).
			Dim As s32 nAng = CLng( _ 
				(atan2((pMst->nPosY Shr 8) - gBreak.nPlayerPosY, gBreak.nPlayerPosX - (pMst->nPosX Shr 8)) * 128 / 3.1415927) )
			
			if FireAdd(1, pMst->nPosX Shr 8, pMst->nPosY Shr 8, nAng) <> -1 Then 
				Sfx_PlaySfx(e_Sfx_BatMagnet, e_SfxPrio_20) 	' Sfx.
			EndIf
  
			' On repasse en phase de repos ?
			pSpe->nNbAttk-=1
			if ( pSpe->nNbAttk = 0) Then 
				AnmSetIfNew(@gAnm_MstDohMouthCloses(0), pMst->nAnm) 
				DohInitTimers(pSpe) 	' On change de vitesse si nécessaire.
				pMst->nPhase = e_MstDoh_Idle 
			Else
				pSpe->nCntAttk = pSpe->nCntAttkInit 	' Reset du compteur d´attente entre les tirs.
			EndIf
		
		EndIf

	case e_MstDoh_Death1 	' Les explosions.
		AnmSetIfNew(@gAnm_MstDohIdle(0), pMst->nAnm) 
		pSpe->nDeath1-=1
		if (pSpe->nDeath1<>0) Then 
			Dim As SSprite Ptr pSpr = SprGetDesc(AnmGetLastImage(pMst->nAnm)) 
			Dim As s32	nPosX, nPosY 
			nPosX = (pMst->nPosX Shr 8) - pSpr->nPtRefX + (rand() Mod pSpr->nLg) 
			nPosY = (pMst->nPosY Shr 8) - pSpr->nPtRefY + (rand() Mod pSpr->nHt) 
			DustSet(@gAnm_MstExplo1NoSound(0), nPosX, nPosY) 	' Anim sans son, pour ne pas déclencher le sfx à chaque frame.
			' Son d´explosion.
			if ((pSpe->nDeath1 And &h0F) = &h0E) Then 
			' Toutes les 16 frames, dès la première (au premier passage, cpt vaut 255 - 1).
				Sfx_PlaySfx(e_Sfx_Explosion1, e_SfxPrio_40) 	' Sfx explosion.
			EndIf
		Else
			pMst->nPhase = e_MstDoh_Death2
			' Score.
			gBreak.nPlayerScore += gpMstTb(pMst->nMstNo).nPoints 
		EndIf

	case e_MstDoh_Death2 	' La disparition.
		AnmSetIfNew(@gAnm_MstDohDisappears(0), pMst->nAnm) 
		if (AnmGetLastImage(pMst->nAnm) = SPR_NoSprite) Then 
			' Anim terminée, on quitte.
			gBreak.nRemainingBricks = 0 
		EndIf
	End Select

	nSpr = AnmGetImage(pMst->nAnm) 

	' Touché par la balle ?
	pBall = @gBreak.pBalls(0) 	' 1 seule balle dans ce niveau.
	rVal = SprCheckColPix(pBall->nSpr, pBall->nPosX Shr 8, pBall->nPosY Shr 8, nSpr, pMst->nPosX Shr 8, pMst->nPosY Shr 8) 
	if (rVal) Then 
		if (pSpe->nNoCol = 0) Then
			' Rebond de la balle.
			Dim As SSprite Ptr pSpr = SprGetDesc(nSpr) 
			Dim As s32 nXMin, nXMax, nYMin, nYMax 

			nXMin = (pMst->nPosX Shr 8) - pSpr->nPtRefX 
			nXMax = nXMin + pSpr->nLg 
			nYMin = (pMst->nPosY Shr 8) - pSpr->nPtRefY 
			nYMax = nYMin + pSpr->nHt 

			if (pSpe->nLastBallPosY(2) >= nYMin) AndAlso (pSpe->nLastBallPosY(2) <= nYMax) Then
				pBall->nAngle = 128 - pBall->nAngle 
			ElseIf  (pSpe->nLastBallPosX(2) >= nXMin) AndAlso (pSpe->nLastBallPosX(2) <= nXMax) Then
				pBall->nAngle = -pBall->nAngle 
			Else
				' Coin.
				Dim As s32	dx, dy 
				dx = pSpe->nLastBallPosX(2) - (pMst->nPosX Shr 8) 	' Pour le sens.
				dy = pSpe->nLastBallPosY(2) - (pMst->nPosY Shr 8) 
				' J´ai honte, c´est une recopie du code de collision avec la brique.
				if (dx >= 0) AndAlso (dy >= 0) Then 			' Bas droite.
					if (CByte(pBall->nAngle) >= -32) AndAlso (CByte(pBall->nAngle) < 64+32) Then
						pBall->nAngle -= 64 
					Else
						pBall->nAngle += 64 
					EndIf
				ElseIf  (dx >= 0) AndAlso (dy <= 0) Then 	' Haut droite.
					if (pBall->nAngle >= 32) AndAlso (pBall->nAngle < 128+32) Then
						pBall->nAngle -= 64 
					Else
						pBall->nAngle += 64 
					EndIf
				ElseIf  (dx <= 0) AndAlso (dy <= 0) Then 	' Haut gauche.
					if (pBall->nAngle >= 64+32) AndAlso (pBall->nAngle < 192+32) Then
						pBall->nAngle -= 64 
					Else
						pBall->nAngle += 64 
					EndIf
				ElseIf  (dx <= 0) AndAlso (dy >= 0) Then  ' Bas gauche.
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
 
			' Il reste des points de vie ?
			if pSpe->nLifePts<>0 Then 
			 	pSpe->nLifePts-=1
				if pSpe->nLifePts = 0 Then 
					' Death !
					pMst->nPhase  = e_MstDoh_Death1 
					pSpe->nDeath1 = 255 
					' On fait disparaitre la balle avec un dust...
					BallsKill() 
					' ... et le joueur ne peut plus exploser.
					gBreak.nPlayerFlags Or= PLAYER_Flg_NoKill 
					' On fait aussi disparaitre les tirs.
					FireRemoveDohShoots() 
				Else
					' Anim de hit.
					AnmSetIfNew(@gAnm_MstDohHit(0), pMst->nAnm) 
				EndIf
			EndIf
			pSpe->nNoCol = 1 
		EndIf 'viene de -> if (pSpe->nNoCol == 0)
	ElseIf pSpe->nNoCol<>0 Then 
		pSpe->nNoCol = 0 
	EndIf


	' Affichage.
	SprDisplay(nSpr, pMst->nPosX Shr 8, pMst->nPosY Shr 8, e_Prio_Briques) 

	' Last pos de la balle.
	pSpe->nLastBallPosX(2) = pSpe->nLastBallPosX(1) 
	pSpe->nLastBallPosY(2) = pSpe->nLastBallPosY(1) 
	pSpe->nLastBallPosX(1) = pSpe->nLastBallPosX(0) 
	pSpe->nLastBallPosY(1) = pSpe->nLastBallPosY(0) 
	pSpe->nLastBallPosX(0) = gBreak.pBalls(0).nPosX Shr 8 
	pSpe->nLastBallPosY(0) = gBreak.pBalls(0).nPosY Shr 8 
	return (0) 

End Function

'=============================================================================

' Debug, vérification de la taille des structures.
Function MstCheckStructSizes() As u32

	'assert(sizeofXTypeAs  SMstDoh) < MST_COMMON_DATA_SZ) 
	'assert(sizeofXTypeAs  SMstMst1) < MST_COMMON_DATA_SZ) 
	return (0) 
End Function

