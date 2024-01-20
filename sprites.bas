 ' Gestion des sprites.




' Pour capture des sprites.
#Define SPR_MAX_NB 2048
Dim Shared As SSprite pSpr(SPR_MAX_NB-1) 
Dim Shared As u32 gnSprNbSprites 		' Nb de sprites captur�s.


' Pour tri des sprites � chaque frame.
Type SSprStockage 
	As u32 nSprNo 
	As s32 nPosX, nPosY 
	As u32 nPrio 
End Type 

#Define SPR_STO_MAX 512
Dim Shared As SSprStockage gpSprSto(SPR_STO_MAX-1)
Dim Shared As SSprStockage Ptr gpSprSort(SPR_STO_MAX-1) 	' Pour tri.


' Initialisation du moteur.
Sub SprInitEngine()

	gnSprNbSprites = 0 	' Nb de sprites captur�s.
	gnSprSto = 0 		' Nb de sprites stock�s pour affichage.

End Sub

' Nettoyage.
Sub SprRelease()

	Dim as u32 i 

	for i = 0 To gnSprNbSprites -1      
		Delete pSpr(i).pGfx
	Next
End Sub

' R�cup�ration des sprites d�une planche.
' In: pSprPal == NULL, on ne sauvegarde pas la palette.
'     pSprPal != NULL, on sauvegarde la palette de nPalIdx � 256.
Sub SprLoadBMP( pFilename As Zstring Ptr ,  pSprPal As SDL_Color Ptr , nPalIdx As u32)

	Dim As SDL_Surface Ptr pPlanche 
	Dim As u32 nNbSprPlanche = 0 

	' Lecture du BMP.
	pPlanche = SDL_LoadBMP(pFilename) 
	if (pPlanche = NULL) Then 
		print "Error cargando BMP (SprLoadBMP): ";*pFilename, SDL_GetError()
		Sleep:End
	EndIf
  
	' Sauvegarde la palette ?
	if (pSprPal <> NULL) Then 
		Dim As SDL_Color Ptr pSrcPal = pPlanche->format->palette->colors 
		Dim As u32 i 
		for i = nPalIdx To 255    
			pSprPal[i - nPalIdx] = pSrcPal[i]
      Next
	EndIf
  

	' On parcourt la planche pour en extraire les sprites.
	Dim As u32 ix, iy 
	Dim As u8 Ptr pPix = cast(u8 ptr,pPlanche->pixels) 

	for iy = 0 To pPlanche->h -1      
		for ix = 0 To pPlanche->w -1  ' On tombe sur un sprite ?
			if (*(pPix + (iy * pPlanche->w) + ix) = 0) Then  ' On a encore de la place ?
				if (gnSprNbSprites >= SPR_MAX_NB) Then 
					Print "Spr: No more sprites slots available." 
					SprRelease() 
					Sleep:End  ' Fain�antise, on peut faire un syst�me de realloc tous les x sprites.
				EndIf
  
				Dim As u32 LgExt, HtExt 
				Dim As u32 PtRefX, PtRefY 		' Pts de ref.
				Dim As u32 ii, ij, ik 

				' Recherche des largeurs ext�rieures (cadre de 1 pixel). + Pts de ref.
				PtRefX = 0 
				LgExt = 1 
				ii = ix + 1 
				While (*(pPix + (iy * pPlanche->w) + ii) = 0) OrElse (*(pPix + (iy * pPlanche->w) + ii + 1) = 0)
					if (*(pPix + (iy * pPlanche->w) + ii) <> 0) Then PtRefX = LgExt - 1 
					ii+=1  
					LgExt+=1  
				Wend

				PtRefY = 0 
				HtExt = 1 
				ii = iy + 1 
				While (*(pPix + (ii * pPlanche->w) + ix) = 0) OrElse (*(pPix + ((ii + 1) * pPlanche->w) + ix) = 0)
					if (*(pPix + (ii * pPlanche->w) + ix) <> 0) Then PtRefY = HtExt - 1 
					ii+=1  
					HtExt+=1  
				Wend

				' Stockage des valeurs.
				pSpr(gnSprNbSprites).nPtRefX = PtRefX 
				pSpr(gnSprNbSprites).nPtRefY = PtRefY 
				pSpr(gnSprNbSprites).nLg = LgExt - 2 
				pSpr(gnSprNbSprites).nHt = HtExt - 2 
				' Avec un seul malloc (taille gfx + taille masque).
				pSpr(gnSprNbSprites).pGfx = cast(u8 Ptr,malloc(pSpr(gnSprNbSprites).nLg * pSpr(gnSprNbSprites).nHt * 2) ) 
				if (pSpr(gnSprNbSprites).pGfx = NULL) Then 
					Print "Spr: malloc failed."
					SprRelease() 
					Sleep:End 
				EndIf
  
				pSpr(gnSprNbSprites).pMask = pSpr(gnSprNbSprites).pGfx + (pSpr(gnSprNbSprites).nLg * pSpr(gnSprNbSprites).nHt) 

				' R�cup�ration du sprite + g�n�ration du masque.
				ik = 0 
				for ij = 0 To HtExt - 3      
					for ii = 0 To LgExt - 3    
						pSpr(gnSprNbSprites).pGfx[ik]  = *(pPix + ((iy + ij + 1) * pPlanche->w) + (ix + ii + 1)) 
						pSpr(gnSprNbSprites).pMask[ik] = IIf(pSpr(gnSprNbSprites).pGfx[ik] , 0 , 255) 
						ik+=1  
               Next
            Next

				' Effacement du sprite dans la planche originale.
				for ij = 0 To HtExt -1       
					For ii = 0 To LgExt -1     
						*(pPix + ((iy + ij) * pPlanche->w) + (ix + ii)) = 255 
               Next
            Next

				' Termin�.
				nNbSprPlanche+=1  
				gnSprNbSprites+=1  
			EndIf
      Next
   Next

	' On lib�re la surface.
	SDL_FreeSurface(pPlanche) 

