 


' 1 u32 : 1 clef.
' Ensuite :
' 1 u32 : Nb de frames d´affichage
'  Si b31, code de contrôle : Voir liste en haut de anims.h.
' 1 u32 : N° du sprite.


' Raquette joueur.
Dim Shared As u32 gAnm_Raquette(...) = _
{ _
e_AnmKey_Null, _
65000, e_Spr_Raquette, _
e_Anm_Jump, Cast(u32, -2) _
} 

' Raquette, apparition.
Dim Shared As u32 gAnm_RaqAppear(...) = _
{ _
	e_AnmKey_PlyrAppear, _
	4, e_Spr_RaquetteApparition, _
	4, e_Spr_RaquetteApparition + 1, _
	4, e_Spr_RaquetteApparition + 2, _
	4, e_Spr_RaquetteApparition + 3, _
	4, e_Spr_RaquetteApparition + 4, _
	4, e_Spr_RaquetteApparition + 5, _
	4, e_Spr_RaquetteApparition + 6, _
	4, e_Spr_RaquetteApparition + 7, _
	4, e_Spr_RaquetteApparition + 8, _
	4, e_Spr_RaquetteApparition + 9, _
	4, e_Spr_RaquetteApparition + 10, _
	4, e_Spr_RaquetteApparition + 11, _
	4, e_Spr_RaquetteApparition + 12, _
	4, e_Spr_RaquetteApparition + 13, _
	e_Anm_Goto, Cast(u32, @gAnm_Raquette(0)) _
} 

' Raquette, aimant.
Dim Shared As u32 gAnm_RaqAimant(...) = _
{ _
	e_AnmKey_Null, _
	15, e_Spr_RaquetteAimant, _
	8, e_Spr_RaquetteAimant+1, _
	8, e_Spr_RaquetteAimant+2, _
	8, e_Spr_RaquetteAimant+1, _
	e_Anm_Goto, Cast(u32, @gAnm_RaqAimant(0)) _
} 

' Joueur, mort (sz 0).
Dim Shared As u32 gAnm_RaqDeath0(...) = _
{ _
	e_AnmKey_PlyrDeath, _
	e_Anm_Sfx, e_Sfx_Explosion2, e_SfxPrio_40, _
	5, e_Spr_RaquetteDeathSz0, _
	5, e_Spr_RaquetteDeathSz0 + 1, _
	5, e_Spr_RaquetteDeathSz0 + 2, _
	5, e_Spr_RaquetteDeathSz0 + 3, _
	5, e_Spr_RaquetteDeathSz0 + 4, _
	5, e_Spr_RaquetteDeathSz0 + 5, _
	5, e_Spr_RaquetteDeathSz0 + 6, _
	5, e_Spr_RaquetteDeathSz0 + 7, _
	e_Anm_End _
} 

' Joueur, mort (sz 1).
Dim Shared As u32 gAnm_RaqDeath1(...) = _
{ _
	e_AnmKey_PlyrDeath, _
	e_Anm_Sfx, e_Sfx_Explosion2, e_SfxPrio_40, _
	5, e_Spr_RaquetteDeathSz1, _
	5, e_Spr_RaquetteDeathSz1 + 1, _
	5, e_Spr_RaquetteDeathSz1 + 2, _
	5, e_Spr_RaquetteDeathSz1 + 3, _
	5, e_Spr_RaquetteDeathSz1 + 4, _
	5, e_Spr_RaquetteDeathSz1 + 5, _
	5, e_Spr_RaquetteDeathSz1 + 6, _
	5, e_Spr_RaquetteDeathSz1 + 7, _
	e_Anm_End _
} 

' Joueur, mort (sz 2).
Dim Shared As u32 gAnm_RaqDeath2(...) = _
{ _
	e_AnmKey_PlyrDeath, _
	e_Anm_Sfx, e_Sfx_Explosion2, e_SfxPrio_40, _
	5, e_Spr_RaquetteDeathSz2, _
	5, e_Spr_RaquetteDeathSz2 + 1, _
	5, e_Spr_RaquetteDeathSz2 + 2, _
	5, e_Spr_RaquetteDeathSz2 + 3, _
	5, e_Spr_RaquetteDeathSz2 + 4, _
	5, e_Spr_RaquetteDeathSz2 + 5, _
	5, e_Spr_RaquetteDeathSz2 + 6, _
	5, e_Spr_RaquetteDeathSz2 + 7, _
	e_Anm_End _
} 

