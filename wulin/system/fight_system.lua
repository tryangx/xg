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
end


---------------------------------------
function FIGHT_SYSTEM:Activate()
end


---------------------------------------
function FIGHT_SYSTEM:Update( deltaTime )
	local list = {}
	ECS_Foreach( "FIGHT_COMPONENT", function ( fight )
		self:ProcessFight( fight )

		--clear the under attack status
		local groupentity = ECS_FindEntity( fight.bluegroupid )
		if groupentity then
			local group = groupentity:GetComponent( "GROUP_COMPONENT" )
			group:DecStatusValue( "UNDER_ATTACK", 1 )
		end

		local makeVassal = true
		local atkGroup = ECS_FindComponent( fight.atkgroupid, "GROUP_COMPONENT" )		
		if #atkGroup.members == 0 then makeVassal = false Group_Terminate( atkGroup.entityid ) end

		--siege
		if fight.rules["SIEGE"] then			
			if fight.result == "ATK_WIN" then
				--group terminated
				local defGroup = ECS_FindComponent( fight.defgroupid, "GROUP_COMPONENT" )
				if #defGroup.members == 0 then makeVassal = false Group_Terminate( defGroup.entityid ) end
				if makeVassal then Relation_MakeVassal( fight.atkgroupid, fight.defgroupid ) end	
			end
		end

		table.insert( list, fight.entityid )
		--return true
	end )

	for _, ecsid in ipairs( list ) do		
		local entity = ECS_FindEntity( ecsid )
		--destroy fight entity
		ECS_DestroyEntity( entity )
		Log_Write( "fight", "fight removed id=" .. ecsid )
		--InputUtil_Pause( "End Fight", entity.ecsid )
	end	

	--InputUtil_Pause( "Fight Left:", #self._fights )
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
function FIGHT_SYSTEM:ProcessFight( fight )
	--[[
	local entity = ECS_FindEntity( ecsid )
	if not entity then
		ECS_Foreach( "FIGHT_COMPONENT", function ( fight )
			print( "fightid=" .. fight.entityid )
		end )
		DBG_Error( "Invalid fight entity! ID=" .. 	ecsid )
		return
	end
	]]
	local fight = entity:GetComponent( "FIGHT_COMPONENT" )
	Fight_Process( fight )
end


---------------------------------------
function FIGHT_SYSTEM:Dump()
	ECS_Foreach( "FIGHT_COMPONENT", function ( fight )
		fight:Dump()
	end )
end