End Sub

' Renvoie un ptr sur un descripteur de sprite.
Function SprGetDesc(nSprNo As u32) As SSprite Ptr
    return (@pSpr(nSprNo))
End Function


' Affichage d�un sprite. (+ gestion de l�ombre).
' Avec ecran locked.
Sub SprDisplayLock(nSprNo As u32 , nPosX As s32 , nPosY As s32)

	Dim As s32	nXMin, nXMax, nYMin, nYMax 
	Dim As s32	nSprXMin, nSprXMax, nSprYMin, nSprYMax 
	Dim As s32	diff 
	Dim As u8	Ptr pScr = cast(u8 Ptr,gVar.pScreen->pixels)

	Dim As u32	nSprFlags = nSprNo 		' Pour conserver les flags.

	nSprNo And=  INV(SPR_Flag_Shadow) 

	nXMin = nPosX - pSpr(nSprNo).nPtRefX 
	nXMax = nXMin + pSpr(nSprNo).nLg - 1 
	nYMin = nPosY - pSpr(nSprNo).nPtRefY 
	nYMax = nYMin + pSpr(nSprNo).nHt - 1 

	nSprXMin = 0 
	nSprXMax = pSpr(nSprNo).nLg - 1 
	nSprYMin = 0 
	nSprYMax = pSpr(nSprNo).nHt - 1 

	' Clips.
	if (nXMin < 0) Then 
		diff = 0 - nXMin 
		nSprXMin += diff 
	EndIf
  
	if (nXMax > SCR_Width - 1) Then 
		diff = nXMax - (SCR_Width - 1) 
		nSprXMax -= diff 
	EndIf
  
	' Sprite completement en dehors ?
	if (nSprXMin - nSprXMax > 0) Then Exit Sub 

	if (nYMin < 0) Then 
		diff = 0 - nYMin 
		nSprYMin += diff 
	EndIf
  
	if (nYMax > SCR_Height - 1) Then 
		diff = nYMax - (SCR_Height - 1) 
		nSprYMax -= diff 
	EndIf
  
	' Sprite completement en dehors ?
	if (nSprYMin - nSprYMax > 0) Then Exit Sub 

	Dim As s32	ix, iy 
	Dim As u32	b4, b1, b4b, b1b 
	Dim As u8	Ptr pMsk = pSpr(nSprNo).pMask 
	Dim As u8	Ptr pGfx = pSpr(nSprNo).pGfx 
	Dim As s32	nScrPitch = gVar.pScreen->pitch 

	b1b = nSprXMax - nSprXMin + 1 
	b4b = b1b Shr 2 		' Nb de quads.
	b1b And= 3 			' Nb d�octets restants ensuite.
	pScr += ((nYMin + nSprYMin) * nScrPitch) + nXMin 
	pMsk += (nSprYMin * pSpr(nSprNo).nLg) 
	pGfx += (nSprYMin * pSpr(nSprNo).nLg) 

	if (nSprFlags And SPR_Flag_Shadow)<>0 Then  
		' Affichage d�une ombre. (ombre=sombra)
		Dim As u8	Ptr pSrc  = cast(u8 Ptr,gVar.pLevel->pixels) ' Source = image du level.
		Dim As s32	nSrcPitch = gVar.pLevel->pitch

		pSrc += ((nYMin + nSprYMin) * nSrcPitch) + nXMin 

		For iy = nSprYMin To nSprYMax       
			b4 = b4b 
			ix = nSprXMin
			While b4<>0 ' sombra completa desplazada a la derecha (4 bytes), menos el extremo
				*Cast(u32 Ptr,pScr + ix) And= *cast(u32 Ptr,pMsk + ix) ' crea el hueco negro
				*Cast(u32 Ptr,pScr + ix) Or =(*cast(u32 Ptr,pSrc + ix) _ 
								          And INV(*cast(u32 Ptr,pMsk + ix)) ) _
									       + ( INV(*Cast(u32 Ptr,pMsk + ix)) And &h06060606 )
				b4-=1
				ix+=4
			Wend
			b1 = b1b
			While b1<>0 ' resto de la sombra del extremo desplazado derecho, un byte
				*(pScr + ix) And=   *(pMsk + ix) ' crea un hueco negro
				*(pScr + ix) Or = ( *(pSrc + ix) And INV(*(pMsk + ix)) ) + (INV(*(pMsk + ix)) And &h06) 
				b1-=1
				ix+=1
			Wend
			pScr += nScrPitch 
			pSrc += nSrcPitch 
			pMsk += pSpr(nSprNo).nLg 
			pGfx += pSpr(nSprNo).nLg 
      Next

	else
       
		' Affichage normal.
		For iy = nSprYMin To  nSprYMax       
			b4 = b4b 
			ix = nSprXMin
			While b4<>0
				*Cast(u32 Ptr,pScr + ix) And= *Cast(u32 Ptr,pMsk + ix)
				*Cast(u32 Ptr,pScr + ix) Or = *Cast(u32 Ptr,pGfx + ix)
				b4-=1
				ix+=4
			Wend
			b1 = b1b 
			While b1<>0    
				*(pScr + ix) And= *(pMsk + ix) 
				*(pScr + ix) Or = *(pGfx + ix) 
				b1-=1
				ix+=1
			Wend
			pScr += nScrPitch 
			pMsk += pSpr(nSprNo).nLg 
			pGfx += pSpr(nSprNo).nLg 
      Next

	EndIf
  

