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
-- ATB Action
--   Role will action after its action point is enough, AGILITY is the key attribute
--
-- Duel Process
--   When role ready to act, it will determine his TARGET, ACTION, TACTIC
--   TARGET
--     means a single target or serveral targets
--   ACTION
--     means the fight-skill
--   TACTIC
--     means attack( 100% damage, 50% block ), defend( 50% damage, 100% block, special effect )
--
------------------------------------------------------------------------------
FightFormation = 
{
	
}


FIGHT_SIDE = 
{
	NONE = 0,
	RED  = 1,
	BLUE = 2,
}
--   Role will action after its action point is enough
--   

FIGHT_ACTIONTIME = 
{
	DEFAULT  = 1000,
	USESKILL = 3000,
	DEFEND   = 2000,
}


---------------------------------------
-- Helper
---------------------------------------
local function ForeachRole( teams, fn )
	for _, role in ipairs( teams ) do
		fn ( role )
	end
end


---------------------------------------
local function Dump_Role( role )
	print( role.follower.name )
	print( "", "hp=" .. role.fighter.hp )
	print( "", "mp=" .. role.fighter.mp )
	print( "", "st=" .. role.fighter.st )
	print( "", "DealDamg=" .. ( role.fighter._dealDamage or 0 ) )
	print( "", "HitTimes=" .. ( role.fighter._totalHit or 0 ) )
	print( "", "ActTimes=" .. ( role.fighter._actTimes or 0 ) )
	print( "", "RestTimes=" .. ( role.fighter._restTimes or 0 ) )
end


---------------------------------------
local function IsRoleAlive( role )
	if not role then return false end
	return role.fighter.hp > 0
end	


---------------------------------------
local function CheckResult( cmp )
	--check winner
	function HasAlive( teams )
		for _, data in ipairs( teams ) do
			if IsRoleAlive( data ) then
				return true
			end
		end
	end

	if not HasAlive( cmp._reds ) then
		print( "red teams are all dead" )
		return FIGHT_SIDE.RED
	elseif not HasAlive( cmp._blues ) then
		print( "red teams are all dead" )
		return FIGHT_SIDE.BLUE
	end
	return FIGHT_SIDE.NONE
end


---------------------------------------
local function FindTarget( role, opps )
	--      Red              Blue
	-- Row(r) Line(l)    Row(r) Line(l)
	--  R2L1  R1L1        R1L1   R2L1
	--  R2L2  R1L2        R1L2   R2L2
	--  R2L3  R1L3        R1L3   R2L3
	local find
	local distance
	for _, opp in ipairs( opps ) do
		if IsRoleAlive( opp ) then
			local newDistance = math.abs( opp.line - role.line ) + math.abs( opp.row - role.row )
			if not find then
				distance = newDistance
				find = opp
				--print( role.follower.name, opp.follower.name, "default" )
			else
				--print( role.follower.name, opp.follower.name, newDistance, distance )
				if newDistance < distance then
					distance = newDistance
					find = opp
				end
			end
		end
	end
	if not find then
		print( role.follower.name .. " doesn't find target." ) 
	end
	return find
end


---------------------------------------
local function CanUsingSkill( skill, atk, def, isDefend )
	--check cost
	--print( "can using skill", skill.name, skill.cost.type, skill.cost.value )	
	local value
	if isDefend then
		value = skill.cost.defend
	else
		value = skill.cost.using
	end
	if skill.cost.type == "ST" then
		return atk.fighter.st > value
	elseif skill.cost.type == "MP" then
		return atk.fighter.mp > value
	elseif skill.cost.type == "HP" then
		return atk.fighter.hp > value
	end
	return true
end


---------------------------------------
local function UseSkill( role, skill, isDefend )
	if not skill then return end
	local value
	if isDefend then
		value = skill.cost.defend
	else
		value = skill.cost.using
	end
	if skill.cost.type == "ST" then
		role.fighter.st = role.fighter.st - value
	elseif skill.cost.type == "MP" then
		role.fighter.mp = role.fighter.mp - value
	elseif skill.cost.type == "HP" then
		role.fighter.hp = role.fighter.hp - value
	end
end

---------------------------------------
local function DetermineSkill( atk, def )
	local usingSkill
	local totalProb = 0
	local skills = {}
	for _, id in ipairs( atk.fighter.skills ) do
		local skill = FIGHTSKILL_DATATABLE_Get( id )		
		if CanUsingSkill( skill, atk, def ) then
			--print( "select skill", skill.name )
			if not usingSkill then usingSkill = skill end
			totalProb = totalProb + skill.lv
			table.insert( skills, { prob = skill.lv, skill = skill } )
		end
	end

	local prob = Random_GetInt_Sync( 1, totalProb )
	for _, item in ipairs( skills ) do
		if prob <= item.prob then
			usingSkill = item.skill
			break
		end
	end

	--print( atk.follower.name .. " use skill " .. usingSkill.name )
	return usingSkill
