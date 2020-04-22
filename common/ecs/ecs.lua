

---------------------------------------------------
-- Enum declarations
---------------------------------------------------
ECSSTATUS =
{
	CREATED      = 0,
	INITED       = 1,
	ACTIVATING   = 2,
	ACTIVATED    = 3,
	DEACTIVATING = 4,
	DEACTIVATED  = 5,
}


ECSPROPERTIES = 
{
	ecstype  = { type="STRING" },
	ecsname  = { type="STRING" },
	ecsid    = { type="STRING" },
}


ECSCOMPONENTPROPERTIES = 
{
	ecstype  = { type="STRING" },
	ecsname  = { type="STRING" },
}


---------------------------------------------------
---------------------------------------------------
require "scene"
require "entity"
require "component"
require "reflection"
require "property"
require "system"
require "ecsid"

---------------------------------------------------
-- ECS Register Informations
local _ecs = {}


---------------------------------------------------
local _activateScenes = {}
local _currentScene


---------------------------------------------------
---------------------------------------------------
local function ECS_GetDataManager( typeName )
	local data = _ecs[typeName]
	if not data then 
		DBG_Error( "ECSType=" .. typeName .. " isn't registered." )
		return
	elseif not data.mgr then
		DBG_Error( "ECSType=" .. typeName .. " doesn't has manager." )
		return
	end
	return data
end


---------------------------------------------------
-- (Local)Register an ecs class
---------------------------------------------------
local function ECS_Register( typeName, clz, properties )	
	if _ecs[typeName] then
		DBG_Error( "ECSType=" .. typeName .. " is already registered." )		
		return
	elseif not clz or not properties then
		DBG_Error( "ECSType=" .. typeName .. "'s register infomation is invalid" )
		return
	end

	--check properties
	for _, value in pairs( properties ) do
		if not MathUtil_FindByKey( PROPERTY_TYPE, value.type ) then
			DBG_Error( "properties has invalid type=" .. value.type )
		end
	end

	local data = { mgr = Manager( typeName, clz ), properties = properties }
	if typeName == "ECSSCENE" or typeName == "ECSENTITY" then
		data.ecstype = typeName
	end
	_ecs[typeName] = data

	if not clz.Activate then DBG_TraceBug( typeName .. " hasn't Activate()" ) end
	if not clz.Deactivate then DBG_TraceBug( typeName .. " hasn't Deactivate()" ) end
	if not clz.Update then DBG_TraceBug( typeName .. " hasn't Update()" ) end

	DBG_TraceBug( "ECSType=" .. typeName .. " registered." )
end


---------------------------------------------------
-- (Local)Create an ecs object
---------------------------------------------------
local function ECS_Create( typeName, name )
	local data = ECS_GetDataManager( typeName )
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
		--print( "Create component", obj.ecsname, obj.name, obj.ecstype, obj.id )

		--initialize
		for propname, prop in pairs( data.properties ) do
			if prop.type == "NUMBER" then
				obj[propname] = prop.default or 0
			elseif prop.type == "STRING" then
				obj[propname] = prop.default or ""
			elseif prop.type == "OBJECT" then
				obj[propname] = {}
			elseif prop.type == "ECSID" then
				--to reduce the check operation
				obj[propname] = nil
			elseif prop.type == "LIST" then
				obj[propname] = {}
			elseif prop.type == "DICT" then
				obj[propname] = {}
			else
				error( "Unhandle type=" .. prop.type )
			end
			--print( propname, propvalue )
		end
	end

	obj.status = ECSSTATUS.INITED
	
	--print( "====Create ECS", obj.ecstype, obj.ecsname, obj.ecsid, obj )	

	return obj
end


---------------------------------------------------
-- (Local)Find an ecs object by type and keyname
-- @param id scene:name, entity:id
---------------------------------------------------
local function ECS_Find( typeName, keyname )	
	local data = ECS_GetDataManager( typeName )
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


---------------------------------------------------
function ECS_GetNum( typeName )
	local data = ECS_GetDataManager( typeName )
	return data.mgr:GetCount()
end


---------------------------------------------------
-- (Global)Foreach ecs objects by specified type
---------------------------------------------------
function ECS_Foreach( typeName, fn )
	local data = ECS_GetDataManager( typeName )
	if data then
		data.mgr:ForeachData( fn )
	end
end


---------------------------------------------------
-- (Global)Reset ECS enviroment
---------------------------------------------------
function ECS_Reset()
	--reset scenes
	_currentScene = nil
	_activateScenes = {}

	--reset manager	
	for _, data in pairs( _ecs ) do data.mgr:Clear() end

	--reset ecsid
	ECS_ResetID()

	--game
	ECS_Foreach( "GAME_COMPONENT", function ( game ) game:Dump() end )

	print( "=========Reset ECS==========" )
end


