DATA_TYPE = 
{
	GROUP_DATA  = 1,
	ROLE_DATA   = 2,
	FIGHT_DATA  = 3,
	GAME_DATA   = 4,
	MAP_DATA    = 5,
}
---------------------------------------------------
---------------------------------------------------
local _dataRoots = {}

local function InitFighter()	
	local roletemplates = TxtDataUtil_Parse( "data/wuxia.csv" )	
	ECS_GetSystem( "FIGHTER_SYSTEM" ):SetTemplateData( roletemplates )
end


local function InitFightSkill()
	FIGHTSKILL_DATATABLE_Foreach( function ( skill ) ECS_GetSystem( "FIGHTSKILL_SYSTEM" ):Create( skill, skill.template ) end )
end


local function InitGroups( scene )
	local entity = ECS_CreateEntity( "GROUP_DATA" )
	GROUP_DATATABLE_Foreach( function ( groupTable )
		local groupEntity = Group_CreateByTableData( groupTable )
		entity:AddChild( groupEntity )
		groupEntity:AddComponent( ECS_CreateComponent( "RELATION_COMPONENT" ) )
		groupEntity:AddComponent( ECS_CreateComponent( "INTEL_COMPONENT" ) )
	end )
	scene:GetRootEntity():AddChild( entity )
	entity:CreateComponent( "DATA_COMPONENT" ).type = "GROUP_DATA"
	--ECS_Dump( entity )	InputUtil_Pause()
	return entity
end


local function InitRoles( scene )
	local entity = ECS_CreateEntity( "ROLE_DATA" )
	--Don't create role by datatable now
	--ROLE_DATATABLE_Foreach( function ( roleTable ) entity:AddChild( Role_CreateByTableData( roleTable ) ) end )
	scene:GetRootEntity():AddChild( entity )
	entity:CreateComponent( "DATA_COMPONENT" ).type = "ROLE_DATA"
	return entity
end


local function InitFight( scene )
	local entity = ECS_CreateEntity( "FIGHT_DATA" )
	scene:GetRootEntity():AddChild( entity )
	entity:CreateComponent( "DATA_COMPONENT" ).type = "FIGHT_DATA"
	return entity
end


local function InitMap( scene )
	local entity = ECS_CreateEntity( "MAP_DATA" )	
	scene:GetRootEntity():AddChild( entity )	
	entity:CreateComponent( "DATA_COMPONENT" ).type = "MAP_DATA"
	
	local mapData = MAP_DATATABLE_Get( 1 )
	local map = entity:CreateComponent( "MAP_COMPONENT" )
	map:Setup( mapData )
	map:Generate( mapData )	
	map:GenerateRoutes( mapData )
	map:Update()

	--add city
	for _, cityData in pairs( map.cities ) do
		local cityEntity = ECS_CreateEntity( "CITY_DATA" )
		entity:AddChild( cityEntity )

		local cityCmp  = cityEntity:CreateComponent( "CITY_COMPONENT" )
		local city     = map.cities[cityData.id]
		cityCmp.name   = city.name
		cityCmp.lv     = city.lv
		cityCmp.cityid = city.id

		local entrustCmp = cityEntity:CreateComponent( "ENTRUST_COMPONENT" )
	end

	--ECS_Dump( entity ) InputUtil_Pause( "init" )

	return entity
end


local function InitGame( scene )
	local entity = ECS_CreateEntity( "GAME_DATA" )	
	scene:GetRootEntity():AddChild( entity )	
	entity:CreateComponent( "DATA_COMPONENT" ).type = "GAME_DATA"

	local gameCmp = entity:CreateComponent( "GAME_COMPONENT" );
	gameCmp.startTime = Time_CalcDateValue( 960, 1, 1 )
	gameCmp.endTime   = Time_CalcDateValue( 970, 1, 1 )
	gameCmp.curTime   = gameCmp.startTime

	return entity
end


function Init_Table()
	InitFighter()
	InitFightSkill()
end


function InitScene()
	local scene = ECS_CreateScene( "mainscene" )	
	scene:SetRootEntity( ECS_CreateEntity( "RootEntity" ) )

	InitGame( scene )
	InitMap( scene )
	InitGroups( scene )
	InitRoles( scene )
	InitFight( scene )

	return scene
end


---------------------------------------------------
--
-- Return the root entity of each type data
--
-- @example: Data_GetRoot( "ROLE_DATA" )
--
---------------------------------------------------
function Data_GetRoot( type )
	return _dataRoots[type]
end


function Data_SetRootEntity( type, ecsid )
	local entity = ECS_FindEntity( ecsid )
	_dataRoots[type] = entity

	print( "Data=" .. type, "Root=" .. ecsid )
end


function Data_AddEntity( type, entity )
	local root = _dataRoots[type]
	if not root then DBG_Error( "Data root isn't initialized! Type=" .. type ) return end
	root:AddChild( entity )
	DBG_Trace( "[DATA]Type=" .. type, "add new entity", entity.ecsid )
end


function Data_RemoveEntity( type, entity )
	local root = _dataRoots[type]
	if not root then DBG_Error( "Data root isn't initialized! Type=" .. type ) return end
	root:RemoveChild( entity )
	DBG_Trace( "[DATA]Type=" .. type, "remove an entity", entity.ecsid )
end


---------------------------------------------------
--
-- Prepare the data
--
-- !!This should be called after scene is activated
-- and before gameloop running.
--
---------------------------------------------------
function Data_Prepare()
	ECS_Foreach( "GROUP_COMPONENT", function ( group )
		--initialized the necessary datas
		Group_Prepare( group )
	end )

	--Group may recruit some role
	ECS_Foreach( "ROLE_COMPONENT", function ( role )
		Role_Prepare( role )
	end)
end
