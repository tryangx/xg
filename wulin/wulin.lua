---------------------------------------------------
---------------------------------------------------
package.path = package.path .. ";wulin/component/?.lua"
package.path = package.path .. ";wulin/system/?.lua"
package.path = package.path .. ";wulin/datatable/?.lua"

--data table
require "fightskill_datatable"
require "fightskilltemplate_datatable"
require "role_datatable"

--component
require "fight_component"
require "fighter_component"
require "fightskill_component"
require "fightertemplate_component"
require "follower_component"
require "gang_component"

--system
require "fight_system"
require "fightergenerator_system"
require "fightskillcreator_system"


---------------------------------------------------
---------------------------------------------------
--register component
ECS_RegisterComponent( "GANG_COMPONENT",          GANG_COMPONENT,          GANG_PROPERTIES )
ECS_RegisterComponent( "FOLLOWER_COMPONENT",      FOLLOWER_COMPONENT,      FOLLOWER_PROPERTIES )
ECS_RegisterComponent( "FIGHT_COMPONENT",         FIGHT_COMPONENT,         FIGHT_PROPERTIES )
ECS_RegisterComponent( "FIGHTER_COMPONENT",       FIGHTER_COMPONENT,       FIGHTER_PROPERTIES )
ECS_RegisterComponent( "FIGHTSKILL_COMPONENT",    FIGHTSKILL_COMPONENT,    FIGHTSKILL_PROPERTIES )
ECS_RegisterComponent( "FIGHTERTEMPLATE_COMPONENT",    FIGHTERTEMPLATE_COMPONENT,    FIGHTERTEMPLATE_PROPERTIES )


---------------------------------------------------
---------------------------------------------------
--register system
FightSystem = FIGHT_SYSTEM()
ECS_RegisterSystem( FightSystem )

FighterGeneratorSystem = FIGHTERGENERATOR_SYSTEM()
FightSkillCreatorSystem = FIGHTSKILLCREATOR_SYSTEM()

---------------------------------------------------
---------------------------------------------------
function run()	
	g_curTurn = 1
	g_endTurn = 2
	function IsGameEnd()
		if g_curTurn >= g_endTurn then return true end
		g_curTurn = g_curTurn + 1
	end

	while not IsGameEnd() do		
		ECS_Update()
	end
end

---------------------------------------------------
function save_data( data, filename )
	print( "Save Data to File=", filename )
	if data then
		ExportFileReflection:SetFile( filename )
		Reflection_Export( ExportFileReflection, data )
		Reflection_Flush( ExportFileReflection )
	end
end

---------------------------------------------------
function load_data( filename )
	print( "Load Test Data From File=", filename )

	--load from bf.json
	ImportFileReflection:SetFile( filename )
	local file = Reflection_Import( ImportFileReflection )
	if file then
		data = MathUtil_GetDataByIndex( file )
		--ECS_Dump( data )
		--Dump( data )
		return data
	end
end

---------------------------------------------------
function create_fightskill( id )
	local fightSkill = ECS_CreateComponent( "FIGHTSKILL_COMPONENT" )
	MathUtil_ShallowCopy( FIGHTSKILL_DATATABLE_Get( id ), fightSkill )
	save_data( fightSkill, "fightskill_template.json" )
end


function create_fighter( id )
	local fighter = ECS_CreateComponent( "FIGHTER_COMPONENT" )
	MathUtil_ShallowCopy( ROLE_DATATABLE_Get( 100 ), fighter )	
	save_data( fighter, "fighter_" .. id .. ".json" )
end


function create_follower( id )
	local follower = ECS_CreateComponent( "FOLLOWER_COMPONENT" )
	MathUtil_ShallowCopy( ROLE_DATATABLE_Get( id ), follower )	
	save_data( fighter, "follower_" .. id .. ".json" )	
end


function create_component_bytabledata( componentType, tabledata )
	local component = ECS_CreateComponent( componentType )
	if tabledata then
		--use properties	
		--print( "properties", component._properties )
		for name, _ in pairs( component._properties ) do
			if tabledata[name] then
				component[name] = MathUtil_ShallowCopy( tabledata[name] )
				--print( "set", name, component[name] )
			end			
		end
	end
	--MathUtil_ShallowCopy( getter( id ), component )	
	return component
