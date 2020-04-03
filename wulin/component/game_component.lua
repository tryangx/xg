---------------------------------------
---------------------------------------
GAME_COMPONENT = class()

---------------------------------------
GAME_PROPERTIES = 
{
	scenario = { type="NUMBER" },

	curTime  = { type="NUMBER" },
	startTime= { type="NUMBER" },
	endTime  = { type="NUMBER", default = 1 },
}

---------------------------------------
function GAME_COMPONENT:__init()
end

---------------------------------------
function GAME_COMPONENT:Deactivate()
	InputUtil_Pause( "Deactivated", self:ToString() )
end

---------------------------------------
function GAME_COMPONENT:Update( deltaTime )
	self.curTime = self.curTime + deltaTime
end

---------------------------------------
function GAME_COMPONENT:IsGameOver( ... )
	return self.curTime >= self.endTime
end

---------------------------------------
function GAME_COMPONENT:ToString()
	local content = "GameTime:" .. self.curTime .. "/" .. self.endTime
	return content	
end

function GAME_COMPONENT:Dump()
	print( self:ToString() )
end