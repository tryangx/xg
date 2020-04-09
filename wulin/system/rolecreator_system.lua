---------------------------------------
-- Role Data
--   
--
--
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
	roleEntity:AddComponent( fighter )

	--Create fighter template data
	fightertemplate = roleEntity:CreateComponent( "FIGHTERTEMPLATE_COMPONENT" )

	--Create task
	roleEntity:CreateComponent( "TASK_COMPONENT" )

	--Create traveler
	roleEntity:CreateComponent( "TRAVELER_COMPONENT" )

	--Generate datas
	if not roleTable.template then DBG_Error( "Role data needs template" ) end
	ECS_GetSystem( "FIGHTER_SYSTEM" ):Generate( fighter, fightertemplate, roleTable.template )

	return roleEntity
end


---------------------------------------
---------------------------------------