---------------------------------------------------
--
-- Creation Interfaces
--
-- Include Create(), Register()
--
---------------------------------------------------
function ECS_CreateComponent( name )
	local component =  ECS_Create( name, "ECSCOMPONENT" )
	return component
end


function ECS_RegisterComponent( name, clz, properties )
	ECS_Register( name, clz, properties )
end


function ECS_CreateScene( name )
	local scene = ECS_Create( "ECSSCENE", name )
	
	--create role data root entity
	--local rootEntity = ECS_CreateEntity( "RootEntity" )
	--scene:SetRootEntity( rootEntity )

	return scene
end


function ECS_CreateEntity( name )
	return ECS_Create( "ECSENTITY", name )
end


---------------------------------------------------
--
-- Destroy Interfaces
--
---------------------------------------------------
function ECS_DestroyEntity( entity )
	if not entity then return end
	local data = ECS_GetDataManager( "ECSENTITY" )

	--remove from parent
	entity:RemoveFromParent()

	--remove components first
	if entity.components then
		for _, component in ipairs( entity.components ) do
			--print( "remove cmp", component.id )
			ECS_DestroyComponent( component )
		end
	end

	--remove children
	if entity.children then
		for _, child in ipairs( entity.children ) do
			--print( "remove child", child.ecsid )
			ECS_DestroyEntity( child )
		end
	end

	data.mgr:RemoveData( entity.id )
end


function ECS_DestroyComponent( component )
	if not component then return end
	local data = ECS_GetDataManager( component.ecsname )
	data.mgr:RemoveData( component.id )
end


---------------------------------------------------
--
-- Access Interfaces
--
-- Includes Getter(), Is()
--
---------------------------------------------------
function ECS_GetProperties( typeName )
	return _ecs[typeName] and _ecs[typeName].properties
end

function ECS_IsEntity( entity )
	return entity.ecstype == "ECSENTITY"
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


---------------------------------------------------
-- Get the component from the entity
-- @note if component isn't exist, then create one
---------------------------------------------------
function ECS_GetComponent( entityid, name )
	local entity = ECS_FindEntity( entityid )	
	if not entity then DBG_Erro( "entity is invalid!" ) return end
	local cmp = entity:GetComponent( name )
	return cmp or entity:CreateComponent( name )
end


function ECS_FindComponent( entityid, name )
	local entity = ECS_FindEntity( entityid )	
	return entity and entity:GetComponent( name )
end


---------------------------------------------------
-- 
-- Add a listener for the component
--
---------------------------------------------------
local _listener = {}
function ECS_AddListener( component, type, callback )
	if component.ecstype ~= "ECSCOMPONENT" then return end	
	local list = _listener[component.ecsname]
	if not list then
		_listener[component.ecsname] = {}
		list = _listener[component.ecsname]
	end

	if not list[type] then list[type] = {} end
	list[type][component.entityid] = callback
end


function ECS_RemoveListener( component, type )
	if component.ecstype ~= "ECSCOMPONENT" then return end
	local list = _listener[component.ecsname]
	if not list then return end

	list[type][component.entityid] = nil
end


function ECS_SendEvent( ecsname, type, ... )
	local list = _listener[ecsname]
	if not list then DBG_Error( "No event type=" .. type .. " " .. ecsname ) return end

	local ret = nil
	for id, callback in pairs( list[type] ) do
		ret = callback( ... )
		if ret then return ret end
	end
end

---------------------------------------------------
--
-- Working Interfaces
--
-- Include Activate(), Deactivate(), Update()
--
---------------------------------------------------
function ECS_Update( deltaTime )
	--update system
	ECS_UpdateSystem( deltaTime )

	--update scenes, entities, components
	for _, scene in ipairs( _activateScenes ) do scene:Update( deltaTime ) end

	return _currentScene
end


---------------------------------------------------
--
---------------------------------------------------
function ECS_SwitchScene( scene )
	_currentScene = scene
	table.insert( _activateScenes, scene )
end


function ECS_PushScene( scene )
	if not _currentScene then _currentScene = scene end
	scene:Activate()
	table.insert( _activateScenes, scene )
end


function ECS_LeaveScene( scene )
	if not scene then scene = _currentScene end	
	MathUtil_Remove( _activateScenes, scene )
	if scene == _currentScene then
		_currentScene = nil
		--print( "CurrentScene=",  _currentScene, "ActiveScene=" .. #_activateScenes )
	end
end


function ECS_ForeachScene( fn )
	for _, scene in ipairs( _activateScenes ) do
		fn( scene )
	end
end


---------------------------------------------------
--
-- Debug Interfaces
--
-- Include Dump()
--
---------------------------------------------------
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


---------------------------------------------------
--
-- Preprocess
--
---------------------------------------------------
ECS_Register( "ECSSCENE", ECSScene, ECSSCENEPROPERTIES )
ECS_Register( "ECSENTITY", ECSEntity, ECSENTITYPROPERTIES )