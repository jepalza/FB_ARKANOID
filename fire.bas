 ' Gestion des tirs.



' Définition des tirs.
Type SFireRecord 
	As u32	Ptr pAnm 
	As s32	nSpeed 
	As u8	nAngle 
	As u8	nPlyr 		' 1 = Tir du joueur, 0 = Tir d´un monstre;
	As u32	Ptr pAnmDust 	' Anim de disparition. NULL si pas utilisée.

End Type 

Dim Shared As SFireRecord gpFireTable(1) 
	gpFireTable(0)=Type( @gAnm_PlyrShot(0)  , &h400, 64    , 1 , NULL )	
	gpFireTable(1)=Type( @gAnm_DohMissile(0), &h200, 64+128, 0 , @gAnm_DohMissileDisp(0) ) 
	
'As todo: rajouter un dust générique pour le tir ?




Type SFire 
	As u8		nUsed 			' 0 = slot vide, 1 = slot occupé.
	As s32	nAnm 			' Anim.
	As s32	nPosX, nPosY 	' 8b de virgule fixe.
	As s32	nSpeed 
	As u8		nAngle 
	As u8		nPlyr 
	As u32	Ptr pAnmDust 		' Anim de disparition. NULL si pas utilisée.
End Type

#define	FIRE_MAX_SLOTS	64
Dim Shared As SFire gpFireSlots(FIRE_MAX_SLOTS) 
Dim Shared As u32 gnFireLastUsed 


' RAZ moteur.
Sub FireInitEngine()

	Dim As u32	i 

	' RAZ de tous les slots.
	for i = 0 To FIRE_MAX_SLOTS -1      
		gpFireSlots(i).nUsed = 0 
	Next
	gnFireLastUsed = 0 

End Sub

' Cherche un slot libre.
' Out : N° d´un slot libre. -1 si erreur.
Function FireGetSlot() As s32

	Dim As u32	i 

	for  i = gnFireLastUsed To FIRE_MAX_SLOTS -1      
		if (gpFireSlots(i).nUsed = 0) Then 
			gnFireLastUsed = i + 1 		' La recherche commencera au suivant.
			return (i) 
		EndIf
	Next
	
	return (-1) 
End Function

' Libère un slot.
Sub FireReleaseSlot(nSlotNo As u32)

	' Libère l´anim.
	AnmReleaseSlot(gpFireSlots(nSlotNo).nAnm) 
	' Pour accélérer la recherche des slots libres.
	if (nSlotNo < gnFireLastUsed) Then 
		gnFireLastUsed = nSlotNo 
	EndIf
  
	gpFireSlots(nSlotNo).nUsed = 0 

End Sub

' Init d´un tir.
' In : sAngle = -1 => On prend l´angle par défaut. Sinon val [0;255] => Angle.
' Out : N° du slot. -1 si erreur.
Function FireAdd(nShot As u32 , nPosX As s32 , nPosY As s32 , nAngle As s32) As s32

	Dim As s32	nSlotNo 

	nSlotNo = FireGetSlot()
	if nSlotNo = -1 Then return (-1) 
	gpFireSlots(nSlotNo).nAnm = AnmSet(gpFireTable(nShot).pAnm, -1)
	if gpFireSlots(nSlotNo).nAnm  = -1 Then return (-1) 

	gpFireSlots(nSlotNo).nUsed  = 1 
	gpFireSlots(nSlotNo).nPosX  = nPosX Shl 8 
	gpFireSlots(nSlotNo).nPosY  = nPosY Shl 8 
	gpFireSlots(nSlotNo).nSpeed = gpFireTable(nShot).nSpeed 
	gpFireSlots(nSlotNo).nAngle = iif(nAngle = -1 , gpFireTable(nShot).nAngle , (nAngle And &hFF)) 
	gpFireSlots(nSlotNo).nPlyr  = gpFireTable(nShot).nPlyr 
	gpFireSlots(nSlotNo).pAnmDust = gpFireTable(nShot).pAnmDust 

	return (nSlotNo) 
End Function


