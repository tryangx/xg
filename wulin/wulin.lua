--------------------------------------
package.path = package.path .. ";wulin/component/?.lua"
package.path = package.path .. ";wulin/system/?.lua"

--require "follower_component"
require "gang_component"
require "follower_component"
require "fight_component"

require "fight_system"

--------------------------------------
--register component
ECS_RegisterComponent( "GANG_COMPONENT",     GANG_COMPONENT,     GangProperties )
ECS_RegisterComponent( "FOLLOWER_COMPONENT", FOLLOWER_COMPONENT, FollowerProperties )
ECS_RegisterComponent( "FIGHT_COMPONENT",    FIGHT_COMPONENT,    FightProperties )


--register system
ECS_RegisterSystem( FightSystem( { name = "FIGHT_SYSTEM" } ) )


local bfscene

function create()
	print( "Generate Test Data" )
	--------------------------------------
	--test case
	--------------------------------------
	--skip creating scene
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

function run()	
	g_curTurn = 1
	g_endTurn = 2
	function IsGameEnd()
		if g_curTurn >= g_endTurn then return true end
		g_curTurn = g_curTurn + 1
	end

	while not IsGameEnd() do
		print( "run loop" )
		ECS_Update()
	end
end

function load( filename )	
	print( "Load Test Data From File=", filename )

	ECS_Reset()

	--load from bf.json
	ImportFileReflection:SetFile( filename )
	local file = Reflection_Import( ImportFileReflection )
	bfscene = MathUtil_GetDataByIndex( file )
	--print( "load=", bfscene ) MathUtil_Dump( bfscene, 8 )	
	ECS_Dump( bfscene )
	bfscene:Activate()
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

--[[
create()
save( "bf.json" )
--]]

--[[
load()
save( "bf1.json" )
--]]

--[[]]
load( "bf.json" )
run()
--]]
