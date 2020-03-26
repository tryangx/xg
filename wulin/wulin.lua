---------------------------------------------------
---------------------------------------------------
package.path = package.path .. ";wulin/component/?.lua"
package.path = package.path .. ";wulin/system/?.lua"
package.path = package.path .. ";wulin/datatable/?.lua"


--data table
require "fightskill_datatable"
require "fightskilltemplate_datatable"
require "role_datatable"
require "roletemplate_datatable"
require "gang_datatable"


--component
require "fight_component"
require "role_component"
require "fighter_component"
require "fightskill_component"
require "fightertemplate_component"
require "follower_component"
require "gang_component"
require "game_component"
require "data_component"


--system
require "rolecreator_system"
require "fightergenerator_system"
require "fightskillcreator_system"
require "role_system"
require "gang_system"
require "fight_system"
require "data_system"
require "game_system"


---------------------------------------------------
---------------------------------------------------
--register component
ECS_RegisterComponent( "GAME_COMPONENT",               GAME_COMPONENT,               GAME_PROPERTIES )
ECS_RegisterComponent( "DATA_COMPONENT",               DATA_COMPONENT,               DATA_PROPERTIES )
ECS_RegisterComponent( "GANG_COMPONENT",               GANG_COMPONENT,               GANG_PROPERTIES )
ECS_RegisterComponent( "ROLE_COMPONENT",               ROLE_COMPONENT,               ROLE_PROPERTIES )
ECS_RegisterComponent( "FOLLOWER_COMPONENT",           FOLLOWER_COMPONENT,           FOLLOWER_PROPERTIES )
ECS_RegisterComponent( "FIGHT_COMPONENT",              FIGHT_COMPONENT,              FIGHT_PROPERTIES )
ECS_RegisterComponent( "FIGHTER_COMPONENT",            FIGHTER_COMPONENT,            FIGHTER_PROPERTIES )
ECS_RegisterComponent( "FIGHTSKILL_COMPONENT",         FIGHTSKILL_COMPONENT,         FIGHTSKILL_PROPERTIES )
ECS_RegisterComponent( "FIGHTERTEMPLATE_COMPONENT",    FIGHTERTEMPLATE_COMPONENT,    FIGHTERTEMPLATE_PROPERTIES )


---------------------------------------------------
---------------------------------------------------
--register system
RoleSystem = ROLE_SYSTEM()
ECS_RegisterSystem( RoleSystem )

GangSystem = GANG_SYSTEM()
ECS_RegisterSystem( GangSystem )

FightSystem = FIGHT_SYSTEM()
ECS_RegisterSystem( FightSystem )

GameSystem = GAME_SYSTEM()
ECS_RegisterSystem( GameSystem )


FighterGeneratorSystem = FIGHTERGENERATOR_SYSTEM()
FightSkillCreatorSystem = FIGHTSKILLCREATOR_SYSTEM()


---------------------------------------------------
---------------------------------------------------
function run()
	while ECS_Update( 1 ) do
		if pause_menu()	then return end
	end

	ECS_DumpSystem()

	Stat_Dump( StatType.LIST )
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
		ECS_Dump( data )
		--Dump( data )
		return data
	end
end


---------------------------------------------------
function save( filename )
	print( "[SAVE]Try to save file=" .. filename )
	ExportFileReflection:SetFile( filename )
	ECS_ForeachScene( function ( scene )
		print( "[SAVE]Save Scene=" .. scene.ecsname )
		--ECS_Dump( scene )
		Reflection_Export( ExportFileReflection, scene )
	end)	
	Reflection_Flush( ExportFileReflection )
	InputUtil_Pause( "[SAVE]End to save file=" .. filename )
end


---------------------------------------------------
function load( filename )
	print( "[LOAD]Load from file=" .. filename )
	ImportFileReflection:SetFile( filename )
	local file = Reflection_Import( ImportFileReflection )
	if not file then return end
	local scene = MathUtil_GetDataByIndex( file )
	--ECS_Dump( data )
	InputUtil_Pause( "[LOAD]End to load file=" .. filename )

	--need to process data entities
	ECS_PushScene( scene )
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
--!!!test fightsystem
function test_fightsystem()
	Init_Table()

	--create scene
	local scene = ECS_CreateScene( "battlefield" )

	--create role-data entity
	local roleDataEntity = InitRoles( scene )	

	--create fight-data entity
	local fightDataEntity = InitFight( scene )

	local fight = ECS_CreateComponent( "FIGHT_COMPONENT" )
	Prop_Add( fight, "reds",  roleDataEntity:GetChild( 1 ).ecsid )
	--Prop_Add( fight, "reds",  roleDataEntity:GetChild( 3 ).ecsid )
	Prop_Add( fight, "blues", roleDataEntity:GetChild( 3 ).ecsid )
	--Prop_Add( fight, "blues", roleDataEntity:GetChild( 4 ).ecsid )
	fightDataEntity:AddComponent( fight )

	--activate
	scene:Activate()

	run()
	--save_data( bfscene, "test.scene" )
end

--test_fightsystem()
--new_game()


---------------------------------------------------
---------------------------------------------------
function new_game()
	local scene = InitScene()
	ECS_PushScene( scene )
	run()
end


local _savefile = "testsave.sav"
---------------------------------------------------
---------------------------------------------------
function pause_menu()
	local cmp = ECS_FindComponent( Data_GetRoot( "GAME_DATA" ).ecsid, "GAME_COMPONENT" )
	cmp:ToString()
	return Menu_PopupMenu(
					{
						{ c = "1", content = 'SAVE',   fn = function () save( _savefile ) end },
						{ c = "2", content = 'LOAD',   fn = function () load( _savefile ) end }, 
						{ c = "3", content = 'EXIT',   ret = 1, fn = function () end }, 
						{ c = "", content = 'RESUME',  fn = function () end },
					}
				, "Pause Menu" )
end


---------------------------------------------------
---------------------------------------------------
function main_menu()
	Init_Table()

	Menu_PopupMenu( 
					{
						{ c = "1", content = 'NEW',  fn = function () new_game() end },
						{ c = "2", content = 'LOAD', fn = function () load( _savefile ) run() end }, 
						{ c = "3", content = 'EXIT', fn = function () end },
					}
				, "Main Menu" )
end


---------------------------------------------------
---------------------------------------------------
main_menu()
--new_game()