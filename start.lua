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
--Test ECS
--[[
package.path = package.path .. ";sample/?.lua"
require "ecs_sample"
--]]

---------------------------------------------