
#Define INV(x) -1-1*(x) 'Not(x) 
 
#Define u32 ULong
#Define u16 UShort
#Define u8  UByte

#Define s32 Long
#Define s16 Short
#Define s8  Byte
 
 
' Includes.
#Include "SDL/SDL.bi"


#include "render.bi"
#include "preca.bi"
#include "breaker.bi"
#include "frame.bi"
#include "sprites.bi"
#include "animspr.bi"
#include "anims.bi"
#include "dust.bi"
#include "fire.bi"
#include "mst.bi"
#include "monsters.bi"
#include "font.bi"
#include "menu.bi"
#include "sfx.bi"

'#Include "crt.bi" ' para QSORT en SPRITES.BAS


' Define.
#define  SCR_Width  320  ' resolucion real, luego se hace x2
#define  SCR_Height 240

#define	SHADOW_OfsX	4
#define	SHADOW_OfsY	4

#define	GFX_NbBkg	5
#define	MENU_NbBkg	2

#define	MOUSE_BtnLeft	1	' Masques binaires.
#define	MOUSE_BtnRight	2

#define	SPR_Palette_Idx	128	' 0 à x : Palette du décor / x à 256 : Palette des sprites.

' Types de variables.
Type SGene 
	As SDL_Surface Ptr pScreen 	' Ptr sur le buffer écran.
	As SDL_Surface Ptr pLevel 	' Ptr sur l´image de fond d´un level.
	As SDL_Surface Ptr pLev(GFX_NbBkg-1) 	' Les images de fond.
	As SDL_Surface Ptr pBackground 		' Ptr sur l´images de fond des menus.
	As SDL_Rect		Ptr pBkgRect 			' Ptr sur le rect pour déplacer le blit.
	As SDL_Rect			 sBkgRect 			' Rect pour déplacer le blit.
	As SDL_Surface Ptr pBkg(MENU_NbBkg-1) 	' Les images de fond.

	As u8	Ptr pKeys 		' Buffer clavier.

	As SDL_Color pColors(256 -1) 	' Palette générale, à réinitialiser au changement de mode.
	As SDL_Color pSprColors(256 - SPR_Palette_Idx) 	' Palette des sprites.

	As s16	pSinCos(256 + 64 -1) 	' Table contenant les sin et cos * 256, sur 256 angles.
	As s16	Ptr pSin 			' Ptrs sur les tables.
	As s16	Ptr pCos 

	As s32	nMousePosX, nMousePosY 	' Position de la souris.
	As u8		nMouseButtons 			' Boutons de la souris

	As s32	nFadeVal 		' 0 = Noir / 256 = Couleurs finales.
End Type 

' Structure d´échange entre les différents modules.
Type SExg 
	As u32	nExitCode 	' Pour sortie du jeu. Tjs à 0, sauf pour sortie.
	As u32	nLevel 		' Level atteint au game over.
	As u32	nScore 		' Score au game over.
End Type 

' Variables générales.Dim Shared As XTypeAs SGene:XDim Shared As TypeAs SExg 


