---------------------------------------
--package.path = package.path .. ";utility/?.lua"

---------------------------------------
require "fileutil"
require "logutil"
require "inpututil"
require "txtdatautil"
require "statisticutil"
require "menuutil"
require "stringutil"
require "trackutil"
require "pathfinderutil"


---------------------------------------
require "socket"
function Util_Sleep( time )
   socket.select( nil, nil, time )
end