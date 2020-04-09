FIGHTER_RULE = 
{
	NO_DEAD    = 1,
	TESTFIGHT  = 2,	
	DEATHFIGHT = 3,		
}

FightFormation = 
{
	
}


FIGHT_SIDE = 
{
	NONE = 0,
	RED  = 1,
	BLUE = 2,
}
--   Role will action after its action point is enough
--   

FIGHT_ACTIONTIME = 
{
	DEFAULT  = 1000,
	USESKILL = 3000,
	REST     = 5000,
	DEFEND   = 5000,
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


FIGHT_PARAMS = 
{
	DEFEND_COST_RATE    = 0.25,

	DAMAGE_RATE         = 100,
}