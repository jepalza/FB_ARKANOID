  
 
'Dim Shared pFctInitPtr2 As Sub ( As Any Ptr)
'Dim shared pFctMainPtr2 As Function ( As Any Ptr) As s32
 
' Structures.
Type SMstTb 
	As u32 pFctInit	
	As u32 pFctMain
	
	As u32 Ptr pAnm 
	As u16 nPoints 
End Type 


' Prototypes.
Declare Sub MstDoorROpen() 
Declare Function MstCheckStructSizes() As u32 	' Debug.


' Liste des monstres.
Enum 
	e_Mst_Pill_0 = 0,		' Pour base du random.
	e_Mst_Pill_Aimant = e_Mst_Pill_0,
	e_Mst_Pill_Mitrailleuse,
	e_Mst_Pill_BallTraversante,
	e_Mst_Pill_BallBigger,
	e_Mst_Pill_BallX3,
	e_Mst_Pill_RaqRallonge,
	e_Mst_Pill_RaqReduit,
	e_Mst_Pill_1Up,
	e_Mst_Pill_DoorR,
	e_Mst_Pill_SpeedUp,
	e_Mst_Pill_SpeedDown,
	e_Mst_Generateur,		' Generateur d´ennemis.
	e_Mst_Mst1,				' Monstres des niveaux (x & 3).
	e_Mst_DoorR,			' Porte à droite.
	e_Mst_Doh				' Doh !
End Enum  


Declare Sub MstInit_Pill(  pMst As SMstCommon Ptr)
Declare Function MstMain_Pill(pMst As SMstCommon Ptr) As s32

Declare Sub MstInit_Generateur(pMst As SMstCommon Ptr)
Declare Function MstMain_Generateur(pMst As SMstCommon Ptr) As s32

Declare Sub MstInit_Mst1(pMst As SMstCommon Ptr)
Declare Function MstMain_Mst1(pMst As SMstCommon Ptr) As s32

Declare Sub MstInit_DoorR(pMst As SMstCommon Ptr)
Declare Function MstMain_DoorR(pMst As SMstCommon Ptr) As s32

Declare Sub MstInit_Doh(pMst As SMstCommon Ptr)
Declare Function MstMain_Doh(pMst As SMstCommon Ptr) As s32



