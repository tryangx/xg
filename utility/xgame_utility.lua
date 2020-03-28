---------------------------------------
--package.path = package.path .. ";utility/?.lua"

---------------------------------------
require "mathutil"
require "randomizer"
require "fileutil"
require "logutil"
require "inpututil"
require "txtdatautil"
require "statisticutil"
require "menuutil"
require "stringutil"
require "trackutil"


---------------------------------------
require "socket"
function Util_Sleep( time )
   socket.select( nil, nil, time )
end