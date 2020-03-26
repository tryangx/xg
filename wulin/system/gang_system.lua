---------------------------------------
---------------------------------------
local memberidx = 1
function Gang_AddMember( gang, entity )
	local role = entity:GetComponent( "ROLE_COMPONENT" )
	if not role then DBG_Error( "Can't find role component, Failed to AddMember()" ) end

	Prop_Add( gang, "members", entity.ecsid )
	--table.insert( gang.members, entity.ecsid )

	role.gang = gang.entityid
	role.name = gang.name .. role.name .. memberidx
	memberidx = memberidx + 1
	print( gang.name .. " recruit " .. role.name )
end


---------------------------------------
---------------------------------------
function Gang_RemoveMember( gang, ecsid )	
	if not Prop_Remove( gang, "members", ecsid ) then
		print( "remove member failed! ID=", ecsid )
	end
end


---------------------------------------
---------------------------------------
function Gang_CreateByTableData( gangTable )
	local gangEntity, gangComponent
	
	--create root role entity
	gangEntity = ECS_CreateEntity( "Gang" )

	--create role
	gang = create_component_bytabledata( "GANG_COMPONENT", gangTable )
	gangEntity:AddComponent( gang )

	return gangEntity
end


---------------------------------------
---------------------------------------
function Gang_RecruitMember( gang )
	if #gang.members > 5 then return end

	gang.membertemplates = { 1, 2, 3 }
	local idx = Random_GetInt_Sync( 1, #gang.membertemplates )
	local id = gang.membertemplates[idx]
	local data = ROLE_DATATABLE_Get( id )		
	local entity = Role_CreateByTableData( data )
	Data_AddEntity( "ROLE_DATA", entity )
	Gang_AddMember( gang, entity )
end


---------------------------------------
---------------------------------------
local GANG_PARAMS = 
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


function Gang_UpdateActionPoints( gang )
	if not gang.masterid or gang.masterid == "" then return end
	local entity = ECS_FindEntity( gang.masterid )	
	if not entity then DBG_TraceBug( "Gang master is invalid!" ) return end
	local role = entity:GetComponent( "ROLE_COMPONENT" )
	if not role then DBG_Error( "No role component" ) end
	local param = GANG_PARAMS[gang.size]
	gang.MANAGEMENT = param.std + ( role.commonSkills.MANAGEMENT or 0 )
	gang.STRATEGIC  = param.std + ( role.commonSkills.STRATEGIC or 0 )
	gang.TACTIC     = param.std + ( role.commonSkills.TACTIC or 0 )
end


---------------------------------------
-- 
-- Select the master of gang
--   Occured when master is dead
--
---------------------------------------
function Gang_SelectMaster( gang )
	if gang.masterid ~= "" then print( "has master", gang.masterid ) end

	local list
	local HighestJob
	local totalProb = 0

	function CalcMasterProb( follower )
		return ( follower.seniority or 0 ) + ( follower.contribution and follower.contribution.value or 0 )
	end

	--print( "select master")
	MathUtil_Foreach( gang.members, function ( key, ecsid )
		local entity = ECS_FindEntity( ecsid )
		if not entity then DBG_Error( "Role entity is invalid! Id=" .. ecsid ) end
		local follower = entity:GetComponent( "FOLLOWER_COMPONENT" )
		if not follower then DBG_Error( "Not follower component" ) end

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
		if prob < data.prob then
			gang.masterid = data.entity.ecsid
			return
		end		
	end
end


---------------------------------------
---------------------------------------
function Gang_ListRoles( gang, status_includes, status_excludes )
	local roles = {}
	MathUtil_Foreach( gang.members, function ( key, ecsid )
		if Role_HasStatus( ecsid, status_includes, status_excludes ) == true then table.insert( roles, ecsid ) end
	end )
	return roles
end


---------------------------------------
---------------------------------------
function Gang_Attack( gang )
	if #gang.members == 0 then return end

	if gang.statuses["UNDER_ATTACK"] == 1 then return end	

	local list = {}
	ECS_Foreach( "GANG_COMPONENT", function ( target )
		if gang == target then return end
		if target.statuses["UNDER_ATTACK"] == 1 then return end
		table.insert( list, target )
	end )
	local num = #list
	if num == 0 then return end
	local index = Random_GetInt_Sync( 1, num )
	local target = list[index]

	--choice follower to attack
	local atk_eids = Gang_ListRoles( gang, {}, { "OUTING" } )
	local def_eids = Gang_ListRoles( target, {}, { "OUTING" } )	

	print( gang.name .. "(" .. #atk_eids ..  ")"  .. " attack " .. target.name .. "(".. #def_eids .. ")" )
	--[[
	print( "atk eids", #atk_eids )
	Dump( atk_eids )
	print( "def eids", #def_eids )
	Dump( def_eids )
	--]]

	--process status
	target.statuses["UNDER_ATTACK"] = 1
	for _, ecsid in ipairs( atk_eids ) do Role_SetStatus( ecsid, { BUSY=1, OUTING=1 } ) end
	for _, ecsid in ipairs( def_eids ) do Role_SetStatus( ecsid, { BUSY=1 } ) end

	ECS_GetSystem( "FIGHT_SYSTEM" ):CreateFight( atk_eids, def_eids )
end


---------------------------------------
---------------------------------------
GANG_SYSTEM = class()


---------------------------------------
---------------------------------------
function GANG_SYSTEM:__init( ... )
	local args = ...
	self._name = args and args.name or "GANG_SYSTEM"
end


---------------------------------------
---------------------------------------
function GANG_SYSTEM:HoldMeeting()
	--arrange follower schedule
	--trainning: Train self in each, teamwork( friends ), inspire, lazy( no teacher ), crazy
	--learning:  Teacher teachs, teamwork, inspire, anti
	--rest:      Force execution when has bad status like hurt, also use to keep mental into normal
	--freetime:  Only way to lowdown the passion(SIN)
	--execute task: Execute the taks from Entrust
	--envy:         Friendly, Ally, Declare war to other gang
	--reconn:       
	--operation:
	--activity:
end


---------------------------------------
---------------------------------------
function GANG_SYSTEM:Update()
	--print( "update gang" )
	local sys = self
	ECS_Foreach( "GANG_COMPONENT", function ( gang )		
		Gang_UpdateActionPoints( gang )
		Gang_SelectMaster( gang )
		Gang_Attack( gang )
		Gang_RecruitMember( gang )
		--gang:Dump()
	end )
end


---------------------------------------
---------------------------------------
function GANG_SYSTEM:Dump()
	ECS_Foreach( "GANG_COMPONENT", function ( gang )
		gang:Dump()
	end )
end