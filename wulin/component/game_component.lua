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

	rules    = { type="DICT" },
}

---------------------------------------
function GAME_COMPONENT:__init()
end

---------------------------------------
function GAME_COMPONENT:Deactivate()
	local cmp = self
	ECS_AddListener( self, "Get", nil, function( ... ) return cmp end )
end
	
---------------------------------------
function GAME_COMPONENT:Deactivate()
	local cmp = self
	ECS_RemoveListener( self, "Get", nil, function( ... ) return cmp end )
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