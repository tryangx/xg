---------------------------------------
---------------------------------------
FIGHT_REUSLT = 
{
	NONE     = 0,
	DRAW     = 1,
	ATK_WIN  = 2,
	DEF_WIN  = 3,
}

FIGHT_RULE = 
{
	NO_DEAD    = 1,
	TESTFIGHT  = 2,	
	DEATHFIGHT = 3,
	SIEGE      = 4,
}


FIGHT_SIDE = 
{
	NONE     = 0,
	ATTACKER = 1,
	DEFENDER = 2,
}


FIGHT_SKILLPOSE = 
{
	NONE   = { NONE={}, UPPER={ atk=-10 }, CENTER={ hit=10 },  LOWER={ def=10 },  ALL={} },
	UPPER  = { NONE={}, UPPER={ atk=-10 }, CENTER={ hit=10 },  LOWER={ def=10 },  ALL={} },
	CENTER = { NONE={}, UPPER={ def=10 },  CENTER={ atk=-10 }, LOWER={ hit=10 },  ALL={} },
	LOWER  = { NONE={}, UPPER={ hit=10 },  CENTER={ def=10 },  LOWER={ atk=-10 }, ALL={} },
	ALL    = { NONE={}, UPPER={ hit=10 },  CENTER={ hit=10 },  LOWER={ hit=10 },  ALL={} },
}


FIGHT_TARGET =
{
	SELF          = 0,
	TARGET        = 1,
	SINGLE_ENEMY  = 10,
	ALL_ENEMIES   = 11,	
	SINGLE_FRIEND = 20,
	ALL_FRIENDS   = 21,
	ALL           = 30,
	SINGLE_ALL    = 31,
}


FIGHT_RULE = 
{
	ENABLE_SAVEPONIT = 1,
	ENABLE_CRITICAL  = 1,	
}


---------------------------------------
---------------------------------------
FIGHT_ACTIONTIME = 
{
	DEFAULT  = 3000,
	USESKILL = 5000,
	REST     = 5000,
	DEFEND   = 5000,
}

FIGHT_PARAMS = 
{
	DEFEND_COST_RATE    = 0.25,

	DAMAGE_RATE         = 100,

	ATB_AGI_BASE        = 300,
}