' Joueur, mort (sz 3).
Dim Shared As u32 gAnm_RaqDeath3(...) = _
{ _
	e_AnmKey_PlyrDeath, _
	e_Anm_Sfx, e_Sfx_Explosion2, e_SfxPrio_40, _
	5, e_Spr_RaquetteDeathSz3, _
	5, e_Spr_RaquetteDeathSz3 + 1, _
	5, e_Spr_RaquetteDeathSz3 + 2, _
	5, e_Spr_RaquetteDeathSz3 + 3, _
	5, e_Spr_RaquetteDeathSz3 + 4, _
	5, e_Spr_RaquetteDeathSz3 + 5, _
	5, e_Spr_RaquetteDeathSz3 + 6, _
	5, e_Spr_RaquetteDeathSz3 + 7, _
	e_Anm_End _
} 

' Raquette, se rallonge (0).
Dim Shared As u32 gAnm_RaqRallonge0(...) = _
{ _
e_AnmKey_Null, _
2, e_Spr_RaquetteRallonge0, _
2, e_Spr_RaquetteRallonge0+1, _
2, e_Spr_RaquetteRallonge0+2, _
2, e_Spr_RaquetteRallonge0+3, _
2, e_Spr_RaquetteRallonge0+4, _
2, e_Spr_RaquetteRallonge0+5, _
65000, e_Spr_Raquette, _
e_Anm_Jump, Cast(u32, -2) _
} 

' Raquette, se réduit (0).
Dim Shared As u32 gAnm_RaqReduit0(...) = _
{ _
	e_AnmKey_Null, _
	2, e_Spr_Raquette, _
	2, e_Spr_RaquetteRallonge0+5, _
	2, e_Spr_RaquetteRallonge0+4, _
	2, e_Spr_RaquetteRallonge0+3, _
	2, e_Spr_RaquetteRallonge0+2, _
	2, e_Spr_RaquetteRallonge0+1, _
	65000, e_Spr_RaquetteRallonge0, _
	e_Anm_Jump, Cast(u32, -2) _
} 

' Raquette, se rallonge (1).
Dim Shared As u32 gAnm_RaqRallonge1(...) = _
{ _
	e_AnmKey_Null, _
	2, e_Spr_Raquette, _
	2, e_Spr_RaquetteRallonge1, _
	2, e_Spr_RaquetteRallonge1+1, _
	2, e_Spr_RaquetteRallonge1+2, _
	2, e_Spr_RaquetteRallonge1+3, _
	2, e_Spr_RaquetteRallonge1+4, _
	65000, e_Spr_RaquetteRallonge1+5, _
	e_Anm_Jump, Cast(u32, -2) _
} 

' Raquette, se réduit (1).
Dim Shared As u32 gAnm_RaqReduit1(...) = _
{ _
	e_AnmKey_Null, _
	2, e_Spr_RaquetteRallonge1+5, _
	2, e_Spr_RaquetteRallonge1+4, _
	2, e_Spr_RaquetteRallonge1+3, _
	2, e_Spr_RaquetteRallonge1+2, _
	2, e_Spr_RaquetteRallonge1+1, _
	2, e_Spr_RaquetteRallonge1, _
	65000, e_Spr_Raquette, _
	e_Anm_Jump, Cast(u32, -2) _
} 

' Raquette, se rallonge (2).
Dim Shared As u32 gAnm_RaqRallonge2(...) = _
{ _
	e_AnmKey_Null, _
	2, e_Spr_RaquetteRallonge1+5, _
	2, e_Spr_RaquetteRallonge2, _
	2, e_Spr_RaquetteRallonge2+1, _
	2, e_Spr_RaquetteRallonge2+2, _
	2, e_Spr_RaquetteRallonge2+3, _
	2, e_Spr_RaquetteRallonge2+4, _
	65000, e_Spr_RaquetteRallonge2+5, _
	e_Anm_Jump, Cast(u32, -2) _
} 

