---------------------------------------
--
-- Fight Skill
--
--   Overview
--     One skill has serveral action steps( maximum is 10 )
--     Every action step has its own movement with special attributes.
--     Every action has two main objectives: 1. Break Defense and Deal Damage, 2. 
--
--   Main Properties
--     Weapon      : type( Close( Fist, Palm, Finger, Dagger, Pawl ) / Mid( Sword, Hammer, ... ) / Long( Whip, Rod ) / Fly( Bow, Crossbow, Hidden Weapon ) )
--     Cost        : type( Internal, Hard, Speed ), 
--
--   Action Properties
--     Power : Determine the effect( damage, block defense )
--     Block : Determine the block
--     Hit   : Determine the hit
--     Buff  : When Hit, buff will be accumulated
--     Debuff: When Hit, debuff will be accumulated
--     Pose  : Upper, Center, Lower
--
---------------------------------------
FIGHTSKILL_WEAPONTYPE = 
{
	CLOSE   = 1,
	MID	    = 2,
	LONG    = 3,
	FLY     = 4,
}


FIGHTSKILL_WEAPONSUBTYPE = 
{
	FIST    = 100,
	PALM    = 101,
	FINGER  = 102,
	DAGGER  = 110,
	PAWL    = 120,

	SWORD   = 200,
	HAMMER  = 220,

	ROD     = 300,
	WHIP    = 400,

	HIDDEN  = 1000,	
	BOW     = 2000,
}


FIGHTSKILL_COSTTYPE =
{
	STAMINA  = 1,
	INTERNAL = 2,
}


FIGHTSKILL_POSE =
{
	NONE   = 0,
	UPPER  = 1,
	CENTER = 2,	
	LOWER  = 3,
}

---------------------------------------
---------------------------------------
FIGHTSKILL_COMPONENT = class()

---------------------------------------
FIGHTSKILL_PROPERTIES = 
{
	name       = { type="STRING", },

	lv         = { type="NUMBER", },

	cost       = { type="OBJECT", },

	acttime    = { type="NUMBER", },

	weapon     = { type="OBJECT", },
	
	actions    = { type="OBJECT", },
}

---------------------------------------
function FIGHTSKILL_COMPONENT:__init( ... )
end

---------------------------------------
function FIGHTSKILL_COMPONENT:Activate()	
end

function FIGHTSKILL_COMPONENT:Deactivate()

end

function FIGHTSKILL_COMPONENT:Update()

end
---------------------------------------