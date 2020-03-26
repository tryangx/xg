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
	REST     = 5000,
	DEFEND   = 5000,
}


FIGHT_SKILLPOSE = 
{
	NONE   = { NONE={}, UPPER={ atk=-10 }, CENTER={ hit=10 },  LOWER={ def=10 },  ALL={} },
	UPPER  = { NONE={}, UPPER={ atk=-10 }, CENTER={ hit=10 },  LOWER={ def=10 },  ALL={} },
	CENTER = { NONE={}, UPPER={ def=10 },  CENTER={ atk=-10 }, LOWER={ hit=10 },  ALL={} },
	LOWER  = { NONE={}, UPPER={ hit=10 },  CENTER={ def=10 },  LOWER={ atk=-10 }, ALL={} },
	ALL    = { NONE={}, UPPER={ hit=10 },  CENTER={ hit=10 },  LOWER={ hit=10 },  ALL={} },
}


FIGHT_TARGET =
{
	SELF          = 0,
	TARGET        = 1,
	SINGLE_ENEMY  = 10,
	ALL_ENEMIES   = 11,	
	SINGLE_FRIEND = 20,
	ALL_FRIENDS   = 21,
	ALL           = 30,
	SINGLE_ALL    = 31,
}


FIGHT_RULE = 
{
	ENABLE_SAVEPONIT = 1,
	ENABLE_CRITICAL  = 1,	
}


FIGHT_PARAMS = 
{
	DEFEND_COST_RATE    = 0.25,

	DAMAGE_RATE         = 100,
}

---------------------------------------
-- Helper
---------------------------------------
local function ForeachRole( teams, fn, ... )
	for _, role in ipairs( teams ) do
		fn ( role, ... )
	end
end