End Sub



' Inscrit les sprites dans une liste.
Sub SprDisplay(nSprNo As u32 , nPosX As s32 , nPosY As s32 , nPrio As u32)

	if (gnSprSto >= SPR_STO_MAX) Then 
   	Print "Sprites: Out of slots!":Beep:end
	EndIf
  
	if (nSprNo = SPR_NoSprite) Then Exit sub 			' Peut servir pour des clignotements, par exemple.

	gpSprSto(gnSprSto).nSprNo = nSprNo
	gpSprSto(gnSprSto).nPosX  = nPosX 
	gpSprSto(gnSprSto).nPosY  = nPosY 
	gpSprSto(gnSprSto).nPrio  = nPrio

	gpSprSort(gnSprSto) = @gpSprSto(gnSprSto) 	' Pour tri.
'Print "Estoy en SprDisplay:";gnSprSto,nSprNo,nPosX,nPosY,nprio,gpSprSort(gnSprSto)
	gnSprSto+=1  

End Sub



' estructura "SSprStockage"
	' u32 nSprNo 
	' s32 nPosX, nPosY 
	' u32 nPrio 
' La comparaison du qsort.
' -----------------------------------------------------
'    esta rutina NO creo que funcione bien, me parece <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
'    que ordena mal las prioridades
Function qscmp2 Cdecl( pEl1 As SSprStockage , pEl2 As SSprStockage ) As Long
	Dim As u32  spr1 = pEl1.nPrio
	Dim As u32  spr2 = pEl2.nPrio

	Return spr2 - spr1