end


---------------------------------------
local function Rest_Role( role )
	local maxhp = role.fighter.vital * 10
	local maxst = role.fighter.strength * 5
	local maxmp = role.fighter.internal * 5
	--role.fighter.hp = math.max( role.fighter.hp, math.min( math.ceil( maxhp * 0.5 ), role.fighter.hp + math.ceil( maxhp * 0.05 ) ) )
	role.fighter.st = math.max( role.fighter.st, math.min( math.ceil( maxst * 0.5 ), role.fighter.st + math.ceil( maxst * 0.05 ) ) )
	role.fighter.mp = math.max( role.fighter.mp, math.min( math.ceil( maxmp * 0.5 ), role.fighter.mp + math.ceil( maxmp * 0.05 ) ) )
end

---------------------------------------
local function MakeTeamDuel( teams, oppTeams, duels )
	for _, atk in ipairs( teams ) do
		local def = FindTarget( atk, oppTeams )
		if IsRoleAlive( def ) then
			local priority = Random_GetInt_Sync( 1, atk.fighter.agility )

			--determine skill
			if not atk.fighter._usingSkill then atk.fighter._usingSkill = DetermineSkill( atk, def ) end
			if not def.fighter_usingSkill then atk.fighter._usingSkill = DetermineSkill( def, atk ) end

			table.insert( duels, { atk = atk, def = def, priority = priority } )
			--print( "make duel", atk.follower.name, def.follower.name )
		end
	end
end


---------------------------------------
local function MakeDuels( cmp )
	local duels = {}

	--make duels
	MakeTeamDuel( cmp._reds, cmp._blues, duels )
	MakeTeamDuel( cmp._blues, cmp._reds, duels )

	--shuffle
	MathUtil_Shuffle_Sync( duels )

	--resort
	table.sort( duels, function ( l, r )
		--print( "compare", l.priority, r.priority )
		return l.priority > r.priority
	end )

	return duels;
end


---------------------------------------
local function FightSystem_GetSkillElementAdd( role, element )
	--Dump( role )
	if not element then
		return 0
	elseif element == "NON" then
		return 0
	elseif element == "PHY" then
		return role.fighter.strength
	elseif element == "INT" then
		return role.fighter.internal
	end
	DBG_Error( "Invalid action element" )
end


---------------------------------------
local function DealDamage_Role( role, damage )
	local realDamage = math.min( role.fighter.hp, damage ) 
	role.fighter.hp = role.fighter.hp - realDamage
	return realDamage
end


