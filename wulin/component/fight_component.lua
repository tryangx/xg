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
end

function FIGHT_COMPONENT:Deactivate()

end

function FIGHT_COMPONENT:Update()

end

---------------------------------------
function FIGHT_COMPONENT:UpdateRound()
	
end

---------------------------------------
function FIGHT_COMPONENT:UpdateTurn()
	
end

---------------------------------------
function FIGHT_COMPONENT:UpdateAll()
	
end

---------------------------------------