' Raquette, se réduit (2).
Dim Shared As u32 gAnm_RaqReduit2(...) = _
{ _
	e_AnmKey_Null, _
	2, e_Spr_RaquetteRallonge2+5, _
	2, e_Spr_RaquetteRallonge2+4, _
	2, e_Spr_RaquetteRallonge2+3, _
	2, e_Spr_RaquetteRallonge2+2, _
	2, e_Spr_RaquetteRallonge2+1, _
	2, e_Spr_RaquetteRallonge2, _
	65000, e_Spr_RaquetteRallonge1+5, _
	e_Anm_Jump, Cast(u32, -2) _
} 

' Raquette, mitrailleuse gauche, repos.
Dim Shared As u32 gAnm_RaqMitGRepos(...) = _
{ _
	e_AnmKey_Null, _
	65000, e_Spr_RaquetteMitrG, _
	e_Anm_Jump, Cast(u32, -2) _
} 

' Raquette, mitrailleuse droite, repos.
Dim Shared As u32 gAnm_RaqMitDRepos(...) = _
{ _
	e_AnmKey_Null, _
	65000, e_Spr_RaquetteMitrD, _
	e_Anm_Jump, Cast(u32, -2) _
} 

' Raquette, mitrailleuse gauche, tir.
Dim Shared As u32 gAnm_RaqMitGShoot(...) = _
{ _
	e_AnmKey_Null, _
	2, e_Spr_RaquetteMitrG+1, _
	2, e_Spr_RaquetteMitrG+2, _
	2, e_Spr_RaquetteMitrG+3, _
	e_Anm_Goto, Cast(u32, @gAnm_RaqMitGRepos(0)) _
} 

' Raquette, mitrailleuse droite, tir.
Dim Shared As u32 gAnm_RaqMitDShoot(...) = _
{ _
	e_AnmKey_Null, _
	2, e_Spr_RaquetteMitrD+1, _
	2, e_Spr_RaquetteMitrD+2, _
	2, e_Spr_RaquetteMitrD+3, _
	e_Anm_Goto, Cast(u32, @gAnm_RaqMitDRepos(0)) _
} 

' Tir mitraillette joueur.
Dim Shared As u32 gAnm_PlyrShot(...) = _
{ _
	e_AnmKey_Null, _
	65000, e_Spr_PlyrShot, _
	e_Anm_Jump, Cast(u32, -2) _
} 


' Raquette, clignotant gauche.
Dim Shared As u32 gAnm_RaqClignG(...) = _
{ _
	e_AnmKey_Null, _
	3, e_Spr_RaqClignG, _
	3, e_Spr_RaqClignG + 1, _
	3, e_Spr_RaqClignG + 2, _
	3, e_Spr_RaqClignG + 3, _
	3, e_Spr_RaqClignG + 4, _
	3, e_Spr_RaqClignG + 3, _
	3, e_Spr_RaqClignG + 2, _
	3, e_Spr_RaqClignG + 1, _
	e_Anm_Goto, Cast(u32, @gAnm_RaqClignG(0)) _
} 

' Raquette, clignotant droit.
Dim Shared As u32 gAnm_RaqClignD(...) = _
{ _
	e_AnmKey_Null, _
	3, e_Spr_RaqClignD, _
	3, e_Spr_RaqClignD + 1, _
	3, e_Spr_RaqClignD + 2, _
	3, e_Spr_RaqClignD + 3, _
	3, e_Spr_RaqClignD + 4, _
	3, e_Spr_RaqClignD + 3, _
	3, e_Spr_RaqClignD + 2, _
	3, e_Spr_RaqClignD + 1, _
	e_Anm_Goto, Cast(u32, @gAnm_RaqClignD(0)) _
} 


