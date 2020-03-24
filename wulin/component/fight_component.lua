---------------------------------------
---------------------------------------
FIGHT_REUSLT = 
{
	NONE     = 0,
	DRAW     = 1,
	RED_WIN  = 2,
	BLUE_WIN = 3,
}


---------------------------------------
---------------------------------------
FIGHT_COMPONENT = class()

---------------------------------------
FIGHT_PROPERTIES = 
{
	reds       = { type="LIST" },--store the entity id of fighter
	blues      = { type="LIST" },--store the entity id of fighter
	result     = { type="STRING", default="NONE" },
}

---------------------------------------
function FIGHT_COMPONENT:__init()
	--self.ecsname     = "FIGHT_COMPONENT"
	--self._properties = FightProperties	
end

---------------------------------------
function FIGHT_COMPONENT:Activate()
	ECS_GetSystem( "FIGHT_SYSTEM" ):AppendFight( self.entityid )
	--prepare datas

	--get fighter datas
	function PrepareFight( teams, positions )
		--      Red              Blue
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
	self._blues = {}
	self._reds  = {}
	PrepareFight( self.blues, self._blues )
	PrepareFight( self.reds,  self._reds )
end

function FIGHT_COMPONENT:Deactivate()

end

function FIGHT_COMPONENT:Update()

end

---------------------------------------