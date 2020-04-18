---------------------------------------
--
--
---------------------------------------
FIGHTER_PROPERTIES = 
{
	fighteff   = { type="NUMBER" },
	ranking    = { type="NUMBER" },

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
	knowledge  = { type="NUMBER" },

	--status
	--  valuetype: { type = FIGHTER_STATUSTYPE, effect = number, duration = number }
	statuses   = { type="DICT" },

	--skills
	skills        = { type="LIST" },
	passiveSkills = { type="LIST" },
}

---------------------------------------
---------------------------------------
FIGHTER_COMPONENT = class()

---------------------------------------
function FIGHTER_COMPONENT:Activate()
end

---------------------------------------
function FIGHTER_COMPONENT:Deactivate()
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
	--passiveskill
	for _, id in pairs( self.passiveSkills ) do
		content = content .. " " .. PASSIVESKILL_DATATABLE_Get( id ).name
	end
	return content
end

---------------------------------------
function FIGHTER_COMPONENT:Dump()	
	print( self:ToString() )
end

---------------------------------------
function FIGHTER_COMPONENT:ObtainSkill( id )
	Prop_Add( self, "skills", id )
	DBG_Trace( ECS_FindComponent( self.entityid, "ROLE_COMPONENT" ).name .. " obtain fightskill=" .. FIGHTSKILL_DATATABLE_Get( id ).name )
end

---------------------------------------
function FIGHTER_COMPONENT:ObtainPassiveSkill( id )
	Prop_Add( self, "skills", id )
	DBG_Trace( ECS_FindComponent( self.entityid, "ROLE_COMPONENT" ).name .. " obtain skill=" .. FIGHTSKILL_DATATABLE_Get( id ).name )
end

---------------------------------------
function FIGHTER_COMPONENT:HasSkill( id )
	
end