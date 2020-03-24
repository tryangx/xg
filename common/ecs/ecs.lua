---------------------------------------
---------------------------------------
require "scene"
require "entity"
require "component"
require "reflection"
require "property"
require "system"
require "ecsid"

---------------------------------------
-- Enum declarations
---------------------------------------
ECSSCENESTATUS =
{
	CREATED      = 0,
	INITED       = 1,
	ACTIVATING   = 2,
	ACTIVATED    = 3,
	DEACTIVATING = 4,
	DEACTIVATED  = 5,
}


ECSENTITYSTATUS =
{
	CREATED      = 0,
	INITED       = 1,
	ACTIVATING   = 2,
	ACTIVATED    = 3,
	DEACTIVATING = 4,
	DEACTIVATED  = 5,
}


ECSProperties = 
{
	ecstype  = { type="STRING" },
	ecsname  = { type="STRING" },
	ecsid    = { type="STRING" },
}


ECSComponentProperties = 
{
	ecstype  = { type="STRING" },
	ecsname  = { type="STRING" },
}

---------------------------------------
-- ECS Register Informations
local _ecs = {}


---------------------------------------
local _activateScenes = {}


---------------------------------------
-- (Local)Register an ecs class
---------------------------------------
local function ECS_Register( typeName, clz, properties )
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

	if not clz.Activate then DBG_Trace( typeName .. " hasn't Activate()" ) end
	if not clz.Deactivate then DBG_Trace( typeName .. " hasn't Deactivate()" ) end
	if not clz.Update then DBG_Trace( typeName .. " hasn't Update()" ) end

	DBG_Trace( "ECSType=" .. typeName .. " registered." )
end


---------------------------------------
-- (Local)Create an ecs object
---------------------------------------
local function ECS_Create( typeName, name )
	local data = _ecs[typeName]
	if not data then 
		DBG_Error( "ECSType=" .. typeName .. " isn't registered." )
	elseif not data.mgr then
		DBG_Error( "ECSType=" .. typeName .. " doesn't has manager." )
	else
		local obj = data.mgr:NewData()
		if data.ecstype then
			--create ecsid
			obj.ecsid       = ECS_CreateID()
			obj.ecstype     = data.ecstype
			obj.ecsname     = name
		else
			--create component
			obj.ecstype     = "ECSCOMPONENT"
			obj.ecsname     = typeName
			obj._properties = data.properties
			--print( "Create component", obj.ecsname, obj.name, obj.ecstype )

			--initialize
			for propname, prop in pairs( data.properties ) do
				if prop.type == "NUMBER" then
					obj[propname] = prop.default or 0
				elseif prop.type == "STRING" then
					obj[propname] = prop.default or ""
				elseif prop.type == "OBJECT" then
				elseif prop.type == "ECSID" then
				elseif prop.type == "LIST" then
					obj[propname] = {}
				elseif prop.type == "DICT" then
					obj[propname] = {}
				elseif prop.type == "LIST_ECSID" then
					obj[propname] = {}
				end
				--print( propname, propvalue )
			end
		end
		--print( "====Create ECS", obj.ecstype, obj.ecsname, obj.ecsid, obj )	

		return obj
	end

	DBG_Error( "Create ecstype=" .. typeName .. " failed!", DBGLevel.FATAL )
end


---------------------------------------
-- (Local)Find an ecs object by type and keyname
-- @param id scene:name, entity:id
---------------------------------------
local function ECS_Find( typeName, keyname )	
	local data = _ecs[typeName]
	if not data then 
		DBG_Error( "ECSType=" .. typeName .. " isn't registered." )
	elseif not data.mgr then
		DBG_Error( "ECSType=" .. typeName .. " doesn't has manager." )
	else
		local obj = data.mgr:GetData( keyname )		
		if typeName == "ECSCOMPONENT" then
			--keyname is id
			--use a filter to find the name			
			return data.mgr:GetDataByFilter( function( target )
					return target.ecsname == keyname 
				end )
		else
			return data.mgr:GetDataByAttr( "ecsid", keyname )
		end
	end
end


