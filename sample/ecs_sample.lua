--1.save 2.load
test_mode = 2

--test save
if test_mode == 1 then
	--create scene
	bs = ECS_CreateScene( "battlefield" )

	--create entity
	gang_entity = ECS_CreateEntity( "gang" )
	bs:SetRootEntity( gang_entity )
	--create component
	gang_component = gang_entity:CreateComponent( "GANG_COMPONENT" )	
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

	print( "json:" )
	print( json.encode( bs ) )
end


--test load
if test_mode == 2 then
	--load from bf.json
	ImportFileReflection:SetFile( "bf.json" )
	local t = Reflection_Import( ImportFileReflection )	

	--print( "load=", t )	MathUtil_Dump( t, 10 )

	--save to bf1.json
	if t then
		ExportFileReflection:SetFile( "bf1.json" )
		Reflection_Export( ExportFileReflection, t )
		Reflection_Flush( ExportFileReflection )
	end
end