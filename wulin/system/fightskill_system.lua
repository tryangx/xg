FIGHTSKILL_SYSTEM = class()

---------------------------------------
function FIGHTSKILL_SYSTEM:__init( ... )
	local args = ...
	self._name = args and args.name or "FIGHTSKILL_SYSTEM"
end


---------------------------------------
function FIGHTSKILL_SYSTEM:Create( skill, id )
	if not id then return end

	local template = FIGHTSKILLTEMPLATE_DATATABLE_Get( id )
	if not template then
		--for test
		--[[
		template = 
		{
			id     = id,
			name   = "Luohan Fist",
			groupidx= 1,--shao lin
			lv     = 1, --			
			weapon = { range="CLOSE", subtype="FIST" },
			step   = { min=5, max=8 },
			cost   = { st_std=10, mp_std=0 },
			actions=
			{
				atk={ std=80, min=-4, max=6, step=5 },
				def={ std=50, min=-2, max=5, step=5 },
				acc={ std=50, min=-2, max=5, step=5 },
				pose={ CENTER=500, LOWER=-200, UPPER=200 },
				elem={ INTERNAL=-500 },
			},
		}
		--]]
		DBG_TraceBug( "no template=", id )
		return
	end

	skill.groupidx = template.groupidx
	skill.lv       = template.lv
	skill.template = template.id
	skill.weapon   = MathUtil_ShallowCopy( template.weapon )
	skill.actions  = {}
	--use skill id as seed
	Random_SetSeed_Unsync( skill.id )

	local step = Random_GetInt_Unsync( template.step.min, template.step.max )
	local sum_atk = 0
	local sum_def = 0
	local sum_acc = 0
	local tot_st = 0
	local tot_mp = 0
	for i = 1, step do
		local st = template.cost.st_std and ( template.cost.st_std * ( template.cost.step or 1 ) ) or 0
		local mp = template.cost.mp_std and ( template.cost.mp_std * ( template.cost.step or 1 ) ) or 0
		function GenerateValue( name )
			if not template.actions[name] then return 0 end
			local v = template.actions[name] and template.actions[name].std or 0
			if template.actions[name].min and template.actions[name].max then
				local step = template.actions[name].step or 1
				v = v + Random_GetInt_Unsync( template.actions[name].min, template.actions[name].max ) * step
			end
			return v
		end
		function GeneratePose()
			local pose_prob = 
			{
				NONE   = 0,
				UPPER  = 1000,
				CENTER = 1000,
				LOWER  = 1000,
				ALL    = 0,
			}
			local totalprob = 0
			local list = {}
			for pose, prob in pairs( pose_prob )	do
				prob = prob + ( template.actions.pose[pose] or 0 )
				if prob > 0 then
					totalprob = totalprob + prob
					table.insert( list, { type=pose, prob=totalprob } )
				end
			end
			local prob = Random_GetInt_Unsync( 1, totalprob )
			for _, item in ipairs( list ) do if prob <= item.prob then return item.type end end
			DBG_Error( "why no pose" )
			return "NONE"
		end
		function GenerateElem()
			local pose_prob = 
			{
				INTERNAL = 1000,
				STRENGTH = 1000,
			}
			local totalprob = 0
			local list = {}
			for elem, prob in pairs( pose_prob ) do
				prob = prob + ( template.actions.elem[elem] or 0 )
				if prob > 0 then
					totalprob = totalprob + prob
					table.insert( list, { type=elem, prob=totalprob } )
				end
			end
			local prob = Random_GetInt_Unsync( 1, totalprob )
			for _, item in ipairs( list ) do if prob <= item.prob then return item.type end end
			DBG_Error( "why no elem" )
			return "STRENGTH"
		end
		function GenerateComboEffects()

		end
		local action = {}
		action.attack   = GenerateValue( "atk" ) 
		action.defense  = GenerateValue( "def" ) 
		action.accuracy = GenerateValue( "acc" ) 
		action.cri      = GenerateValue( "cri" ) 
		action.pose     = GeneratePose()
		action.element  = GenerateElem()
		action.comboeffects = GenerateComboEffects()
		table.insert( skill.actions, action )

		tot_st = tot_st + st
		tot_mp = tot_mp + mp
	end
	skill.cost = { st=tot_st, mp=tot_mp }

	print( "Create Skill " .. skill.name, "", "by Template=" .. template.name )
	--Dump( skill, 6 ) 	InputUtil_Pause()
end