---------------------------------------
---------------------------------------
function Role_HasStatus( ecsid, status_includes, status_excludes )
	local entity = ECS_FindEntity( ecsid )
	if not entity then DBG_Error( "Role entity is invalid!Id=" .. ecsid ) end
	local role = entity:GetComponent( "ROLE_COMPONENT" )
	if not role then DBG_Error( "No role component" ) end
	for _, status in pairs( status_includes ) do
		local ret = role.statuses[status]
		if not ret or ret == 0 then return false end
	end
	for _, status in pairs( status_excludes ) do
		local ret = role.statuses[status]
		if ret and ret ~= 0 then return false end
	end
	return true
end


---------------------------------------
---------------------------------------
function Role_SetStatus( ecsid, statues )
	local entity = ECS_FindEntity( ecsid )
	if not entity then DBG_Error( "Role entity is invalid!Id=" .. ecsid ) end
	local role = entity:GetComponent( "ROLE_COMPONENT" )
	if not role then DBG_Error( "No role component" ) end
	if not role.statuses then return end
	for status, value in pairs( statues ) do
		--print( role.name, "status=" .. status, "value=" .. value )
		role.statuses[status] = value
	end
end


---------------------------------------
--
-- Role dead
--
---------------------------------------
function Role_Dead( ecsid )	
	local entity = ECS_FindEntity( ecsid )
	if not entity then DBG_Error( "Role entity is invalid! Id=" .. ecsid ) end
	
	local role = entity:GetComponent( "ROLE_COMPONENT" )
	if not role then DBG_Error( "No role component" ) end

	role.statuses["DEAD"] = 1

	--remove from gang
	local gang = ECS_FindComponent( role.gang, "GANG_COMPONENT" )
	if not gang then DBG_Error( "Gang component is invalid!" ) end

	Gang_RemoveMember( gang, ecsid )

	entity:RemoveFromParent()

	ECS_DestroyEntity( entity )

	Stat_Add( "RoleDeath", role.name, StatType.LIST )
	print( role.name, "Dead" )
end


---------------------------------------
---------------------------------------
ROLE_SYSTEM = class()


---------------------------------------
---------------------------------------
function ROLE_SYSTEM:__init( ... )
	local args = ...
	self._name = args and args.name or "ROLE_SYSTEM"
end


---------------------------------------
---------------------------------------
function ROLE_SYSTEM:Dump()	
	ECS_Foreach( "FIGHTER_COMPONENT", function ( obj )
		local entity = ECS_FindEntity( obj.entityid )
		if not entity then return end
		local role = entity:GetComponent( "ROLE_COMPONENT" )
		role:Dump()
		obj:Dump()
	end )
end