' Disparition d´une brique normale.
Dim Shared As u32 gAnm_BrickExplo(...) = _
{ _
	e_AnmKey_Null, _
	e_Anm_Sfx, e_Sfx_BrickDissolve, e_SfxPrio_10, _
	4, (e_Spr_BricksExplo Or SPR_Flag_Shadow), _
	2, (e_Spr_BricksExplo Or SPR_Flag_Shadow)+1, _
	2, (e_Spr_BricksExplo Or SPR_Flag_Shadow)+2, _
	2, (e_Spr_BricksExplo Or SPR_Flag_Shadow)+3, _
	2, (e_Spr_BricksExplo Or SPR_Flag_Shadow)+4, _
	2, (e_Spr_BricksExplo Or SPR_Flag_Shadow)+5, _
	2, (e_Spr_BricksExplo Or SPR_Flag_Shadow)+6, _
	2, (e_Spr_BricksExplo Or SPR_Flag_Shadow)+7, _
	2, (e_Spr_BricksExplo Or SPR_Flag_Shadow)+8, _
	2, (e_Spr_BricksExplo Or SPR_Flag_Shadow)+9, _
	e_Anm_Kill, 0 _
} 

' Disparition d´une brique à taper 2 fois.
Dim Shared As u32 gAnm_Brick2HitExplo(...) = _
{ _
	e_AnmKey_Null, _
	e_Anm_Sfx, e_Sfx_BrickDissolve, e_SfxPrio_10, _
	4, (e_Spr_Bricks2HitExplo Or SPR_Flag_Shadow), _
	2, (e_Spr_Bricks2HitExplo Or SPR_Flag_Shadow)+1, _
	2, (e_Spr_Bricks2HitExplo Or SPR_Flag_Shadow)+2, _
	2, (e_Spr_Bricks2HitExplo Or SPR_Flag_Shadow)+3, _
	2, (e_Spr_Bricks2HitExplo Or SPR_Flag_Shadow)+4, _
	2, (e_Spr_Bricks2HitExplo Or SPR_Flag_Shadow)+5, _
	2, (e_Spr_Bricks2HitExplo Or SPR_Flag_Shadow)+6, _
	2, (e_Spr_Bricks2HitExplo Or SPR_Flag_Shadow)+7, _
	2, (e_Spr_Bricks2HitExplo Or SPR_Flag_Shadow)+8, _
	2, (e_Spr_Bricks2HitExplo Or SPR_Flag_Shadow)+9, _
	e_Anm_Kill, 0 _
} 

' Disparition d´une brique qui revient.
Dim Shared As u32 gAnm_BrickCBExplo(...) = _
{ _
	e_AnmKey_Null, _
	e_Anm_Sfx, e_Sfx_BrickDissolve, e_SfxPrio_10, _
	4, (e_Spr_BricksCBExplo Or SPR_Flag_Shadow), _
	2, (e_Spr_BricksCBExplo Or SPR_Flag_Shadow)+1, _
	2, (e_Spr_BricksCBExplo Or SPR_Flag_Shadow)+2, _
	2, (e_Spr_BricksCBExplo Or SPR_Flag_Shadow)+3, _
	2, (e_Spr_BricksCBExplo Or SPR_Flag_Shadow)+4, _
	2, (e_Spr_BricksCBExplo Or SPR_Flag_Shadow)+5, _
	2, (e_Spr_BricksCBExplo Or SPR_Flag_Shadow)+6, _
	2, (e_Spr_BricksCBExplo Or SPR_Flag_Shadow)+7, _
	2, (e_Spr_BricksCBExplo Or SPR_Flag_Shadow)+8, _
	2, (e_Spr_BricksCBExplo Or SPR_Flag_Shadow)+9, _
	e_Anm_Kill, 0 _
} 

' Brique à taper 2 fois, hit.
Dim Shared As u32 gAnm_Brick2Hit(...) = _
{ _
	e_AnmKey_Null, _
	e_Anm_Sfx, e_Sfx_BrickBounce, e_SfxPrio_10, _
	2, e_Spr_Brick2Hit, _
	2, e_Spr_Brick2Hit+1, _
	2, e_Spr_Brick2Hit+2, _
	2, e_Spr_Brick2Hit+3, _
	2, e_Spr_Brick2Hit+4, _
	2, e_Spr_Brick2Hit+5, _
	e_Anm_Kill, 0 _
} 