end


function create_component_bydatatableid( componentType, getter, id )
	local component = ECS_CreateComponent( componentType )
	local tabledata = getter( id )
	if tabledata then
		--use properties	
		--print( "properties", component._properties )
		for name, _ in pairs( component._properties ) do
			if tabledata[name] then
				component[name] = MathUtil_ShallowCopy( tabledata[name] )
				--print( "set", name, component[name] )
			end			
		end
	end
	--MathUtil_ShallowCopy( getter( id ), component )	
	return component
end

---------------------------------------------------
---------------------------------------------------
--[[
local bfscene 
function load( filename )	
	print( "Load Test Data From File=", filename )

	ECS_Reset()
	
	--load from bf.json
	ImportFileReflection:SetFile( filename )
	local file = Reflection_Import( ImportFileReflection )
	if file then
		bfscene = MathUtil_GetDataByIndex( file )
		--print( "load=", bfscene ) MathUtil_Dump( bfscene, 8 )	
		ECS_Dump( bfscene )
		bfscene:Activate()
	end
end

function save( filename )
	print( "Save Data to File=", filename )
	--save to bf1.json	
	if bfscene then
		ExportFileReflection:SetFile( filename )
		Reflection_Export( ExportFileReflection, bfscene )
		Reflection_Flush( ExportFileReflection )
	end
end
--]]

--!!!test create ecs
--[[
function create()
	print( "Generate Test Data" )
	--------------------------------------
	--test case
	--------------------------------------
	--creating scene
	bfscene = ECS_CreateScene( "battlefield" )

	--create role data root entity
	local rootEntity = ECS_CreateEntity( "RootEntity" )
	bfscene:SetRootEntity( rootEntity )

	local roleDataEntity = ECS_CreateEntity( "RoleData" )
	bfscene:GetRootEntity():AddChild( roleDataEntity )

	--create role entity
	local roleEntity1 = ECS_CreateEntity( "Role" )
	--create component
	local follower = ECS_CreateComponent( "FOLLOWER_COMPONENT" )	
	follower.name = "肖峰"
	follower.age = 40
	follower:GenFightAttr( { level = 3 } )
	roleEntity1:AddComponent( follower )

	local roleEntity2 = ECS_CreateEntity( "Role" )
	local follower = roleEntity2:CreateComponent( "FOLLOWER_COMPONENT" )	
	follower.name = "段誉"
	follower.age = 25
	follower:GenFightAttr( { level = 2 } )

	roleDataEntity:AddChild( roleEntity1 )
	roleDataEntity:AddChild( roleEntity2 )

	--create fight data root entity
	local fightDataEntity = ECS_CreateEntity( "FightData" )
	bfscene:GetRootEntity():AddChild( fightDataEntity )

	local fight = ECS_CreateComponent( "FIGHT_COMPONENT" )
	Prop_Add( fight, "reds", roleEntity1.ecsid )
	Prop_Add( fight, "blues", roleEntity2.ecsid )
	fightDataEntity:AddComponent( fight )
end
--]]

---------------------------------------------------
--[[
create()
save( "bf.json" )
--]]
---------------------------------------------------

---------------------------------------------------
--[[
load_data()
save( "bf1.json" )
--]]
---------------------------------------------------

---------------------------------------------------
--[[
load_data( "bf.json" )
run()
--]]
---------------------------------------------------

---------------------------------------------------
--!!!test create component by data-table
--create_fightskill()
--create_fighter()
---------------------------------------------------

---------------------------------------------------
--!!!test load component from file
--load_data( "fighter_1.json" )
---------------------------------------------------


---------------------------------------------------
--!!!test load component and push into the entity
--[[
function test_addcomponent2entity_fromfile()
	local roleEntity = ECS_CreateEntity( "Role" )
	local fighter    = load_data( "fighter_1.json" )
	roleEntity:AddComponent( fighter )	

	ECS_Dump( roleEntity )
	Dump( roleEntity )
end
test_addcomponent2entity_fromfile()
]]
---------------------------------------------------

