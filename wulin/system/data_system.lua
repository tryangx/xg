---------------------------------------------------
---------------------------------------------------
local _dataRoots = {}

local function InitFighterGenerator()	
	local roletemplates = TxtDataUtil_Parse( "data/wuxia.csv" )
	FighterGeneratorSystem:SetTemplateData( roletemplates )
end


local function InitFightSkillCreator()
	FIGHTSKILL_DATATABLE_Foreach( function ( skill ) FightSkillCreatorSystem:Create( skill, skill.template ) end )
end


local function InitGangs( scene )
	local entity = ECS_CreateEntity( "GANG_DATA" )
	GANG_DATATABLE_Foreach( function ( gangTable ) entity:AddChild( Gang_CreateByTableData( gangTable ) ) end )
	scene:GetRootEntity():AddChild( entity )
	entity:CreateComponent( "DATA_COMPONENT" ).type = "GANG_DATA"
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
	InitFighterGenerator()
	InitFightSkillCreator()
end


function InitScene()
	local scene = ECS_CreateScene( "mainscene" )	
	scene:SetRootEntity( ECS_CreateEntity( "RootEntity" ) )

	InitGame( scene )
	InitGangs( scene )
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
---------------------------------------------------