' Brique qui revient, hit.
Dim Shared As u32 gAnm_BrickCBHit(...) = _
{ _
	e_AnmKey_Null, _
	e_Anm_Sfx, e_Sfx_BrickBounce, e_SfxPrio_10, _
	2, e_Spr_BrickCBHit, _
	2, e_Spr_BrickCBHit+1, _
	2, e_Spr_BrickCBHit+2, _
	2, e_Spr_BrickCBHit+3, _
	2, e_Spr_BrickCBHit+4, _
	2, e_Spr_BrickCBHit+5, _
	e_Anm_Kill, 0 _
} 

' Brique indestructible, hit.
Dim Shared As u32 gAnm_BrickIndesHit(...) = _
{ _
	e_AnmKey_Null, _
	e_Anm_Sfx, e_Sfx_BrickBounce, e_SfxPrio_10, _
	2, e_Spr_BrickIndesHit, _
	2, e_Spr_BrickIndesHit+1, _
	2, e_Spr_BrickIndesHit+2, _
	2, e_Spr_BrickIndesHit+3, _
	2, e_Spr_BrickIndesHit+4, _
	2, e_Spr_BrickIndesHit+5, _
	e_Anm_Kill, 0 _
} 


' Animations des items (pillules qui descendent).
Dim Shared As u32 gAnm_Itm1(...) = _
{ _
	e_AnmKey_Null, _
	16, e_Spr_Itm1, _
	3, e_Spr_Itm1+1, _
	3, e_Spr_Itm1+2, _
	3, e_Spr_Itm1+3, _
	3, e_Spr_Itm1+4, _
	e_Anm_Goto, Cast(u32, @gAnm_Itm1(0)) _
} 

Dim Shared As u32 gAnm_Itm2(...) = _
{ _
	e_AnmKey_Null, _
	16, e_Spr_Itm2, _
	3, e_Spr_Itm2+1, _
	3, e_Spr_Itm2+2, _
	3, e_Spr_Itm2+3, _
	3, e_Spr_Itm2+4, _
	e_Anm_Goto, Cast(u32, @gAnm_Itm2(0)) _
} 

Dim Shared As u32 gAnm_Itm3(...) = _
{ _
	e_AnmKey_Null, _
	16, e_Spr_Itm3, _
	3, e_Spr_Itm3+1, _
	3, e_Spr_Itm3+2, _
	3, e_Spr_Itm3+3, _
	3, e_Spr_Itm3+4, _
	e_Anm_Goto, Cast(u32, @gAnm_Itm3(0)) _
} 

Dim Shared As u32 gAnm_Itm4(...) = _
{ _
	e_AnmKey_Null, _
	16, e_Spr_Itm4, _
	3, e_Spr_Itm4+1, _
	3, e_Spr_Itm4+2, _
	3, e_Spr_Itm4+3, _
	3, e_Spr_Itm4+4, _
	e_Anm_Goto, Cast(u32, @gAnm_Itm4(0)) _
} 

Dim Shared As u32 gAnm_Itm5(...) = _
{ _
	e_AnmKey_Null, _
	16, e_Spr_Itm5, _
	3, e_Spr_Itm5+1, _
	3, e_Spr_Itm5+2, _
	3, e_Spr_Itm5+3, _
	3, e_Spr_Itm5+4, _
	e_Anm_Goto, Cast(u32, @gAnm_Itm5(0)) _
} 

Dim Shared As u32 gAnm_Itm6(...) = _
{ _
	e_AnmKey_Null, _
	16, e_Spr_Itm6, _
	3, e_Spr_Itm6+1, _
	3, e_Spr_Itm6+2, _
	3, e_Spr_Itm6+3, _
	3, e_Spr_Itm6+4, _
	e_Anm_Goto, Cast(u32, @gAnm_Itm6(0)) _
} 

Dim Shared As u32 gAnm_Itm7(...) = _
{ _
	e_AnmKey_Null, _
	16, e_Spr_Itm7, _
	3, e_Spr_Itm7+1, _
	3, e_Spr_Itm7+2, _
	3, e_Spr_Itm7+3, _
	3, e_Spr_Itm7+4, _
	e_Anm_Goto, Cast(u32, @gAnm_Itm7(0)) _
} 

