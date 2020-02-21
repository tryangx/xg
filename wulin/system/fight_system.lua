------------------------------------------------------------------------------
--
-- Fight System
--
-- A Fight means two teams duel in a area
--
-- Teams stands in 2*3 blocks likes below:
--    6 1
--    5 2
--    4 3
--
-- Fighters will fight with 
--
------------------------------------------------------------------------------
FightFormation = 
{
	
}


---------------------------------------
---------------------------------------
FightSystem = class()

---------------------------------------
function FightSystem:__init( ... )
	local args = ...
	self._name = args and args.name or "FIGHT_SYSTEM"

	--store the fight_component's entity-id
	self._fights = {}
end


---------------------------------------
function FightSystem:Activate()

end


---------------------------------------
function FightSystem:Update( deltaTime )
	for _, fight in ipairs( self._fights ) do
		self:Fight( fight )
	end
end


---------------------------------------
function FightSystem:AppendFight( entityid )
	table.insert( self._fights, entityid )
	--print( "add fight", entityid )
end


---------------------------------------
function FightSystem:Fight( fight_id )
	local entity = ECS_FindEntity( fight_id )
	if not entity then
		DBG_Error( "invalid fight entity!", fight_id )
		return
	end
	
	local cmp = entity:GetComponent( "FIGHT_COMPONENT" )

	print( "Lets fight", fight_id, entity, cmp )

	local duels = {}

	function FindTarget( fighter, opps )
		--      Red              Blue
		-- Row(r) Line(l)    Row(r) Line(l)
		--  R2L1  R1L1        R1L1   R2L1
		--  R2L2  R1L2        R1L2   R2L2
		--  R2L3  R1L3        R1L3   R2L3
		local find
		local distance = 0
		for _, opp in ipairs( opps ) do			
			if not find then
				find = opp.fighter
			else
				local newDistance = abs( opp.line - fighter.line ) + abs( opp.fighter - fighter.row )
				if newDistance < distance then
					find = opp.fighter
				end
			end
		end
		return find
	end
	
	function MakeTeamDuel( teams, oppTeams )
		for _, data in ipairs( teams ) do
			local fighter = data.fighter
			local target = FindTarget( fighter, oppTeams )
			if target then
				local priority = Random_GetInt_Sync( 1, fighter.fight_attr.agi )				
				table.insert( duels, { atk = fighter, def = target, priority = priority } )
				print( "make duel", fighter, target )
			end
		end
	end

	--make duels
	MakeTeamDuel( cmp._reds, cmp._blues )
	MakeTeamDuel( cmp._blues, cmp._reds )

	--shuffle
	MathUtil_Shuffle_Sync( duels )

	--resort
	table.sort( duels, function ( l, r )
		print( "compare", l.priority, r.priority )
		return l.priority > r.priority
	end )

	function ProcessDuel( atk, def )
		if def.fight_attr.hp <= 0 then return end
		--damage
		--  DamageOutput = atk
		--  DamageExtra  = rand( 1, ski )
		--  DamageOutputResist = def		
		local base_damage = atk.fight_attr.atk - def.fight_attr.def
		local extra_damage = Random_GetInt_Sync( 0, atk.fight_attr.ski ) - Random_GetInt_Sync( 0, math.floor( def.fight_attr.agi * 0.5 ) )
		local damage = math.max( 0, base_damage + extra_damage )
		if damage <= 0 then return end
		print( atk.name .. " deal damage " .. damage .. " to " .. def.name )
		def.fight_attr.hp = math.max( 0, def.fight_attr.hp - damage )
		print( def.name .. " hp is " .. def.fight_attr.hp .. " now." )
	end

	--process duels
	for _, duel in ipairs( duels ) do
		ProcessDuel( duel.atk, duel.def )
	end

	--check winner
	function HasAlive( teams )
		for _, data in ipairs( teams ) do
			local fighter = data.fighter
			if fighter.fight_attr.hp > 0 then
				return true
			end
		end
	end

	if not HasAlive( cmp._reds ) then
		print( "red teams are all dead" )
	elseif not HasAlive( cmp._reds ) then
		print( "red teams are all dead" )
	end
end

---------------------------------------
function FightSystem:Duel( roleid1, roleid2 )

end


---------------------------------------