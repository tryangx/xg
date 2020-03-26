---------------------------------------
package.path = package.path .. ";lib/json/?.lua"

---------------------------------------
require "unclasslib"

--declare a global target
json = require( "3rdjson" )
--json = require "json"

print( "Use 3rd party json" )
