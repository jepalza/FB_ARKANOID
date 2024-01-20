 ' Gestion des animations de sprites.




' Flags.
Enum
	e_AnmFlag_End = 1 '1 Shl 0
End Enum 

Type SAnim 
	As u8 nUsed 		' 0 = slot vide, 1 = slot occupé.
	As u8 nFlags 
	As u32 Ptr pOrg 	' Ptr sur le début de l´anim.
	As u32 Ptr pAnm 
	As u32 nKey 		' Clef d´anim. 16b Priorité | 16b No.
	As u32 nFramesCnt ' Compteur de frames restant pour l´image en cours.
	As u32 nCurSpr 	' N° du sprite en cours.
End Type 

#Define ANM_MAX_SLOTS 64
Dim Shared As SAnim pAnmSlots(ANM_MAX_SLOTS-1) 
Dim Shared As u32 gnAnmLastUsed 

' RAZ moteur.
Sub AnmInitEngine()

	Dim As u32 i 

	' RAZ de tous les slots.
	for i = 0 To ANM_MAX_SLOTS-1       
		pAnmSlots(i).nUsed = 0 
   Next
	gnAnmLastUsed = 0 

End Sub

' Cherche un slot libre.
' Out : N° d´un slot libre. -1 si erreur.
Function AnmGetSlot() As s32

	Dim As u32 i 

	for i = gnAnmLastUsed To ANM_MAX_SLOTS-1       
		if pAnmSlots(i).nUsed = 0 Then 
			gnAnmLastUsed = i + 1 		' La recherche commencera au suivant.
			return (i) 
		EndIf
   Next
   
	return (-1) 
End Function

' Libère un slot.
Sub AnmReleaseSlot(nSlotNo As s32)

	if (nSlotNo = -1) Then return 

	' Pour accélérer la recherche des slots libres.
	if (CLng(nSlotNo) < gnAnmLastUsed) Then 
		gnAnmLastUsed = nSlotNo 
	EndIf
  
	pAnmSlots(nSlotNo).nUsed = 0 

End Sub

' Récupère la clef d´une anim.
Function AnmGetKey(nSlotNo As s32) As u32
	return (pAnmSlots(nSlotNo).nKey) 
End Function

' Teste si l´anim est terminée (e_Anm_End).
' 0 si pas terminée, x si terminée.
Function AnmCheckEnd(nSlotNo As s32) As u32
	return (pAnmSlots(nSlotNo).nFlags And e_AnmFlag_End) 
End Function

' Init une anim si ce n´est pas la même que précédement, et si la priorité est ok.
Function AnmSetIfNew( pAnm As u32 Ptr , nSlotNo As s32) As s32

	if nSlotNo = -1 Then 
		return (AnmSet(pAnm, nSlotNo)) 
	ElseIf pAnmSlots(nSlotNo).pOrg <> pAnm Then
		' Anim différente. On teste la priorité.
		if ((*pAnm) Shr 16) >= (pAnmSlots(nSlotNo).nKey Shr 16) Then 
			return AnmSet(pAnm, nSlotNo)
		EndIf
	EndIf
  
	' C´est la même, ou pas la même mais avec une priorité <, on ne réinitialise pas.
	return (nSlotNo) 
End Function

' Init d´une anim.
' Out : N° du slot. -1 si erreur.
Function AnmSet( pAnm As u32 Ptr , nSlotNo As s32) As s32

	' Si nSlotNo == -1, on cherche un nouveau slot.
	if nSlotNo = -1 Then 
		nSlotNo = AnmGetSlot()
		if nSlotNo = -1 Then return (-1) 
		pAnmSlots(nSlotNo).nUsed = 1 
	EndIf

	pAnmSlots(nSlotNo).nFlags = 0 			' Flags.
	pAnmSlots(nSlotNo).nKey = *pAnm 		' Clef d´anim.
	pAnmSlots(nSlotNo).pOrg =  pAnm 			' Ptr sur le début de l´anim.

	' On fait un GetImage pour initialiser le slot.
	pAnmSlots(nSlotNo).pAnm = pAnm - 1 
	pAnmSlots(nSlotNo).nFramesCnt = 1 
	AnmGetImage(nSlotNo) 

	return (nSlotNo) 
End Function

' Renvoie l´image en cours et avance l´anim.
Function AnmGetImage(nSlotNo As s32) As s32

	' Décrémentation et avancée si nécéssaire.
	pAnmSlots(nSlotNo).nFramesCnt-=1
	if pAnmSlots(nSlotNo).nFramesCnt = 0 Then 
		
		pAnmSlots(nSlotNo).pAnm += 2 		' Avance le ptr sur la suite.
		while ((*pAnmSlots(nSlotNo).pAnm) And BIT31) <> 0
		 
			' Code de contrôle.
			Select Case *pAnmSlots(nSlotNo).pAnm
			 
			case e_Anm_Jump 	' Ajoute un offset au pointeur.
				pAnmSlots(nSlotNo).pAnm += *Cast(s32 ptr,(pAnmSlots(nSlotNo).pAnm + 1)) ' * 2;

			case e_Anm_Goto 	' Fait sauter le pointeur à une autre adresse.
				pAnmSlots(nSlotNo).pAnm = Cast(u32 ptr,*(pAnmSlots(nSlotNo).pAnm + 1)) 
				pAnmSlots(nSlotNo).pOrg =   pAnmSlots(nSlotNo).pAnm 
				pAnmSlots(nSlotNo).nKey = *(pAnmSlots(nSlotNo).pAnm) 		' Clef d´anim.
				pAnmSlots(nSlotNo).pAnm+=1  

			case e_Anm_End 		' Fin de l´anim. Place le flag End et renvoie SPR_NoSprite.
				pAnmSlots(nSlotNo).pAnm -= 2 			' Recule le ptr pour repointer sur e_Anm_End au prochain tour.
				pAnmSlots(nSlotNo).nFramesCnt = 1 		' Reset compteur.
				pAnmSlots(nSlotNo).nCurSpr = SPR_NoSprite 	' End => No Sprite.
				pAnmSlots(nSlotNo).nFlags Or= e_AnmFlag_End 	' Flag.
				return (pAnmSlots(nSlotNo).nCurSpr) 

			case e_Anm_Kill 	' Fin de l´anim + libération du slot.
				AnmReleaseSlot(nSlotNo) 
				return (-1) 

			case e_Anm_Sfx 		' Joue un son.
				Sfx_PlaySfx(*(pAnmSlots(nSlotNo).pAnm + 1), *(pAnmSlots(nSlotNo).pAnm + 2)) 
				pAnmSlots(nSlotNo).pAnm += 3 

			case else 
				Print "Anm: Unknown control code." 
			
			End Select
		
		Wend
		
		' Image.
		pAnmSlots(nSlotNo).nFramesCnt =  *pAnmSlots(nSlotNo).pAnm 		' Compteur de frames restant pour l´image en cours.
		pAnmSlots(nSlotNo).nCurSpr    = *(pAnmSlots(nSlotNo).pAnm + 1) ' N° du sprite en cours.
	
	EndIf
  
	return (pAnmSlots(nSlotNo).nCurSpr) 	' N° du sprite en cours.

End Function


' Renvoie la dernière image affichée.
Function AnmGetLastImage(nSlotNo As s32) As s32
	return (pAnmSlots(nSlotNo).nCurSpr) 	' N° du sprite en cours.
End Function

