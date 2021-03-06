function Fighter_CalcFightEff( fighter )
	local value = 0
	value = value + fighter.maxhp * 0.6
	value = value + fighter.maxmp * 0.25
	value = value + fighter.maxst * 0.25
	value = value + fighter.internal  * 0.8
	value = value + fighter.strength  * 0.8
	value = value + fighter.technique * 0.6
	value = value + fighter.agility   * 0.6
	return value
end

---------------------------------------
---------------------------------------
FIGHTER_SYSTEM = class()

---------------------------------------
function FIGHTER_SYSTEM:__init( ... )
	local args = ...
	self._name = args and args.name or "FIGHTER_SYSTEM"
end

---------------------------------------
function FIGHTER_SYSTEM:SetTemplateData( templates )
	self.templates = {}
	for _, template in ipairs( templates ) do
		self.templates[template.id] = template
	end
end

---------------------------------------
function FIGHTER_SYSTEM:GetTemplate( id )
	return self.templates and self.templates[id]
end

---------------------------------------
function FIGHTER_SYSTEM:Generate( fighter, fightertemplate, id )
	local template = self:GetTemplate( id )
	if not template then
		DBG_Error( "Invalid fighter template! Id=" .. id )
		return
	end
	fightertemplate.name   = template.name
	fightertemplate.grade  = template.grade
	fightertemplate.traits = MathUtil_ShallowCopy( template.traits )
	if not fightertemplate.traits then fightertemplate.traits = {} end
	local traits = fightertemplate.traits

	--Determine potential
	local data                = FIGHTERTEMPLATE_GENERATOR[fightertemplate.grade]
	fightertemplate.potential = math.min( data.lv.max, ( traits.lv_max or 0 ) + Random_GetInt_Sync( data.lv.min, data.lv.max ) )

	--Initialize template attributes( )
	--Value = Base + Max_Bonus + ( Mod + Lv_Up ) * Lv * Rate
	local lv                  = fightertemplate.potential
	fightertemplate.hp        = math.ceil( ( traits.hp_max or 0 )  + ( data.hp.base or 0 )  + ( data.hp.mod  + ( traits.hp_lvup or 0 ) )  * lv * ( traits.hp_rate or 1 ) )
	fightertemplate.mp        = math.ceil( ( traits.mp_max or 0 )  + ( data.mp.base or 0 )  + ( data.mp.mod  + ( traits.mp_lvup or 0 ) )  * lv * ( traits.mp_rate or 1 ) )
	fightertemplate.st        = math.ceil( ( traits.st_max or 0 )  + ( data.st.base or 0 )  + ( data.st.mod  + ( traits.st_lvup or 0 ) )  * lv * ( traits.st_rate or 1 ) )
	fightertemplate.internal  = math.ceil( ( traits.int_max or 0 ) + ( data.int.base or 0 ) + ( data.int.mod + ( traits.int_lvup or 0 ) ) * lv * ( traits.int_rate or 1 ) )
	fightertemplate.strength  = math.ceil( ( traits.str_max or 0 ) + ( data.str.base or 0 ) + ( data.str.mod + ( traits.str_lvup or 0 ) ) * lv * ( traits.str_rate or 1 ) )
	fightertemplate.technique = math.ceil( ( traits.tec_max or 0 ) + ( data.tec.base or 0 ) + ( data.tec.mod + ( traits.tec_lvup or 0 ) ) * lv * ( traits.tec_rate or 1 ) )
	fightertemplate.agility   = math.ceil( ( traits.agi_max or 0 ) + ( data.agi.base or 0 ) + ( data.agi.mod + ( traits.agi_lvup or 0 ) ) * lv * ( traits.agi_rate or 1 ) )

	--Determine initial level
	fighter.lv = 0
	if traits.init_lv then
		lv = traits.init_lv
	elseif not fighter.lv or fighter.lv == 0 then
		lv = Random_GetInt_Sync( traits.init_lv or 1, fightertemplate.potential )
	end
	--test

	--initialize fighter's attributes
	self:LevelUp( fighter, fightertemplate, lv )

	--fighter's skills
	if fighter.skills and #fighter.skills > 0 then
		print( "Already has skills" )
	else
		fighter.skills = {}
		function AddSkill( pool, times )
			if not pool then return end
			if #fighter.skills >= data.skill.max then return end;
			if times then
				local num = #pool
				if num > 0 then
					local id = pool[Random_GetInt_Sync( 1, #pool )]
					fighter:ObtainSkill( id )
				end
			else
				--add all
				if typeof(pool) == "table" then
					for _, id in ipairs( pool ) do
						fighter:ObtainSkill( id )
					end
				else
					--print( template.name, pool, string.len( pool ))
				end
			end
		end
		function AddPassiveSkill( pool, times )
		end
		AddSkill( template.skill_priority )
		AddSkill( template.skill_pool1, 1 )
		AddSkill( template.skill_pool2, 1 )
		AddSkill( template.skill_pool3, 1 )
		AddPassiveSkill( template.passive_skill_pool1, 1 )
		AddPassiveSkill( template.passive_skill_pool2, 1 )
		--Dump( fighter.skills ) InputUtil_Pause( "list skill" )
	end
	if template.skills and #template.skills > 0 then
		fighter.skills = MathUtil_ShallowCopy( template.skills )		
	end

	--initialize skills data
	if not fighter.skills then fighter.skills = {} end

	--initialize vital data
	fighter.hp = fighter.maxhp
	fighter.mp = fighter.maxmp
	fighter.st = fighter.maxst

	fighter.knowledge = 1000
	fighter.exp       = 50

	--fighter:Dump() 	Dump( template ) 	InputUtil_Pause()
end


---------------------------------------
function FIGHTER_SYSTEM:LevelUp( target, template, lv )
	if not lv or lv == 0 then return end
	if lv == target.lv then return end
	target.lv        = math.min( template.potential, lv )
	lv = target.lv
	local data       = FIGHTERTEMPLATE_GENERATOR[template.grade]
	local traits     = template.traits
	target.maxhp     = math.min( template.hp,        math.ceil( ( traits.hp_max or 0 )  + ( data.hp.base or 0 )  + ( data.hp.mod  + ( traits.hp_lvup or 0 ) )  * lv * ( traits.hp_rate or 1 ) ))
	target.maxmp     = math.min( template.mp,        math.ceil( ( traits.mp_max or 0 )  + ( data.mp.base or 0 )  + ( data.mp.mod  + ( traits.mp_lvup or 0 ) )  * lv * ( traits.mp_rate or 1 ) ) )
	target.maxst     = math.min( template.st,        math.ceil( ( traits.st_max or 0 )  + ( data.st.base or 0 )  + ( data.st.mod  + ( traits.st_lvup or 0 ) )  * lv * ( traits.sp_rate or 1 ) ) )
	target.strength  = math.min( template.strength,  math.ceil( ( traits.str_max or 0 ) + ( data.str.base or 0 ) + ( data.str.mod + ( traits.str_lvup or 0 ) ) * lv * ( traits.str_rate or 1 ) ) )
	target.internal  = math.min( template.internal,  math.ceil( ( traits.int_max or 0 ) + ( data.int.base or 0 ) + ( data.int.mod + ( traits.int_lvup or 0 ) ) * lv * ( traits.int_rate or 1 ) ) )
	target.technique = math.min( template.technique, math.ceil( ( traits.tec_max or 0 ) + ( data.tec.base or 0 ) + ( data.tec.mod + ( traits.tec_lvup or 0 ) ) * lv * ( traits.tec_rate or 1 ) ) )
	target.agility   = math.min( template.agility,   math.ceil( ( traits.agi_max or 0 ) + ( data.agi.base or 0 ) + ( data.agi.mod + ( traits.agi_lvup or 0 ) ) * lv * ( traits.agi_rate or 1 ) ) )
end