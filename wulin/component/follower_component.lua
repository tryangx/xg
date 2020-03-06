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
	name       = { type="STRING", },
	age        = { type="NUMBER", },

	lv         = { type="NUMBER", },
	exp        = { type="NUMBER", },
}

---------------------------------------
function FOLLOWER_COMPONENT:__init()
end

---------------------------------------
function FOLLOWER_COMPONENT:Activate()	
	--print( "Activate Follower")
end


function FOLLOWER_COMPONENT:Deactivate()

end


function FOLLOWER_COMPONENT:Update()

end

---------------------------------------