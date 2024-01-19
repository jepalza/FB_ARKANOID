 

' Define.
#define	LEVEL_Max	37

'#define	LEVEL_SELECT_Max	(LEVEL_Max - 1)
#define	LEVEL_SELECT_Max	(12 - 1)

#define	PLAYER_Lives_Start	3
#define	PLAYER_Lives_Max	10

#define	TIMER_GameOver	(60 * 5)
#define	TIMER_DisplayLevel	(60 * 3)

#define	BRICK_ComingBackCnt	(5 * 60)

#define	WALL_XMin	(10)
#define	WALL_XMax	(SCR_Width-10)
#define	WALL_YMin	16

#define	BRICK_Width		20
#define	BRICK_Height	10

#Define  NBELEM(tabs) UBound(tabs) 

#define	TABLE_Width		15
#define	TABLE_Height	17


' Flags pour la balle.
#define	BALL_Flg_Traversante		(1 Shl 0)
#define	BALL_Flg_Aimantee			(1 Shl 1)	' Balle collée sur la raquette.

' Flags pour la raquette.
#define	PLAYER_Flg_Aimant			(1 Shl 0)
#define	PLAYER_Flg_Mitrailleuse	(1 Shl 1)
#define	PLAYER_Flg_NoKill			(1 Shl 2)
#define	PLAYER_Flg_DoorR			(1 Shl 3)
#define	PLAYER_Flg_BossWait		(1 Shl 4)

' Flags pour la brique.
#define BRICK_Flg_Indestructible	(1 Shl 0)
#Define BRICK_Flg_ComingBack		(1 Shl 1)


' Phases de jeu.
enum 
	e_Game_SelectLevel = 0,	' Selection du level.
	e_Game_Normal,				' Jeu.
	e_Game_LevelCompleted,	' Niveau terminé.
	e_Game_GameOver,			' Game over.
	e_Game_AllClear,			' Jeu terminé.
	e_Game_Pause				' Pause.
End Enum


' Structures.
Type SBrique 
	As u8		nPres 		' Brique présente ou pas.
	As u8		nCnt 			' Nb de touches restantes avant la destruction.
	As u8		nFlags 		' Flags : Voir liste.
	As u16	nResetCnt 	' Compteur pour retour de la brique.

	As u32	nSprNo 		' Sprite par défaut.
	As s32	nAnmNo 		' Remplacé par l´anim si != -1.

	As u32	Ptr pAnmHit 	' Anim à utiliser pour le hit.
	As u32	Ptr pAnmExplo 	' Anim à utiliser pour la disparition.
	As u16	nScore 			' Nb de points rapportés par la brique.
End Type 

#define	BALL_GfxLg	32
#define	BALL_MAX_NB	12
#define	BALL_MAX_SIZE	3		' [0;BALL_MAX_SIZE]
Type SBall 
	As u8	nUsed 			' Slot utilisé ou pas.

	As s32	nPosX, nPosY 	' Virgule fixe 8 bits.
	As s32	nSpeed 			' Virgule fixe 8 bits.
	As u8		nAngle 
	As u32	nFlags 
	As u32	nSize 

	As u32 	nRayon ' = 3;	// Offset du centre.
	As u32 	nDiam ' = 7;	// Hauteur. (Largeur = puissance de 2 à choisir).
	As u8 	pBallMask((BALL_GfxLg * BALL_GfxLg)-1) 	' Masque de la balle, avec une largeur qui nous arrange pour accélérer les tests.
	As u32 	nSpr        ' Sprite de la balle.

	As s32	nOffsRaq 	' Offset sur la raquette (pour aimantation).
End Type 

Type SBreaker 
	As SBall pBalls(BALL_MAX_NB-1) 
	As u32	nBallsNb 			' Nb de balles gérés en cours.

	As s32	nPlayerPosX, nPlayerPosY 
	'As s32	nPlayerLastPosX;
	As s32	nPlayerAnmNo 'nPlayerSprNo;	// Sprite de la raquette.
	As s32	nPlayerAnmBonusM 				' Bonus central.
	As s32	nPlayerAnmBonusG 				' Bonus G.
	As s32	nPlayerAnmBonusD 				' Bonus D.
	As s32	nPlayerAnmClignG 			' Clignotant gauche.
	As s32	nPlayerAnmClignD 			' Clignotant droit.
	As u32	nPlayerFlags 
	As u32	nPlayerRSize 				' Taille de la raquette.
	As u32	nPlayerLives 				' Nb de vies.
	As u32	nPlayerScore, nPlayerLastScore 	' Score.

	As SBrique	pLevel((TABLE_Width * TABLE_Height)-1) 	' Les briques.
	As u32	nRemainingBricks 			' Nb de briques restantes.
	As u32	nBricksComingBackNbCur 		' Nb de briques qui sont en phase disparue, en attente de revenir.
	As u32	nBricksComingBackTotal 		' Nb de briques qui reviennent total du niveau.

	As u32	nPhase 		' Phase de jeu (init, jeu, game over...).
	As u32	nLevel 		' Level en cours.

	As u32	nTimerGameOver 		' Countdown pour game over.
	As u32	nTimerLevelDisplay 	' Compteur pour affichage du n° de level.
End Type 

Dim Shared As SBreaker gBreak


' Prototypes.
Declare Sub ExgBrkInit() 
Declare Sub BreakerInit() 
Declare Sub Breaker() 

Declare Function BrickHit(nBx As u32 , nBy As u32 , nBallFlags As u32) As u32 

Declare Sub BreakerBonusSetAimant() 
Declare Sub BreakerBonusSetMitrailleuse() 
Declare Sub BreakerBonusRaquetteSize(nSens As s32) 
Declare Sub BreakerBonusBallTraversante() 
Declare Sub BreakerBonusBallBigger() 
Declare Sub BreakerBonusBallX3() 
Declare Sub BreakerBonus1Up() 
Declare Sub BreakerBonusSpeedUp(nSens As s32) 

Declare Sub BallsKill() 