---------------------------------------
local function ProcessDuel( atk, def )
	--when target is dead, pass through
	if def.fighter.hp <= 0 then return end

	--print( atk.follower.name .. " attack " .. def.follower.name )

	--Check the status
	--  If attacker was been hit first, it won't triggeer the HIT
	local hitCount = 0

	local atkSkill = atk.fighter._usingSkill
	local defSkill = def.fighter._usingSkill
	if not atkSkill then DBG_Error( "why no skill" ) end

	UseSkill( atk, atkSkill )
	UseSkill( def, defSkill, true )
	
	atk.fighter._hitTimes = 0
	atk.fighter._hitCombo = 0
	atk.fighter._skillDamage = 0

	for action_idx, atkAction in ipairs( atkSkill.actions ) do
		--calculate hit accuracy		

		--[[
		local accuracy = ( atkAction.accuracy or 0 ) + atk.fighter.technique * 2
		local dodge = ( def.fighter.technique + def.fighter.agility )
		local hit = math.max( 10, accuracy - dodge )
		print( atk.follower.name .. " hit accuracy is " .. accuracy )
		print( def.follower.name .. " dodge is " .. dodge )
		--]]

		--[[
		local atkAccuracy = ( atk.fighter.technique + atkAction.accuracy )
		local defDodge = ( def.fighter.technique + def.fighter.agility )
		--print( atkAccuracy, defDodge, atkAccuracy / ( atkAccuracy + defDodge ) )
		local hit = math.max( 10, math.ceil( atkAccuracy * 100 / ( atkAccuracy + defDodge ) ) )
		--print( atk.follower.name .. " hit accuracy is " .. hit )
		]]		
		local defAction = defSkill and defSkill.actions[action_idx]

		local accuracy = atk.fighter.technique
		local dodge    = def.fighter.technique * 0.4 + def.fighter.agility * 0.4
		local hit      = math.max( atk.fighter._hitMod or 0, math.ceil( ( atkAction.accuracy or 0 ) + accuracy * 50 / ( accuracy + dodge ) ) )
		--print( atk.follower.name .. " hit accurcy is " .. hit )

		local isHit = Random_GetInt_Sync( 1, 100 ) < hit

		if isHit then			
			local atkPow       = FightSystem_GetSkillElementAdd( atk, atkAction.element )
			local defPow       = FightSystem_GetSkillElementAdd( def, atkAction.element )
			local critical     = atkAction.attack + ( atk.fighter._ap or 0 )
			local atkDamage    = atkPow * critical * 0.01
			local defDefend    = defPow
			--print( "atk=" .. atkDamage, "def=" .. defDefend, atkPow, critical )
			local base_damage  = atkDamage * atkDamage / ( atkDamage + defDefend )
			local block        = ( defAction and defAction.defense or 0 ) + ( def.fighter._dp or 0 )
			local final_damage = math.ceil( base_damage * 10 / ( block + 100 ) )

			--block damage
			if atk.fighter._shiled then
				local resistDamage = 0
				if atk.fighter._shiled > final_damage then
					resistDamage = final_damage
					atk.fighter._shiled = atk.fighter._shiled - final_damage					
					final_damage = 0
				else
					resistDamage = atk.fighter._shiled
					final_damage = final_damage - atk.fighter._shiled
					atk.fighter._shiled = 0
				end				
				print( def.follower.name .. " resist damage " .. resistDamage )
			end
			
			if final_damage > 0 then
				local real_damage  = DealDamage_Role( def, final_damage )							
				atk.fighter._dealDamage = atk.fighter._dealDamage and atk.fighter._dealDamage + real_damage or real_damage
				atk.fighter._skillDamage = atk.fighter._skillDamage and atk.fighter._skillDamage + real_damage or real_damage
				--print( atk.follower.name .. " deal damage " .. real_damage .. " to " .. def.follower.name .. " hp is " .. def.fighter.hp .. " now." )
			end

			--damage
			atk.fighter._ap = atkAction.attack * 0.5
			atk.fighter._dp = atkAction.defense * 0.5

			def.fighter._dp = defAction and defAction.defense * 0.5 or 0

			--statistic
			atk.fighter._totalHit = atk.fighter._totalHit and atk.fighter._totalHit + 1 or 1
			atk.fighter._hitTimes = atk.fighter._hitTimes + 1
			atk.fighter._hitCombo = atk.fighter._hitCombo + 1
		else
			--no damage, full defense broken
			--atk.fighter._ap = atkAction.attack * 0.5
			atk.fighter._dp = atkAction.defense * 0.5

			def.fighter._dp = defAction and defAction.defense * 0.75 or 0

			atk.fighter._hitMod = math.min( atk.fighter._hitMod and atk.fighter._hitMod + 10 or 10, 30 )

			--stop combo
			atk.fighter._hitCombo = 0
		end

		--print( atk.follower.name, "ap=" .. atk.fighter._ap, "dp=" .. atk.fighter._dp )

		if not IsRoleAlive( def ) then
			atk.fighter._kill = atk.fighter._kill and atk.fighter._kill + 1 or 0
			break
		end
	end

	print( atk.follower.name .. " hit " .. def.follower.name ..  " " .. atk.fighter._hitTimes .. " times, deal damage=" .. atk.fighter._skillDamage )
end	


local function ProcessDuels( duels )
	--process duels
	for _, duel in ipairs( duels ) do
		ProcessDuel( duel.atk, duel.def )
	end
end


---------------------------------------
local function Prepare_Role( role )
	if not role.fighter._ap then role.fighter._ap = 0 end
	if not role.fighter._dp then role.fighter._dp = 0 end
	role.fighter._usingSkill = nil
end


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
	--print( "Activate System")
end


---------------------------------------
function FightSystem:Update( deltaTime )	
	for _, fight in ipairs( self._fights ) do
		self:ProcessFight( fight )
	end
end


------------------------------ ---------
function FightSystem:AppendFight( entityid )
	table.insert( self._fights, entityid )
	--print( "add fight", entityid )
end


---------------------------------------
local function ForAllRole( component, fn )
	for _, role in ipairs( component._reds ) do fn( role ) end
	for _, role in ipairs( component._blues ) do fn( role ) end
end


local function FindOppside( component, side )
	if side == FIGHT_SIDE.RED then return FIGHT_SIDE.BLUE
	elseif side == FIGHT_SIDE.BLUE then return FIGHT_SIDE.RED end
	return FIGHT_SIDE.NONE
end


local function FindTeam( component, side )
	if side == FIGHT_SIDE.RED then return component._reds
	elseif side == FIGHT_SIDE.BLUE then return component._blues end
end


