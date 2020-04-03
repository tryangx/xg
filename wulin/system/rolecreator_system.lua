---------------------------------------
---------------------------------------
function Role_CreateByTableData( roleTable )
	local roleEntity, role, follower, fighter, fightertemplate
	
	--create root role entity
	roleEntity = ECS_CreateEntity( "Role" )

	--create role
	role = DataTable_CreateComponent( "ROLE_COMPONENT", roleTable )
	roleEntity:AddComponent( role )

	--Create follower data
	follower = DataTable_CreateComponent( "FOLLOWER_COMPONENT", roleTable )
	roleEntity:AddComponent( follower )

	--Create fighter data
	fighter = DataTable_CreateComponent( "FIGHTER_COMPONENT", roleTable )	
	--fighter = ECS_CreateComponent( "FIGHTER_COMPONENT" )
	roleEntity:AddComponent( fighter )

	--Create fighter template data
	fightertemplate = ECS_CreateComponent( "FIGHTERTEMPLATE_COMPONENT" )
	roleEntity:AddComponent( fightertemplate )

	--Generate datas
	if not roleTable.template then DBG_Error( "Role data needs template" ) end
	ECS_GetSystem( "FIGHTER_SYSTEM" ):Generate( fighter, fightertemplate, roleTable.template )

	return roleEntity
end


---------------------------------------
---------------------------------------