--register component
ECS_Register( "GANG_COMPONENT", GANG_COMPONENT, GangProperties )

--create scene
s = ECS_CreateScene( "battlefield" )

--1.save 2.load
test_mode = 2

--test save
if test_mode == 1 then
	--create entity
	e = s:CreateEntity( "gang" )

	--create component
	c = e:CreateComponent( "GANG_COMPONENT" )	
	c.level = 99

	--Reflection_Export( DumpReflection, s )
	--Reflection_Flush( DumpReflection )

	ExportFileReflection:SetFile( "bf.json" )
	Reflection_Export( ExportFileReflection, s )
	Reflection_Flush( ExportFileReflection )

	s._properties = nil
	print( "json:" )
	print( json.encode( s ) )
end


--test load
if test_mode == 2 then
	ImportFileReflection:SetFile( "bf.json" )
	local t = Reflection_Import( ImportFileReflection )
	print( "load=", t )	MathUtil_Dump( t, 10 )

	if t then
		ExportFileReflection:SetFile( "bf1.json" )
		Reflection_Export( ExportFileReflection, t )
		Reflection_Flush( ExportFileReflection )
	end
end