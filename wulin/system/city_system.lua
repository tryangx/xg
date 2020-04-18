---------------------------------------
---------------------------------------
local function City_UpdatePopu( city )
end

---------------------------------------
---------------------------------------
CITY_SYSTEM = class()

---------------------------------------
function CITY_SYSTEM:__init( ... )
	local args = ...
	self._name = args and args.name or "CITY_SYSTEM"
end


---------------------------------------
function CITY_SYSTEM:Update()
	ECS_Foreach( "CITY_COMPONENT", function ( city )
		City_UpdatePopu( city )
	end )
end


---------------------------------------
function CITY_SYSTEM:Dump()
	ECS_Foreach( "CITY_COMPONENT", function ( city )
		city:Dump()
		local entrustCmp = ECS_FindComponent( city.entityid, "ENTRUST_COMPONENT" )
		entrustCmp:Dump()
	end )
end
