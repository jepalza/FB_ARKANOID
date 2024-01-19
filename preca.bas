 

#define PI 3.1415927

' Précalcul des tables de sinus-cosinus.
' 256 angles, val *256 (=> varie de -256 à 256).
Sub PrecaSinCos()

	Dim As u32	i 

	for i = 0 To (256 + 64)-1       
		gVar.pSinCos(i) = CInt(Cos(i * 2 * PI / 256) * 256) 
	Next
	gVar.pSin = @gVar.pSinCos(0)+64
	gVar.pCos = @gVar.pSinCos(0) 

End Sub


