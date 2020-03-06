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
--
--
-- Duel Process
--   1. Both side choose its fight-skill at first
--   2. Traverse all the actions both
--   3. Determine tactic( default / speed / power / skill )
--      Speed : attack 50%, defend 100%, speed 150%
--      Power : attack 150%, defend 50%, speed 50%
--      Skill : attack 50%, defend 150%, speed 50%
--      Normal: nothing
--      Rest  : recover 10%, defend 25%
--   4. Calculate the 
--
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
	print( "Activate System")
end


---------------------------------------
function FightSystem:Update( deltaTime )	
	for _, fight in ipairs( self._fights ) do
		self:ProcessFight( fight )
	end
end


---------------------------------------
function FightSystem:AppendFight( entityid )
	table.insert( self._fights, entityid )
	--print( "add fight", entityid )
end


---------------------------------------
local function MakeDuels( cmp )
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
				find = opp
			else
				local newDistance = abs( opp.line - fighter.line ) + abs( opp.fighter - fighter.row )
				if newDistance < distance then
					find = opp
				end
			end
		end
		return find
	end
	
	function MakeTeamDuel( teams, oppTeams )
		for _, data in ipairs( teams ) do
			local target = FindTarget( data.fighter, oppTeams )
			if target then
 				local priority = Random_GetInt_Sync( 1, data.fighter.agility )				
				table.insert( duels, { atk = data, def = target, priority = priority } )
				--print( "make duel", data.follower.name, target.follower.name )
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

	return duels;
end


local function ProcessDuels( duels )
	function ProcessDuel( atk, def )
		if def.fighter.hp <= 0 then return end
		--damage
		--  DamageOutput = atk
		--  DamageExtra  = rand( 1, ski )
		--  DamageOutputResist = def		
		local base_damage = 100--atk.fighter.atk - def.fight_attr.def
		local extra_damage = Random_GetInt_Sync( 0, atk.fighter.technique ) - Random_GetInt_Sync( 0, math.floor( def.fighter.agility * 0.5 ) )
		local damage = math.max( 0, base_damage + extra_damage )
		if damage <= 0 then return end
		print( atk.follower.name .. " deal damage " .. damage .. " to " .. def.follower.name )
		def.fighter.hp = math.max( 0, def.fighter.hp - damage )
		print( def.follower.name .. " hp is " .. def.fighter.hp .. " now." )
	end	

	--process duels
	for _, duel in ipairs( duels ) do
		ProcessDuel( duel.atk, duel.def )
	end
end


local function CheckResult( cmp )
	--check winner
	function HasAlive( teams )
		for _, data in ipairs( teams ) do
			local fighter = data.fighter
			if data.fighter.hp > 0 then
				return true
			end
		end
	end

	if not HasAlive( cmp._reds ) then
		print( "red teams are all dead" )
	elseif not HasAlive( cmp._blues ) then
		print( "red teams are all dead" )
	end
end


function FightSystem:ProcessFight( fight_id )
	local entity = ECS_FindEntity( fight_id )
	if not entity then
		DBG_Error( "invalid fight entity!", fight_id )
		return
	end

	print( "Fight", fight_id, entity )

	local cmp = entity:GetComponent( "FIGHT_COMPONENT" )
	local duels = MakeDuels( cmp )
	ProcessDuels( duels )
	CheckResult( cmp )
end


---------------------------------------
function FightSystem:Duel( roleid1, roleid2 )

end


---------------------------------------