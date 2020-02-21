---------------------------------------
---------------------------------------
FightResult = 
{
	DRAW     = 0,
	RED_WIN  = 1,
	BLUE_WIN = 2,
}


---------------------------------------
---------------------------------------
FIGHT_COMPONENT = class()

---------------------------------------
FightProperties = 
{
	reds       = { type="LIST" },--store the entity id of fighter
	blues      = { type="LIST" },--store the entity id of fighter
	state      = { type="NUMBER" },
}

---------------------------------------
function FIGHT_COMPONENT:__init()
	--self.ecsname     = "FIGHT_COMPONENT"
	--self._properties = FightProperties
end

---------------------------------------
function FIGHT_COMPONENT:Activate()	
	print( "activate fight_cmp eid=", self.entityid )
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
			local fighter = ECS_FindEntity( id )
			if fighter then
				local component = fighter:GetComponent( "FOLLOWER_COMPONENT" )
				if not component then error( "Role Component is invalid" ) end				
				--Dump( component ) print( "!!!!!!!!!!find fighter", fighter, id ) Dump( component )
				print( "parepare", component.name, id )
				table.insert( positions, { fighter=component, row=row, line=line } )
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