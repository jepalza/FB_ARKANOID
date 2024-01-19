 



' itoa.
Sub MyItoA(nNb As s32 , pDst As String)

	' he reconstruido por completo esta rutina
	' para acomodarla a los "gustos" del FB
	Dim As Integer a
	Dim As String sa
	a=InStrRev(pDst," ")
	If a=0 Then sa=pDst Else sa=Mid(pDst,a+1)
	sa=Right(sa+Trim(Str(nNb)),Len(sa))
	If a=0 Then pDst=sa Else pDst=Left(pDst,a)+sa

End Sub


' Affichage d´une phrase en sprites.
' Renvoie la largeur en pixels de la phrase.
Function Font_Print(nPosX As s32 , nPosY As s32 ,  pStrs2 As String , nFlags As u32) As u32

	Dim As u32 pStrs=1
	Dim As Byte	cChr 
	Dim As SSprite	Ptr pSprs 
	Dim As s32	nPosXOrg = nPosX 

	while pStrs<=Len(pStrs2)
		cChr  = Asc(Mid(pStrs2,pStrs,1)) : pStrs+=1  
		cChr -= Asc(" ") 
		if (cChr <> 0) Then 
			' Char normal.
			cChr-=1  
			pSprs = SprGetDesc(e_Spr_FontSmall + cChr) 
			if ((nFlags And FONT_NoDisp) = 0) Then 
				SprDisplay(e_Spr_FontSmall + cChr, nPosX, nPosY, e_Prio_HUD) 
			EndIf
		Else
			' Espace, on avance de la taille d´un ´I´.
			pSprs = SprGetDesc( e_Spr_FontSmall + Asc("I") - Asc(" ") ) 
		EndIf
		nPosX += pSprs->nLg + 1 
	Wend

	return nPosX - nPosXOrg 
End Function



