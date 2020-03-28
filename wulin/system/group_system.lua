---------------------------------------
---------------------------------------
local memberidx = 1
function Group_AddMember( group, entity )
	local role = entity:GetComponent( "ROLE_COMPONENT" )
	if not role then DBG_Error( "Can't find role component, Failed to AddMember()" ) end

	Prop_Add( group, "members", entity.ecsid )
	--table.insert( group.members, entity.ecsid )

	role.groupid = group.entityid
	role.name = group.name .. role.name .. memberidx
	memberidx = memberidx + 1
	print( group.name .. " recruit " .. role.name )
end


---------------------------------------
---------------------------------------
function Group_RemoveMember( group, ecsid )	
	if not Prop_Remove( group, "members", ecsid ) then
		print( "remove member failed! ID=", ecsid )
	end
end


---------------------------------------
---------------------------------------
function Group_CreateByTableData( groupTable )
	local groupEntity, groupComponent
	
	--create root role entity
	groupEntity = ECS_CreateEntity( "Group" )

	--create role
	group = create_component_bytabledata( "GROUP_COMPONENT", groupTable )
	groupEntity:AddComponent( group )

	return groupEntity
end


---------------------------------------
---------------------------------------
function Group_TrainFollower()
	-- body
end


---------------------------------------
---------------------------------------
function Group_EducateFollwer()
end


---------------------------------------
---------------------------------------
function Group_MakeSchedule( group )
	local role = ECS_FindComponent( group.masterid, "ROLE_COMPONENT" )
	if not role then DBG_Error( "No group master role component!" ) end

	MathUtil_Foreach( group.members, function ( _, ecsid )
		if group.masterid == ecsid then return end local target = ECS_FindComponent( ecsid )
		AI_DetermineSchedule( group.masterid, { follower=ecsid } )
	end )
end


