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
function GAME_SYSTEM:Update( deltaTime )
	CurrentGame:Elapsed( deltaTime )
	if not CurrentGame:IsGameOver() then return end
	
	CurrentGame.totpower = 0
	ECS_Foreach( "GROUP_COMPONENT", function ( group )
		CurrentGame.totpower = CurrentGame.totpower + group:GetAttr( "POWER" )
	end )

	ECS_Foreach( "GROUP_COMPONENT", function ( group )
		CurrentGame:CalcScore( group )
	end )

	if CurrentGame.winner then
		print( CurrentGame.winner )
		DBG_Trace( "Winner=" .. ECS_FindComponent( CurrentGame.winner, "GROUP_COMPONENT" ).name )
	end

	InputUtil_Pause( "game end" )
	ECS_LeaveScene()
end