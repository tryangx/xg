---------------------------------------
---------------------------------------
TEST_COMPONENT = class()

---------------------------------------
TEST_PROPERTIES = 
{
	name      = { type="STRING", },
}

---------------------------------------
function TEST_COMPONENT:__init()
	self.actionpts       = {}
	self.members         = {}
	self.membertemplates = {}
end


ECS_RegisterComponent( "TEST_COMPONENT",               TEST_COMPONENT,               TEST_PROPERTIES )

--1.save 2.load 3.create/destroy
test_mode = 2

--test save
if test_mode == 1 then
	--create scene
	bs = ECS_CreateScene( "battlefield" )
	
	gang_entity = bs:GetRootEntity()

	--create component
	gang_component = gang_entity:CreateComponent( "TEST_COMPONENT" )	
	gang_component.level = 99

	--create follow entity
	follow_entity = ECS_CreateEntity( "follower" )
	gang_entity:AddChild( follow_entity )

	--create master
	m = { name = "master", age="50" }
	gang_component.master = m

	--Reflection_Export( DumpReflection, s )
	--Reflection_Flush( DumpReflection )

	ExportFileReflection:SetFile( "bf.json" )
	Reflection_Export( ExportFileReflection, bs )
	Reflection_Flush( ExportFileReflection )

	--print( "json:" )
	--print( json.encode( bs ) )
end


--test load
if test_mode == 2 then
	--load from bf.json
	ImportFileReflection:SetFile( "bf.json" )
	local t = Reflection_Import( ImportFileReflection )	

	--print( "load=", t )	MathUtil_Dump( t, 10 )
	ECS_Dump( t )

	--save to bf1.json
	if t and nil then
		ExportFileReflection:SetFile( "bf1.json" )
		Reflection_Export( ExportFileReflection, t )
		Reflection_Flush( ExportFileReflection )
	end
end

--test create and destroy scene/entity/component
if test_mode == 3 then
	scene = ECS_CreateScene( "ROOTSCENE" )
	entity1 = ECS_CreateEntity( "ENTITY1" )
	scene:GetRootEntity():AddChild( entity1 )
	entity1_1 = ECS_CreateEntity( "ENTITY1_1" )
	entity1:AddChild( entity1_1 )
	entity1_1:CreateComponent( "TEST_COMPONENT" ).name = "1-1"

	entity1_2 = ECS_CreateEntity( "ENTITY1_2" )	
	entity1:AddChild( entity1_2 )
	entity1_2:CreateComponent( "TEST_COMPONENT" ).name = "1-2a"
	local cmp = entity1_2:CreateComponent( "TEST_COMPONENT" )
	cmp.name = "1-2b"

	entity2 = ECS_CreateEntity( "ENTITY2" )
	scene:GetRootEntity():AddChild( entity2 )
	entity2_1 = ECS_CreateEntity( "ENTITY2_1" )
	entity2:AddChild( entity2_1 )
	entity2:CreateComponent( "TEST_COMPONENT" ).name = "2"
	entity2_1:CreateComponent( "TEST_COMPONENT" ).name = "2-1"
	
	ECS_Dump( scene )
	InputUtil_Pause( "Begining" )

	print( "Try to remove component", cmp )
	print( "Remove from " .. entity1_1.ecsid, entity1_1:RemoveComponent( cmp ) )
	print( "Remove from " .. entity1_2.ecsid, entity1_2:RemoveComponent( cmp ) )
		
	ECS_Dump( scene )
	InputUtil_Pause( "After component removed" )

	print( "Try to remove leaf entity", entity1_1.ecsname )
	entity1:RemoveChild( entity1_1 )

	ECS_Dump( scene )
	InputUtil_Pause( "After entity removed" )

	print( "Try to remove node entity", entity1.ecsname )
	scene:GetRootEntity():RemoveChild( entity1 )	

	ECS_Dump( scene )
	InputUtil_Pause( "After entity removed" )
end