---------------------------------------
---------------------------------------
function Group_RecruitMember( group )
	if #group.members > 5 then return end

	group.membertemplates = { 1, 2, 3 }
	local idx = Random_GetInt_Sync( 1, #group.membertemplates )
	local id = group.membertemplates[idx]
	local data = ROLE_DATATABLE_Get( id )		
	local entity = Role_CreateByTableData( data )
	Data_AddEntity( "ROLE_DATA", entity )
	Group_AddMember( group, entity )
end


---------------------------------------
---------------------------------------
local GROUP_PARAMS = 
{
	ACTION_PTS = 
	{
		FAMILY     = { std=2, max=1000 },
		SMALL      = { std=3, max=1000 },
		MID        = { std=3, max=1000 },
		BIG        = { std=4, max=1000 },
		HUGE       = { std=5, max=1000 },
	}
}


function Group_UpdateActionPoints( group )
	if not group.masterid or group.masterid == "" then return end
	local entity = ECS_FindEntity( group.masterid )	
	if not entity then DBG_TraceBug( "Group master is invalid!" ) return end
	local role = entity:GetComponent( "ROLE_COMPONENT" )
	if not role then DBG_Error( "No role component" ) end
	local param = GROUP_PARAMS.ACTION_PTS[group.size]
	group.MANAGEMENT = param.std + ( role.commonSkills.MANAGEMENT or 0 )
	group.STRATEGIC  = param.std + ( role.commonSkills.STRATEGIC or 0 )
	group.TACTIC     = param.std + ( role.commonSkills.TACTIC or 0 )
end


---------------------------------------
-- 
-- Select the master of group
--   Occured when master is dead
--
---------------------------------------
function Group_SelectMaster( group )
	if group.masterid ~= "" then print( "has master", group.masterid ) end

	local list
	local HighestJob
	local totalProb = 0

	function CalcMasterProb( follower )
		return ( follower.seniority or 0 ) + ( follower.contribution and follower.contribution.value or 0 )
	end

	MathUtil_Foreach( group.members, function ( _, ecsid )
		local entity = ECS_FindEntity( ecsid )
		if not entity then DBG_Error( "Role entity is invalid! Id=" .. ecsid ) end
		local follower = entity:GetComponent( "FOLLOWER_COMPONENT" )
		if not follower then DBG_Error( "No follower component" ) end
		local role = entity:GetComponent( "ROLE_COMPONENT" )
		if not role then DBG_Error( "No role component" ) end
		
		if not HighestJob or HighestJob < follower.job then
			HighestJob = follower.job
			list = {}
			totalProb  = CalcMasterProb( follower )
			table.insert( list, { entity=entity, prob=totalProb } )
		elseif HighestJob == follower.job then
			totalProb = totalProb + CalcMasterProb( follower )
			table.insert( list, { entity=entity, prob=totalProb } )
		end
	end )

	if not list or #list == 0 then return end

	local prob = Random_GetInt_Sync( 1, totalProb )
	
	for _, data in ipairs( list ) do
		if prob <= data.prob then
			group.masterid = data.entity.ecsid
			print( group.name, "select", data.entity:GetComponent( "ROLE_COMPONENT" ).name .. " as master" )
			return
		end		
	end
end


---------------------------------------
---------------------------------------
function Group_ListRoles( group, status_includes, status_excludes )
	local roles = {}
	MathUtil_Foreach( group.members, function ( _, ecsid )
		if Role_IsMatch( ecsid, { status_includes=status_includes, status_excludes=status_excludes } ) == true then
			table.insert( roles, ecsid )
		end
	end )
	return roles
end


---------------------------------------
---------------------------------------
function Group_Attack( group )
	if #group.members == 0 then return end

	--print( group.name .. " has member=" .. #group.members )

	if group:GetStatusValue( "UNDER_ATTACK" ) > 0 then
		--print( group.name .. " is under attack! Cann't attack other!" )
		return
	end

	local list = {}
	ECS_Foreach( "GROUP_COMPONENT", function ( target )
		if group == target then return end
		if target:GetStatusValue( "UNDER_ATTACK" ) > 0 then
			--print( target.name .. "is under attack! Cann't be the target" )
			return
		end
		table.insert( list, target )
	end )
	local num = #list
	if num == 0 then
		--print( group.name .. "doesn't have activate target" )
		return
	end
	local index = Random_GetInt_Sync( 1, num )
	local target = list[index]

	--choice follower to attack
	local atk_eids = Group_ListRoles( group, nil, { "OUTING" } )
	local def_eids = Group_ListRoles( target, nil, { "OUTING" } )

	if #atk_eids == 0 then
		print( target.name .. "doesn't have enough followr to attack" )
		return
	end

	print( group.name .. "(" .. #atk_eids ..  ") "  .. "attack" .. " " .. target.name .. "(".. #def_eids .. ")" )
	
	--[[
	print( "atk eids", #atk_eids )
	Dump( atk_eids )
	print( "def eids", #def_eids )
	Dump( def_eids )
	--]]

	--process status
	target:IncStatusValue( "UNDER_ATTACK", 1 )
	for _, ecsid in ipairs( atk_eids ) do Role_SetStatus( ecsid, { BUSY=1, OUTING=1 } ) end
	for _, ecsid in ipairs( def_eids ) do Role_SetStatus( ecsid, { BUSY=1 } ) end

	ECS_GetSystem( "FIGHT_SYSTEM" ):CreateFight( group.entityid, target.entityid, atk_eids, def_eids )

	--print( target.name .. " is been attack by " .. group.name )
end


---------------------------------------
---------------------------------------
function Group_HoldMeeting( group )
	MathUtil_Foreach( group.members, function ( _, ecsid )
		AI_DetermineSchedule( group.masterid, { target=ecsid } )
	end )
end


---------------------------------------
---------------------------------------
GROUP_SYSTEM = class()


---------------------------------------
---------------------------------------
function GROUP_SYSTEM:__init( ... )
	local args = ...
	self._name = args and args.name or "GROUP_SYSTEM"
end


---------------------------------------
---------------------------------------
function GROUP_SYSTEM:Update()
	--print( "update group", ECS_GetNum( "GROUP_COMPONENT" ) )
	local sys = self
	ECS_Foreach( "GROUP_COMPONENT", function ( group )
		print( "[GROUP]" .. group.name .. " action......" )
		Group_UpdateActionPoints( group )
		Group_SelectMaster( group )
		Group_HoldMeeting( group )
		Group_Attack( group )		
	end )
	print( "end group", ECS_GetNum( "GROUP_COMPONENT" ) )
end


---------------------------------------
---------------------------------------
function GROUP_SYSTEM:Dump()
	ECS_Foreach( "GROUP_COMPONENT", function ( group )
		group:Dump()
	end )
end