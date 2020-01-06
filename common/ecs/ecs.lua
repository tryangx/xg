---------------------------------------
require "scene"
require "entity"
require "component"
require "reflection"
require "property"

---------------------------------------
ECSProperties = 
{
	ecstype  = { type="STRING" },
	name     = { type="STRING" },
	--id      = { type="NUMBER" },
}

---------------------------------------
local _ecs = {}

---------------------------------------
function ECS_Register( typeName, clz, properties )
	if _ecs[typeName] then
		DBG_Error( "ECSType=" .. typeName .. " is already registered." )
		return
	elseif not clz or not properties then
		DBG_Error( "ECSType=" .. typeName .. "'s register infomation is invalid" )
		return
	end

	local data = { mgr = Manager( typeName, clz ), properties = properties }
	if typeName == "ECSSCENE" or typeName == "ECSENTITY" then
		data.ecstype = typeName		
	end
	_ecs[typeName] = data

	DBG_Trace( "ECSType=" .. typeName .. " registered." )
end

---------------------------------------
function ECS_GetProperties( typeName )
	return _ecs[typeName] and _ecs[typeName].properties
end

---------------------------------------
function ECS_Create( typeName, name )
	local data = _ecs[typeName]
	if not data then 
		DBG_Error( "ECSType=" .. typeName .. " isn't registered." )
	elseif not data.mgr then
		DBG_Error( "ECSType=" .. typeName .. " doesn't has manager." )
	else
		local obj = data.mgr:NewData()
		if data.ecstype then
			obj.ecstype = data.ecstype
			obj.name = name
		else
			obj.ecstype = "ECSCOMPONENT"
			obj.name = typeName
		end		
		return obj
	end
	DBG_Error( "Create ecstype=" .. typeName .. " failed!" )
end

---------------------------------------
function ECS_CreateScene( name )
	return ECS_Create( "ECSSCENE", name )
end

---------------------------------------
function ECS_CreateEntity( name )
	return ECS_Create( "ECSENTITY", name )
end

---------------------------------------
ECS_Register( "ECSSCENE", ECSScene, ECSSceneProperties )
ECS_Register( "ECSENTITY", ECSEntity, ECSEntityProperties )