---------------------------------------
-- (Global)Foreach ecs objects by specified type
---------------------------------------
function ECS_Foreach( typeName, fn )
	local data = _ecs[typeName]
	if not data then 
		DBG_Error( "ECSType=" .. typeName .. " isn't registered." )
	elseif not data.mgr then
		DBG_Error( "ECSType=" .. typeName .. " doesn't has manager." )
	else
		data.mgr:ForeachData( fn )
	end
end


---------------------------------------
-- (Global)Reset ECS enviroment
---------------------------------------
function ECS_Reset()
	--reset manager	
	for _, data in pairs( _ecs ) do
		data.mgr:Clear()
	end

	--reset ecsid
	ECS_ResetID()

	print( "Reset ECS" )
end


---------------------------------------
--
-- Creation Interfaces
--
-- Include Create(), Register()
--
---------------------------------------
function ECS_CreateComponent( name )
	local component =  ECS_Create( name, "ECSCOMPONENT" )
	return component
end


function ECS_RegisterComponent( name, clz, properties )
	--append component's properties into the owner's	
	--ECS_Register( name, clz, MathUtil_MergeDict( properties, ECSComponentProperties ) )
	ECS_Register( name, clz, properties )
end


function ECS_CreateScene( name )
	local scene = ECS_Create( "ECSSCENE", name )
	
	--create role data root entity
	local rootEntity = ECS_CreateEntity( "RootEntity" )
	scene:SetRootEntity( rootEntity )

	return scene
end


function ECS_CreateEntity( name )
	return ECS_Create( "ECSENTITY", name )
end


---------------------------------------
--
-- Access Interfaces
--
-- Includes Getter(), Is()
--
---------------------------------------
function ECS_GetProperties( typeName )
	return _ecs[typeName] and _ecs[typeName].properties
end


function ECS_IsComponent( component )
	return component.ecstype == "ECSCOMPONENT"
end


function ECS_FindScene( name )
	return ECS_Find( "ECSSCENE", name )
end


function ECS_FindEntity( id )
	return ECS_Find( "ECSENTITY", id )
end


function ECS_FindComponent( entity, name )
	return entity:GetComponent( name )
end


local _listener = {}
function ECS_AddListener( component )
	if component.ecstype ~= "ECSCOMPONENT" then return end
	local list = _listener[component.ecsname]
	if not list then
		_listener[component.ecsname] = {}
		list = _listener[component.ecsname]
	end
	--table.insert( _listener )
end


---------------------------------------
--
-- Working Interfaces
--
-- Include Activate(), Deactivate(), Update()
--
---------------------------------------
function ECS_Update( deltaTime )
	--update system
	ECS_UpdateSystem( deltaTime )
end


---------------------------------------
--
-- Debug Interfaces
--
-- Include Dump()
--
---------------------------------------
function ECS_Dump( object, indent )
	if not object then print( "invalid to dump" ) return end
	if not indent then indent = 0 print( "******** Start Dump ********") end
	local blank = string.rep (" ", indent)

	local t = typeof( object )
	if t == "number" or t == "string" or t == "boolean" then
		print( blank .. "value=", object )
	else
		
		if object.ecstype == "ECSSCENE" then
			print( blank .. "ecstype=" .. object.ecstype, " ecsname=" .. object.ecsname, " ecsid=" .. object.ecsid, object )
			ECS_Dump( object:GetRootEntity(), indent + 1 )
		elseif object.ecstype == "ECSENTITY" then
			print( blank .. "ecstype=" .. object.ecstype, " ecsname=" .. object.ecsname, " ecsid=" .. object.ecsid, object )
			if object.children then
				for _, entity in ipairs( object.children ) do
					ECS_Dump( entity, indent + 1 )
				end
			end
			if object.components then
				for _, component in ipairs( object.components ) do
					ECS_Dump( component, indent + 1 )
				end
			end
		elseif object.ecstype == "ECSCOMPONENT" then
			print( blank .. "ecstype=" .. object.ecstype, " ecsname=" .. object.ecsname, object )
		else
			for _, subObj in pairs( object ) do
				ECS_Dump( subObj, indent + 1 )
			end
		end
	end		
end


---------------------------------------
--
-- Preprocess
--
---------------------------------------
ECS_Register( "ECSSCENE", ECSScene, ECSSceneProperties )
ECS_Register( "ECSENTITY", ECSEntity, ECSEntityProperties )