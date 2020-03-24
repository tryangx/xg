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