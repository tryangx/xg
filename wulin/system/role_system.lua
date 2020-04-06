---------------------------------------
---------------------------------------
function Role_IsMatch( ecsid, params )
	local role = ECS_FindComponent( ecsid, "ROLE_COMPONENT" )
	if not role then DBG_Error( "No role component" ) return end
	return role:IsMatch( params )
end

function Role_SetStatus( ecsid, statuses )
	local role = ECS_FindComponent( ecsid, "ROLE_COMPONENT" )
	if not role then DBG_Error( "No role component" ) return end
	role:SetStatus( statues )
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
	print( role.name, "Dead" )
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

local function Role_Drill( role )
	ECS_GetSystem( "TRAINING_SYSTEM" ):AddPupil( role.groupid, role )
end

local function Role_Teach( role )
	ECS_GetSystem( "TRAINING_SYSTEM" ):AddTeacher( role.groupid, role )
end

local function Role_Scirimmage( role )
	
end

local function Role_Championship( role )

end

local function Role_Produce( role )

end

local function Role_Act( role )
	local actor = ECS_GetComponent( role.entityid, "ACTOR_COMPONENT" )
	local cmd	
	if role.groupid then
		--in group
		local disobey_evl = role:GetMentalValue( "DISSATISFACTION" ) - ( 50 + role:GetMentalValue( "LOYALITY" ) )
		if Random_GetInt_Sync( 1, 100 ) > disobey_evl then
			cmd = actor.task
		else
			print( role.name, "Disobey" )
		end
	end
	if not cmd then		
		AI_DetermineAction( role.entityid, { target=ecsid } )
		cmd = actor.task
	end

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

	elseif cmd == "SKIRIMMAGE" then
		Role_Scirimmage( role )
	elseif cmd == "CHAMPIONSHIP" then
		Role_Championship( role )
	elseif cmd == "PRODUCE" then

	else
		DBG_Trace( role.name .. " unhandle command type=", cmd )
		Role_Idle( role )
	end
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