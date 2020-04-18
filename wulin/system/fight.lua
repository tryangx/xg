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
local _fight


---------------------------------------
local function Fight_Debug( ... )
	--print( ... )
	Log_Write( "fight", ... )
end

---------------------------------------
local function Fight_ForeachRole( teams, fn, ... )
	for _, actor in ipairs( teams ) do
		fn ( actor, ... )
	end
end

---------------------------------------
local function Fight_DumpRole( actor, type )
	print( "Dump=" .. actor.role.name )
	if MathUtil_IndexOf( type, "ATTRS" ) then
		print( "", "lv=" .. actor.fighter.lv .. "/" .. actor.template.potential )
		print( "", "hp=" .. actor.fighter.hp .. "/" .. actor.fighter.maxhp )
		print( "", "mp=" .. actor.fighter.mp .. "/" .. actor.fighter.maxmp )
		print( "", "st=" .. actor.fighter.st .. "/" .. actor.fighter.maxst )
		print( "", "STRENGTH =" .. actor.fighter.strength  .. "/" .. actor.template.strength )
		print( "", "INTERNAL =" .. actor.fighter.internal  .. "/" .. actor.template.internal )
		print( "", "TECHNIQUE=" .. actor.fighter.technique .. "/" .. actor.template.technique )
		print( "", "AGILITY  =" .. actor.fighter.agility   .. "/" .. actor.template.agility )
		print( "", "template =" .. actor.template.name )
		print( "", "skills   =" .. #actor.fighter.skills )
		print( "", "passiveSkills   =" .. #actor.fighter.passiveSkills )
	else
		print( "", "lv=" .. actor.fighter.lv )
		print( "", "hp=" .. actor.fighter.hp )
		print( "", "mp=" .. actor.fighter.mp )
		print( "", "st=" .. actor.fighter.st )		
	end	
	if MathUtil_IndexOf( type, "STATS" ) then
		print( "", "HitTimes=" .. ( actor.fighter._totalHit or 0 ) .. "-" .. ( ( actor.fighter._totalHit and actor.fighter._totalHitTries ) and math.ceil( actor.fighter._totalHit * 100 / actor.fighter._totalHitTries ) .. "%" or "" ) )
		print( "", "CriTimes=" .. ( ( actor.fighter._criticalTimes and actor.fighter._totalHit and actor.fighter._totalHit > 0 ) and actor.fighter._criticalTimes .. "(" .. math.ceil( actor.fighter._criticalTimes * 100 / actor.fighter._totalHit ) .. "%)" or "" ) )
		print( "", "ActTimes=" .. ( actor.fighter._skillTimes or 0 ) .. "Skill/" .. ( actor.fighter._restTimes or 0 ) .. "Rest/" .. ( actor.fighter._defendTimes or 0 ) .. "Defend" )
		print( "", "DealDamg=" .. ( actor.fighter._dealDamage or 0 ) .. "/" ..  ( actor.fighter._INTERNAL_DMG or 0 ) .. "Int/" .. ( actor.fighter._STRENGTH_DMG or 0 ) .. "Str" )		
		print( "", "DmgPerTim=" .. ( ( actor.fighter._dealDamage and actor.fighter._totalHit ) and math.ceil( actor.fighter._dealDamage / actor.fighter._totalHit ) or 0 ) )
		if actor.fighter._usingSkillList then
			for skill, times in pairs( actor.fighter._useSkillList ) do
				print( "", skill.name .. "=" .. times )
			end
		end
	end
end


---------------------------------------
local function Fight_IsRoleAlive( actor )
	if not actor then return false end
	if not _fight.rules["TESTFIGHT"] then
		return actor.fighter.hp > 0
	end
	return actor.fighter.hp > actor.fighter.maxhp * 0.5
end	


---------------------------------------
local function Fight_CheckResult( cmp )
	--check winner
	function HasAlive( teams )
		for _, data in ipairs( teams ) do
			if Fight_IsRoleAlive( data ) then
				return true
			end
		end
	end

	if not HasAlive( cmp._atks ) then
		--print( "atk team are all dead" )
		cmp.reuslt = "ATK_WIN"
		return FIGHT_SIDE.ATTACKER
	elseif not HasAlive( cmp._defs ) then
		--print( "def team are all dead" )
		cmp.reuslt = "DEF_WIN"
		return FIGHT_SIDE.DEFENDER
	end

	cmp.result = "DRAW"
	return FIGHT_SIDE.NONE
end


---------------------------------------
local function Fight_FindTarget( actor, opps )
	--      ATK              DEF
	-- Row(r) Line(l)    Row(r) Line(l)
	--  R2L1  R1L1        R1L1   R2L1
	--  R2L2  R1L2        R1L2   R2L2
	--  R2L3  R1L3        R1L3   R2L3
	local find
	local distance
	for _, opp in ipairs( opps ) do
		if Fight_IsRoleAlive( opp ) then
			local newDistance = math.abs( opp.line - actor.line ) + math.abs( opp.row - actor.row )
			if not find then
				distance = newDistance
				find = opp
				--print( actor.role.name, opp.role.name, "default" )
			elseif newDistance < distance then
				distance = newDistance
				find = opp
			end
		end
	end
	if not find then Fight_Debug( actor.role.name .. " doesn't find target." ) end
	return find
end


---------------------------------------
-- @params type reference to PASSIVESKILL_TYPE
---------------------------------------
local function Fight_GetPassiveSkill( actor, action )
	local passiveSkill
	for _, id in ipairs( actor.fighter.passiveSkills ) do
		local skill = PASSIVESKILL_DATATABLE_Get( id )
		local skillAction = skill[action]
		if skillAction then
			--prob
			if not skillAction.prob or Random_GetInt_Sync( 1, 50 ) < skillAction.prob then
				--cooldown
				local cd = actor.passiveSkillDelays[skill.id]
				if not skillAction.cd or skillAction.cd.max >= ( cd and cd[action] or 0 ) then
					passiveSkill = skill
					break
				end
			end
		end
	end
	--use the last one as the activate
	return passiveSkill
end


---------------------------------------
local function Fight_UsePassiveSkill( actor, passiveSkill, action )	
	if not passiveSkill[action] or not passiveSkill[action].cd then error("1") return end
	if not actor.passiveSkillDelays then actor.passiveSkillDelays = {} end
	if not actor.passiveSkillDelays[passiveSkill.id] then actor.passiveSkillDelays[passiveSkill.id] = {} end
	if actor.passiveSkillDelays[passiveSkill.id][action] then
		actor.passiveSkillDelays[passiveSkill.id][action] = actor.passiveSkillDelays[passiveSkill.id][action] + ( passiveSkill[action].cd.step or 0 )
	else
		actor.passiveSkillDelays[passiveSkill.id][action] = ( passiveSkill[action].cd.step or 0 )
	end
	--InputUtil_Pause( "use passiveSkill", actor.passiveSkillDelays[passiveSkill.id][action] )
	Stat_Add( "PassiveSkill" .. passiveSkill.name, 1, StatType.TIMES )
end


---------------------------------------
local function Fight_CanUsingSkill( skill, atk, def, isDefend )
	--check cost
	--print( "can using skill", skill.name, skill.cost.type, skill.cost.value )	
	local rate = isDefend and FIGHT_PARAMS.DEFEND_COST_RATE or 1

	local st_cost = math.ceil( skill.cost.st * rate )
	if atk.fighter.st < st_cost then return false end

	local mp_cost = math.ceil( skill.cost.mp * rate )
	if atk.fighter.mp < mp_cost then return false end

	if skill.cost.max_cd and actor.fightSkillDelays and actor.fightSkillDelays[skill.id] >= skill.cost.max_cd then return false	end

	return true
end


---------------------------------------
local function Fight_UseSkill( actor, skill, isDefend )
	if not skill then return end
	local rate = isDefend and FIGHT_PARAMS.DEFEND_COST_RATE or 1
	local st_cost = math.ceil( skill.cost.st * rate )
	local mp_cost = math.ceil( skill.cost.mp * rate )
	if skill.cost.st > 0 then actor.fighter.st = math.max( 0, actor.fighter.st - st_cost ) end
	if skill.cost.mp > 0 then actor.fighter.mp = math.max( 0, actor.fighter.mp - mp_cost ) end

	--cooldown
	if skill.cost.step_cd then
		if not actor.fightSkillDelays then actor.fightSkillDelays = {} end
		actor.fightSkillDelays[skill.id] = actor.fightSkillDelays[skill.id] + skill.cost.step_cd
	end
end

---------------------------------------
local function Fight_DetermineSkill( atk, def )
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
		if skill and Fight_CanUsingSkill( skill, atk, def ) then
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
local function Fight_RoleRest( actor )
	local passiveSkill = Fight_GetPassiveSkill( actor, "restAction" )
	if not passiveSkill or passiveSkill.restAction then return end
	Fight_UsePassiveSkill( actor, passiveSkill, "restAction" )
	if passiveSkill.restAction.st then
		local maxst = math.ceil( actor.fighter.maxst * ( passiveSkill.restAction.st.max or 1 ) )
		local value = passiveSkill.restAction.st.value or 0
		local pvalue = math.ceil( maxst * passiveSkill.restAction.st.ratio )
		local inc    = value + pvalue		
		actor.fighter.st = math.min( math.ceil( maxst * 0.5 ), actor.fighter.st + inc )
	end
	if passiveSkill.restAction.mp then
		local maxmp = math.ceil( actor.fighter.maxmp * ( passiveSkill.restAction.mp.max or 1 ) )
		local value = passiveSkill.restAction.mp.value or 0
		local pvalue = math.ceil( maxmp * passiveSkill.restAction.mp.ratio )
		local inc    = value + pvalue
		actor.fighter.mp = math.min( math.ceil( maxmp * 0.5 ), actor.fighter.mp + inc )
	end
	if passiveSkill.restAction.hp then
		local maxhp = math.ceil( actor.fighter.maxhp * ( passiveSkill.restAction.hp.max or 1 ) )
		local value = passiveSkill.restAction.hp.value or 0
		local pvalue = math.ceil( maxhp * passiveSkill.restAction.hp.ratio )
		local inc    = value + pvalue
		actor.fighter.hp = math.min( math.ceil( maxhp * 0.5 ), actor.fighter.hp + inc )
	end
end


---------------------------------------
local function Fight_MakeTeamDuel( teams, oppTeams, duels )
	for _, atk in ipairs( teams ) do
		local def = Fight_FindTarget( atk, oppTeams )
		if Fight_IsRoleAlive( def ) then
			local priority = Random_GetInt_Sync( 1, Fight_GetValueByBuff( atk, FIGHTER_ATTR.AGILITY ) )

			--determine skill
			if not atk.fighter._usingSkill then atk.fighter._usingSkill = Fight_DetermineSkill( atk, def ) end
			if not def.fighter_usingSkill then def.fighter._usingSkill = Fight_DetermineSkill( def, atk ) end

			table.insert( duels, { atk = atk, def = def, priority = priority } )
			--print( "make duel", atk.role.name, def.role.name )
		end
	end
end


---------------------------------------
local function Fight_MakeDuels( cmp )
	local duels = {}

	--make duels
	Fight_MakeTeamDuel( cmp._atks, cmp._defs, duels )
	Fight_MakeTeamDuel( cmp._defs, cmp._atks, duels )

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
local function Fight_RoleDealDamage( actor, damage )
	local realDamage = math.min( actor.fighter.hp, damage ) 
	actor.fighter.hp = actor.fighter.hp - realDamage
	return realDamage
end


---------------------------------------
local function Fight_GetRoleTireness( actor )
	local r1 = actor.fighter.hp / actor.fighter.maxhp
	local r2 = actor.fighter.mp / actor.fighter.maxmp
	local r3 = actor.fighter.st / actor.fighter.maxst
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
local function Fight_CanTriggerSkillBuff( actor, skill )	
	if not skill.statuses then return end
	for _, comboeffect in ipairs( skill.comboeffects ) do
		local match = true
		if comboeffect.combo ~= actor.fighter._hitCombo then match = false end		
		if match then			
			if Random_GetInt_Sync( 1, 1000 ) < comboeffect.prob then
				--print( actor.role.name, "trigger skill buff=" .. skill.name )
				return comboeffect
			end
		end
	end
end


---------------------------------------
local function Fight_AddSkillBuff( actor, comboeffect, buff )
	if not actor.statuses then actor.statuses = {} end

	local skillAction = buff.isDebuff and "debuffAction" or "buffAction"
	local passiveSkill = Fight_GetPassiveSkill( actor, skillAction )
	if passiveSkill then
		Fight_UsePassiveSkill( actor, passiveSkill, skillAction )
		if passiveSkill[skillAction] and passiveSkill[skillAction].resist_prob then
			if Random_GetInt_Sync( 1, 100 ) < passiveSkill.buffAction.resist_prob then
				return
			end
		end
	end

	function SetStatusBuff( data, comboeffect, buff )
		data.name     = comboeffect.name
		data.effects  = {}
		data.duration = buff.duration or 1
		data.effects  = MathUtil_ShallowCopy( buff.effects )
		if not buff.duration then
			for _, effect in ipairs( buff.effects ) do data.duration = math.max( data.duration, effect.duration ) end
		end

		if passiveSkill and passiveSkill.buffAction then			
			if passiveSkill.buffAction.reduce_time then
				data.duration = math.ceil( data.duration * passiveSkill.buffAction.reduce_time )
			end
		end
	end

	for _, existStatus in ipairs( actor.statuses ) do
		--check by category
		if existStatus.cate == comboeffect.cate then
			--replace the status			
			SetStatusBuff( existStatus, comboeffect, buff )
			return
		end
	end

	table.insert( actor.statuses, {} )
	SetStatusBuff( actor.statuses[#actor.statuses], comboeffect, buff )

	--Dump( role.statuses, 6 )
	--InputUtil_Pause( actor.role.name, "gain buff", status.name )
end


---------------------------------------
local function Fight_TriggerSkillBuff( atk, def, comboeffect )
	if not comboeffect.buffs then return end
	for _, buff in ipairs( comboeffect.buffs ) do
		if buff.target == "SELF" then
			Fight_AddSkillBuff( atk, comboeffect, buff )
		elseif buff.target == "TARGET" then
			Fight_AddSkillBuff( def, comboeffect, buff )
		end
	end
end


---------------------------------------
--Unfinished
local function Fight_TriggerSkillBuff( role, statusType )
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
local function Fight_CalcRoleStatus( role, statusType )
	if not role.statuses then return end
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
local function Fight_ModifyValueByBuff( value, buff, debuff )
	--if buff or debuff then print( "before buff affected:", value ) end
	value = value + ( buff and buff.value or 0 ) - ( debuff and debuff.value or 0 )
	value = math.ceil( value * ( 100 + ( buff and buff.value_percent or 0 ) - ( debuff and debuff.value_percent or 0 ) ) * 0.01 )
	--if buff or debuff then Dump( debuff ) print( "after " .. ( buff and "buff" or "debuff" ) .. " affected:", value ) end	
	return value
end


---------------------------------------
local function Fight_GetValueByBuff( actor, attr )
	if attr == FIGHTER_ATTR.INTERNAL then
		return Fight_ModifyValueByBuff( actor.fighter.internal, Fight_CalcRoleStatus( actor, "INTERNAL_ENHANCED" ), Fight_CalcRoleStatus( actor, "INTERNAL_WEAKEN" ) )
	elseif attr == FIGHTER_ATTR.STRENGTH then
		return Fight_ModifyValueByBuff( actor.fighter.strength, Fight_CalcRoleStatus( actor, "STRENGTH_ENHNACED" ), Fight_CalcRoleStatus( actor, "STRENGTH_WEAKEN" ) )
	elseif attr == FIGHTER_ATTR.TECHNIQUE then
		return Fight_ModifyValueByBuff( actor.fighter.technique, Fight_CalcRoleStatus( actor, "TECHNIQUE_ENHANCED" ), Fight_CalcRoleStatus( actor, "TECHNIQUE_WEAKEN" ) )
	elseif attr == FIGHTER_ATTR.AGILITY then
		return Fight_ModifyValueByBuff( actor.fighter.agility, Fight_CalcRoleStatus( actor, "AGILITY_ENHANCED" ), Fight_CalcRoleStatus( actor, "AGILITY_WEAKEN" ) )
	end
end


---------------------------------------
local function Fight_ProcessDuel( atk, def )
	--when target is dead, pass through
	if def.fighter.hp <= 0 then return end

	--print( atk.role.name .. " attack " .. def.role.name )

	local hitCount = 0

	local atkSkill = atk.fighter._usingSkill
	local defSkill = def.fighter._usingSkill
	if not atkSkill then DBG_Error( "why no skill" ) end

	Fight_UseSkill( atk, atkSkill )
	Fight_UseSkill( def, defSkill, true )
	
	local _hitTimes = 0
	atk.fighter._hitTries = 0
	atk.fighter._hitCombo = 0
	atk.fighter._skillDamage = 0

	--passive skill
	local atkDmgMod     = 1
	local defDodge      = 0
	local defDodgeTimes = 0
	
	--passive skill atk	
	passiveSkill = Fight_GetPassiveSkill( atk, "atkAction" )
	if passiveSkill then
		if passiveSkill.atkAction.hit then
			defDodge = defDodge - ( passiveSkill.atkAction.hit.mod or 0 )
			defDodgeTimes = defDodgeTimes - ( passiveSkill.atkAction.hit.times or 0 )
		end
		if passiveSkill.atkAction.dmg then
			atkDmgMod = passiveSkill.atkAction.dmg.mod
		end
		Fight_UsePassiveSkill( atk, passiveSkill, "atkAction" )
	end

	--passive skill def	
	passiveSkill = Fight_GetPassiveSkill( def, "defAction" )
	if passiveSkill then
		if passiveSkill.defAction.dodge then
			defDodge = defDodge + passiveSkill.defAction.dodge.mod or 0
			defDodgeTimes = defDodgeTimes + passiveSkill.defAction.dodge.times or 0
		end
		Fight_UsePassiveSkill( def, passiveSkill, "defAction" )
	end	
	
	for action_idx, atkAction in ipairs( atkSkill.actions ) do
		--calculate hit accuracy
		local defAction = defSkill and defSkill.actions[action_idx]

		local pose = FIGHT_SKILLPOSE[atkAction.element] and FIGHT_SKILLPOSE[atkAction.element][defAction.element]

		local accuracy = Fight_GetValueByBuff( atk, FIGHTER_ATTR.TECHNIQUE )
		local dodge    = Fight_GetValueByBuff( def, FIGHTER_ATTR.TECHNIQUE ) * 0.3 + Fight_GetValueByBuff( def, FIGHTER_ATTR.AGILITY ) * 0.7
		local hit      = math.max( atk.fighter._hitMod or 0, ( pose and pose.hit or 0 ) + math.ceil( ( atkAction.accuracy * 0.5 or 0 ) + accuracy * 100 / ( accuracy + dodge ) ) - defDodge ) * 100
		--print( atk.role.name .. " hit accurcy is " .. hit )

		local isHit = true
		if defDodgeTimes > 0 then
			isHit = false
			defDodgeTimes = defDodgeTimes - 1
		elseif defDodgeTimes < 0 then
			defDodgeTimes = defDodgeTimes + 1
		else
			isHit = Random_GetInt_Sync( 1, 10000 ) < hit
		end

		atk.fighter._totalHitTries = atk.fighter._totalHitTries and atk.fighter._totalHitTries + 1 or 1

		if not FIGHT_RULE.ENABLE_SAVEPOINT then
			atk.fighter._ap = 0
			atk.fighter._dp = 0
		end

		if isHit then			
			--status modification
			local atkPow = Fight_GetValueByBuff( atk, FIGHTER_ATTR[atkAction.element] )
			local defPow = Fight_GetValueByBuff( def, FIGHTER_ATTR[atkAction.element] )
			local atkSkillMod = ( atkAction.attack + ( atk.fighter._ap or 0 ) ) * Fight_GetRoleTireness( atk )

			local critical = 100
			local atkTec = Fight_GetValueByBuff( atk, FIGHTER_ATTR.TECHNIQUE )
			local defTec = Fight_GetValueByBuff( def, FIGHTER_ATTR.TECHNIQUE )			
			if FIGHT_RULE.ENABLE_CRITICAL ~= 0 then
				local critical_prob = math.min( 90, ( atkAction.cri or 0 ) + math.ceil( ( atkTec * 1.2 - defTec * 0.8 ) * 100 / ( atkTec + defTec ) ) )
				if Random_GetInt_Sync( 1, 10000 ) < critical_prob * 100 then
					critical = 100 + ( pose and pose.cri or 0 )
					atk.fighter._criticalTimes = atk.fighter._criticalTimes and atk.fighter._criticalTimes + 1 or 1
				end
				--print( atkSkill.name, "critical", atkAction.cri, critical_prob )
			end			
			local atkDamage    = atkPow * atkSkillMod * critical * atkDmgMod * 0.0001
			local defDefend    = defPow			
			local base_damage  = atkDamage * atkDamage / ( atkDamage + defDefend )
			local block        = ( defAction and defAction.defense or 0 ) + ( def.fighter._dp or 0 )
			local final_damage = math.ceil( base_damage * FIGHT_PARAMS.DAMAGE_RATE / ( block + 100 ) )			
			
			--InputUtil_Pause( atkSkill.name, "finaldmg=" .. final_damage, "base_damage=" .. base_damage, "apow=" .. atkPow, "dpow=" .. defPow )

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
				Fight_Debug( def.role.name .. " resist damage " .. resistDamage )
			end
			
			if final_damage > 0 then
				local real_damage  = Fight_RoleDealDamage( def, final_damage )							
				atk.fighter._dealDamage = atk.fighter._dealDamage and atk.fighter._dealDamage + real_damage or real_damage
				atk.fighter._skillDamage = atk.fighter._skillDamage and atk.fighter._skillDamage + real_damage or real_damage
				local statName = "_" .. atkAction.element .. "_DMG"
				atk.fighter[statName] = atk.fighter[statName] and atk.fighter[statName] + real_damage or real_damage				
				--print( atkPow, atkSkillMod, critical, atkDmgMod )
				--print( atk.role.name .. " deal damage " .. real_damage .. " to " .. def.role.name .. " hp is " .. def.fighter.hp .. " now." )
			end

			--buff/debuff
			local comboeffect = Fight_CanTriggerSkillBuff( atk, atk.fighter._usingSkill )
			if comboeffect then Fight_TriggerSkillBuff( atk, def, comboeffect ) end

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

		if not Fight_IsRoleAlive( def ) then
			atk.fighter._kill = atk.fighter._kill and atk.fighter._kill + 1 or 0
			break
		end
	end

	Fight_Debug( atk.role.name .. " hit " .. def.role.name ..  " " .. _hitTimes .. "/" .. #atkSkill.actions .. " times, deal damage=" .. atk.fighter._skillDamage )
end	


local function Fight_ProcessDuels( duels )
	--process duels
	for _, duel in ipairs( duels ) do
		Fight_ProcessDuel( duel.atk, duel.def )
	end
end


---------------------------------------
local function Fight_RolePrepare( actor )
	if not actor.fighter._ap then actor.fighter._ap = 0 end
	if not actor.fighter._dp then actor.fighter._dp = 0 end
	actor.fighter._usingSkill = nil
end


---------------------------------------
local function Fight_RolePassTime( actor, time )
	--reduce atb
	actor.fighter._atb = actor.fighter._atb - time

	--reduce
	if actor.statuses then
		MathUtil_RemoveIf( actor.statuses, function ( status )
			status.duration = status.duration - time
			--if status.duration <= 0 then InputUtil_Pause( "actor.role.name, remove status", status.name ) end
			return status.duration <= 0
		end )
	end
end


---------------------------------------
local function ForAllRole( component, fn )
	for _, role in ipairs( component._atks ) do fn( role ) end
	for _, role in ipairs( component._defs ) do fn( role ) end
end


local function FindOppside( component, side )
	if side == FIGHT_SIDE.ATTACKER then return FIGHT_SIDE.DEFENDER
	elseif side == FIGHT_SIDE.DEFENDER then return FIGHT_SIDE.ATTACKER end
	return FIGHT_SIDE.NONE
end


local function FindTeam( component, side )
	if side == FIGHT_SIDE.ATTACKER then return component._atks
	elseif side == FIGHT_SIDE.DEFENDER then return component._defs end
end


---------------------------------------
function Fight_Process( fight )	
	if fight.result ~= "NONE" then return true end

	_fight = fight
		
	local result = FIGHT_SIDE.NONE

	local actionSequence = {}	

	--Create a shuffled sequence as roles's priority
	local priorities = MathUtil_CreateShuffledSequence( #fight._atks + #fight._defs )

	function DetermineATB( actor, action, time )
		if not action then action = "DEFAULT" end
		local actionTime = time and time + FIGHT_ACTIONTIME[action] or FIGHT_ACTIONTIME[action]
		local addTime = math.floor( actionTime / ( Fight_GetValueByBuff( actor, FIGHTER_ATTR.AGILITY ) + FIGHT_PARAMS.ATB_AGI_BASE ) )
		actor.fighter._atb = actor.fighter._atb and actor.fighter._atb + addTime or addTime
		--InputUtil_Pause( actor.role.name, "atb=" .. actor.fighter._atb .. " addtime=" .. addTime, actionTime )
	end

	--Determine all roles's action time
	function PrepareFight( actor, side )
		--initialize
		actor.fighter._side     = side
		actor.fighter._priority = table.remove( priorities, 1 )
		actor.fighter._ap       = 0
		actor.fighter._dp       = 0
		actor.passiveSkillDelays = {}
		DetermineATB( actor )
		table.insert( actionSequence, actor )
	end	

	function SortActionSequence()
		--Sort the action sequence by the action time and priority
		table.sort( actionSequence, function( l, r ) 
			if l.fighter._atb < r.fighter._atb then return true end
			if l.fighter._atb == r.fighter._atb then return l.fighter._priority < r.fighter._priority end
			return false
		end )
	end

	for _, actor in ipairs( fight._atks ) do PrepareFight( actor, FIGHT_SIDE.ATTACKER ) end
	for _, actor in ipairs( fight._defs ) do PrepareFight( actor, FIGHT_SIDE.DEFENDER ) end

	SortActionSequence()

	local result   = FIGHT_SIDE.NONE
	local passTime = 0
	local lastTime = 0
	local maxTime  = fight.remainTime
	while result == FIGHT_SIDE.NONE do
		local actionRole = table.remove( actionSequence, 1 )		

		if not actionRole then result = Fight_CheckResult( fight ) break end

		--print( "Turn to", actionRole.role.name )

		if Fight_IsRoleAlive( actionRole ) then
			print( actionRole.role.name .. " action, atb=" .. actionRole.fighter._atb )

			--pass the time		
			for _, role in ipairs( actionSequence ) do				
				Fight_RolePassTime( role, actionRole.fighter._atb )
			end
			passTime = passTime + actionRole.fighter._atb

			Fight_RolePassTime( actionRole, actionRole.fighter._atb )

			actionRole.fighter._actTimes = actionRole.fighter._actTimes and actionRole.fighter._actTimes + 1 or 1

			--choose target
			local target = Fight_FindTarget( actionRole, FindTeam( fight, FindOppside( fight, actionRole.fighter._side ) ) )

			if not target then
				actionRole.fighter._usingSkill = nil
			else
				if Random_GetInt_Sync( 1, 100 ) > Fight_GetRoleTireness( actionRole ) * 100 then
					--print( "tireness", Fight_GetRoleTireness( actionRole ) * 100 )
					actionRole.fighter._usingSkill = nil
				else
					--determine action
					actionRole.fighter._usingSkill = Fight_DetermineSkill( actionRole, target )
					target.fighter._usingSkill     = Fight_DetermineSkill( target, actionRole, true )
				end
			end

			--process duel
			if actionRole.fighter._usingSkill then
				Fight_ProcessDuel( actionRole, target )

				actionRole.fighter._skillTimes = actionRole.fighter._skillTimes and actionRole.fighter._skillTimes + 1 or 1
				if not actionRole.fighter._useSkillList then
					actionRole.fighter._useSkillList = {}
				end
				if actionRole.fighter._useSkillList[actionRole.fighter._usingSkill.id] then
					actionRole.fighter._useSkillList[actionRole.fighter._usingSkill.id] = actionRole.fighter._useSkillList[actionRole.fighter._usingSkill.id] + 1
				else
					actionRole.fighter._useSkillList[actionRole.fighter._usingSkill.id] = 1
				end				

				--Determine
				DetermineATB( actionRole, "USESKILL", actionRole.fighter._usingSkill.cd and ctionRole.fighter._usingSkill.cd.time or 0 )

			--elseif target.fighter._usingSkill then
			else
				--no mp, sp
				Fight_RoleRest( actionRole )
				actionRole.fighter._restTimes = actionRole.fighter._restTimes and actionRole.fighter._restTimes + 1 or 1
				--print( actionRole.role.name, "rest" )				
				DetermineATB( actionRole, "REST" )
			end

			--InputUtil_Pause( actionRole.role.name, " action" )

			if Fight_IsRoleAlive( actionRole ) then				
				table.insert( actionSequence, actionRole )

				--Resort
				SortActionSequence( actionSequence )
			end
		end

		result = Fight_CheckResult( fight )

		--print( "time", passTime .. "/" .. maxTime )
		if passTime > maxTime then break end
	end

	function FightEnd( actor )
		--Fight_DumpRole( actor, { "ATTRS", "STATS" } )

		if Fight_IsRoleAlive( actor ) then return end

		if not fight.rules["NO_DEAD"] then
			--dead
			Role_Dead( actor.fighter.entityid )
		end
	end

	print( "Fight End", fight:ToString() )

	Fight_ForeachRole( fight._atks,  FightEnd );
	Fight_ForeachRole( fight._defs, FightEnd );

	_fight = nil
end