' Gestion des tirs.
Sub FireManage()

	Dim As u32 i 

	for i = 0 To FIRE_MAX_SLOTS-1       
		if (gpFireSlots(i).nUsed) Then 
			Dim As s32 nSpr 

			nSpr = AnmGetImage(gpFireSlots(i).nAnm) 
			if (nSpr = -1) Then 
				' L´anim est finie. On kille le tir.
				FireReleaseSlot(i) 
			Else
				' Déplacement du tir.
				gpFireSlots(i).nPosX += (gVar.pCos[gpFireSlots(i).nAngle] * gpFireSlots(i).nSpeed) Shr 8 
				gpFireSlots(i).nPosY += (gVar.pSin[gpFireSlots(i).nAngle] * gpFireSlots(i).nSpeed) Shr 8 
				' Clip ? (simplifié, le joueur tire vers le haut, le boss vers le bas).
				if (gpFireSlots(i).nPosY Shr 8 <= WALL_YMin) OrElse (gpFireSlots(i).nPosY Shr 8 >= SCR_Height + 5) Then 
					FireReleaseSlot(i) 
					' eventuellement, dust.
					goto _Skip 
				EndIf

				' Spécifique au casse-brique, on teste les collisions briques-tir ici.
				if (gpFireSlots(i).nPlyr) Then 
					' Collision avec une brique ?
					' Avancement < hauteur d´une brique => On teste en (x,y) directement.
					Dim As s32 nBx, nBy 
				'todo: comme pour CollBricks(), on peut faire deux tables pour éviter toutes ces divisions. (??? Dans CollBricks, le test n´a pas été concluant...).
					nBx = ((gpFireSlots(i).nPosX Shr 8) - WALL_XMin) / BRICK_Width 
					nBy = ((gpFireSlots(i).nPosY Shr 8) - WALL_YMin) / BRICK_Height 
					if BrickHit(nBx, nBy, 0) <> -1 Then 
						FireReleaseSlot(i) 
						' ... eventuellement, dust. A placer en bas de la brique.
						goto _Skip 
					EndIf
				EndIf
				' Collision avec un monstre ? => Les monstres viendront tester les tirs.

				' Affichage du tir.
				SprDisplay(nSpr, gpFireSlots(i).nPosX Shr 8, gpFireSlots(i).nPosY Shr 8, e_Prio_Tirs) 
_Skip:
				' ein? i = i 
			EndIf
		EndIf
	Next

End Sub


'=============================================================================
' Teste si un monstre se prend un tir.
' Out: 0 = Pas de choc / 1 = Hit. (Eventuellement, renvoyer le nb de pts de dégats...).
Function MstCheckFire(nSpr As u32 , nPosX As s32 , nPosY As s32) As u32', u32 pDustAnm = NULL)	// Pour dust particulier en fct du monstre. Si NULL, utiliser dust générique.

	Dim As u32	i 

	Dim As s32	nXMin1, nXMax1, nYMin1, nYMax1 
	Dim As SSprite Ptr pSpr1 = SprGetDesc(nSpr) 

	nXMin1 = nPosX  - pSpr1->nPtRefX 
	nXMax1 = nXMin1 + pSpr1->nLg 
	nYMin1 = nPosY  - pSpr1->nPtRefY 
	nYMax1 = nYMin1 + pSpr1->nHt 

	nXMin1 Shl = 8: nXMax1 Shl = 8 		' Décalage, pour optimiser les comparaisons.
	nYMin1 Shl = 8: nYMax1 Shl = 8 		' Ca évitera de faire un décalage pour chaque tir, et pour chaque monstre.

	for i = 0 To FIRE_MAX_SLOTS-1       
		if (gpFireSlots(i).nUsed) Then 
			' Le test suivant est commenté pour le casse briques :
			' Ne sert à rien parce qu´il n´y a que le joueur qui tire, sauf au niveau du boss, dans lequel le joueur ne peut pas tirer.
				' On teste juste un point. Si on veut les rectangles, appeler SprCheckColBox().
				if (gpFireSlots(i).nPosX >= nXMin1) AndAlso (gpFireSlots(i).nPosX <= nXMax1) AndAlso (gpFireSlots(i).nPosY >= nYMin1) AndAlso (gpFireSlots(i).nPosY <= nYMax1) Then 
					' Dust ok, mais pas utilisé. (Quand le joueur se prend un tir au niveau du boss, ça ne se voit tellement pas qu´autant le laisser commenté).
					' Dust de disparition.
					FireReleaseSlot(i) 
					return (1) 
					' Pour d´autres types de jeu, continuer la boucle pour que l´ennemi puisse se prendre plusieurs balles en 1 fois et/ou arrêter les tirs.
				EndIf
		EndIf
	Next

	return (0) 

End Function


'=============================================================================
' Supprime les tirs du boss et les remplace par un dust.
Sub FireRemoveDohShoots()

	Dim As u32	i 

	for i = 0 To FIRE_MAX_SLOTS -1      
		if (gpFireSlots(i).nUsed) Then 
			' Dust de disparition.
			if (gpFireSlots(i).pAnmDust <> NULL) Then 
				DustSet(gpFireSlots(i).pAnmDust, gpFireSlots(i).nPosX Shr 8, gpFireSlots(i).nPosY Shr 8) 
			EndIf
			FireReleaseSlot(i) 
		EndIf
	Next

End Sub


