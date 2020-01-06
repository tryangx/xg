---------------------------------------
TestComponent = class()

---------------------------------------
TestComponentProperties = 
{
	{ type="STRING",   name="TYPE" },
	{ type="STRING",   name="NAME" },
	{ type="NUMBER",   name="ID" },
	{ type="STRING",   name="NAME" },
	{ type="OBJECT",   name="DATA" },
	{ type="LIST",     name="NUMBERS" },
	{ type="LIST",     name="NICKNAMES" },
	{ type="LIST",     name="FRIENDS" },
}

---------------------------------------
function TestComponent:__init()
	self.name        = "TEST_COMPONENT"
	self._properties = TestComponentProperties
end
---------------------------------------

--[[
t._properties = nil
file = io.open( "test_component.standard", "w" )
file:write( json.encode( t ) )
file:close()
]]

file = io.open( "test_component.json" )
t = file:read()
print( t )
t = json.decode( t )
MathUtil_Dump( t )

--t._properties = TestComponentProperties
t.ID = 199
if test_import then
	ImportFileReflection:SetFile( "test_component1.json" )
	Reflection_Import( ExportFileReflection, t )
else
	ExportFileReflection:SetFile( "test_component1.json" )
	Reflection_Export( ExportFileReflection, t )
	Reflection_Flush( ExportFileReflection )
end
--]]