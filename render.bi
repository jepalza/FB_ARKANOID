 


enum 
	e_RenderMode_Normal= 0,
	e_RenderMode_Scale2x,
	'
	e_RenderMode_MAX
End Enum

' Param�tres de rendu.
Type SRender 
	' As Note : Je laisse le pointeur pScreen dans gVar.
	' As On fait dans tous les cas le rendu "normal" dans pScreen. Si on a un post-effect � faire, on redirige pScreen dans un buffer secondaire, qu�on recopiera avec l�effet voulu dans l��cran r�el une fois le trac� du jeu fini.

	As SDL_Surface Ptr pScreen2x 		' En modes 2x, ptr sur la surface �cran r�elle.
	As SDL_Surface Ptr pScreenBuf2 	' Buffer de rendu pour le jeu en modes 2x (� la place de la surface �cran r�elle).

	As u8	nRenderMode 			' Mode en cours : normal / 2x.
	As u8	nFullscreenMode 		' Fullscreen ou pas.

End Type
Type As SRender gRender


Declare Sub Render_InitVideo() 
Declare Sub Render_SetVideoMode() 
Declare Sub RenderFlip(nSync As u32) 
Declare Sub RenderRelease() 
Declare Function Render_GetRealVideoSurfPtr() As SDL_Surface Ptr

