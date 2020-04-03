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
	local fighter = ECS_FindComponent( role.entityid, "FIGHTER_COMPONENT" )
	if not fighter then DBG_Error( "No fighter component" ) return end
	local min = 100 - fighter.lv
	local max = role:GetTraitValue( "HARD_WORK" ) + role:GetTraitValue( "CONCENTRATION" ) + role:GetTraitValue( "INSPIRATION" )
	local exp = Random_GetInt_Sync( min, max )
	fighter.exp = math.min( min, fighter.exp + exp )
	if fighter.exp >= 100 then
		local fightertemplate = ECS_FindComponent( role.entityid, "FIGHTERTEMPLATE_COMPONENT" )
		if not fightertemplate then DBG_Error( "No fightertemplate component" ) return end
		Track_Reset()
		Track_Table( "fighter", fighter )
		ECS_GetSystem( "FIGHTER_SYSTEM" ):LevelUp( fighter, fightertemplate, 30 )
		Track_Table( "fighter", fighter )
		--Track_Dump( nil, true )
		--InputUtil_Pause( role.name, "drill, gain exp=" .. fighter.exp .. "+" .. exp )
		Log_Write( "role", role.name .. " LevelUp to " .. fighter.lv )
		fighter.exp = 0
	end	
end

local function Role_Teach( role )
	local fighter = ECS_FindComponent( role.entity, "FIGHTER_COMPONENT" )
	if not fighter then DBG_Error( "No fighter component" ) return end

end

local function Role_Scirimmage( role )
	
end

local function Role_Championship( role )

end

local function Role_Produce( role )

end

local function Role_Act( role )
	local cmd
	if role.groupid then
		local disobey_evl = role:GetMentalValue( "DISSATISFACTION" ) - ( 50 + role:GetMentalValue( "LOYALITY" ) )
		if Random_GetInt_Sync( 1, 100 ) > disobey_evl then			
			cmd = role.instruction
		else
			print( role.name, "Disobey" )
		end
	end
	if not cmd then		
		AI_DetermineAction( role.entityid, { target=ecsid } )
		cmd = role.instruction
	end

	if not cmd then Role_Idle( role ) end

	if cmd.type == "IDLE" then
		Role_Idle( role )
	
	elseif cmd.type == "REST" then
		Role_Rest( role )
	elseif cmd.type == "STROLL" then
		Role_Stroll( role )
	elseif cmd.type == "TRAVEL" then
		Role_Travel( role )

	elseif cmd.type == "DRILL" then
		Role_Drill( role )
	elseif cmd.type == "TEACH" then
		Role_Teach( role )
	elseif cmd.type == "SECLUDE" then
		Role_Seclude( role )

	elseif cmd.type == "SKIRIMMAGE" then
		Role_Scirimmage( role )
	elseif cmd.type == "CHAMPIONSHIP" then
		Role_Championship( role )
	elseif cmd.type == "PRODUCE" then

	else
		Dump( cmd )
		print( role.name .. " unhandle command type=", cmd.type )
		DBG_TraceBug( role.name .. " unhandle command type=", cmd.type )
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