---------------------------------------
---------------------------------------
FightSystem = class()

---------------------------------------
function FightSystem:__init( ... )
	local args = ...
	self._name = args and args.name or "FIGHT_SYSTEM"

	--store the fight_component's entity-id
	self._fights = {}
end


---------------------------------------
function FightSystem:Activate()

end

---------------------------------------
function FightSystem:Fight( fight_id )
	local entity = ECS_FindEntity( fight_id )
	if not entity then
		DBG_Error( "invalid fight entity!", fight_id )
		return
	end
	print( "Lets fight" )
	local cmp = entity:GetComponent( "FIGHT_COMPONENT" )
	Dump( cmp.blues )
	Dump( cmp.reds )
end

---------------------------------------
function FightSystem:AppendFight( role1_id, role2_id )
	table.insert( self._fights, { role1 = role1_id, role2 = role2_id } )
end

function FightSystem:AppendFight( entityid )
	table.insert( self._fights, entityid )
	print( "add fight", entityid )
end

---------------------------------------
function FightSystem:Update( deltaTime )
	print( "update fightsystem")
	for _, fight in ipairs( self._fights ) do
		print( "Lets fight" )
		self:Fight( fight )
	end
end

---------------------------------------