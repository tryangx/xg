----------------------------------
--
-- Fight Attributes
--
--   Hp:    VITAL, Hit points
--   Atk:   HARD, Damage 
--   Def:   INTERNAL, Damage Resist
--   Skill: SOFT, Extra Direct Damage 
--   Agi:   
--
---------------------------------------
---------------------------------------
FOLLOWER_JOB = 
{
	NONE      = 0,
	JUNIOR    = 1,	
	SENIOR    = 2,	
	MASTER    = 10,
	ELDER     = 11,
}


---------------------------------------
---------------------------------------
FOLLOWER_COMPONENT = class()

---------------------------------------
FOLLOWER_PROPERTIES = 
{
	belong       = { type="ECSID" },
	job          = { type="STRING" },
	seniority    = { type="NUMBER" }, --days
	contribution = { type="OBJECT" }, --historic, unrewarded
}

---------------------------------------
function FOLLOWER_COMPONENT:__init()
end

---------------------------------------
function FOLLOWER_COMPONENT:Update()

end

---------------------------------------