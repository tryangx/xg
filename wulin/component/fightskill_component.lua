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
FIGHTSKILL_PROPERTIES = 
{
	name       = { type="STRING", },

	lv         = { type="NUMBER", },

	cost       = { type="OBJECT", },

	acttime    = { type="NUMBER", },

	weapon     = { type="OBJECT", },
	
	actions    = { type="OBJECT", },

	statuses   = { type="OBJECT", },
}

---------------------------------------
FIGHTSKILL_COMPONENT = class()

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