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
FOLLOWER_COMPONENT = class()

---------------------------------------
FOLLOWER_PROPERTIES = 
{
	job          = { type="STRING" },
	seniority    = { type="NUMBER" }, --days
	contribution = { type="OBJECT" }, --value, unrewarded
}

---------------------------------------
function FOLLOWER_COMPONENT:__init()
end

---------------------------------------
function FOLLOWER_COMPONENT:Update()

end

---------------------------------------