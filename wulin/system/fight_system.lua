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
		local groupentity = ECS_FindEntity( fight.bluegroupid )
		if groupentity then
			local group = groupentity:GetComponent( "GROUP_COMPONENT" )
			group:DecStatusValue( "UNDER_ATTACK", 1 )
		end

		--siege
		if fight.rules["SIEGE"] then
			if fight.result == "ATK_WIN" then
				Relation_MakeVassal( fight.atkgroupid, fight.defgroupid )
			end
		end

		--destroy fight entity
		ECS_DestroyEntity( entity )
		Log_Write( "fight", "fight removed id=" .. ecsid )
		InputUtil_Pause( "End Fight" )
		return true
	end)

	--InputUtil_Pause( "Fight Left:", #self._fights )
end


------------------------------ ---------
function FIGHT_SYSTEM:AppendFight( entityid )
	table.insert( self._fights, entityid )
end


---------------------------------------
function FIGHT_SYSTEM:CreateFight( params )
	local entity = ECS_CreateEntity( "FightData" )	
	local fightCmp = ECS_CreateComponent( "FIGHT_COMPONENT" )
	if params.istestfight then
		fightCmp:InitTestFight()
	elseif params.issiege then
		fightCmp:InitSiegeFight()
	end
	Prop_Set( fightCmp, "atkgroupid", params.atkgroupid )
	Prop_Set( fightCmp, "defgroupid", params.defgroupid )
	Prop_AddByTable( fightCmp, "atks", params.atkeids )
	Prop_AddByTable( fightCmp, "defs", params.defeids )
	entity:AddComponent( fightCmp )
	Data_GetRoot( "FIGHT_DATA" ):AddChild( entity )

	DBG_Trace( "Create fight id=" .. entity.ecsid )
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