---------------------------------------------------
function create_battlefield_scene()
	return ECS_CreateScene( "battlefield" )
end

local function create_roleentity_bydatatable( roleDataEntity, roleTable )
	local roleEntity, follower, fighter, fightertemplate
	
	--create root role entity
	roleEntity = ECS_CreateEntity( "Role" )
	roleDataEntity:AddChild( roleEntity )

	--Create follower data
	follower = create_component_bytabledata( "FOLLOWER_COMPONENT", roleTable )
	roleEntity:AddComponent( follower )

	--Create fighter data
	fighter = create_component_bytabledata( "FIGHTER_COMPONENT", roleTable )	
	--fighter = ECS_CreateComponent( "FIGHTER_COMPONENT" )
	roleEntity:AddComponent( fighter )

	--Create fighter template data
	fightertemplate = ECS_CreateComponent( "FIGHTERTEMPLATE_COMPONENT" )
	roleEntity:AddComponent( fightertemplate )

	--Generate datas
	if not roleTable.template then DBG_Error( "Role data needs template" ) end
	FighterGeneratorSystem:Generate( fighter, fightertemplate, roleTable.template )
	
	--Dump( fightertemplate )
	--InputUtil_Pause()	
end


local function create_roledata_entity()
	local roleDataEntity = ECS_CreateEntity( "RoleData" )
	
	--[[
	create_roleentity_bydatatable( roleDataEntity, 100, 1 )
	create_roleentity_bydatatable( roleDataEntity, 101, 2 )
	create_roleentity_bydatatable( roleDataEntity, 102, 3 )
	create_roleentity_bydatatable( roleDataEntity, 110, 1 )
	--CreateRole( 111 )
	]]
	ROLE_DATATABLE_Foreach( function ( role )
		create_roleentity_bydatatable( roleDataEntity, role )
	end)

	return roleDataEntity
end

---------------------------------------------------
--!!!test fightsystem
function test_fightsystem()
	--create scene
	local bfscene = create_battlefield_scene()

	--create role-data entity
	local roleDataEntity = create_roledata_entity()
	bfscene:GetRootEntity():AddChild( roleDataEntity )

	--create fight-data entity
	local fightDataEntity = ECS_CreateEntity( "FightData" )
	bfscene:GetRootEntity():AddChild( fightDataEntity )
	local fight = ECS_CreateComponent( "FIGHT_COMPONENT" )
	Prop_Add( fight, "reds",  roleDataEntity:GetChild( 1 ).ecsid )
	--Prop_Add( fight, "reds",  roleDataEntity:GetChild( 3 ).ecsid )
	Prop_Add( fight, "blues", roleDataEntity:GetChild( 3 ).ecsid )
	--Prop_Add( fight, "blues", roleDataEntity:GetChild( 4 ).ecsid )
	fightDataEntity:AddComponent( fight )

	--activate
	bfscene:Activate()

	run()
	--save_data( bfscene, "test.scene" )
end


function test_fightergenerator()	
	local roletemplate = TxtDataUtil_Parse( "data/wuxia.csv" )
	FighterGeneratorSystem:SetTemplateData( roletemplate )
	--Dump( roletemplate, 8 )
end


function test_fightskillcreateor()
	FIGHTSKILL_DATATABLE_Foreach( function ( skill )
		FightSkillCreatorSystem:Create( skill, skill.template )
	end)

--[[

	skill       = {}
	skill.name  = "降龙十八掌"
	skill.id    = 110
	FightSkillCreatorSystem:Create( skill, 110 )
	FIGHTSKILL_DATATABLE_Add( skill.id, skill )	

	skill = {}
	skill.name  = "六脉神剑"
	skill.id    = 120
	FightSkillCreatorSystem:Create( skill, 120 )
	FIGHTSKILL_DATATABLE_Add( skill.id, skill )	

	skill = {}
	skill.name  = "天山折梅手"
	skill.id    = 130
	FightSkillCreatorSystem:Create( skill, 130 )
	FIGHTSKILL_DATATABLE_Add( skill.id, skill )	
	]]
end


--[[]]
test_fightskillcreateor()
--]]
--[[]]
--test_fightsystem()
test_fightergenerator()
test_fightsystem()
--]]