 

' Enums.
enum 
	MENU_Null = 0,
	MENU_Main,
	MENU_Game,
	MENU_HallOfFame,
	MENU_Quit
End Enum


' Prototypes.
Declare Sub Fade(nFadeVal As s32) 

Declare Sub MenuInit cdecl() 
Declare Sub MenuMain_Init Cdecl() 
Declare Function MenuMain_Main Cdecl() As u32 
Declare Sub MenuHighScores_Init Cdecl() 
Declare Function MenuHighScores_Main Cdecl() As u32 
Declare Sub MenuGetName_Init Cdecl() 
Declare Function MenuGetName_Main Cdecl() As u32 

Declare Function Scr_CheckHighSc(nScorePrm As u32) As s32 
Declare Sub Scr_Load() 
Declare Sub Scr_Save() 