End Function


'************************************************************
' en lugar de la anterior rutina de ordenacion, empleo esta otra en FB encontrada en el foro FREEBASIC
'************************************************************
Sub QuickSort(ArrayToSort() As SSprStockage Ptr, StartEl As integer, NumEls As Integer)
'************************************************************
'Standard QuickSort Routine
'************************************************************
  Dim Temp As integer
  Dim As Integer First, Last, i, j, StackPtr
  ReDim As Integer QStack(NumEls \ 5 + 10)
    First = StartEl
    Last = StartEl + NumEls - 1
      Do
        Do
          Temp = ArrayToSort((Last + First) \ 2)->nPrio
          i = First
          j = Last
            Do
              While ArrayToSort(i)->nPrio < Temp
                i = i + 1
              Wend
              While ArrayToSort(j)->nPrio > Temp
                j = j - 1
              Wend
              If i > j Then Exit Do
              If i < j Then SWAP ArrayToSort(i), ArrayToSort(j)
              i = i + 1
              j = j - 1
            Loop While i <= j
          If i < Last Then
            QStack(StackPtr) = i
            QStack(StackPtr + 1) = Last
            StackPtr = StackPtr + 2
          End If
          Last = j
        Loop While First < Last
        If StackPtr = 0 Then Exit Do
        StackPtr = StackPtr - 2
        First = QStack(StackPtr)
        Last = QStack(StackPtr + 1)
      Loop
 Erase QStack
End Sub
'************************************************************


	
' Trie la liste des sprites et les affiche.
' A appeler une fois par frame.
Sub SprDisplayAll()

	Dim As u32 i 

	If (gnSprSto = 0) Then Exit Sub 		' Rien � faire ?

	' Tri sur la priorit�.
	' anulo la rutina QSORT (y por ende, el "include crt.bi") por que creo que no ordena bien las prioridades
	'qsort( @gpSprSort(0), gnSprSto-1, sizeof(SSprStockage ptr), CPtr(Any Ptr,@qscmp2) )
	
	' empleo esta en su lugar, que he encontrado en el foro FreeBasic, y solo es un pelin mal lenta
	QuickSort(gpSprSort(),0,gnSprSto-1)

	' Affichage.
	SDL_LockSurface(gVar.pScreen) 
	
	' Premi�re passe pour les ombres (en dessous de tout).
	for i = 0 To gnSprSto-1       
		if (gpSprSort(i)->nSprNo And SPR_Flag_Shadow) Then 
			SprDisplayLock(gpSprSort(i)->nSprNo, gpSprSort(i)->nPosX + SHADOW_OfsX, gpSprSort(i)->nPosY + SHADOW_OfsY)
			gpSprSort(i)->nSprNo And= INV(SPR_Flag_Shadow)
		EndIf
   Next
   
	' Sprites normaux.
	for i = 0 To gnSprSto-1       
		SprDisplayLock(gpSprSort(i)->nSprNo, gpSprSort(i)->nPosX, gpSprSort(i)->nPosY)
	Next
	
	SDL_UnlockSurface(gVar.pScreen) 

	' RAZ pour le prochain tour.
	gnSprSto = 0 

End Sub


' Teste une collision entre 2 sprites.
' Out: 1 col, 0 pas col.
Function SprCheckColBox(nSpr1 As u32 , nPosX1 As s32 , nPosY1 As s32 , nSpr2 As u32 , nPosX2 As s32 , nPosY2 As s32) As u32

	Dim As s32	nXMin1, nXMax1, nYMin1, nYMax1 
	Dim As s32	nXMin2, nXMax2, nYMin2, nYMax2 
	
	Dim As SSprite Ptr pSpr1 = SprGetDesc(nSpr1) 
	Dim As SSprite Ptr pSpr2 = SprGetDesc(nSpr2) 

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
		return (1) 
	EndIf
  
	return (0) 
End Function


