 '
' Petit moteur de monstres.
'

#define	MST_MAX_SLOTS	32
Dim Shared As SMstCommon gpMstSlots(MST_MAX_SLOTS-1) 
Dim Shared As u32 gnMstLastUsed 


' RAZ moteur.
Sub MstInitEngine()

	Dim As u32	i 

	' RAZ de tous les slots. (raz=reinicio=reset)
	for i = 0 To MST_MAX_SLOTS -1      
		gpMstSlots(i).nUsed = 0 
	Next
	gnMstLastUsed = 0 

End Sub

' Cherche un slot libre.
' Out : N° d´un slot libre. -1 si erreur.
Function MstGetSlot() As s32

	Dim As u32 i 
	for i = gnMstLastUsed To MST_MAX_SLOTS -1      
		if (gpMstSlots(i).nUsed = 0) Then 
			gnMstLastUsed = i + 1 		' La recherche commencera au suivant.
			return i
		EndIf
	Next
	return -1
End Function

' Libère un slot.
Sub MstReleaseSlot(nSlotNo As u32)

	' Libère l´anim.
	if (gpMstSlots(nSlotNo).nAnm <> -1) Then AnmReleaseSlot(gpMstSlots(nSlotNo).nAnm) 
	' Pour accélérer la recherche des slots libres.
	if (nSlotNo < gnMstLastUsed) Then 
		gnMstLastUsed = nSlotNo 
	EndIf
  
	gpMstSlots(nSlotNo).nUsed = 0 

End Sub

' Ajoute un monstre dans la liste.
Function MstAdd(nMstNo As u32 , nPosX As s32 , nPosY As s32) As s32

	Dim As s32 nSlotNo 

	nSlotNo = MstGetSlot()
	if nSlotNo = -1 Then return (-1) 
	gpMstSlots(nSlotNo).nAnm = -1 
	if (gpMstTb(nMstNo).pAnm <> NULL) Then  ' Si NULL, on ne réserve pas d´anim.
		gpMstSlots(nSlotNo).nAnm = AnmSet(gpMstTb(nMstNo).pAnm, -1)
		if gpMstSlots(nSlotNo).nAnm = -1 Then return (-1)
	EndIf
  
	gpMstSlots(nSlotNo).nUsed = 1 
	gpMstSlots(nSlotNo).nMstNo = nMstNo 

	gpMstSlots(nSlotNo).nPosX = nPosX Shl 8 
	gpMstSlots(nSlotNo).nPosY = nPosY Shl 8 

	gpMstSlots(nSlotNo).nSpd = 0 
	gpMstSlots(nSlotNo).nAngle = 0 
	gpMstSlots(nSlotNo).pFctInit = gpMstTb(nMstNo).pFctInit
	gpMstSlots(nSlotNo).pFctMain = gpMstTb(nMstNo).pFctMain 
	' Appel de la fonction d´init du monstre.
	gpMstSlots(nSlotNo).pFctInit(@gpMstSlots(nSlotNo))

	return (nSlotNo) 
End Function


' Gestion des monstres.
Sub MstManage()

	Dim As u32 i 

	gnMstPrio = 0 
	for i = 0 To MST_MAX_SLOTS-1       
		if gpMstSlots(i).nUsed Then 
			If gpMstSlots(i).pFctMain(@gpMstSlots(i)) = -1 Then 
				' Le monstre est mort, on libère le slot.
				MstReleaseSlot(i) 
			EndIf
			gnMstPrio = (gnMstPrio + 1) And MSTPRIO_AND 
		EndIf
	Next

End Sub


' Teste si un monstre se trouve dans un rectangle (pour retour des briques qui reviennent).
Function MstCheckRectangle(nXMin As s32 , nXMax As s32 , nYMin As s32 , nYMax As s32) As u32

	Dim As u32 i 

	for i = 0 To MST_MAX_SLOTS-1       
		if (gpMstSlots(i).nUsed) Then 
			if (gpMstSlots(i).nPosX >= nXMin) AndAlso _
				(gpMstSlots(i).nPosX <= nXMax) AndAlso _
				(gpMstSlots(i).nPosY >= nYMin) AndAlso _
				(gpMstSlots(i).nPosY <= nYMax) Then _
					Return 1 
		EndIf
	Next

	Return 0
End Function

