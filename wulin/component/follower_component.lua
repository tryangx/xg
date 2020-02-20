---------------------------------------
FOLLOWER_COMPONENT = class()

---------------------------------------
FollowerProperties = 
{
	name       = { type="STRING", },
	age        = { type="NUMBER", },

	lv         = { type="NUMBER", },
	exp        = { type="NUMBER", },
	
	fight_attr = { type="OBJECT", },
	lv         = { type="NUMBER", },
}

---------------------------------------
function FOLLOWER_COMPONENT:__init()
	--self.ecsname     = "FOLLOWER_COMPONENT"
	--self._properties = FollowerProperties
end

---------------------------------------
function FOLLOWER_COMPONENT:Activate()	
end


function FOLLOWER_COMPONENT:Deactivate()

end


function FOLLOWER_COMPONENT:Update()

end

---------------------------------------
local Fighter_Attr_Level = 
{
	[1] = { attrs={atk={min=3,max=5},def={min=1,max=3},agi={min=1,max=3},ski={min=1,max=3},hp={min=10,max=15} } },
	[2] = { attrs={atk={min=4,max=8},def={min=2,max=5},agi={min=2,max=4},ski={min=2,max=4},hp={min=12,max=25} } },
	[3] = { attrs={atk={min=6,max=12},def={min=4,max=8},agi={min=3,max=6},ski={min=3,max=6},hp={min=20,max=30} } },
}

function FOLLOWER_COMPONENT:GenFightAttr( params )
	self.fight_attr = { atk = 1, def = 1, agi = 1, ski = 1, hp = 10 }
	--by level
	local level = params and params.level or Random_GetInt_Sync( 1, 3 )
	if level then
		local levels = Fighter_Attr_Level[params.level]
		if not levels then error( "no level data" ) end
		local attrs = levels.attrs
		local attrNames = { "atk", "def", "agi", "ski", "hp" }
		for _, attrName in ipairs( attrNames ) do
			self.fight_attr[attrName] = Random_GetInt_Sync( attrs[attrName].min, attrs[attrName].max )
		end
	end	
end