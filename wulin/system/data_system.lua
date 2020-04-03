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
	GROUP_DATATABLE_Foreach( function ( groupTable ) entity:AddChild( Group_CreateByTableData( groupTable ) ) end )
	scene:GetRootEntity():AddChild( entity )
	entity:CreateComponent( "DATA_COMPONENT" ).type = "GROUP_DATA"
	return entity
end


local function InitRoles( scene )
	local entity = ECS_CreateEntity( "ROLE_DATA" )
	ROLE_DATATABLE_Foreach( function ( roleTable ) entity:AddChild( Role_CreateByTableData( roleTable ) ) end )
	scene:GetRootEntity():AddChild( entity )
	entity:CreateComponent( "DATA_COMPONENT" ).type = "ROLE_DATA"
	return entity
end


local function InitFight( scene )
	local entity = ECS_CreateEntity( "FIGHT_DATA" )
	scene:GetRootEntity():AddChild( entity )
	entity:CreateComponent( "DATA_COMPONENT" ).type = "FIGHT_DATA"
end


local function InitGame( scene )
	local entity = ECS_CreateEntity( "GAME_DATA" )	
	scene:GetRootEntity():AddChild( entity )
	entity:CreateComponent( "DATA_COMPONENT" ).type = "GAME_DATA"
	local game = entity:CreateComponent( "GAME_COMPONENT" )
	game.endTime = 10
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
	DBG_TraceBug( "[DATA]Type=" .. type, "add new entity", entity.ecsid )
end


function Data_RemoveEntity( type, entity )
	local root = _dataRoots[type]
	if not root then DBG_Error( "Data root isn't initialized! Type=" .. type ) return end
	root:RemoveChild( entity )
	DBG_TraceBug( "[DATA]Type=" .. type, "remove an entity", entity.ecsid )
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
end