Dim Shared As u32 gAnm_Itm8(...) = _
{ _
	e_AnmKey_Null, _
	16, e_Spr_Itm8, _
	3, e_Spr_Itm8+1, _
	3, e_Spr_Itm8+2, _
	3, e_Spr_Itm8+3, _
	3, e_Spr_Itm8+4, _
	e_Anm_Goto, Cast(u32, @gAnm_Itm8(0))_
} 

Dim Shared As u32 gAnm_Itm9(...) = _
{ _
	e_AnmKey_Null, _
	16, e_Spr_Itm9, _
	3, e_Spr_Itm9+1, _
	3, e_Spr_Itm9+2, _
	3, e_Spr_Itm9+3, _
	3, e_Spr_Itm9+4, _
	e_Anm_Goto, Cast(u32, @gAnm_Itm9(0)) _
} 

Dim Shared As u32 gAnm_Itm10(...) = _
{ _
	e_AnmKey_Null, _
	16, e_Spr_Itm10, _
	3, e_Spr_Itm10+1, _
	3, e_Spr_Itm10+2, _
	3, e_Spr_Itm10+3, _
	3, e_Spr_Itm10+4, _
	e_Anm_Goto, Cast(u32, @gAnm_Itm10(0)) _
} 

Dim Shared As u32 gAnm_Itm11(...) = _
{ _
	e_AnmKey_Null, _
	16, e_Spr_Itm11, _
	3, e_Spr_Itm11+1, _
	3, e_Spr_Itm11+2, _
	3, e_Spr_Itm11+3, _
	3, e_Spr_Itm11+4, _
	e_Anm_Goto, Cast(u32, @gAnm_Itm11(0)) _
} 

 
Dim Shared As u32 gAnm_MstDoorWait(...) = _
{ _
	e_AnmKey_Null, _
	65000, e_Spr_SortieMst, _
	e_Anm_Jump, Cast(u32, -2) _
} 

' Monstres : Fermeture de la porte.
Dim Shared As u32 gAnm_MstDoorClose(...) = _
{ _
	2, _'e_AnmKey_Null, _
	3, e_Spr_SortieMst + 2, _
	3, e_Spr_SortieMst + 1, _
	3, e_Spr_SortieMst, _
	e_Anm_Goto, Cast(u32, @gAnm_MstDoorWait(0)) _
} 

' Monstres : Porte ouverte (monstre sort).
Dim Shared As u32 gAnm_MstDoorOpened(...) = _
{ _
	1, _'e_AnmKey_Null, _
	30, e_Spr_SortieMst + 2, _
	e_Anm_Goto, Cast(u32, @gAnm_MstDoorClose(0)) _
}

' Monstres : Ouverture de la porte.
Dim Shared As u32 gAnm_MstDoorOpen(...) = _
{ _
	e_AnmKey_Null, _
	3, e_Spr_SortieMst, _
	3, e_Spr_SortieMst + 1, _
	3, e_Spr_SortieMst + 2, _
	e_Anm_Goto, Cast(u32, @gAnm_MstDoorOpened(0)) _
} 

' Monstres des niveaux 0.
Dim Shared As u32 gAnm_Mst1(...) = _
{ _
	e_AnmKey_Null, _
	5, e_Spr_Mst1, _
	5, e_Spr_Mst1 + 1, _
	5, e_Spr_Mst1 + 2, _
	5, e_Spr_Mst1 + 3, _
	5, e_Spr_Mst1 + 4, _
	5, e_Spr_Mst1 + 5, _
	5, e_Spr_Mst1 + 6, _
	5, e_Spr_Mst1 + 7, _
	e_Anm_Goto, Cast(u32, @gAnm_Mst1(0)) _
} 

' Monstres des niveaux 1.
Dim Shared As u32 gAnm_Mst2(...) = _
{ _
	e_AnmKey_Null, _
	5, e_Spr_Mst2, _
	5, e_Spr_Mst2 + 1, _
	5, e_Spr_Mst2 + 2, _
	5, e_Spr_Mst2 + 3, _
	5, e_Spr_Mst2 + 4, _
	5, e_Spr_Mst2 + 5, _
	5, e_Spr_Mst2 + 6, _
	5, e_Spr_Mst2 + 7, _
	5, e_Spr_Mst2 + 8, _
	5, e_Spr_Mst2 + 9, _
	5, e_Spr_Mst2 + 10, _
	5, e_Spr_Mst2 + 11, _
	e_Anm_Goto, Cast(u32, @gAnm_Mst2(0)) _
} 

