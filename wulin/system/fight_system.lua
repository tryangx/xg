---------------------------------------
---------------------------------------
require "fight"

---------------------------------------
---------------------------------------
FIGHT_SYSTEM = class()

---------------------------------------
function FIGHT_SYSTEM:__init( ... )
	local args = ...
	self._name = args and args.name or "FIGHT_SYSTEM"

	--store the fight_component's entity-id
	self._fights = {}
end


---------------------------------------
function FIGHT_SYSTEM:Activate()
	--print( "Activate System")
end


---------------------------------------
function FIGHT_SYSTEM:Update( deltaTime )
	--print( "Update Fight System" )
	MathUtil_RemoveListItemIf( self._fights, function ( ecsid )
		self:ProcessFight( ecsid )

		--clear the under attack status
		local entity = ECS_FindEntity( ecsid )
		local fight = entity:GetComponent( "FIGHT_COMPONENT" )
		local gangentity = ECS_FindEntity( fight.bluegang )		
		local gang = gangentity:GetComponent( "GANG_COMPONENT" )
		gang:DecStatusValue( "UNDER_ATTACK", 1 )

		ECS_DestroyEntity( entity )

		Log_Write( "fight", "fight removed id=" .. ecsid )

		return true
	end)

	--InputUtil_Pause( "Fight Left:", #self._fights )
end


------------------------------ ---------
function FIGHT_SYSTEM:AppendFight( entityid )
	table.insert( self._fights, entityid )
	--InputUtil_Pause( "add fight" )
end


---------------------------------------
function FIGHT_SYSTEM:CreateFight( atkgang, defgang, atk_eids, def_eids )
	local entity = ECS_CreateEntity( "FightData" )	
	local fight = ECS_CreateComponent( "FIGHT_COMPONENT" )
	Prop_Set( fight, "redgang", atkgang )
	Prop_Set( fight, "bluegang", defgang )
	Prop_Add( fight, "reds",  atk_eids )
	Prop_Add( fight, "blues", def_eids )
	entity:AddComponent( fight )
	Data_GetRoot( "FIGHT_DATA" ):AddChild( entity )
	entity:Activate()

	Log_Write( "fight", "Create fight id=" .. entity.ecsid )
end


---------------------------------------
function FIGHT_SYSTEM:ProcessFight( ecsid )
	local entity = ECS_FindEntity( ecsid )
	if not entity then
		ECS_Foreach( "FIGHT_COMPONENT", function ( fight )
			print( "fightid=" .. fight.entityid )
		end )
		DBG_Error( "Invalid fight entity! ID=" .. 	ecsid )
		return
	end
	
	local fight = entity:GetComponent( "FIGHT_COMPONENT" )

	Fight_Process( fight )
end


---------------------------------------
function FIGHT_SYSTEM:Dump()
	ECS_Foreach( "FIGHT_COMPONENT", function ( fight )
		fight:Dump()
	end )
end