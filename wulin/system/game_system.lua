---------------------------------------
---------------------------------------
GAME_SYSTEM = class()


---------------------------------------
---------------------------------------
function GAME_SYSTEM:__init( ... )
	local args = ...
	self._name = args and args.name or "GAME_SYSTEM"
end


---------------------------------------
---------------------------------------
function GAME_SYSTEM:Update()
	ECS_Foreach( "GAME_COMPONENT", function ( game )		
		if game:IsGameOver() then
			InputUtil_Pause( "game end" )
			ECS_LeaveScene()
		end
	end )
end