---------------------------------------
function FightSystem:ProcessFight( fight_id )
	local entity = ECS_FindEntity( fight_id )
	if not entity then
		DBG_Error( "invalid fight entity!", fight_id )
		return
	end
	print( "Fight", fight_id, entity )
	local cmp = entity:GetComponent( "FIGHT_COMPONENT" )
	local result = FIGHT_SIDE.NONE

	local actionSequence = {}	

	--Create a shuffled sequence as roles's priority
	local priorities = MathUtil_CreateShuffledSequence( #cmp._reds + #cmp._blues )

	function DetermineATB( role, action, time )
		if not action then action = "DEFAULT" end
		local actionTime = time and time + FIGHT_ACTIONTIME[action] or FIGHT_ACTIONTIME[action]
		local addTime = math.floor( actionTime / ( role.fighter.agility + 100 ) )
		role.fighter._atb = role.fighter._atb and role.fighter._atb + addTime or addTime
		--print( role.follower.name, "atb=" .. role.fighter._atb .. " time=" .. addTime, actionTime )
	end

	--Determine all roles's action time
	function PrepareFight( role, side )
		--initialize
		role.fighter._side     = side
		role.fighter._priority = table.remove( priorities, 1 )
		role.fighter._ap       = 0
		role.fighter._dp       = 0
		DetermineATB( role )
		table.insert( actionSequence, role )
	end	

	function SortActionSequence()
		--Sort the action sequence by the action time and priority
		table.sort( actionSequence, function( l, r ) 
			if l.fighter._atb < r.fighter._atb then return true end
			if l.fighter._atb == r.fighter._atb then return l.fighter._priority < r.fighter._priority end
			return false
		end )
	end

	for _, role in ipairs( cmp._reds ) do PrepareFight( role, FIGHT_SIDE.RED ) end
	for _, role in ipairs( cmp._blues ) do PrepareFight( role, FIGHT_SIDE.BLUE ) end

	SortActionSequence()

	local result   = FIGHT_SIDE.NONE
	local passTime = 0
	local lastTime = 0
	while result == FIGHT_SIDE.NONE do
		local actionRole = table.remove( actionSequence, 1 )

		if not actionRole then DBG_Error( "why" ) end

		if IsRoleAlive( actionRole ) then
			--print( actionRole.follower.name .. " action, atb=" .. actionRole.fighter._atb )

			--pass the time		
			for _, role in ipairs( actionSequence ) do				
				--print( role.follower.name .. " pass time=" .. actionRole.fighter._atb .. " left=" .. role.fighter._atb )
				role.fighter._atb = role.fighter._atb - actionRole.fighter._atb
			end
			passTime = passTime + actionRole.fighter._atb

			actionRole.fighter._atb = 0

			actionRole.fighter._actTimes = actionRole.fighter._actTimes and actionRole.fighter._actTimes + 1 or 1

			--choose target
			local target = FindTarget( actionRole, FindTeam( cmp, FindOppside( cmp, actionRole.fighter._side ) ) )

			--determine action
			actionRole.fighter._usingSkill = DetermineSkill( actionRole, target )
			target.fighter._usingSkill     = DetermineSkill( target, actionRole, true )

			--process duel
			if actionRole.fighter._usingSkill then
				ProcessDuel( actionRole, target )

				--Determine
				DetermineATB( actionRole, "USESKILL", actionRole.fighter._usingSkill.time )
			else
				--no mp, sp
				Rest_Role( actionRole )
				actionRole.fighter._restTimes = actionRole.fighter._restTimes and actionRole.fighter._restTimes + 1 or 1
				--print( actionRole.follower.name, "rest" )
			end

			if IsRoleAlive( actionRole ) then				
				table.insert( actionSequence, actionRole )

				--Resort
				SortActionSequence( actionSequence )
			end
		end

		result = CheckResult( cmp )

		--InputUtil_Pause()
	end

	ForeachRole( cmp._reds,  Dump_Role )
	ForeachRole( cmp._blues, Dump_Role )
end

--[[
function FightSystem:ProcessFight( fight_id )
	local entity = ECS_FindEntity( fight_id )
	if not entity then
		DBG_Error( "invalid fight entity!", fight_id )
		return
	end

	print( "Fight", fight_id, entity )

	local cmp = entity:GetComponent( "FIGHT_COMPONENT" )

	local result = FIGHT_SIDE.NONE

	local turn   = 1
	while result == FIGHT_SIDE.NONE do
		--prepare
		for _, role in ipairs( cmp._reds ) do Prepare_Role( role ) end
		for _, role in ipairs( cmp._blues ) do Prepare_Role( role ) end

		--make dule
		local duels = MakeDuels( cmp )
		
		--process dule
		ProcessDuels( duels )

		--process result
		result = CheckResult( cmp )

		turn = turn + 1
		print( "turn", turn )
	end

	ForeachRole( cmp._reds, Dump_Role )
	ForeachRole( cmp._blues, Dump_Role )
end
]]


---------------------------------------