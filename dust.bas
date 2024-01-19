 ' Gestion des poussières.




Type SDust 
	As u8		nUsed 	' 0 = slot vide, 1 = slot occupé.
	As s32	nAnm 		' Anim.
	As s32	nPosX, nPosY 
End Type 

#define	DUST_MAX_SLOTS	64
Dim Shared As SDust gpDustSlots(DUST_MAX_SLOTS-1) 
Dim Shared As u32 gnDustLastUsed 

' RAZ moteur.
Sub DustInitEngine()

	Dim As u32 i 

	' RAZ de tous les slots.
	for i = 0 To DUST_MAX_SLOTS -1      
		gpDustSlots(i).nUsed = 0 
	Next
	gnDustLastUsed = 0 

End Sub

' Cherche un slot libre.
' Out : N° d´un slot libre. -1 si erreur.
Function DustGetSlot() As s32
	Dim As u32	i 

	for i = gnDustLastUsed To DUST_MAX_SLOTS-1       
		if (gpDustSlots(i).nUsed = 0) Then 
			gnDustLastUsed = i + 1 		' La recherche commencera au suivant.
			return (i) 
		EndIf
	Next
	return (-1) 
End Function

' Libère un slot.
Sub DustReleaseSlot(nSlotNo As u32)

	' Libère l´anim.
	AnmReleaseSlot(gpDustSlots(nSlotNo).nAnm) 
	' Pour accélérer la recherche des slots libres.
	if (nSlotNo < gnDustLastUsed) Then 
		gnDustLastUsed = nSlotNo 
	EndIf
  
	gpDustSlots(nSlotNo).nUsed = 0 

End Sub

' Init d´une anim.
' Out : N° du slot. -1 si erreur.
Function DustSet( pAnm As u32 Ptr , nPosX As s32 , nPosY As s32) As s32

	Dim As s32	nSlotNo 

	nSlotNo = DustGetSlot()
	if nSlotNo = -1 Then return (-1) 

	gpDustSlots(nSlotNo).nAnm = AnmSet(pAnm, -1)
	if gpDustSlots(nSlotNo).nAnm = -1 Then return (-1) 

	gpDustSlots(nSlotNo).nUsed = 1 
	gpDustSlots(nSlotNo).nPosX = nPosX 
	gpDustSlots(nSlotNo).nPosY = nPosY 

	return (nSlotNo) 

End Function


' Avance les anims toutes les frames.
Sub DustManage()

	Dim As u32 i 

	for i = 0 To DUST_MAX_SLOTS  -1     
		if (gpDustSlots(i).nUsed) Then 
			Dim As s32	nSpr 

			nSpr = AnmGetImage(gpDustSlots(i).nAnm) 
			if (nSpr = -1) Then 
				' L´anim est finie. On kille la poussière.
				DustReleaseSlot(i) 
			Else
				' Affichage de la poussière.
				SprDisplay(nSpr, gpDustSlots(i).nPosX, gpDustSlots(i).nPosY, e_Prio_Dust) 
			EndIf
		EndIf
	Next

End Sub




