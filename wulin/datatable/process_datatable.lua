--------------------------------------------------
--------------------------------------------------
local PROCESS_DATATABLE = 
{
	[10] =
	{
		name     = "炼钢",
		type     = "SMELT",
		condition = { commonskill="BLACKSMITH" },
		material = { type="IRON_ORE", value=100 },
		products = { resource={type="STEEL", value=20} },
		time     = { value=60 },
	},
	[20] =
	{
		name     = "饲养",
		type     = "RAISELIVESTOK",
		material = { },
		products = { resource={type="LIVESTOCK", value=20} },
		time     = { value=180 },
	},
	[30] =
	{
		name     = "种草药",
		type     = "PLANTHERB",
		material = { },
		products = { resource={type="HERB", value=20} },
		time     = { value=90 },
	},
	[40] =
	{
		name     = "制药",
		type     = "MAKEMEDICINE",
		material = { type="HERB", value=30 },
		products = { consumable={type="MAKEMEDICINE", value=5} },
		time     = { value=30 },
	},
	[50] =
	{
		name     = "制药",
		type     = "MAKEMEDICINE",
		material = { type="HERB", value=30 },
		products = { consumable={type="MAKEMEDICINE", value=5} },
		time     = { value=30 },
	},
}


--------------------------------------------------
function PROCESS_DATATABLE_Get( id )
	return PROCESS_DATATABLE[id]
end


--------------------------------------------------
local function PROCESS_DATATABLE_Match( group, process )
	if process.material then
		if process.material.type and group:GetNumOfResource( process.material.type ) < process.material.value then
			return false
		end
	end

	if process.condition then
		if process.condition.commonskill then			
			local list = group:FindMember( function ( ecsid )
				local role = ECS_FindComponent( ecsid, "ROLE_COMPONENT" )
				return role and role.commonSkills[process.condition.commonskill]
			end )
			if #list == 0 then return false end
		end		
	end

	return true
end


--------------------------------------------------
function PROCESS_DATATABLE_Find( group, type )
	local list = {}
	for _, process in pairs( PROCESS_DATATABLE ) do
		if not types or type     == process.type then
			if PROCESS_DATATABLE_Match( group, process ) then
				table.insert( list, process )
			end
		end
	end
	return list
end
