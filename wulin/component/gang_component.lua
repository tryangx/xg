---------------------------------------
---------------------------------------
--[[
	


--]]
---------------------------------------
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
	--self.ecsname     = "GANG_COMPONENT"
	--self._properties = GangProperties
end

---------------------------------------
function GANG_COMPONENT:Activate()	
end

function GANG_COMPONENT:Deactivate()

end

function GANG_COMPONENT:Update()

end