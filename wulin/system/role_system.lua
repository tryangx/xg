---------------------------------------
---------------------------------------
function Role_MatchStatus( ecsid, params )
	local role = ECS_FindComponent( ecsid, "ROLE_COMPONENT" )
	if not role then DBG_Error( "No role component" ) return end
	return role:MatchStatus( params )
end

function Role_SetStatus( ecsid, statuses )
	local role = ECS_FindComponent( ecsid, "ROLE_COMPONENT" )
	if not role then DBG_Error( "No role component" ) return end
	for type, value in pairs( statuses ) do
		role:SetStatusValue( type, value )
	end	
end

---------------------------------------
function Role_Prepare( role )
	local traveler = ECS_FindComponent( role.entityid, "TRAVELER_COMPONENT")
	local group = ECS_FindComponent( role.groupid, "GROUP_COMPONENT" )
	if group then
		traveler.location = group.location
	else
		local map = ECS_SendEvent( "MAP_COMPONENT", "Get" )
		local index = Random_GetInt_Unsync( 1, #map.cities )
		local city = map.cities[index]		
		traveler.location = city.id
		DBG_Trace( role.name .. " stay at " .. city.name )
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

	--remove from group
	local group = ECS_FindComponent( role.groupid, "GROUP_COMPONENT" )
	if not group then DBG_Error( "Group component is invalid!" ) end
	Group_RemoveMember( group, ecsid )

	ECS_DestroyEntity( entity )
	
	Stat_Add( "RoleDeath", role.name, StatType.LIST )	
	DBG_AddData( role.entityid )
	DBG_Trace( role.name, "Dead" )

	error( "")
end


---------------------------------------
--
-- Role Command
--
---------------------------------------
local function Role_Idle( role )
	print( role.name, "idle" )
end


local function Role_Rest( role )
	print( role.name, "rest" )
end

local function Role_Stroll( role )
	--trigger event
	print( role.name, "stroll" )
end

local function Role_Travel( role )

end

---------------------------------------
local function Role_Drill( role )
	ECS_GetSystem( "TRAINING_SYSTEM" ):AddPupil( role.groupid, role, 1 )
end

local function Role_Teach( role )
	ECS_GetSystem( "TRAINING_SYSTEM" ):AddTeacher( role.groupid, role, 1 )
end

local function Role_Seclude( role )
	ECS_GetSystem( "TRAINING_SYSTEM" ):AddSeclude( role, 1 )
end

local function Role_ReadBook( role )
	ECS_GetSystem( "TRAINING_SYSTEM" ):AddReader( role, 1 )
end

---------------------------------------
local function Role_Scirimmage( role )
	
end

local function Role_TestFight( role )
	local follower = ECS_FindComponent( role.entityid, "FOLLOWER_COMPONENT" )
	local master   = ECS_FindComponent( follower.masterid, "ROLE_COMPONENT" )
	--debug
	if DBG_FindData( role ) then error( "Find in debugger data" ) end
	if not master or not master:MatchStatus( { status_excludes={ "BUSY", "OUTING" } } ) then return end
	local masterTask = ECS_FindComponent( follower.masterid, "TASK_COMPONENT" )
	if not masterTask or masterTask.task == "TESTFIGHT_OFFICER" then DBG_Trace( master.name .. " didn't ") end

	role:SetStatusValue( "BUSY", 1 )
	master:SetStatusValue( "BUSY", 1 )

	local fightEntity = ECS_CreateEntity( "TestFight" )
	local fightCmp = ECS_CreateComponent( "FIGHT_COMPONENT" )
	fightCmp:InitTestFight()
	Prop_Add( fightCmp, "reds",  role.entityid )
	Prop_Add( fightCmp, "blues", master.entityid )
	fightEntity:AddComponent( fightCmp )	
	Data_AddEntity( "FIGHT_DATA", fightEntity )

	--InputUtil_Pause( "fight ready", fightEntity.ecsid )
end

local function Role_TestFightOfficer( role )
	InputUtil_Pause( role.name, "is TESTFIGHT_OFFICER now." )
end

local function Role_Championship( role )

end

local function Role_Produce( role )

end

local function Role_Act( role )
	local task = ECS_GetComponent( role.entityid, "TASK_COMPONENT" )
	local cmd	
	if role.groupid then
		--in group
		local disobey_evl = role:GetMentalValue( "DISSATISFACTION" ) - ( 50 + role:GetMentalValue( "LOYALITY" ) )
		if Random_GetInt_Sync( 1, 100 ) > disobey_evl then
			cmd = task.task
		else
			print( role.name, "Disobey" )
		end
	end

	if not cmd then
		AI_DetermineAction( role.entityid, { target=ecsid } )
		cmd = task.task
	end

	--InputUtil_Pause( role.name, "action", cmd )

	if not cmd then cmd = "IDLE" end

	if cmd == "IDLE" then
		Role_Idle( role )
	
	elseif cmd == "REST" then
		Role_Rest( role )
	elseif cmd == "STROLL" then
		Role_Stroll( role )
	elseif cmd == "TRAVEL" then
		Role_Travel( role )

	elseif cmd == "DRILL" then
		Role_Drill( role )
	elseif cmd == "TEACH" then
		Role_Teach( role )
	elseif cmd == "SECLUDE" then
		Role_Seclude( role )
	elseif cmd == "READBOOK" then
		Role_ReadBook( role )

	elseif cmd == "SKIRIMMAGE" then
		Role_Scirimmage( role )
	elseif cmd == "TESTFIGHT" then
		Role_TestFight( role )
	elseif cmd == "TESTFIGHT_OFFICER" then
		Role_TestFightOfficer( role )
	elseif cmd == "CHAMPIONSHIP" then
		Role_Championship( role )

	elseif cmd == "PRODUCE" then

	else
		DBG_Trace( role.name .. " unhandle command type=", cmd )
		Role_Idle( role )
	end
end


local function Role_Update( role )
	if role.groupid then role:IncStatusValue( "TESTFIGHT_INTERVAL", 1 ) end
end

---------------------------------------
---------------------------------------
ROLE_SYSTEM = class()


---------------------------------------
function ROLE_SYSTEM:__init( ... )
	local args = ...
	self._name = args and args.name or "ROLE_SYSTEM"
end

---------------------------------------
function ROLE_SYSTEM:Update( deltaTime )	
	ECS_Foreach( "ROLE_COMPONENT", function ( role )
		Role_Update( role )
		Role_Act( role )
	end )
end

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