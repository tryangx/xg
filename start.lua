---------------------------------------------
--Link the libraries
package.path = package.path .. ";lib/?.lua"
package.path = package.path .. ";base/?.lua"
package.path = package.path .. ";utility/?.lua"
package.path = package.path .. ";common/?.lua"

require "xgame_lib"
require "xgame_base"
require "xgame_utility"
require "xgame_common"

---------------------------------------------
--Link the GameLogic
package.path = package.path .. ";wulin/?.lua"

require "wulin"

---------------------------------------------

--[[
local list = { 1, 2, 3, 4, 5 }
MathUtil_RemoveListItemIf( list, function( v )
	return v == 2 or v == 4
end )
--list will be 1=1, 2=3, 3=5.
Dump( list )

]]