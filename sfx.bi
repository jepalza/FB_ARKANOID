 
' Prototypes.
Declare Sub Sfx_SoundInit() 
Declare Sub Sfx_SoundOn() 
Declare Sub Sfx_SoundOff() 
Declare Sub Sfx_LoadWavFiles() 
Declare Sub Sfx_FreeWavFiles() 
Declare Sub Sfx_PlaySfx(nSfxNo As u32 , nSfxPrio As u32) 


' Enums.
Enum
 	e_Sfx_PillBonus,
	e_Sfx_PillMalus,
	e_Sfx_Shot,
	e_Sfx_DoorThrough,
	e_Sfx_MenuClic,
	e_Sfx_BrickBounce,
	e_Sfx_BallBounce,
	e_Sfx_Explosion1,
	e_Sfx_Explosion2,
	e_Sfx_BrickDissolve,
	e_Sfx_ExtraLife,
	e_Sfx_BatPing,
	e_Sfx_BatMagnet,
	e_Sfx_LAST
End Enum  


Enum 
	e_SfxPrio_0 = 0,
	e_SfxPrio_10 = 10,
	e_SfxPrio_20 = 20,
	e_SfxPrio_30 = 30,
	e_SfxPrio_40 = 40,
	e_SfxPrio_Max = 254
End Enum 