---------------------------------------
local function Dump_Role( role, type )
	print( "Dump=" .. role.role.name )
	if MathUtil_IndexOf( type, "ATTRS" ) then
		print( "", "lv=" .. role.fighter.lv .. "/" .. role.template.potential )
		print( "", "hp=" .. role.fighter.hp .. "/" .. role.fighter.maxhp )
		print( "", "mp=" .. role.fighter.mp .. "/" .. role.fighter.maxmp )
		print( "", "st=" .. role.fighter.st .. "/" .. role.fighter.maxst )
		print( "", "STRENGTH =" .. role.fighter.strength  .. "/" .. role.template.strength )
		print( "", "INTERNAL =" .. role.fighter.internal  .. "/" .. role.template.internal )
		print( "", "TECHNIQUE=" .. role.fighter.technique .. "/" .. role.template.technique )
		print( "", "AGILITY  =" .. role.fighter.agility   .. "/" .. role.template.agility )
		print( "", "template =" .. role.template.name )
		print( "", "skills   =" .. #role.fighter.skills )
	else
		print( "", "lv=" .. role.fighter.lv )
		print( "", "hp=" .. role.fighter.hp )
		print( "", "mp=" .. role.fighter.mp )
		print( "", "st=" .. role.fighter.st )		
	end	
	if MathUtil_IndexOf( type, "STATS" ) then
		print( "", "HitTimes=" .. ( role.fighter._totalHit or 0 ) .. "-" .. ( ( role.fighter._totalHit and role.fighter._totalHitTries ) and math.ceil( role.fighter._totalHit * 100 / role.fighter._totalHitTries ) .. "%" or "" ) )
		print( "", "CriTimes=" .. ( ( role.fighter._criticalTimes and role.fighter._totalHit and role.fighter._totalHit > 0 ) and role.fighter._criticalTimes .. "(" .. math.ceil( role.fighter._criticalTimes * 100 / role.fighter._totalHit ) .. "%)" or "" ) )
		print( "", "ActTimes=" .. ( role.fighter._skillTimes or 0 ) .. "Skill/" .. ( role.fighter._restTimes or 0 ) .. "Rest/" .. ( role.fighter._defendTimes or 0 ) .. "Defend" )
		--[[
		print( "", "ActTimes=" .. ( role.fighter._actTimes or 0 ) )
		print( "", "RestTimes=" .. ( role.fighter._restTimes or 0 ) )
		print( "", "DefdTimes=" .. ( role.fighter._defendTimes or 0 ) )		
		print( "", "IntDamage=" .. ( role.fighter._INTERNAL_DMG or 0 ) )
		print( "", "StrDamage=" .. ( role.fighter._STRENGTH_DMG or 0 ) )
		]]
		print( "", "DealDamg=" .. ( role.fighter._dealDamage or 0 ) .. "/" ..  ( role.fighter._INTERNAL_DMG or 0 ) .. "Int/" .. ( role.fighter._STRENGTH_DMG or 0 ) .. "Str" )		
		print( "", "DmgPerTim=" .. ( ( role.fighter._dealDamage and role.fighter._totalHit ) and math.ceil( role.fighter._dealDamage / role.fighter._totalHit ) or 0 ) )
		for skill, times in pairs( role.fighter._useSkillList ) do
			print( "", skill.name .. "=" .. times )
		end
	end
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
		cmp.reuslt = "RED_WIN"
		return FIGHT_SIDE.RED
	elseif not HasAlive( cmp._blues ) then
		print( "red teams are all dead" )
		cmp.reuslt = "BLUE_WIN"
		return FIGHT_SIDE.BLUE
	end

	cmp.result = "DRAW"
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
				--print( role.role.name, opp.role.name, "default" )
			else
				--print( role.role.name, opp.role.name, newDistance, distance )
				if newDistance < distance then
					distance = newDistance
					find = opp
				end
			end
		end
	end
	if not find then
		print( role.role.name .. " doesn't find target." ) 
	end
	return find
end


---------------------------------------
local function CanUsingSkill( skill, atk, def, isDefend )
	--check cost
	--print( "can using skill", skill.name, skill.cost.type, skill.cost.value )
	local rate = isDefend and FIGHT_PARAMS.DEFEND_COST_RATE or 1
	local st_cost = math.ceil( skill.cost.st * rate )
	if atk.fighter.st < st_cost then 
		--print( "Need", st_cost, atk.fighter.st )
		return false
	end
	local mp_cost = math.ceil( skill.cost.mp * rate )
	if atk.fighter.mp < mp_cost then
		--print( "Need", mp_cost, atk.fighter.mp )
		return false
	end
	return true
end


---------------------------------------
local function UseSkill( role, skill, isDefend )
	if not skill then return end
	local rate = isDefend and FIGHT_PARAMS.DEFEND_COST_RATE or 1
	local st_cost = math.ceil( skill.cost.st * rate )
	local mp_cost = math.ceil( skill.cost.mp * rate )
	if skill.cost.st > 0 then role.fighter.st = math.max( 0, role.fighter.st - st_cost ) end
	if skill.cost.mp > 0 then role.fighter.mp = math.max( 0, role.fighter.mp - mp_cost ) end
end

---------------------------------------
local function DetermineSkill( atk, def )
	if not atk.fighter.skills or #atk.fighter.skills == 0 then
		DBG_Error( atk.role.name, "no skills" )
		return
	end
	local usingSkill
	local totalProb = 0
	local skills = {}
	for _, id in ipairs( atk.fighter.skills ) do
		local skill = FIGHTSKILL_DATATABLE_Get( id )
		if not skill then DBG_Error( "Skill is invalid! Id=" .. id ) end		
		if skill and CanUsingSkill( skill, atk, def ) then
			--print( "push skill pool", skill.name, skill.lv, totalProb )
			if not usingSkill then usingSkill = skill end
			totalProb = totalProb + skill.lv
			table.insert( skills, { prob = totalProb, skill = skill } )
		end
	end

	local prob = Random_GetInt_Sync( 1, totalProb )
	for _, item in ipairs( skills ) do
		if prob <= item.prob then
			usingSkill = item.skill
			break
		end
	end

	--print( atk.role.name .. " use skill " .. usingSkill.name )
	return usingSkill
end


---------------------------------------
local function Rest_Role( role )
	local maxhp = role.fighter.maxhp
	local maxst = role.fighter.maxst
	local maxmp = role.fighter.maxmp
	--role.fighter.hp = math.max( role.fighter.hp, math.min( math.ceil( maxhp * 0.5 ), role.fighter.hp + math.ceil( maxhp * 0.05 ) ) )
	role.fighter.st = math.max( role.fighter.st, math.min( math.ceil( maxst * 0.5 ), role.fighter.st + math.ceil( maxst * 0.05 ) ) )
	role.fighter.mp = math.max( role.fighter.mp, math.min( math.ceil( maxmp * 0.5 ), role.fighter.mp + math.ceil( maxmp * 0.05 ) ) )
end


---------------------------------------
local function Defend_Role( role )	
end


---------------------------------------
local function MakeTeamDuel( teams, oppTeams, duels )
	for _, atk in ipairs( teams ) do
		local def = FindTarget( atk, oppTeams )
		if IsRoleAlive( def ) then
			local priority = Random_GetInt_Sync( 1, GetValueByBuff( atk, FIGHTER_ATTR.AGILITY ) )

			--determine skill
			if not atk.fighter._usingSkill then atk.fighter._usingSkill = DetermineSkill( atk, def ) end
			if not def.fighter_usingSkill then def.fighter._usingSkill = DetermineSkill( def, atk ) end

			table.insert( duels, { atk = atk, def = def, priority = priority } )
			--print( "make duel", atk.role.name, def.role.name )
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
local function DealDamage_Role( role, damage )
	local realDamage = math.min( role.fighter.hp, damage ) 
	role.fighter.hp = role.fighter.hp - realDamage
	return realDamage
end


---------------------------------------
local function GetRoleTireness( role )
	local r1 = role.fighter.hp / role.fighter.maxhp
	local r2 = role.fighter.mp / role.fighter.maxmp
	local r3 = role.fighter.st / role.fighter.maxst
	local very_tired = 0.35
	local tired = 0.65
	if r1 < very_tired and r2 < very_tired and r3 < very_tired then
		return 0.35
	elseif r1 < tired or r2 < tired or r3 < tired then
		return 0.5
	end
	return 1
end


---------------------------------------
local function CanTriggerSkillBuff( role, skill )	
	if not skill.statuses then return end
	for _, comboeffect in ipairs( skill.comboeffects ) do
		local match = true
		if comboeffect.combo ~= role.fighter._hitCombo then match = false end		
		if match then			
			if Random_GetInt_Sync( 1, 1000 ) < comboeffect.prob then
				--print( role.role.name, "trigger skill buff=" .. skill.name )
				return comboeffect
			end
		end
	end
end


---------------------------------------
local function AddSkillBuff( role, comboeffect, buff )
	if not role.statuses then role.statuses = {} end

	function SetStatusBuff( data, comboeffect, buff )
		data.name     = comboeffect.name
		data.effects  = {}
		data.duration = buff.duration or 1
		data.effects  = MathUtil_ShallowCopy( buff.effects )
		if not buff.duration then
			for _, effect in ipairs( buff.effects ) do data.duration = math.max( data.duration, effect.duration ) end
		end
	end

	for _, existStatus in ipairs( role.statuses ) do
		--check by category
		if existStatus.cate == comboeffect.cate then
			--replace the status			
			SetStatusBuff( existStatus, comboeffect, buff )
			return
		end
	end

	table.insert( role.statuses, {} )
	SetStatusBuff( role.statuses[#role.statuses], comboeffect, buff )

	--Dump( role.statuses, 6 )
	--InputUtil_Pause( role.role.name, "gain buff", status.name )
end


---------------------------------------
local function TriggerSkillBuff( atk, def, comboeffect )
	if not comboeffect.buffs then return end
	for _, buff in ipairs( comboeffect.buffs ) do
		if buff.target == "SELF" then
			AddSkillBuff( atk, comboeffect, buff )
		elseif buff.target == "TARGET" then
			AddSkillBuff( def, comboeffect, buff )
		end
	end
end


---------------------------------------
--Unfinished
local function HasRoleStatus( role, statusType )
	if not role.statuses then return end
	for _, status in ipairs( role.statuses ) do		
		for _, effect in ipairs( status.effects ) do
			if effect.status == statusType then
				return true
			end
		end
	end
end


---------------------------------------
local function CalcRoleStatus( role, statusType )
	if not role.statuses then 
		--print( role.role.name, "no status" )
		return
	end
	local value = 0
	local value_percent = 0
	for _, status in ipairs( role.statuses ) do
		for _, effect in ipairs( status.effects ) do
			if effect.status == statusType then				
				value = math.max( value, effect.value )
				value_percent = math.max( value_percent, effect.value_percent )
			end			
		end
	end
	if value == 0 or value_percent == 0 then return end
	return { value=value, value_percent=value_percent }
end


---------------------------------------
local function ModifyValueByBuff( value, buff, debuff )
	--if buff or debuff then print( "before buff affected:", value ) end
	value = value + ( buff and buff.value or 0 ) - ( debuff and debuff.value or 0 )
	value = math.ceil( value * ( 100 + ( buff and buff.value_percent or 0 ) - ( debuff and debuff.value_percent or 0 ) ) * 0.01 )
	--if buff or debuff then Dump( debuff ) print( "after " .. ( buff and "buff" or "debuff" ) .. " affected:", value ) end	
	return value
end


---------------------------------------
local function GetValueByBuff( role, attr )
	if attr == FIGHTER_ATTR.INTERNAL then
		return ModifyValueByBuff( role.fighter.internal, CalcRoleStatus( role, "INTERNAL_ENHANCED" ), CalcRoleStatus( role, "INTERNAL_WEAKEN" ) )
	elseif attr == FIGHTER_ATTR.STRENGTH then
		return ModifyValueByBuff( role.fighter.strength, CalcRoleStatus( role, "STRENGTH_ENHNACED" ), CalcRoleStatus( role, "STRENGTH_WEAKEN" ) )
	elseif attr == FIGHTER_ATTR.TECHNIQUE then
		return ModifyValueByBuff( role.fighter.technique, CalcRoleStatus( role, "TECHNIQUE_ENHANCED" ), CalcRoleStatus( role, "TECHNIQUE_WEAKEN" ) )
	elseif attr == FIGHTER_ATTR.AGILITY then
		return ModifyValueByBuff( role.fighter.agility, CalcRoleStatus( role, "AGILITY_ENHANCED" ), CalcRoleStatus( role, "AGILITY_WEAKEN" ) )
	end
end


---------------------------------------
local function ProcessDuel( atk, def )
	--when target is dead, pass through
	if def.fighter.hp <= 0 then return end

	--print( atk.role.name .. " attack " .. def.role.name )

	local hitCount = 0

	local atkSkill = atk.fighter._usingSkill
	local defSkill = def.fighter._usingSkill
	if not atkSkill then DBG_Error( "why no skill" ) end

	UseSkill( atk, atkSkill )
	UseSkill( def, defSkill, true )
	
	local _hitTimes = 0
	atk.fighter._hitTries = 0
	atk.fighter._hitCombo = 0
	atk.fighter._skillDamage = 0

	for action_idx, atkAction in ipairs( atkSkill.actions ) do
		--calculate hit accuracy
		local defAction = defSkill and defSkill.actions[action_idx]

		local pose = FIGHT_SKILLPOSE[atkAction.element] and FIGHT_SKILLPOSE[atkAction.element][defAction.element]

		local accuracy = GetValueByBuff( atk, FIGHTER_ATTR.TECHNIQUE )
		local dodge    = GetValueByBuff( def, FIGHTER_ATTR.TECHNIQUE ) * 0.3 + GetValueByBuff( def, FIGHTER_ATTR.AGILITY ) * 0.7
		local hit      = math.max( atk.fighter._hitMod or 0, ( pose and pose.hit or 0 ) + math.ceil( ( atkAction.accuracy * 0.5 or 0 ) + accuracy * 100 / ( accuracy + dodge ) ) ) * 100
		--print( atk.role.name .. " hit accurcy is " .. hit )

		local isHit = Random_GetInt_Sync( 1, 10000 ) < hit

		atk.fighter._totalHitTries = atk.fighter._totalHitTries and atk.fighter._totalHitTries + 1 or 1

		if not FIGHT_RULE.ENABLE_SAVEPOINT then
			atk.fighter._ap = 0
			atk.fighter._dp = 0
		end

		if isHit then			
			--status modification
			local atkPow = GetValueByBuff( atk, FIGHTER_ATTR[atkAction.element] )
			local defPow = GetValueByBuff( def, FIGHTER_ATTR[atkAction.element] )
			local atkSkillMod = ( atkAction.attack + ( atk.fighter._ap or 0 ) ) * GetRoleTireness( atk )

			local atkTec = GetValueByBuff( atk, FIGHTER_ATTR.TECHNIQUE )
			local defTec = GetValueByBuff( def, FIGHTER_ATTR.TECHNIQUE )

			local critical     = 100
			if FIGHT_RULE.ENABLE_CRITICAL ~= 0 then
				local critical_prob = math.min( 90, ( atkAction.cri or 0 ) + math.ceil( ( atkTec * 1.2 - defTec * 0.8 ) * 100 / ( atkTec + defTec ) ) )
				if Random_GetInt_Sync( 1, 10000 ) < critical_prob * 100 then
					critical = 100 + ( pose and pose.cri or 0 )
					atk.fighter._criticalTimes = atk.fighter._criticalTimes and atk.fighter._criticalTimes + 1 or 1
				end
				--print( atkSkill.name, "critical", atkAction.cri, critical_prob )
			end			
			local atkDamage    = atkPow * atkSkillMod * critical * 0.0001
			local defDefend    = defPow			
			local base_damage  = atkDamage * atkDamage / ( atkDamage + defDefend )
			local block        = ( defAction and defAction.defense or 0 ) + ( def.fighter._dp or 0 )
			local final_damage = math.ceil( base_damage * FIGHT_PARAMS.DAMAGE_RATE / ( block + 100 ) )
			--print( atkSkill.name, "finaldmg=" .. final_damage, "base_damage=" .. base_damage, "apow=" .. atkPow, "dpow=" .. defPow )

			--block damage
			if atk.fighter._shield then
				local resistDamage = 0
				if atk.fighter._shield > final_damage then
					resistDamage = final_damage
					atk.fighter._shield = atk.fighter._shield - final_damage					
					final_damage = 0
				else
					resistDamage = atk.fighter._shield
					final_damage = final_damage - atk.fighter._shield
					atk.fighter._shield = 0
				end				
				Log_Write( "fight", def.role.name .. " resist damage " .. resistDamage )
			end
			
			if final_damage > 0 then
				local real_damage  = DealDamage_Role( def, final_damage )							
				atk.fighter._dealDamage = atk.fighter._dealDamage and atk.fighter._dealDamage + real_damage or real_damage
				atk.fighter._skillDamage = atk.fighter._skillDamage and atk.fighter._skillDamage + real_damage or real_damage
				local statName = "_" .. atkAction.element .. "_DMG"
				atk.fighter[statName] = atk.fighter[statName] and atk.fighter[statName] + real_damage or real_damage				
				--print( atk.role.name .. " deal damage " .. real_damage .. " to " .. def.role.name .. " hp is " .. def.fighter.hp .. " now." )
			end

			--buff/debuff
			local comboeffect = CanTriggerSkillBuff( atk, atk.fighter._usingSkill )
			if comboeffect then TriggerSkillBuff( atk, def, comboeffect ) end

			--damage
			atk.fighter._ap = atkAction.attack * 0.5
			atk.fighter._dp = atkAction.defense * 0.5

			def.fighter._dp = defAction and defAction.defense * 0.5 or 0

			--statistic
			atk.fighter._totalHit = atk.fighter._totalHit and atk.fighter._totalHit + 1 or 1
			atk.fighter._hitCombo = atk.fighter._hitCombo + 1
			_hitTimes = _hitTimes + 1
		else
			--no damage, full defense broken
			--atk.fighter._ap = atkAction.attack * 0.5
			atk.fighter._dp = atkAction.defense * 0.5

			def.fighter._dp = defAction and defAction.defense * 0.75 or 0

			atk.fighter._hitMod = math.min( atk.fighter._hitMod and atk.fighter._hitMod + 5 or 5, 20 )

			--stop combo
			atk.fighter._hitCombo = 0

			--print( atk.role.name, "not hit", hit )
		end

		--print( atk.role.name, "ap=" .. atk.fighter._ap, "dp=" .. atk.fighter._dp )

		if not IsRoleAlive( def ) then
			atk.fighter._kill = atk.fighter._kill and atk.fighter._kill + 1 or 0
			break
		end
	end

	Log_Write( "fight", atk.role.name .. " hit " .. def.role.name ..  " " .. _hitTimes .. "/" .. #atkSkill.actions .. " times, deal damage=" .. atk.fighter._skillDamage )
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
local function PassTime_Role( role, time )
	--reduce atb
	role.fighter._atb = role.fighter._atb - time

	--reduce
	if role.statuses then
		MathUtil_RemoveIf( role.statuses, function ( status )
			status.duration = status.duration - time
			--if status.duration <= 0 then InputUtil_Pause( "role.role.name, remove status", status.name ) end
			return status.duration <= 0
		end )
	end
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
		return self:ProcessFight( ecsid )
	end)

	--InputUtil_Pause( "Fight Left:", #self._fights )
end

------------------------------ ---------
function FIGHT_SYSTEM:SetFightDataEntity( entity )
	self._fightDataEntity = entity
end


------------------------------ ---------
function FIGHT_SYSTEM:AppendFight( entityid )
	table.insert( self._fights, entityid )
	--InputUtil_Pause( "add fight" )
end


---------------------------------------
function FIGHT_SYSTEM:CreateFight( atk_eids, def_eids )	
	if not self._fightDataEntity then DBG_Error( "Not specified Fight Data Entity" ) return end
	local entity = ECS_CreateEntity( "FightData" )	
	local fight = ECS_CreateComponent( "FIGHT_COMPONENT" )
	Prop_Add( fight, "reds",  atk_eids )
	Prop_Add( fight, "blues", def_eids )
	entity:AddComponent( fight )
	self._fightDataEntity:AddChild( entity )
	entity:Activate()
	--InputUtil_Pause( "Create fight", entity.ecsid )
end


---------------------------------------
function FIGHT_SYSTEM:ProcessFight( ecsid )	
	local entity = ECS_FindEntity( ecsid )
	if not entity then DBG_Error( "Invalid fight entity! ID=" .. ecsid ) return end
	
	local fight = entity:GetComponent( "FIGHT_COMPONENT" )

	if fight.result ~= "NONE" then return true end
		
	local result = FIGHT_SIDE.NONE

	local actionSequence = {}	

	--Create a shuffled sequence as roles's priority
	local priorities = MathUtil_CreateShuffledSequence( #fight._reds + #fight._blues )

	function DetermineATB( role, action, time )
		if not action then action = "DEFAULT" end
		local actionTime = time and time + FIGHT_ACTIONTIME[action] or FIGHT_ACTIONTIME[action]
		local addTime = math.floor( actionTime / ( GetValueByBuff( role, FIGHTER_ATTR.AGILITY ) + 100 ) )
		role.fighter._atb = role.fighter._atb and role.fighter._atb + addTime or addTime
		--print( role.role.name, "atb=" .. role.fighter._atb .. " time=" .. addTime, actionTime )
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

	for _, role in ipairs( fight._reds ) do PrepareFight( role, FIGHT_SIDE.RED ) end
	for _, role in ipairs( fight._blues ) do PrepareFight( role, FIGHT_SIDE.BLUE ) end

	SortActionSequence()

	local result   = FIGHT_SIDE.NONE
	local passTime = 0
	local lastTime = 0
	local maxTime  = fight.remainTime
	while result == FIGHT_SIDE.NONE do
		local actionRole = table.remove( actionSequence, 1 )		

		if not actionRole then DBG_Error( "why" ) end

		if IsRoleAlive( actionRole ) then
			--print( actionRole.role.name .. " action, atb=" .. actionRole.fighter._atb )

			--pass the time		
			for _, role in ipairs( actionSequence ) do				
				PassTime_Role( role, actionRole.fighter._atb )
			end
			passTime = passTime + actionRole.fighter._atb

			PassTime_Role( actionRole, actionRole.fighter._atb )

			actionRole.fighter._actTimes = actionRole.fighter._actTimes and actionRole.fighter._actTimes + 1 or 1

			--choose target
			local target = FindTarget( actionRole, FindTeam( fight, FindOppside( fight, actionRole.fighter._side ) ) )

			if Random_GetInt_Sync( 1, 100 ) > GetRoleTireness( actionRole ) * 100 then
				--print( "tireness", GetRoleTireness( actionRole ) * 100 )
				actionRole.fighter._usingSkill = nil
			else
				--determine action
				actionRole.fighter._usingSkill = DetermineSkill( actionRole, target )
				target.fighter._usingSkill     = DetermineSkill( target, actionRole, true )
			end

			--process duel
			if actionRole.fighter._usingSkill then
				ProcessDuel( actionRole, target )

				actionRole.fighter._skillTimes = actionRole.fighter._skillTimes and actionRole.fighter._skillTimes + 1 or 1
				if not actionRole.fighter._useSkillList then
					actionRole.fighter._useSkillList = {}
				end
				if actionRole.fighter._useSkillList[actionRole.fighter._usingSkill] then
					actionRole.fighter._useSkillList[actionRole.fighter._usingSkill] = actionRole.fighter._useSkillList[actionRole.fighter._usingSkill] + 1
				else
					actionRole.fighter._useSkillList[actionRole.fighter._usingSkill] = 1
				end				

				--Determine				
				DetermineATB( actionRole, "USESKILL", actionRole.fighter._usingSkill.time )

			--elseif target.fighter._usingSkill then
			else
				--no mp, sp
				Rest_Role( actionRole )
				actionRole.fighter._restTimes = actionRole.fighter._restTimes and actionRole.fighter._restTimes + 1 or 1
				--print( actionRole.role.name, "rest" )				
				DetermineATB( actionRole, "REST" )
			--[[
			else
				--no skill
				Defend_Role( action )
				actionRole.fighter._defendTimes = actionRole.fighter._defendTimes and actionRole.fighter._defendTimes + 1 or 1
				DetermineATB( actionRole, "DEFEND" )
			]]
			end

			--InputUtil_Pause( actionRole.role.name, " action" )

			if IsRoleAlive( actionRole ) then				
				table.insert( actionSequence, actionRole )

				--Resort
				SortActionSequence( actionSequence )
			end
		end

		result = CheckResult( fight )

		--print( "time", passTime, maxTime )
		if passTime > maxTime then break end
	end

	function FightEnd( role )
		--Dump_Role( role, { "ATTRS", "STATS" } )

		if IsRoleAlive( role ) then
			return
		end

		--dead
		Role_Dead( role.fighter.entityid )
	end

	ForeachRole( fight._reds,  FightEnd );
	ForeachRole( fight._blues, FightEnd );

	print( "[FIGHTSYS]End", ecsid, entity )
end


---------------------------------------