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
	if not CurrentGame:IsGameOver() then return end
	
	CurrentGame.totpower = 0
	ECS_Foreach( "GROUP_COMPONENT", function ( group )
		CurrentGame.totpower = CurrentGame.totpower + group:GetData( "POWER" )
	end )

	ECS_Foreach( "GROUP_COMPONENT", function ( group ) CurrentGame:CalcScore( group ) 	end )

	if CurrentGame.winner then 	DBG_Trace( "Winner=" .. ECS_FindComponent( CurrentGame.winner, "GROUP_COMPONENT" ).name ) end

	ECS_LeaveScene()

	InputUtil_Pause( "game end" )
end