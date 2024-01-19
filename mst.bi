 
Type pFctInitPtr1 As Sub ( As Any Ptr)
'Dim Shared pFctInitPtr1 As Sub ( As Any Ptr)
Type pFctMainPtr1 As Function ( As Any Ptr) As s32
'Dim Shared pFctMainPtr1 As Function ( As Any Ptr) As s32
 

' Structure commune à tous les monstres.
#define MST_COMMON_DATA_SZ  64
Type SMstCommon 
	As u8	nUsed 			' 0 = slot vide, 1 = slot occupé.
	As u8	nMstNo 			' No du monstre.

	As pFctInitPtr1 pFctInit ' Fct d´init du monstre.	
	As pFctMainPtr1 pFctMain ' Fct principale du monstre.
	'As u32 pFctInit ' Fct d´init du monstre.	
	'As u32 pFctMain ' Fct principale du monstre.
	
	As s32	nPosX, nPosY 
	As s32	nSpd 
	As u8		nAngle 
	As s32	nAnm 			' Anim.
	As u8		nPhase 

	As u8		pData(MST_COMMON_DATA_SZ) 	' On fera pointer les structures spécifiques ici.
End Type 

Dim Shared As u32 gnMstPrio 		' Pour priorité de l´affichage.

#define	MSTPRIO_AND	31

' Prototypes.
Declare Sub MstInitEngine() 
Declare Sub MstManage() 
Declare Function MstAdd(nMstNo As u32 , nPosX As s32 , nPosY As s32) As s32 

Declare Function MstCheckRectangle(nXMin As s32 , nXMax As s32 , nYMin As s32 , nYMax As s32) As u32 


