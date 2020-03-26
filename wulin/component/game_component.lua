---------------------------------------
---------------------------------------
GAME_COMPONENT = class()

---------------------------------------
GAME_PROPERTIES = 
{
	scenario = { type="NUMBER" },

	startTime= { type="NUMBER" },
	endTime  = { type="NUMBER", default = 1 },
}

---------------------------------------
function GAME_COMPONENT:__init()
end


---------------------------------------
function GAME_COMPONENT:Update( deltaTime )
	self.startTime = self.startTime + deltaTime
end

---------------------------------------
function GAME_COMPONENT:IsGameOver( ... )
	return self.startTime >= self.endTime
end

---------------------------------------
function GAME_COMPONENT:ToString()
	print( "GameTime:" .. self.startTime .. "/" .. self.endTime )
end