---------------------------------------
---------------------------------------
local GROUP_PARAMS = 
{
	START = 
	{
		FAMILY     = 
			{
			member={min=1,max=3,ELDER={num=1}},
			assets={ LAND={init=3}, REPUTATION={min=100,max=300}, INFLUENCE={min=100,max=300}, MONEY={min=1000,max=2000} },
			resources=
				{
				CLOTH={min=100,max=200}, FOOD={min=100,max=200}, MEAT={min=100,max=200}, WOOD={min=100,max=200}, 
				LEATHER={min=100,max=200}, STONE={min=100,max=200}, IRON_ORE={min=100,max=200}, DRAKSTEEL={min=100,max=200},
				},
			constrs={ HOUSE=1 }
			},
		SMALL      =
			{
			member={min=1,max=3,ELDER=1},
			assets={ LAND={init=3}, REPUTATION={min=200,max=500}, INFLUENCE={min=200,max=500}, MONEY={min=1000,max=2000} },
			resources=
				{
				CLOTH={min=100,max=200}, FOOD={min=100,max=200}, MEAT={min=100,max=200}, WOOD={min=100,max=200}, 
				LEATHER={min=100,max=200}, STONE={min=100,max=200}, IRON_ORE={min=100,max=200}, DRAKSTEEL={min=100,max=200},
				},
			constrs={ HOUSE=1 }
			},
		MID        =
			{
			member={min=1,max=3,ELDER=1},
			assets={ LAND={init=3}, REPUTATION={min=300,max=1000}, INFLUENCE={min=0,max=100}, MONEY={min=1000,max=2000} },
			resources=
				{
				CLOTH={min=100,max=200}, FOOD={min=100,max=200}, MEAT={min=100,max=200}, WOOD={min=100,max=200}, 
				LEATHER={min=100,max=200}, STONE={min=100,max=200}, IRON_ORE={min=100,max=200}, DRAKSTEEL={min=100,max=200},
				},
			constrs={ HOUSE=1 }
			},			
		BIG        =
			{
			member={min=1,max=3,ELDER=1},
			assets={ LAND={init=3}, REPUTATION={min=500,max=3000}, INFLUENCE={min=0,max=100}, MONEY={min=1000,max=2000} },
			resources=
				{
				CLOTH={min=100,max=200}, FOOD={min=100,max=200}, MEAT={min=100,max=200}, WOOD={min=100,max=200}, 
				LEATHER={min=100,max=200}, STONE={min=100,max=200}, IRON_ORE={min=100,max=200}, DRAKSTEEL={min=100,max=200},
				},
			constrs={ HOUSE=1 }
			},		
		HUGE       =
			{
			member={min=1,max=3,ELDER=1},
			assets={ LAND={init=3}, REPUTATION={min=2000,max=5000}, INFLUENCE={min=0,max=100}, MONEY={min=1000,max=2000} },
			resources=
				{
				CLOTH={min=100,max=200}, FOOD={min=100,max=200}, MEAT={min=100,max=200}, WOOD={min=100,max=200}, 
				LEATHER={min=100,max=200}, STONE={min=100,max=200}, IRON_ORE={min=100,max=200}, DRAKSTEEL={min=100,max=200},
				},
			constrs={ HOUSE=1 }
			},		
	},

	ACTION_PTS = 
	{
		FAMILY     = { std=2, max=1000 },
		SMALL      = { std=3, max=1000 },
		MID        = { std=3, max=1000 },
		BIG        = { std=4, max=1000 },
		HUGE       = { std=5, max=1000 },
	},
}

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
	group = DataTable_CreateComponent( "GROUP_COMPONENT", groupTable )
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
function Group_Prepare( group )
	local start = GROUP_PARAMS.START[group.size]

	if group.location == 0 then
		--we should find a location
		local map = ECS_SendEvent( "MAP_COMPONENT", "Get" )
		local index = Random_GetInt_Unsync( 1, #map.cities )
		local city = map.cities[index]		
		group.location = city.id
		DBG_Trace( group.name .. " set base at " .. city.name )
	end

	--members
	local need = Random_GetInt_Sync( start.member.min, start.member.max )
	local needRecruit = need - #group.members
	Log_Write( "game", group.name .. " need recruit " .. needRecruit .. "members" )
	while needRecruit > 0 do
		Group_RecruitMember( group )
		needRecruit = needRecruit - 1
	end

	--rank
	for rank, _ in pairs( FOLLOWER_RANK ) do
		if start.member[rank] then
			local num = start.member[rank].num
			for _, memberid in pairs( group.members ) do				
				follower = ECS_FindComponent( memberid, "FOLLOWER_COMPONENT" )
				if not FOLLOWER_RANK[follower.rank] then
					follower.rank = rank
					DBG_Trace( ECS_FindComponent( memberid, "ROLE_COMPONENT" ).name .. " is promoted to " .. rank, "Left=" .. num )
					num = num - 1
					if num <= 0 then break end
				end
			end
		end
	end

	--assets
	if start.assets then
		for name, value in pairs( start.assets ) do
			if value.init then
				group.assets[name] = value.init
			elseif value.min and value.max then
				group.assets[name] = Random_GetInt_Sync( value.min, value.max )				
			else
				group.assets[name] = 0
			end
			DBG_Trace( group.name .. " asset " .. name .. "=" .. group.assets[name] )
		end
	end

	--resources
	if start.resources then
		for name, value in pairs( start.resources ) do
			if value.init then
				group.resources[name] = value.init
			elseif value.min and value.max then
				group.resources[name] = Random_GetInt_Sync( value.min, value.max )				
			else
				group.resources[name] = 0
			end
			DBG_Trace( group.name .. " resource " .. name .. "=" .. group.resources[name] )
		end
	end

	--constructions
	if start.constrs then
		for type, num in pairs( start.constrs ) do
			local list = CONSTRUCTION_DATATABLE_Find( type, group )
			if #list == 0 then
				DBG_TraceBug( "Is group=" .. group.name .. " has enough constructions=" .. #group.constructions )
			else
				local index = Random_GetInt_Sync( 1, #list )
				local id = list[index].id
				DBG_Trace( group.name .. "need construction=" .. CONSTRUCTION_DATATABLE_Get( id ).name )
				group:CompleteConstruction( id )
			end
		end
	end

	Group_SelectMaster( group )

	DBG_Trace( group.name, "Start=", group.size )
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
function Group_StartBuildingConstruction( group, id )
	local constr = CONSTRUCTION_DATATABLE_Get( id )
	if not constr then DBG_Error( "Construction is invalid! ID=", id ) return end
	local affair = {}
	affair.type  = "BUILD_CONSTRUCTION"
	affair.construction = id
	affair.time  = constr.costs.time or 1

	print( group.name, constr.name )
	Track_Reset()
	Track_Table( "group", group )		
	--use the assets and resources one time
	if constr.costs.assets then
		for name, data in pairs( constr.costs.assets ) do
			group:UseAssets( name, data.value )
		end
	end
	if constr.costs.resources then
		for name, data in pairs( constr.costs.resources ) do
			group:UseResources( name, data.value )
		end
	end
	Track_Table( "group", group )
	Track_Dump( nil, true )
	table.insert( group.affairs, affair )
	DBG_Trace( group.name, " start building construction=" .. constr.name )
end

function Group_StartUpgradingConstruction( group, id, target_id )
	local constr = CONSTRUCTION_DATATABLE_Get( id )
	if not constr then DBG_Error( "Construction is invalid! ID=", id ) return end

	local affair = {}
	affair.type = "UPGRADE_CONSTRUCTION"
	affair.construction = id
	affair.target = target_id
	affair.time = constr.costs.time or 1

	--use the assets and resources one time
	if constr.costs.assets then
		for name, data in pairs( constr.costs.assets ) do
			group:UseAssets( name, data.value )
		end
	end
	if constr.costs.resources then
		for name, data in pairs( constr.costs.resources ) do
			group:UseResources( name, data.value )
		end
	end

	table.insert( group.affairs, affair )
	DBG_Trace( group.name, " start upgrading construction=" .. constr.name )
end

function Group_BulidConstruction( group, affair, deltaTime )
	local constr = CONSTRUCTION_DATATABLE_Get( affair.construction )
	if not constr then DBG_Error( "Construction is invalid! ID=", id ) return end
	affair.time = affair.time - deltaTime
	if affair.time > 0 then return end

	if affair.target then
		--destroy the old one
		group:DestroyConstruction( affair.target )
	end

	--finished
	group:CompleteConstruction( affair.construction )
	--remove affair
	--InputUtil_Pause( group.name, " finished building construction=" .. constr.name, affair.target and "Upgrade" or "" )
	return true
end


---------------------------------------
---------------------------------------
local function Group_DealAffair( group, affair, deltaTime )
	if affair.type == "BUILD_CONSTRUCTION" or affair.type == "UPGRADE_CONSTRUCTION" then
		return Group_BulidConstruction( group, affair, deltaTime )
	end
end

function Group_UpdateAffairs( group, deltaTime )
	--print( group.name, "affairs=" .. #group.affairs )
	MathUtil_RemoveListItemIf( group.affairs, function ( affair )
		Group_DealAffair( group, affair, deltaTime )
	end )
end


---------------------------------------
---------------------------------------
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
	local list
	local HighestRank
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
		
		if not HighestRank or HighestRank < follower.rank then
			HighestRank = follower.rank
			list = {}
			totalProb  = CalcMasterProb( follower )
			table.insert( list, { entity=entity, prob=totalProb } )
		elseif HighestRank == follower.rank then
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
		--DBG_Trace( target.name .. "doesn't have enough followr to attack" )
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
	if not group.masterid then return end

	--Determine affair for group
	AI_DetermineGroupAffair( group.masterid )

	--Make schedule for members by special priority
	--  1st junior
	--  2nd other
	local list = {}
	function CheckPriority( follower )
		return follower.rank == "JUNIOR" or follower.rank == "NONE"
	end
	MathUtil_Foreach( group.members, function ( _, ecsid )
		local follower = ECS_FindComponent( ecsid, "FOLLOWER_COMPONENT" )
		if CheckPriority( follower ) then
			AI_DetermineSchedule( group.masterid, { target=ecsid } )
		end
	end )
	MathUtil_Foreach( group.members, function ( _, ecsid )
		local follower = ECS_FindComponent( ecsid, "FOLLOWER_COMPONENT" )
		if not CheckPriority( follower ) then
			AI_DetermineSchedule( group.masterid, { target=ecsid } )
		end
	end )
end

---------------------------------------
---------------------------------------
function Group_Clear( group )
	--clear temp status
	group.statuses["HAS_DRILL_FOLLOWER"] = nil
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
function GROUP_SYSTEM:Update( deltaTime )
	--print( "update group", ECS_GetNum( "GROUP_COMPONENT" ) )
	local sys = self
	ECS_Foreach( "GROUP_COMPONENT", function ( group )
		print( "[GROUP]" .. group.name .. " action......" )
		Group_UpdateActionPoints( group )
		Group_UpdateAffairs( group, deltaTime )
		Group_SelectMaster( group )
		Group_HoldMeeting( group )
		Group_Attack( group )
		Group_Clear( group )
	end )
	--print( "Update group", ECS_GetNum( "GROUP_COMPONENT" ) )	
end


---------------------------------------
---------------------------------------
function GROUP_SYSTEM:Dump()
	ECS_Foreach( "GROUP_COMPONENT", function ( group )
		group:Dump()
	end )
end