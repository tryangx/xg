---------------------------------------------
package.path = package.path .. ";lib/?.lua"
package.path = package.path .. ";base/?.lua"
package.path = package.path .. ";utility/?.lua"
package.path = package.path .. ";common/?.lua"

require "xgame_lib"
require "xgame_base"
require "xgame_utility"
require "xgame_common"

---------------------------------------------
package.path = package.path .. ";wulin/?.lua"

require "wulin"

---------------------------------------------

--print( package.path )

--require( "json_test")

--[[
--require "json"

function check( name, func )
	xpcall( function()		
		func()
		print( string.format("[pass] %s", name) )
	end, function(err)
		print( string.format("[fail] %s : %s", name, err) )
	end)
end

function mytest()
	--assert( json.decode("true") == true )
	--assert( json.decode("null") == nil )
	--assert( json.decode("NULL") == nil )
	--assert( json.decode("nil") == nil )
	--assert( json.decode("undefined") == nil )
end

--check( "mytest", mytest )

--]]

--[[
local t = 
{
	name = "xyang",
	id   = 10000,
}


print( json.encode( t ) )
--]]

---------------------------------------------
--test import/export component
--require( "gang_component" )

--[[
g = {
	k = { "abc", "def" }
}
local code = json.encode( g )
print( code )
MathUtility_Dump( json.decode( code ) )
--]]

--[[
local fmt = string.format
local o = 
{
	name = "good",
	age=12,
	couple = null,
}
local t = {
	name="dalvin",
	lv=99,
	student={ o }
}

local j = require( "json" )
local r = j.encode( t )
print( r )
d = j.decode( r )
MathUtility_Dump( d )

--]]

---------------------------------------------
--require "sample.component_sample"

require "sample.ecs_sample"