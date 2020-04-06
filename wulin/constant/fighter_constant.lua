---------------------------------------
---------------------------------------
FIGHTER_ATTR = 
{
	INTERNAL   = 10, --Affect MP, INT action damage/resist
	STRENGTH   = 11, --Resist ST, PHY action damage/resist
	TECHNIQUE  = 20, --Affect Hit Accuracy, Critical( Physical Damage )
	AGILITY    = 21, --Affect Evade, Attack Sequence
}


FIGHTER_ELEMENT = 
{
	STRENGTH = 1,
	ELEMENT  = 2,
}


FIGHTER_STATUSTYPE = 
{	
	STUN               = 10,    --Short Duration, Cann't defend
	COIL               = 11,    --Short Duration, Reduce hit power
	BLIND              = 12,    --Short Duration, Reduce hit accuracy
	BLODDY             = 20,    --Short Duration, Lose Hp 
	RESTORE            = 21,    --Short Duration, Gain Hp
	POISION            = 22,    --Short Duration, Lose Hp
	MARK               = 30,    --Short Duration, Easy to be hit

	STRENGTH_ENHNACED  = 100,
	STRENGTH_WEAKEN    = 101,
	INTERNAL_ENHANCED  = 110,
	INTERNAL_WEAKEN    = 111,
	DEFENSE_ENHANCED   = 120,
	DEFENSE_BROKEN     = 121,
	TECHNIQUE_ENHANCED = 130,
	TECHNIQUE_WEAKEN   = 131,
	AGILITY_ENHANCED   = 140,
	AGILITY_WEAKEN     = 141,
}
