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
	hp         = { type="NUMBER" },
	mp         = { type="NUMBER" },
	st         = { type="NUMBER" },
	maxhp      = { type="NUMBER" },
	maxmp      = { type="NUMBER" },
	maxst      = { type="NUMBER" },

	--attr
	ability    = { type="NUMBER" },
	internal   = { type="NUMBER" },
	strength   = { type="NUMBER" },
	technique  = { type="NUMBER" },
	agility    = { type="NUMBER" },

	--growth
	lv         = { type="NUMBER" },
	exp        = { type="NUMBER" },

	--status
	--  valuetype: { type = FIGHTER_STATUSTYPE, effect = number, duration = number }
	statuses   = { type="OBJECT" },

	--skills
	skills        = { type="LIST" },
	passiveSkills = { type="LIST" },
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
function FIGHTER_COMPONENT:ToString( ... )
	local content = "	"
	content = content .. " " .. "lv=" .. self.lv
	content = content .. " " .. "hp=" .. self.hp .. "/" .. self.maxhp
	content = content .. " " .. "mp=" .. self.mp .. "/" .. self.maxmp
	content = content .. " " .. "st=" .. self.st .. "/" .. self.maxst
	content = content .. " " .. "str=" .. self.strength
	content = content .. " " .. "int=" .. self.internal
	content = content .. " " .. "tec=" .. self.technique
	content = content .. " " .. "agi=" .. self.agility
	content = content .. " " .. "ski=" .. #self.skills
	return content
end

---------------------------------------
function FIGHTER_COMPONENT:Dump()	
	print( self:ToString() )
end