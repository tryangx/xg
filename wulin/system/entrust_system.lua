---------------------------------------
---------------------------------------
local function Entrust_UpdateByCity( entrustCmp )
	if not entrustCmp:CanIssue() then return end
	--issue
	local cityCmp = ECS_FindComponent( entrustCmp.entityid, "CITY_COMPONENT" )
	for groupid, _ in pairs( cityCmp.viewpoints ) do
		local viewpoint = cityCmp.viewpoints[groupid]		
		if viewpoint.eval >= viewpoint.influence then			
			local group = ECS_FindComponent( groupid, "GROUP_COMPONENT" )
			local list = ENTRUST_DATATABLE_Find( cityCmp, entrustCmp )
			--print( "view", viewpoint.requirement, viewpoint.influence, #list )
			local num = #list
			if num ~= 0 then
				local index = Random_GetInt_Sync( 1, num )
				local entrust = list[index]
				local poolindex = Random_GetInt_Sync( 1, #entrust.pool )
				entrustCmp:Issue( entrust, poolindex )

				viewpoint.eval = 0
			end			
		end
	end
end


---------------------------------------
---------------------------------------
ENTRUST_SYSTEM = class()


---------------------------------------
function ENTRUST_SYSTEM:__init( ... )
	local args = ...
	self._name = args and args.name or "ENTRUST_SYSTEM"
end


---------------------------------------
function ENTRUST_SYSTEM:Update()	
	ECS_Foreach( "ENTRUST_COMPONENT", function ( entrustCmp )
		Entrust_UpdateByCity( entrustCmp )
	end )
end
