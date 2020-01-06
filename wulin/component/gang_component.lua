---------------------------------------
GANG_COMPONENT = class()

---------------------------------------
GangProperties = 
{
	type      = { type="STRING", },
	level     = { type="NUMBER", },
	followers = { type="LIST_NUMBER", },
	master    = { type="OBJECT", },
}

---------------------------------------
function GANG_COMPONENT:__init()
	self.typename    = "GANG_COMPONENT"
	self._properties = GangProperties
end

---------------------------------------
