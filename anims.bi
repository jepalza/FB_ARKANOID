 
' Codes de contrôle.
#Define BIT31 (1 Shl 31)

Enum 
	e_Anm_Jump  = BIT31 Or 1,	' Ptr + offset.
	e_Anm_Goto	= BIT31 Or 2,	' Initialise une autre anim.
	e_Anm_End	= BIT31 Or 3,	' Fin d´une anim. Renvoie SPR_NoSprite, place e_AnmFlag_End, ne libère pas le slot.
	e_Anm_Kill	= BIT31 Or 4,	' Fin d´une anim. Renvoie -1 et libère le slot (ex: dust).
	e_Anm_Sfx	= BIT31 Or 5	' Joue un son. e_Anm_Sfx, No sfx, Prio sfx.
End Enum 

' Clefs d´anim.	16b = Priorité (à faire) | 16b = No.
#Define ANMPRIO(x) (x Shl 16)
Enum 
	e_AnmKey_Null = 0,
	
	e_AnmKey_PlyrAppear			= ANMPRIO(1) + 0,
	e_AnmKey_PlyrDeath			= ANMPRIO(2) + 0,

	e_AnmKey_MstDohMoutOpens  	= ANMPRIO(1) + 0,
	e_AnmKey_MstDohMoutCloses 	= ANMPRIO(1) + 1,
	e_AnmKey_MstDohAppears    	= ANMPRIO(1) + 2,
	e_AnmKey_MstDohDisappears 	= ANMPRIO(3) + 0,
	e_AnmKey_MstDohHit	     	= ANMPRIO(2) + 0
End Enum
