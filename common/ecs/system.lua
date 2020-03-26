---------------------------------------
---------------------------------------
local _ecsSystems = {}
local _ecsSystemDict = {}

---------------------------------------
ECSSYSTEM_STATE =
{

}

---------------------------------------
function ECS_RegisterSystem( sys )
	if not sys._name then
		DBG_Error( "System name is invalid" )
		return
	end

	for _, localSys in pairs( _ecsSystems ) do
		if localSys == sys or localSys._name == sys._name then
			DBG_Error( "System is already registered" )
			return
		end
	end	
	table.insert( _ecsSystems, sys )
	_ecsSystemDict[sys._name] = sys
	print( "Register System=" .. sys._name )
end

---------------------------------------
function ECS_UpdateSystem( deltaTime )	
	for _, sys in pairs( _ecsSystems ) do
		print( "Update Sys=" .. sys._name )
		if sys.Update then
			sys:Update( deltaTime )
		end
	end
end


---------------------------------------
function ECS_GetSystem( name )
	if name then
		return _ecsSystemDict[name]
	end
end


---------------------------------------
function ECS_DumpSystem()
	for _, sys in pairs( _ecsSystems ) do
		if sys.Dump then
			if sys.Dump then sys:Dump() end
		end
	end
end