' Monstres des niveaux 2.
Dim Shared As u32 gAnm_Mst3(...) = _
{ _
	e_AnmKey_Null, _
	15, e_Spr_Mst3, _		5, e_Spr_Mst3 + 1, _		5, e_Spr_Mst3 + 2, _		5, e_Spr_Mst3 + 3, _
	5, e_Spr_Mst3 + 4, _	5, e_Spr_Mst3 + 5, _		5, e_Spr_Mst3 + 6, _		5, e_Spr_Mst3 + 7, _
	5, e_Spr_Mst3 + 8, _
	15, e_Spr_Mst3 + 9, _	5, e_Spr_Mst3 + 10, _		5, e_Spr_Mst3 + 11, _		5, e_Spr_Mst3 + 12, _
	5, e_Spr_Mst3 + 13, _	5, e_Spr_Mst3 + 14, _		5, e_Spr_Mst3 + 15, _
	15, e_Spr_Mst3 + 16, _	5, e_Spr_Mst3 + 17, _		5, e_Spr_Mst3 + 18, _		5, e_Spr_Mst3 + 19, _
	5, e_Spr_Mst3 + 20, _		5, e_Spr_Mst3 + 21, _		5, e_Spr_Mst3 + 22, _		5, e_Spr_Mst3 + 23, _
	e_Anm_Goto, Cast(u32, @gAnm_Mst3(0)) _
} 

' Monstres des niveaux 3.
Dim Shared As u32 gAnm_Mst4(...) = _
{ _
	e_AnmKey_Null, _
	5, e_Spr_Mst4, _
	5, e_Spr_Mst4 + 1, _
	5, e_Spr_Mst4 + 2, _
	5, e_Spr_Mst4 + 3, _
	5, e_Spr_Mst4 + 4, _
	5, e_Spr_Mst4 + 5, _
	5, e_Spr_Mst4 + 6, _
	5, e_Spr_Mst4 + 7, _
	5, e_Spr_Mst4 + 8, _
	5, e_Spr_Mst4 + 9, _
	5, e_Spr_Mst4 + 10, _
	e_Anm_Goto, Cast(u32, @gAnm_Mst4(0)) _
} 

' Explosion générique pour les monstres.
Dim Shared As u32 gAnm_MstExplo1(...) = _
{ _
	e_AnmKey_Null, _
	e_Anm_Sfx, e_Sfx_Explosion1, e_SfxPrio_40, _
	3, e_Spr_MstExplo1, _
	3, e_Spr_MstExplo1 + 1, _
	3, e_Spr_MstExplo1 + 2, _
	3, e_Spr_MstExplo1 + 3, _
	3, e_Spr_MstExplo1 + 4, _
	3, e_Spr_MstExplo1 + 5, _
	3, e_Spr_MstExplo1 + 6, _
	e_Anm_Kill, 0 _
} 

' Explosion générique pour les monstres, sans son.
Dim Shared As u32 gAnm_MstExplo1NoSound(...) = _
{ _
	e_AnmKey_Null, _
	3, e_Spr_MstExplo1, _
	3, e_Spr_MstExplo1 + 1, _
	3, e_Spr_MstExplo1 + 2, _
	3, e_Spr_MstExplo1 + 3, _
	3, e_Spr_MstExplo1 + 4, _
	3, e_Spr_MstExplo1 + 5, _
	3, e_Spr_MstExplo1 + 6, _
	e_Anm_Kill, 0 _
} 

' Disparition du tir du boss.
Dim Shared As u32 gAnm_DohMissileDisp(...) = _
{ _
	e_AnmKey_Null, _
	3, e_Spr_DohMisDust, _
	3, e_Spr_DohMisDust + 1, _
	3, e_Spr_DohMisDust + 2, _
	3, e_Spr_DohMisDust + 3, _
	e_Anm_Kill, 0 _
} 


