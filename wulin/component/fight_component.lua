---------------------------------------
---------------------------------------
FIGHT_COMPONENT = class()

---------------------------------------
FIGHT_PROPERTIES = 
{
	type       = { type="STRING" },

	atkgroupid = { type="ECSID" },
	defgroupid = { type="ECSID" },

	atks       = { type="LIST" },--store the entity id of fighter
	defs       = { type="LIST" },--store the entity id of fighter

	result     = { type="STRING", default="NONE" },

	rules      = { type="DICT" },

	remainTime = { type="NUMBER", default=100 },
}

---------------------------------------
function FIGHT_COMPONENT:__init()
end

---------------------------------------
function FIGHT_COMPONENT:Activate()
	ECS_GetSystem( "FIGHT_SYSTEM" ):AppendFight( self.entityid )

	--prepare datas

	--get fighter datas
	function PrepareFight( teams, positions )
		--      ATK              DEF
		-- Row(r) Line(l)    Row(r) Line(l)
		--  R2L1  R1L1        R1L1   R2L1
		--  R2L2  R1L2        R1L2   R2L2
		--  R2L3  R1L3        R1L3   R2L3
		local row = 1		
		local line = 1
		for _, id in ipairs( teams ) do
			line = line + 1
			if line > 3 then
				line = 1
				row = row + 1
			end
			local entity = ECS_FindEntity( id )
			if entity then
				local role = entity:GetComponent( "ROLE_COMPONENT" )
				if not role then error( "Role Component is invalid" ) end
				local follower = entity:GetComponent( "FOLLOWER_COMPONENT" )
				if not follower then error( "Follower Component is invalid" ) end
				local fighter = entity:GetComponent( "FIGHTER_COMPONENT" )
				if not fighter then error( "Fighter Component is invalid" ) end
				local template = entity:GetComponent( "FIGHTERTEMPLATE_COMPONENT" )
				if not template  then error( "FighterTemplate Component is invalid" ) end
				--Dump( component ) print( "!!!!!!!!!!find fighter", fighter, id ) Dump( component )
				--print( "parepare", role.name, id )
				table.insert( positions, { role=role, follower=follower, fighter=fighter, template=template, row=row, line=line } )
			end
		end
	end
	self._atks = {}
	self._defs  = {}
	PrepareFight( self.defs, self._defs )
	PrepareFight( self.atks, self._atks )

	if #self.defs == 0 or #self.atks == 0 then DBG_Error( "Invalid fight data" ) end
end

function FIGHT_COMPONENT:Deactivate()

end

function FIGHT_COMPONENT:Update()

end

---------------------------------------
function FIGHT_COMPONENT:ToString()
	local content = "FIGHT BETWEEN"
	local str = 0
	local name = ""
	local atk = ECS_FindEntity( self.atkgroupid )
	local def = ECS_FindEntity( self.defgroupid )
	if atk then
		content = content .. "[" .. atk:GetComponent( "GROUP_COMPONENT" ).name .."]"
	end
	str = 0
	name = ""
	for _, id in ipairs( self.atks ) do		
		name = name .. " " .. ECS_FindComponent( id, "ROLE_COMPONENT" ).name
		str = str + ECS_FindComponent( id, "FIGHTER_COMPONENT" ).fighteff
	end	
	content = content .. "+" .. str .. " " .. name

	content = content .. " VS "

	if def then
		content = content .. "[".. def:GetComponent( "GROUP_COMPONENT" ).name .. "]"
	end	
	for _, id in ipairs( self.defs ) do
		name = name .. " " .. ECS_FindComponent( id, "ROLE_COMPONENT" ).name
		str = str + ECS_FindComponent( id, "FIGHTER_COMPONENT" ).fighteff
	end
	content = content .. "+" .. str .. " " .. name
	return content
end


function FIGHT_COMPONENT:Dump()
	print( self:ToString() )
end

---------------------------------------
function FIGHT_COMPONENT:InitTestFight()
	self.rules["NO_DEAD"]   = 1
	self.rules["TESTFIGHT"] = 1
	self.remainTime = 50
end

---------------------------------------
function FIGHT_COMPONENT:InitSiegeFight()
	self.rules["DEATHFIGHT"] = 1
	self.rules["SIEGE"] = 1
	self.remainTime = 200
end

---------------------------------------
function FIGHT_COMPONENT:InitDeathFight()
	self.rules["DEATHFIGHT"] = 1
	self.remainTime = 300
end