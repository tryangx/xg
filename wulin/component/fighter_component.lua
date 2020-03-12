---------------------------------------
---------------------------------------
FIGHTER_ATTR = 
{
	VITAL      = 1,  --Affect Hp, MP
	PHYSICAL   = 2,  --Affect HP, ST, 
	INTERNAL   = 10, --Affect MP, INT action damage/resist
	STRENGTH   = 11, --Resist ST, PHY action damage/resist
	TECHNIQUE  = 20, --Affect Hit Accuracy, Critical( Physical Damage )
	AGILITY    = 21, --Affect Evade, Attack Sequence
}


FIGHTER_ELEMENT = 
{
	NON = 0,
	PHY = 1,
	INT = 2,	
}


FIGHTER_POINTS = 
{
	HP   = 0,
	ST   = 1,
	MP   = 2,
}

FIGHTER_STATUSTYPE = 
{
	TIRENESS           = 1,     --Long Duration, Increase by Active Action, Reduce by Rest
	PRESSURE           = 2,     --Long Duration, Increase by the Fight/Event 
	
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

FIGHTER_MENTAL = 
{
	WISDOM     = 1,  --Affect Experence needs to level up

}

---------------------------------------
--
-- Attributes
--   Vital Affect 
--
---------------------------------------
FIGHTER_PROPERTIES = 
{
	--points
	-- type : object
	-- value: cur/max
	hp         = { type="OBJECT" },
	mp         = { type="OBJECT" },
	st         = { type="OBJECT" },

	--attr
	-- type : object
	-- value: cur/max
	vital      = { type="OBJECT" },
	physical   = { type="OBJECT" },	

	internal   = { type="OBJECT" },
	strength   = { type="OBJECT" },
	technique  = { type="OBJECT" },
	agility    = { type="OBJECT" },

	--growth
	lv         = { type="NUMBER" },
	maxlv      = { type="NUMBER" },
	exp        = { type="NUMBER" },

	--mental
	-- valuetype: { type: string, init_value = number, post_value = number }
	mentals    = { type="OBJECT" },

	--status
	--  valuetype: { type = FIGHTER_STATUSTYPE, effect = number, duration = number }
	statuses   = { type="OBJECT" },

	--skills
	skills     = { type="OBJECT" },
}

---------------------------------------
---------------------------------------
FIGHTER_COMPONENT = class()

---------------------------------------
function FIGHTER_COMPONENT:_init()	
end

---------------------------------------
function FIGHTER_COMPONENT:Activate()	
	--print( "Activate Fighter" )
end

---------------------------------------
function FIGHTER_COMPONENT:Deactivate()
end

---------------------------------------
function FIGHTER_COMPONENT:Update()	
end

---------------------------------------
local Fighter_Attr_Level = 
{
	[1] = { attrs={atk={min=3,max=5},def={min=1,max=3},agi={min=1,max=3},ski={min=1,max=3},hp={min=10,max=15} } },
	[2] = { attrs={atk={min=4,max=8},def={min=2,max=5},agi={min=2,max=4},ski={min=2,max=4},hp={min=12,max=25} } },
	[3] = { attrs={atk={min=6,max=12},def={min=4,max=8},agi={min=3,max=6},ski={min=3,max=6},hp={min=20,max=30} } },
}

function FIGHTER_COMPONENT:GenFightAttr( params )
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