' Monstre: Porte latérale ouverte vers le niveau suivant.
Dim Shared As u32 gAnm_MstDoorRight(...) = _
{ _
	e_AnmKey_Null, _
	3, e_Spr_MstPorteLevel, _
	3, e_Spr_MstPorteLevel + 2, _
	3, e_Spr_MstPorteLevel + 4, _
	3, e_Spr_MstPorteLevel + 6, _
	3, e_Spr_MstPorteLevel + 8, _
	3, e_Spr_MstPorteLevel + 10, _
	3, e_Spr_MstPorteLevel + 12, _
	3, e_Spr_MstPorteLevel + 14, _
	3, e_Spr_MstPorteLevel + 16, _
	3, e_Spr_MstPorteLevel + 18, _
	e_Anm_Goto, Cast(u32, @gAnm_MstDoorRight(0)) _
} 


' Doh: Idle.
Dim Shared As u32 gAnm_MstDohIdle(...) = _
{ _
	e_AnmKey_Null, _
	256, e_Spr_DohIdle, _
	e_Anm_Jump, Cast(u32, -2) _
} 

' Doh: Appears.
Dim Shared As u32 gAnm_MstDohAppears(...) = _
{ _
	e_AnmKey_MstDohAppears, _
	16, e_Spr_DohDisappear + 4, _
	16, e_Spr_DohDisappear + 3, _
	16, e_Spr_DohDisappear + 2, _
	16, e_Spr_DohDisappear + 1, _
	16, e_Spr_DohDisappear, _
	e_Anm_Goto, Cast(u32, @gAnm_MstDohIdle(0)) _
} 

' Doh: Disappears.
Dim Shared As u32 gAnm_MstDohDisappears(...) = _
{ _
	e_AnmKey_MstDohDisappears, _
	25, e_Spr_DohIdle, _			' Pour laisser le temps aux explosions de disparaître.
	16, e_Spr_DohDisappear, _
	16, e_Spr_DohDisappear + 1, _
	16, e_Spr_DohDisappear + 2, _
	16, e_Spr_DohDisappear + 3, _
	16, e_Spr_DohDisappear + 4, _
	8, SPR_NoSprite, _
	e_Anm_Jump, Cast(u32, -2) _
} 

' Doh: Pour finir le hit, spr de hit avec clef null.
Dim Shared As u32 gAnm_MstDohHit2(...) = _
{ _
	e_AnmKey_Null, _
	8, e_Spr_DohHit, _
	e_Anm_Goto, Cast(u32, @gAnm_MstDohHit2(0)) _
} 
' Doh: Hit.
Dim Shared As u32 gAnm_MstDohHit(...) = _
{ _
	e_AnmKey_MstDohHit, _
	e_Anm_Sfx, e_Sfx_BrickDissolve, e_SfxPrio_10, _
	8, e_Spr_DohHit, _
	e_Anm_Goto, Cast(u32, @gAnm_MstDohHit2(0)) _
} 

' Doh: Tir.
Dim Shared As u32 gAnm_MstDohShoot(...) = _
{ _
	e_AnmKey_Null, _
	256, e_Spr_DohShoot, _
	e_Anm_Jump, Cast(u32, -2) _
} 

' Doh: Ouvre la bouche.
Dim Shared As u32 gAnm_MstDohMouthOpens(...) = _
{ _
	e_AnmKey_MstDohMoutOpens, _
	10, e_Spr_DohIdle, _
	e_Anm_Goto, Cast(u32, @gAnm_MstDohShoot(0)) _
} 

' Doh: Ferme la bouche.
Dim Shared As u32 gAnm_MstDohMouthCloses(...) = _
{ _
	e_AnmKey_MstDohMoutCloses, _
	10, e_Spr_DohShoot, _
	e_Anm_Goto, Cast(u32, @gAnm_MstDohIdle(0)) _
} 

' Tir de Doh.
Dim Shared As u32 gAnm_DohMissile(...) = _
{ _
	e_AnmKey_Null, _
	4, e_Spr_DohMissile, _
	2, e_Spr_DohMissile+1, _
	2, e_Spr_DohMissile+2, _
	4, e_Spr_DohMissile+3, _
	2, e_Spr_DohMissile+2, _
	2, e_Spr_DohMissile+1, _
	e_Anm_Goto, Cast(u32, @gAnm_DohMissile(0)) _
} 


