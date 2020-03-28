----------------------------------------
-- Enviroment & Variables

--who try to submit proposal
local _proposer = nil
--who is the one should do the job
local _actor    = nil

local _city  = nil
local _group = nil

local _meeting = nil
local _topic   = nil

local _registers = {}

local function pause()
	print( g_Time:ToString() )
	--print( "topic=", MathUtil_FindName( MeetingTopic, _topic ) )
	InputUtil_Pause( "debug chara ai", _city.name, MathUtil_FindName( MeetingTopic, _topic ) )
	return true
end

local function ai_log( params )
	Debug_Log( params.log )
end

local bp = { type = "FILTER", condition = pause }

local stop = { type = "FILTER", condition = function ( ... )
	return false
end }

local function dbg( content )
	InputUtil_Pause( content )
end

local function statfilter( params )
	Stat_Add( params.type, params.content )
	return false
end

----------------------------------------

local function PassProposal()
end

local function CheckProposer( params )
	local actor = _proposer

	--check the action point
	local datas = Scenario_GetData( "TASK_ACTION_DATA" )
	local data = datas[params.type]
	if not data then
		return true
	end
	for name, ap in pairs( CharaActionPoint ) do
		--print( name, ap, data[name], actor:GetAP( ap ) )
		if data[name] and actor:GetAP( ap ) < data[name] then
			--InputUtil_Pause( actor:ToString( "AP" ))
			return false
		end
	end

	--check the skill
	--no skill maybe give up the current proposal method
	local type = TaskType[params.type]

	return true
end

local function CostActorAP( actor, type )	
	local datas = Scenario_GetData( "TASK_ACTION_DATA" )
	local data = datas[type]	
	if not data then return end
	--print( actor:ToString( "AP" ) )
	for name, ap in pairs( CharaActionPoint ) do
		if data[name] then
			actor:UseAP( ap, data[name] )
		end
	end
	--InputUtil_Pause( actor:ToString( "AP" ) )
end

local function SubmitProposal( params )
	local proptype = params and params.type

	if _registers["PROPOSAL"] then
		proptype = _registers["PROPOSAL"]
	end

	--check actor
	if _registers["ACTOR"] then
		_actor = _registers["ACTOR"]
	end

	local proposal = Entity_New( EntityType.PROPOSAL )
	Asset_Set( proposal, ProposalAssetID.TYPE,        ProposalType[proptype] )
	Asset_Set( proposal, ProposalAssetID.PROPOSER,    _proposer )	
	Asset_Set( proposal, ProposalAssetID.LOCATION,    _city )
	Asset_Set( proposal, ProposalAssetID.DESTINATION, _city )
	Asset_Set( proposal, ProposalAssetID.TIME,        g_Time:GetDateValue() )
	Asset_Set( proposal, ProposalAssetID.ACTOR,       _actor )

	if _actor:IsBusy() then
		DBG_Error( _actor:ToString(), "already has task" )
	end
	
	if proptype == "ATTACK_CITY" then		
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "corps_list", _registers["ATTACK_CORPS"] )
		Asset_Set( proposal, ProposalAssetID.DESTINATION, _registers["TARGET_CITY"] )
		Debug_Log( "attack", _registers["TARGET_CITY"]:ToString() )
	
	elseif proptype == "HARASS_CITY" then
		Asset_Set( proposal, ProposalAssetID.DESTINATION, _registers["TARGET_CITY"] )
	
	elseif proptype == "INTERCEPT" then
		local enemyCorps = _registers["TARGET_CORPS"]
		local city = Asset_Get( enemyCorps, CorpsAssetID.LOCATION )
		Asset_Set( proposal, ProposalAssetID.DESTINATION, city )
		Asset_Set( proposal, ProposalAssetID.DESTINATION, _registers["TARGET_CITY"] )
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "TARGET_CORPS", enemyCorps )
	
	elseif proptype == "DISPATCH_CORPS" then
		Asset_Set( proposal, ProposalAssetID.DESTINATION, _registers["TARGET_CITY"] )
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "corps", _registers["CORPS"] )

	elseif proptype == "ESTABLISH_CORPS" then
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "plan", TaskType.ESTABLISH_CORPS )

	elseif proptype == "LEAD_CORPS" then
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "leader", _registers["LEADER"] )

	elseif proptype == "DISMISS_CORPS"
		or proptype == "TRAIN_CORPS"
		or proptype == "UPGRADE_CORPS"
		then
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "corps", _registers["CORPS"] )

	elseif proptype == "REGROUP_CORPS" then
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "corps_list", _registers["CORPS_LIST"] )		

	elseif proptype == "REINFORCE_CORPS"
		or proptype == "ENROLL_CORPS" then
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "corps", _registers["CORPS"] )
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "plan", TaskType.COMMANDER_TASK )
	
	elseif proptype == "RECRUIT"
		or proptype == "CONSCRIPT" 
		or proptype == "HIRE_GUARD" then
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "plan", TaskType.COMMANDER_TASK )

	elseif proptype == "PROMOTE_CHARA" then
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "title", _registers["TITLE"] )
	
	elseif proptype == "HIRE_CHARA" then
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "plan", TaskType.HR_TASK )
	
	elseif proptype == "DISPATCH_CHARA" then
		Asset_Set( proposal, ProposalAssetID.DESTINATION, _registers["TARGET_CITY"] )
	
	elseif proptype == "CALL_CHARA" then		
		Asset_Set( proposal, ProposalAssetID.LOCATION, _registers["TARGET_CITY"] )
	
	elseif proptype == "MOVE_CAPITAL" then
		Asset_Set( proposal, ProposalAssetID.LOCATION, _registers["TARGET_CITY"] )
	
	elseif proptype == "DEV_AGRICULTURE" or proptype == "DEV_COMMERCE" or proptype == "DEV_PRODUCTION" 
		or proptype == "LEVY_TAX"
		or proptype == "BUY_FOOD"
		or proptype == "SELL_FOOD"
		then
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "plan", TaskType.OFFICIAL_TASK )
	
	elseif proptype == "BUILD_CITY"
		then
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "construction", _registers["CONSTRUCTION"] )
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "plan", TaskType.BUILD_CITY )

	elseif proptype == "TRANSPORT" then
		Asset_Set( proposal, ProposalAssetID.DESTINATION, _registers["TARGET_CITY"] )
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "plan", TaskType.TRANSPORT )

	elseif proptype == "RECONNOITRE" 
		or proptype == "SABOTAGE"
		or proptype == "DESTROY_DEF"
		then
		Asset_Set( proposal, ProposalAssetID.DESTINATION, _registers["TARGET_CITY"] )

	elseif proptype == "ASSASSINATE" then
		Asset_Set( proposal, ProposalAssetID.DESTINATION, _registers["TARGET_CITY"] )
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "chara", _registers["TARGET_CHARA"] )

	elseif proptype == "RESEARCH" then
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "tech", _registers["TARGET_TECH"] )
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "plan", TaskType.RESEARCH )

	elseif proptype == "IMPROVE_RELATION"	
		or proptype == "DECLARE_WAR"
		then
		local oppGroup = _registers["TARGET_GROUP"]
		local capital  = Asset_Get( oppGroup, GroupAssetID.CAPITAL )
		Asset_Set( proposal, ProposalAssetID.DESTINATION, capital )
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "group", oppGroup )
		if proptype == "IMPROVE_RELATION" then
			Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "plan", TaskType.IMPROVE_RELATION )
		elseif proptype == "DECLARE_WAR" then
			Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "plan", TaskType.DECLARE_WAR )
		end		

	elseif proptype == "SIGN_PACT" then
		local oppGroup = _registers["TARGET_GROUP"]
		local capital  = Asset_Get( oppGroup, GroupAssetID.CAPITAL )
		Asset_Set( proposal, ProposalAssetID.DESTINATION, capital )
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "pact", _registers["PACT"] )		
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "time", _registers["TIME"] )
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "group", oppGroup )
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "plan", TaskType.DIPLOMATIC_TASK )

	elseif proptype == "SET_GOAL" then
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "goalType", _registers["GOALTYPE"] )
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "goalData", _registers["GOALDATA"] )

	elseif proptype == "INSTRUCT_CITY" then
		for _, item in pairs( _registers["INSTRUCT_CITY_LIST"] ) do
			if not item.city then
				for _, item1 in pairs( _registers["INSTRUCT_CITY_LIST"] ) do
					print( item1.city:ToString() )
				end
			end
		end
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "instructCityList", _registers["INSTRUCT_CITY_LIST"] )		

	elseif proptype == "IMPROVE_GRADE" then
		Asset_SetDictItem( proposal, ProposalAssetID.PARAMS, "grade", _registers["grade"] )

	elseif proptype == "TRAIN_CORPS" then

	elseif proptype == "" then
	end

	CostActorAP( _proposer, proptype )

	DBG_Watch( "Debug_Meeting", "submit proposal=" .. proposal:ToString() )

	Stat_Add( "SubmitProposal@" .. _proposer:ToString(), proposal:ToString(), StatType.LIST )
	Stat_Add( "Proposal@Submit_Times", 1, StatType.TIMES )

	--Log_Write( "meeting", "    topic=" .. MathUtil_FindName( MeetingTopic, _topic ) ..  " proposal=" .. proposal:ToString() )

	--InputUtil_Pause( proposal:ToString() )

	--Asset_SetDictItem( _proposer, CharaAssetID.STATUSES, CharaStatus.PROPOSAL_CD, Random_GetInt_Sync( 30, 50 ) )
end

----------------------------------------

local function CheckDate( params )
	if params.month then
		if params.month ~= g_Time:GetMonth() then return false end
	end
	if params.day then
		if params.day ~= g_Time:GetDay() then return false end
	end
	return true
end

local function CheckProbablity( params )
	local prob = params.prob or 100
	return Random_GetInt_Sync( 1, 100 ) < prob
end

local function IsCityCapital()
	local group = Asset_Get( _city, CityAssetID.GROUP )
	--should consider more, like government style
	if not group then return true end
	return Asset_Get( group, GroupAssetID.CAPITAL ) == _city
end

local function IsGroupLeader()
	return _proposer:IsGroupLeader()
end

local function IsTopic( params )
	if not _topic or _topic == MeetingTopic.NONE then
		InputUtil_Pause( "topic pass", _topic )
		return false
	end
	return MeetingTopic[params.topic] == _topic
end

local function IsProposalCD()
	local proposalcd = _proposer:GetStatus( CharaStatus.PROPOSAL_CD )
	return proposalcd and proposalcd > 0 or false
end

local function HasCityStatus( params )
	local ret = _city:GetStatus( CityStatus[params.status] )
	if ret == true then
		--InputUtil_Pause( _city.name, params.status, CityStatus[params.status] )
	end
	return ret
end

local function HasGroupGoal( params )
	if not _group then return false end
	local goalData = _group:GetGoal( GroupGoalType[params.goal] )	
	if not goalData then return false end
	if params.excludeCity then
		if goalData.city == _city then return false end
	end
	--print( params.goal, _group:ToString( "GOAL" ), goalData, goalData.city )
	local ret = goalData.city ~= nil or goalData.city == city
	return ret
end

local function QueryJob( topic )
	local job
	if topic == MeetingTopic.TECHNICIAN then
		job  = CityJob.TECHNICIAN
	elseif topic == MeetingTopic.DIPLOMATIC then
		job  = CityJob.DIPLOMATIC
	elseif topic == MeetingTopic.HR then
		job  = CityJob.HR
	elseif topic == MeetingTopic.OFFICIAL then
		job  = CityJob.OFFICIAL
	elseif topic == MeetingTopic.COMMANDER then
		job  = CityJob.COMMANDER
	elseif topic == MeetingTopic.STAFF then
		job  = CityJob.STAFF
	elseif topic == MeetingTopic.STRATEGY then
		job  = CityJob.COMMANDER
	end
	return job
end

local function CanSubmitPlan( params )
	if IsTopic( params ) == false then
		return false
	end

	--exclusive task checker
	local topic = MeetingTopic[params.topic]
	local job = QueryJob( topic )
	if plan then
		local task = _city:GetPlan( plan )
		if task then return false end
	end

	if _city:IsCharaOfficer( CityJob.EXECUTIVE, _proposer ) == true then
		--find the one who do the job
		local list = {}
		Asset_Foreach( _city, CityAssetID.CHARA_LIST, function ( chara )
			if not chara:IsAtHome() then return false end
			if chara:IsBusy() then return false end
			if not _city:IsCharaOfficer( job, chara ) then return false end

			--should find the fit chara who has skill relat to the topic

			table.insert( list, chara )
			return true
		end )
		if #list > 0 then
			local actor = Random_GetListItem( list )
			if actor then
				_actor = actor
				--Log_Write( "meeting", "      " .. _proposer.name .. " find a actor=" .. _actor.name )
			end
		end
	end

	return true
end

local function IsResponsible()		
	if _city:IsCharaOfficer( CityJob.EXECUTIVE, _proposer ) == true then
		return true
	end

	local job = QueryJob( _topic )
	if _city:IsCharaOfficer( job, _proposer ) then
		--print( _proposer.name, "is job=" .. MathUtil_FindName( CityJob, job ) )
		return true
	end

	return false
end

----------------------------------------

local function CanLeadCorps()
	if Asset_Get( _actor, CharaAssetID.CORPS ) then
		return false
	end

	--sanity check
	Entity_Foreach( EntityType.CORPS, function ( corps )
		if Asset_Get( corps, CorpsAssetID.LEADER ) == _actor then
			DBG_Error( _actor:ToString("CORPS") .. " alread lead corps=" .. corps:ToString() )
		end
	end)

	local corpsList = {}
	Asset_Foreach( _city, CityAssetID.CORPS_LIST, function ( corps )
		if corps:IsAtHome() == false then
			--print( "canld nohome", corps:ToString( "BRIEF" ) )
			return
		end
		if corps:IsBusy() == true then
			--print( "canld busy", corps:ToString( "BRIEF" ) )
			return
		end
		--print( "check ld", corps:ToString() )
		if not Asset_Get( corps, CorpsAssetID.LEADER ) then
			table.insert( corpsList, corps )
			return true
		end
	end)
	if #corpsList == 0 then
		return false
	end

	local findCorps = Random_GetListItem( corpsList )
	_registers["ACTOR"]  = findCorps
	_registers["LEADER"] = _actor

	--Debug_Log( "corps=" .. corps:ToString() .. " lead=" .. _actor:ToString() )

	return true
end

local function CanEstablishCorps()
	--print( "limit=" .. Corps_GetLimitByCity( _city ), "corps=" .. Asset_GetListSize( _city, CityAssetID.CORPS_LIST ) )

	--check corps limitation
	local hasCorpsInCity   = Asset_GetListSize( _city, CityAssetID.CORPS_LIST )

	local limitCorpsInCity = Corps_GetLimitByCity( _city )
	if hasCorpsInCity >= limitCorpsInCity then
		Debug_Log( _city.name, "EstCorpsFailed! corps limit, cann't est corps", _city.name, hasCorpsInCity .. "/" .. limitCorpsInCity )
		return false
	end

	--[[
	--check req corps
	local reqCorps = Corps_GetRequiredByCity( _city )
	if hasCorpsInCity >= reqCorps then		
		--print( "won't est corps, enough coprs" .. hasCorpsInCity .."/"..reqCorps )
		--_city:SetStatus( CityStatus.RESERVE_UNDERSTAFFED, 1 )		
		return false
	end
	]]

	--need a leader
	local charaList = _city:FindFreeCharas( function ( chara )
		--not a leader
		if Asset_Get( chara, CharaAssetID.CORPS ) then
			return false
		end
		--check skill
		--check relation( extension )
		local job = _city:GetCharaJob( chara )
		--Debug_Log( chara.name, MathUtil_FindName( CityJob, job ) )
		return job == CityJob.COMMANDER or job == CityJob.EXECUTIVE
	end)
	if #charaList == 0 then
		Debug_Log( _city.name, "EstCorpsFailed! no commander", _city:ToString("OFFICER") )
		return false
	end

	--check minimum soldier available
	local reserves = _city:GetPopu( CityPopu.RESERVES )
	if reserves < Scenario_GetData( "TROOP_PARAMS" ).MIN_TROOP_SOLDIER then
		Debug_Log( _city.name, "EstCorpsFailed! not enough reserves=", reserves )
		return false
	end

	--check
	if Corps_CanEstablishCorps( _city, reserves, City_HasTroopBudget ) == false then
		Debug_Log( _city.name, "EstCorpsFailed! cann't est" )
		return false
	end

	local leader = Random_GetListItem( charaList )
	_registers["ACTOR"] = leader

	Debug_Log( "est corps", leader:ToString() )

	return true
end

--Check whether we can reinforce any understaffered troop in the corps
local function CanReinforceCorps()
	local reserves = _city:GetPopu( CityPopu.RESERVES )
	if reserves < Scenario_GetData( "TROOP_PARAMS" ).MIN_TROOP_SOLDIER then
		--_city:SetStatus( CityStatus.RESERVE_UNDERSTAFFED, 1 )
		return false
	end

	local totalnum = 0
	local corpsList = {}
	Asset_Foreach( _city, CityAssetID.CORPS_LIST, function ( corps )
		if corps:IsAtHome() == false then return false end
		if corps:IsBusy() == true then return false end
		local understaffed = math.floor( corps:GetStatus( CorpsStatus.UNDERSTAFFED ) ) or 0
		if understaffed <= 0 then return false end
		--print( "staff", corps:ToString(), understaffed )
		totalnum = totalnum + understaffed
		table.insert( corpsList, { num = understaffed, corps = corps } )
	end )
	if #corpsList == 0 then return false end

	local findCorps
	local prob = Random_GetInt_Sync( 1, totalnum )
	for _, data in ipairs( corpsList ) do
		if prob <= data.num then
			findCorps = data.corps
			break
		end
		prob = prob - data.num
	end

	if not findCorps then DBG_Error( "why here", totalnum, prob ) end

	_registers["CORPS"] = findCorps
	_registers["ACTOR"] = findCorps

	--print( "REINFORCE_CORPS", findCorps:ToString( "MILITARY") )

	return true
end

--Check whether we can enroll new troop into the established corps
local function CanEnrollCorps()
	local reserves = _city:GetPopu( CityPopu.RESERVES )
	if reserves < Scenario_GetData( "TROOP_PARAMS" ).MIN_TROOP_SOLDIER then
		--_city:SetStatus( CityStatus.RESERVE_UNDERSTAFFED, 1 )
		return false
	end

	--find corps that has vacancy for troop 
	local findCorps = nil
	Asset_FindItem( _city, CityAssetID.CORPS_LIST, function ( corps )		
		if corps:IsAtHome() == false then return false end
		--print( corps:ToString("STATUS"), Asset_GetListSize( corps, CorpsAssetID.TROOP_LIST ) )
		if corps:IsBusy() == true then return false end
		if Asset_GetListSize( corps, CorpsAssetID.TROOP_LIST ) < Corps_GetTroopNumber( corps ) then
			--print( corps:ToString(), "need enroll", Corps_GetTroopNumber( corps ) )
			return true
		end
	end)
	if not findCorps then
		--print( "no rein corps", Asset_GetListSize( _city, CityAssetID.CORPS_LIST ) )
		return false
	end

	if Corps_CanEstablishCorps( _city, reserves, City_HasTroopBudget ) == false then
		Debug_Log( "cann't enroll corps" )
		return false
	end

	_registers["CORPS"] = findCorps
	_registers["ACTOR"] = findCorps

	--InputUtil_Pause("enroll")

	return true
end

local function CanTrainCorps()
	local findCorps = nil
	Asset_FindItem( _city, CityAssetID.CORPS_LIST, function ( corps )
		if corps:IsAtHome() == false then return false end
		if corps:IsBusy() == true then return false end
		--check corps can train
		if corps:CanTrain() then
			findCorps = corps
			return true
		end
	end)
	if not findCorps then
		--print( "no train corps" )
		return false
	end

	_registers["CORPS"] = findCorps
	_registers["ACTOR"] = findCorps

	return true
end

local function CanRegroupCorps()
	local numOfCorps = Asset_GetListSize( _city, CityAssetID.CORPS_LIST )
	if numOfCorps < 2 then
		return false
	end

	local list = {}
	local mainCorps
	Asset_Foreach( _city, CityAssetID.CORPS_LIST, function ( corps )
		if corps:IsAtHome() == false then
			--print( corps.name, "not home" )
			return
		end
		if corps:IsBusy() == true then
			--print( "corps busy", corps:ToString( "STATUS" ) )
			return
		end
		if not mainCorps or Asset_GetListSize( mainCorps, CorpsAssetID.TROOP_LIST ) < Asset_GetListSize( corps, CorpsAssetID.TROOP_LIST ) then
			mainCorps = corps
		end
		table.insert( list, corps )
	end)

	if #list < 2 then
		return false
	end

	_registers["ACTOR"]      = mainCorps
	_registers["CORPS_LIST"] = list

	return true
end

local function CheckWarWeariness()
	local weariness = _city:GetStatus( CityStatus.WAR_WEARINESS )
	if not weariness then return true end
	return Random_GetInt_Sync( 1, 100 ) < weariness * DAY_IN_MONTH / DAY_IN_SEASON
end

local function CheckCorpsAggressiveScore( corps )
	local score = 0
	local chara = Asset_Get( corps, CorpsAssetID.LEADER )
	if chara then
		Asset_Foreach( chara, CharaAssetID.SKILLS, function ( skill )			
			if skill.type == CharaSkillType.COMMANDER then
				score = score + skill.level
			
			elseif skill.type == CharaSkillType.OFFICER then
				score = score + skill.level * 0.5

			else

			end
		end )
	end
	return score
end

local function CheckAggressiveScore( params )
	local score = 0
	if params.corps then
		score = score + CheckCorpsAggressiveScore( params.corps )
	end
	if params.city then
		Asset_Foreach( params.city, CityAssetID.CORPS_LIST, function ( corps )
			score = score + CheckCorpsAggressiveScore( corps )
		end )
	end
	if params.corpsList then
		for corps in ipairs( params.corpsList ) do
			score = score + CheckCorpsAggressiveScore( corps )
		end
	end
	return score
end

local function CheckEnemyCity( adjaCity, city, params )
	--check food
	if params.corps and Supply_HasEnoughFoodForCorps( city, adjaCity, params.corps ) == false then
		print( "no food for corps to attack" )
		return false
	end
	if params.corpsList and Supply_HasEnoughFoodForCorpsList( city, adjaCity, params.corpsList ) == false then
		print( "no food for corpslist to attack" )
		return false
	end
	
	local score = params and params.score or 0

	if adjaGroup then
		--we cann't attack without declared war
		if Dipl_IsAtWar( _group, adjaGroup ) == false then
			return 
		end
		--if city is the goal target, we eager to do this
		if goal and adjaCity == goal.city then
			score = score + 30
		end
	else
		--target is neutral, we got a chance!
		score = score + 30
	end

	--target city has debuff
	if adjaCity:GetStatus( CityStatus.STARVATION ) then
		score = score + 50
	end

	--check intel
	local citySoldier = Intel_Get( adjaCity, city, CityIntelType.DEFENDER )
	if citySoldier == -1 then
		Debug_Log( adjaCity.name .. " info unknown" )
		return false
	end
	if citySoldier == 0 then
		print( adjaCity:ToString("MILITARY"), "no soldier")
		return true
	end

	--skill bonus
	local charaScore = CheckAggressiveScore( { corps = corps, corpsList = corpsList } )
	local soldier = params.soldier * ( charaScore + 100 ) * 0.01

	--check soldier
	local ratio = soldier / citySoldier
	--TODO: should consider about the officer ability
	local score = 0	
	local item = MathUtil_Approximate( ratio, params.scores, "ratio", true )
	score = score + item.score
	
	--function 
	if params.fn then
		score = score + params.fn( adjaCity, city )
	end
	
	score = score - ( params.oppScore or 0 )

	Debug_Log( "check_enemycity", adjaCity.name .. " solider=" .. citySoldier, " score=" .. score, "opp_score=" .. ( params.oppScore or 0 ) )

	return Random_GetInt_Sync( 1, 100 ) > score
end

local function FindEnemyCityList( city, params )
	return city:FilterAdjaCities( function ( adjaCity )
		local name = "city_" .. adjaCity.name .. "_agg_score"
		local score = Cache_Get( name )
		if not score then
			score = CheckAggressiveScore( { city = adjaCity } )
			Cache_Set( name, score )
		end
		params.oppScore = score

		local adjaGroup = Asset_Get( adjaCity, CityAssetID.GROUP )
		--it's our city!!!
		if adjaGroup == _group then
			return false
		end
		
		return CheckEnemyCity( adjaCity, city, params )
	end )
end

local enemyCityScores = 
{
	{ ratio = 1,   score = 10 },
	{ ratio = 1.5, score = 20 },
	{ ratio = 2,   score = 30 },
	{ ratio = 3,   score = 50 },
	{ ratio = 4,   score = 90 },
}

local function CanHarassCity()
	--check free corps
	local list, tot_soldier, max_soldier = _city:GetMilitaryCorps( 20 )
	if #list == 0 then return false end	
	
	local corps  = list[Random_GetInt_Sync( 1, #list )]
	local goal   = _group:GetGoal( GroupGoalType.OCCUPY_CITY )
	local cities = FindEnemyCityList( _city, { soldier = max_soldier, goal = goal, scores = enemyCityScores, corps = corps } )

	Debug_Log( "canharss", _city:ToString("MILITARY"), "SOL="..max_soldier.."/"..tot_soldier, #list )

	local number = #cities
	if number == 0 then return false end

	local destCity = cities[Random_GetInt_Sync( 1, number )]
	_registers["ACTOR"] = corps
	_registers["TARGET_CITY"] = destCity

	Debug_Log( corps:ToString(), "[harass]", destCity.name )

	return true
end

local function CanAttackCity()	
	--check free corps
	local list, tot_soldier, max_soldier = _city:GetMilitaryCorps( 30 )
	if #list == 0 then
		local numofcorps = Asset_GetListSize( _city, CityAssetID.CORPS_LIST )
		--Debug_Log( _city:ToString("CORPS") )
		--Debug_Log( _city.name, "has corps=" .. numofcorps )		
		--print( "can attack", _city:ToString(), g_Time:ToString() )
		return false
	end

	local goal = _group:GetGoal( GroupGoalType.OCCUPY_CITY )
	local cities = FindEnemyCityList( _city, { soldier = tot_soldier, goal = goal, scores = enemyCityScores, corpsList = list } )

	local number = #cities
	if number == 0 then
		--print( "no enemy city" )
		return false
	end

	Debug_Log( "canattack self=", _city:ToString("MILITARY"), "SOL="..max_soldier.."/"..tot_soldier, "corps_num=" .. #list )

	local corps = list[Random_GetInt_Sync( 1, #list )]
	local destCity = cities[Random_GetInt_Sync( 1, number )]

	Debug_Log( "CombatCompare", corps:ToString( "MILITARY" ), destCity:ToString( "MILITARY" ) )

	_registers["ACTOR"] = corps
	_registers["TARGET_CITY"] = destCity
	_registers["ATTACK_CORPS"] = list

	--InputUtil_Pause( "attack", destCity.name, #list, corps:ToString("MILITARY"),soldier )

	return true
end

local function CanExpedition()
	if 1 then return false end

	--check free corps
	local list, soldier, power = _city:GetMilitaryCorps( 20 )
	if #list == 0 then
		return false
	end

	--expedition target should the target of goal
	local goal = _group:GetGoal( GroupGoalType.OCCUPY_CITY )
	if not goal then
		return false
	end

	local destCity = goal.city
	if not _city:IsEnemeyCity( destCity ) then
		return false
	end

	local corps = list[Random_GetInt_Sync( 1, #list )]

	if not CheckEnemyCity( destCity, _city, { goal = goal, scores = canAttackScores, corps = corps } ) then
		return false
	end	

	Debug_Log( "CombatCompare", corps:ToString( "MILITARY" ), destCity:ToString( "MILITARY" ) )--, "enemy=" .. Intel_Get( destCity, _city, CityIntelType.DEFENDER ) )

	_registers["ACTOR"] = corps
	_registers["TARGET_CITY"] = destCity
	_registers["ATTACK_CORPS"] = list

	Debug_Log( "expedition", destCity.name, #list, corps:ToString("MILITARY"),soldier )

	return true
end

local function CanIntercept()
	local list = _city:GetMilitaryCorps( 20 )
	if #list == 0 then
		--print( _city:ToString( "CORPS" ) )
		--InputUtil_Pause( "intercept", _city.name .. " no corps=", Asset_GetListSize( _city, CityAssetID.CORPS_LIST ) )
		return false
	end

	local target = Asset_Get( _meeting, MeetingAssetID.TARGET )
	local destCity = Asset_Get( target, CorpsAssetID.LOCATION )
	local corps = list[Random_GetInt_Sync( 1, #list )]

	--check food
	if Supply_HasEnoughFoodForCorps( _city, destCity, corps ) == false then
		return false
	end

	--sanity checker
	if Asset_Get( corps, CorpsAssetID.GROUP ) == Asset_Get( target, CorpsAssetID.GROUP ) then
		DBG_Error( "why they are same group", corps:ToString(), target:ToString() )
	end

	--print( target:ToString() )
	--InputUtil_Pause( "intercept", _city:ToString(), destCity.name )

	_registers["ACTOR"]  = corps
	_registers["TARGET_CORPS"] = target
	_registers["TARGET_CITY"]  = destCity	

	return true
end

--1. in danger
--2. not enough reserves
--3. corps understaffed
local function NeedMoreReserves()
	if _city:GetStatus( CityStatus.BUDGET_DANGER ) then
		--print( "budget danger, cann't conscript" )
		--Stat_Add( "BudgetDanger", 1, StatType.TIMES )
		return false
	end

	local reserves = _city:GetPopu( CityPopu.RESERVES )

	if _city:GetStatus( CityStatus.RESERVE_UNDERSTAFFED ) then
		return true
	end
	if _city:GetStatus( CityStatus.AGGRESSIVE_ADV ) then
		return true
	end
	if reserves > math.max( _city:GetLimitPopu( CityPopu.RESERVES ), _city:GetStatus( CityStatus.RESERVE_NEED ) or 0 ) then
		--print( _city:ToString( "BRIEF") )
		--InputUtil_Pause( _city.name, "too many reserves", reserves .."/".. _city:GetLimitPopu( CityPopu.RESERVES ) .. "+" ..  _city:GetStatus( CityStatus.RESERVE_NEED ) )
		return false
	end

	--default score
	local score = 0

	--check "in danger"
	if _group:GetGoal( GroupGoalType.OCCUPY_CITY ) then
		if _city:GetStatus( CityStatus.AGGRESSIVE_WEAK ) then
			--print( _city.name, "AGGRESSIVE wek", score )
			return true
		end
		if _city:GetStatus( CityStatus.AGGRESSIVE_ADV ) then
			score = score - 10
		end
		if _city:GetStatus( CityStatus.MILITARY_BASE ) then
			score = score + 30
		end
	elseif _group:GetGoal( GroupGoalType.DEFEND_CITY ) then
		if _city:GetStatus( CityStatus.DEFENSIVE_DANGER ) then
			--print( _city.name, "DEFENSIVE_DANGER", score )
			return true
		end
		if _city:GetStatus( CityStatus.DEFENSIVE_WEAK ) then
			score = score + 20
		end
	else
		if _city:GetStatus( CityStatus.AGGRESSIVE_WEAK ) then
			score = score + 30
		end
		if _city:GetStatus( CityStatus.AGGRESSIVE_ADV ) then
			score = score - 20
		end
		if _city:GetStatus( CityStatus.DEFENSIVE_DANGER ) then
			score = score + 50
		end
		if _city:GetStatus( CityStatus.DEFENSIVE_WEAK ) then
			score = score + 30
		end
		if _city:GetStatus( CityStatus.MILITARY_BASE ) then
			score = score + 20
		end
	end

	if _city:GetStatus( CityStatus.BATTLEFRONT ) then
		score = score + 30
	end

	--corps understaffed
	local soldier, maxSoldier = _city:GetSoldier()
	local needSoldier = maxSoldier - soldier
	local reserves = _city:GetPopu( CityPopu.RESERVES )
	local ratio = reserves / needSoldier

	local reservesScores = 
	{
		{ ratio = 0.3, score = 100 },
		{ ratio = 0.4, score = 90 },
		{ ratio = 0.5, score = 70 },
		{ ratio = 0.7, score = 50 },
		{ ratio = 0.9, score = 30 },
		{ ratio = 1, score = 0 },
	}
	local item = MathUtil_Approximate( ratio, reservesScores, "ratio", true )
	score = score + item.score
	
	--print( score, reserves, needSoldier )

	if Random_GetInt_Sync( 1, 100 ) > score then
		--Debug_Log( _city:ToString( "STATUS" ) )
		Debug_Log( g_Time:ToString(), _city.name, "failed reserve " .. item.score .. "->" .. score, "needsol=" .. reserves .. "/" .. needSoldier )
		return false
	end

	Debug_Log( g_Time:ToString(), _city.name, "need reserve score=" .. score )
	--print( _city:ToString( "POPULATION" ) )
	--print( _group:ToString( "DIPLOMACY" ) )
	--print( _city:ToString( "STATUS" ) )
	--print( "reserves=" .. reserves, "need=" .. needSoldier, maxSoldier, soldier )	
	return true
end

local function NeedCorps( city, score )
	--if city:IsCapital() == true then return end
	if Corps_GetLimitByCity( city ) <= Asset_GetListSize( city, CityAssetID.CORPS_LIST ) then
		--print( "check", _city.name, city.name, Corps_GetLimitByCity( city ), Asset_GetListSize( city, CityAssetID.CORPS_LIST ) )
		return
	end
	if not score then score = 0 end
	if city:GetStatus( CityStatus.DEFENSIVE_WEAK ) then
		score = score + 10
	end
	if city:GetStatus( CityStatus.DEFENSIVE_DANGER ) then
		score = score + 20
	end
	if city:GetStatus( CityStatus.BATTLEFRONT ) then
		score = score + 30
	end
	Debug_Log( "dis corps", city.name, score )
	return Random_GetInt_Sync( 1, 100 ) < score
end

--force conscript, 
local function CanConscript()
	if _actor:IsBusy() then return false end	
	if NeedMoreReserves() == false then
		return false
	end
	return true
end

--use money to recruit
local function CanRecruit()
	if _actor:IsBusy() then return false end
	if NeedMoreReserves() == false then		
		return false
	end
	return true
end

local function CanHireGuard()
	if _actor:IsBusy() then return false end

	local hasGuard  = _city:GetPopu( CityPopu.GUARD )
	local needGuard = _city:GetReqPopu( CityPopu.GUARD )
	if needGuard < hasGuard then
		return false
	end

	local money = ( needGuard - hasGuard ) * _city:GetPopuValue( "POPU_SALARY", CityPopu.GUARD )
	if Asset_Get( _city, CityAssetID.MONEY ) < money then
		InputUtil_Pause( "no money hire guard", money )
		return false
	end

	local score = 50

	if _group:GetGoal( GroupGoalType.DEFEND_CITY ) then
		if _city:GetStatus( CityStatus.DEFENSIVE_DANGER ) then			
			--print( _city.name, "DEFENSIVE_DANGER should hireguard" )
			return true
		end
		if _city:GetStatus( CityStatus.DEFENSIVE_WEAK ) then
			score = score + 30
		end
	end

	if Random_GetInt_Sync( 1, 100 ) > score then
		Debug_Log( g_Time:ToString(), _city.name, "failed hireguard score=" .. score )
		return false
	end

	Debug_Log( _city.name, "hire guard", hasGuard .. "/" .. needGuard )

	return true
end

local function CanEnhanceMilitaryBase()
	local corpsList = _city:GetFreeCorps()
	if #corpsList == 0 then
		--print( "no corps" )
		return false
	end

	local cityList = {}
	Asset_Foreach( _group, GroupAssetID.CITY_LIST, function ( city )
		if city == _city then return end
		if NeedCorps( city, score ) == false then return end
		if not city:GetStatus( CityStatus.MILITARY_BASE ) then return end
		table.insert( cityList, city )
	end)
	if #cityList == 0 then
		return false
	end

	local corps    = Random_GetListItem( corpsList )
	local destCity = Random_GetListItem( cityList )
	_registers["ACTOR"] = corps
	_registers["CORPS"] = _registers["ACTOR"]
	_registers["TARGET_CITY"] = destCity

	if destCity == Asset_Get( corps, CorpsAssetID.LOCATION ) then
		DBG_Error( _city.name, destCity.name, corps.name )
	end

	--print( _city:ToString("STATUS"), _city:ToString("CORPS") )
	--print( destCity:ToString("STATUS"), destCity:ToString("CORPS") )
	--InputUtil_Pause( "dispatch", corps:ToString(), "to=" .. destCity:ToString(), "from=" .. _city.name )
end

local function CanReinforceAdvancedBase()
	local corpsList = _city:GetFreeCorps()
	if #corpsList == 0 then
		--print( "no corps" )
		return false
	end

	local goalData = _group:GetGoal( GroupGoalType.DEFEND_CITY )
	if not goalData or not goalData.city then
		print( "no goal", _group:ToString( "GOAL" ) )
		return false
	end

	if goalData.city == _city then
		return false
	end

	_registers["ACTOR"] = Random_GetListItem( corpsList )
	_registers["CORPS"] = _registers["ACTOR"]
	_registers["TARGET_CITY"] = goalData.city

	--InputUtil_Pause( "reinforce military base", _registers["TARGET_CITY"].name, _registers["CORPS"].name )

	return true
end

local function CanCorpsBack2Capital()
	if not _proposer:IsGroupLeader() then
		return false
	end

	local corps = Asset_Get( _proposer, CharaAssetID.CORPS )
	if not corps then
		return false
	end
	if not corps:IsAtHome() or corps:IsBusy() then
		return false
	end

	local capital = Asset_Get( _group, GroupAssetID.CAPITAL )
	if not capital then
		return false
	end

	if capital == Asset_Get( corps, CorpsAssetID.ENCAMPMENT ) then
		return false
	end

	_registers["ACTOR"] = corps
	_registers["CORPS"] = _registers["ACTOR"]
	_registers["TARGET_CITY"] = capital

	--InputUtil_Pause( "corps=" .. corps:ToString() .. " back to capital" .. capital:ToString() )

	return true
end

local function CanDispatchCorps()
	--if _city:IsCapital() == false then return false end	

	local corpsList = _city:GetFreeCorps()
	local numOfCorps = #corpsList
	if numOfCorps == 0 then
		return false
	end

	local reqCorps = Corps_GetRequiredByCity( _city )
	if numOfCorps <= reqCorps then
		return false
	end

	local score = 100
	if Asset_GetDictItem( _city, CityAssetID.STATUSES, CityStatus.BATTLEFRONT ) == true then
		score = score - 50
	end
	if Asset_GetDictItem( _city, CityAssetID.STATUSES, CityStatus.FRONTIER ) == true then
		score = score - 30
	end
	if Asset_GetDictItem( _city, CityAssetID.STATUSES, CityStatus.DEFENSIVE_DANGER ) == true then
		score = score - 40
	end
	if Asset_GetDictItem( _city, CityAssetID.STATUSES, CityStatus.DEFENSIVE_WEAK ) == true then
		score = score - 20
	end

	local cityList = {}
	Asset_Foreach( _group, GroupAssetID.CITY_LIST, function ( city )
		if city == _city then return end
		if NeedCorps( city, score ) == false then return end
		table.insert( cityList, city )
	end)
	if #cityList == 0 then
		return false
	end

	local corps    = Random_GetListItem( corpsList )
	local destCity = Random_GetListItem( cityList )
	_registers["ACTOR"] = corps
	_registers["CORPS"] = _registers["ACTOR"]
	_registers["TARGET_CITY"] = destCity

	if destCity == Asset_Get( corps, CorpsAssetID.LOCATION ) then
		DBG_Error( _city.name, destCity.name, corps.name )
	end

	--print( _city:ToString("STATUS"), _city:ToString("CORPS") )
	--print( destCity:ToString("STATUS"), destCity:ToString("CORPS") )
	--InputUtil_Pause( "dispatch", corps:ToString(), "to=" .. destCity:ToString(), "from=" .. _city.name .. "+" .. numOfCorps )

	return true
end

----------------------------------------

local function CanBuildConstruction( fn )
	if _actor:IsBusy() then return false end

	local area = _city:GetMaxBulidArea()
	local has = Asset_GetListSize( _city, CityAssetID.CONSTR_LIST )
	if has >= area then
		--print( _city.name, "no area" )
		return false
	end

	local list = Asset_GetList( _city, CityAssetID.CONSTRTABLE_LIST )
	if #list == 0 then
		return false
	end

	local constrList
	if not fn then
		constrList = list
	else
		for _, constr in pairs( list ) do
			if fn( constr ) == true then
				table.insert( constrList, constr )
			end
		end
		if #constrList == 0 then
			DBG_Error( "no fit constr ha~")
			return false
		end
	end

	local constr = Random_GetListItem( constrList )
	_registers["CONSTRUCTION"] = constr

	--InputUtil_Pause( "build", constr.name )

	return true
end

local function CanBuildDefensive()
	return CanBuildConstruction( function ( constr )
		return constr.type == CityConstructionType.DEFENSIVE
	end )
end

local function CanBuildCity()
	return CanBuildConstruction()
end

function NeedLevyTax( score )
	if not score then score = 0 end
	local security = Asset_Get( _city, CityAssetID.SECURITY )
	if security > 80 then
		score = score + 20
	elseif security > 60 then
		score = score + 10
	elseif security < 30 then
		score = score - 20
	elseif security < 40 then
		score = score - 10
	end
	local money = Asset_Get( _city, CityAssetID.MONEY )
	--if money < then 	end
	return Random_GetInt_Sync( 1, 100 ) < score
end

local function ShouldLevyTax()
	if City_IsBudgetSafe( _city, { safetyMonth = MONTH_IN_SEASON } ) then
		return false
	end
	return true
end

local function CanSellFood()
	if _city:GetStatus( CityStatus.IN_SIEGE ) then
		return false
	end
	--check	mobile-merchant or trade market
	if not _city:GetStatus( CityStatus.MOBILE_MERCHANT ) and not _city:GetConstructionByEffect( CityConstrEffect.TRADE ) then
		return false
	end

	local month = MONTH_IN_HALFYEAR
	if not City_IsFoodBudgetSafe( _city, { safetyMonth = month } ) or City_IsMoneyBudgetSafe( _city, { safetyMonth = month } ) then
		return false
	end

	--InputUtil_Pause( "SELLFOOD", _city:ToString( "ASSET" ) )
	return true
end

local function CanBuyFood()
	if _city:GetStatus( CityStatus.IN_SIEGE ) then
		return false
	end	
	--check	mobile-merchant or trade market
	if not _city:GetStatus( CityStatus.MOBILE_MERCHANT ) and not _city:GetConstructionByEffect( CityConstrEffect.TRADE ) then
		return false
	end

	local month = MONTH_IN_HALFYEAR
	if City_IsFoodBudgetSafe( _city, { safetyMonth = month } ) or not City_IsMoneyBudgetSafe( _city, { safetyMonth = month } ) then
		return false
	end

	--InputUtil_Pause( "BUYFOOD", _city:ToString( "CONSTRUCTION" ) )
	return true
end

local function CanTransport()
	if _actor:IsBusy() then return false end

	--has enough corvee to do this job
	if _city:GetPopu( CityPopu.CORVEE ) < Scenario_GetData( "TROOP_PARAMS" ).MIN_TROOP_SOLDIER then		
		print( _city.name, "not enough corvee")
		return false
	end

	--has enough food/moeny for self
	if _city:GetStatus( CityStatus.BUDGET_DANGER ) then
		print( _city:ToString("ASSET"), "budget danger")
		return false
	end

	if not _city:GetStatus( CityStatus.PRODUCTION_BASE ) then		
		--print( _city.name, "no production")
		return false
	end

	--print( "2 trans" )

	--find advanced base
	local cityList = {}
	Asset_Foreach( _group, GroupAssetID.CITY_LIST, function ( city )
		if _city == city then return end
		if not city:GetStatus( CityStatus.ADVANCED_BASE ) 
			and city:GetStatus( CityStatus.BATTLEFRONT ) then
			return
		end
		table.insert( cityList, city )
	end )

	if #cityList <= 0 then
		return false
	end

	local city = Random_GetListItem( cityList )

	_registers["TARGET_CITY"] = city

	return true
end

local function CanHireChara()
	if _actor:IsBusy() then return false end

	local limit
	if _city then		
		local groupHas = Asset_GetListSize( _group, GroupAssetID.CHARA_LIST )
		limit = Chara_GetLimitByGroup( _group )
		if limit > 0 and limit <= groupHas then
			--Debug_Log( "groupchara limit=" .. groupHas .. "/" .. limit )
			return false
		end

		local cityHas  = Asset_GetListSize( _city, CityAssetID.CHARA_LIST )
		if cityHas > Chara_GetReqNumOfOfficer( _city ) then
			--Debug_Log( "citychara limit=" .. cityHas .. "/" .. limit )
			return false
		end
		--print( _city.name, "has="..has, "lim=" .. limit )
	end
	return true
end
local function CanPromoteChara()	
	local title = Chara_FindNewTitle( _proposer )
	if title then
		_registers["TITLE"] = title
		_registers["ACTOR"] = _proposer
		--print( "promote=" .. title.name, _proposer:ToString("TITLE") )
		return true
	end
	return false
end

local function CanDispatchChara()
	--only disptch chara from capital( for extension, we can dispatch chara from vassal's capital )
	if _city:IsCapital() == false then return false end

	local charaList = _city:FindNonOfficerFreeCharas()
	if #charaList == 0 then return false end

	--print( _city.name, "check disp chara", g_Time:ToString(), "city=" .. Asset_GetListSize( _group, GroupAssetID.CITY_LIST ) )

	local cityList = _group:GetVacancyCityList( _city )
	if #cityList == 0 then	return false end

	--simply random
	local city  = Random_GetListItem( cityList )	
	local chara = Random_GetListItem( charaList )

	_registers["TARGET_CITY"] = city
	_registers["ACTOR"]       = chara

	if Asset_Get( chara, CharaAssetID.LOCATION ) == city then DBG_Error( "why here" ) end

	if Asset_Get( chara, CharaAssetID.CORPS ) then error( "why") end
	--if city.id == 2 then InputUtil_Pause( "dispatch2city", _city:ToString("CHARAS"), city:ToString("CHARAS"), chara.name ) end

	return true
end

local function CanMoveCapital()
	local leader  = Asset_Get( _group, GroupAssetID.LEADER )
	if _proposer ~= leader then
		--only leader can submit move capital
		return false
	end

	local capital = Asset_Get( _group, GroupAssetID.CAPITAL )	
	local city    = Asset_Get( leader, CharaAssetID.HOME )	
	if city == capital then
		return false
	end

	--move to battlefront
	local targetCity
	if not targetCity and _group:HasGoal( GroupGoalType.OCCUPY_CITY ) then
		local goalData = _group:GetGoal( GroupGoalType.OCCUPY_CITY )
		local list = goalData.city:FindNearbyEnemyCities()
		targetCity = Random_GetListItem( list )
	end
	if not targetCity and _group:HasGoal( GroupGoalType.DEFEND_CITY ) then
		local goalData = _group:GetGoal( GroupGoalType.DEFEND_CITY )
		targetCity = goalData.city
	end
	if not targetCity and _proposer:GetTrait( CharaTraitType.AGGRESSIVE ) then
		local list = _group:GetStatusCityList( CityStatus.BATTLEFRONT )
		targetCity = Random_GetListItem( list )
	end

	--move to the biggest city
	if not targetCity and _proposer:GetTrait( CharaTraitType.CONSERVATIVE ) then
		local curLv = Asset_Get( capital, CityAssetID.LEVEL )
		Asset_Foreach( _group, GroupAssetID.CITY_LIST, function ( city )
			local lv = Asset_Get( city, CityAssetID.LEVEL )
			if curLv < lv then
				targetCity = city
				curLv      = lv
			end
		end )
	end

	if not targetCity or capital == targetCity then
		return false
	end

	_registers["TARGET_CITY"] = targetCity

	return true
end

local function CanCharaBack2Capital()
	if not _proposer:IsGroupLeader() then return false end

	local chara = _proposer
	if chara:IsBusy() then return false end

	if Asset_Get( chara, CharaAssetID.CORPS ) then return false end

	local capital = Asset_Get( _group, GroupAssetID.CAPITAL )
	if capital == _city then return false end

	if Asset_Get( chara, CharaAssetID.HOME ) == capital then return false end

	_registers["TARGET_CITY"] = capital
	_registers["ACTOR"]       = chara

	--sanity checker
	if Asset_Get( chara, CharaAssetID.LOCATION ) == capital then DBG_Error( "why here" ) end

	--InputUtil_Pause( "leader=" .. chara:ToString() .. " back to capital" .. capital:ToString() )

	return true
end

function CanCallChara()
	local destCity = _city

	--only call chara to capital
	if destCity:IsCapital() == false then
		return false
	end

	--check
	local numOfChara = Asset_GetListSize( _city, CityAssetID.CHARA_LIST )
	if numOfChara > Chara_GetReqNumOfOfficer( _city ) then
		return false
	end

	--find city which can dispatch chara to the capital
	local charaList = {}
	Asset_Foreach( _group, GroupAssetID.CITY_LIST, function ( city )
		if city == destCity then return end
		local num = Asset_GetListSize( city, CityAssetID.OFFICER_LIST )
		if num > city:GetNumOfOfficerSlot() then
			charaList = city:FindNonOfficerFreeCharas( charaList, function ( chara )
				--no cmd
				if Cmd_Query( chara ) then return false end
				--no corps
				if Asset_Get( chara, CharaAssetID.CORPS ) then return false end
			end )
		end
	end)

	if #charaList == 0 then
		return false
	end

	local chara = Random_GetListItem( charaList )
	
	--sanity check
	if Asset_Get( chara, CharaAssetID.LOCATION ) == destCity then
		--for _, chara in ipairs( charaList ) do print( chara.name, Asset_Get( chara, CharaAssetID.LOCATION ):ToString() ) end
		DBG_Error( "why here", city:ToString() )
	end

	_registers["TARGET_CITY"] = destCity
	_registers["ACTOR"]       = chara

	return true
end

local function CanDevelop( params )
	if _actor:IsBusy() then return false end

	local score = 0
	local ratio

	local tax      = City_GetMonthTax( _city, g_Time:GetMonth( 1 ) )
	local salary   = _city:GetSalary()
	local cost     = _city:GetDevelopCost()
	local hasMoney = Asset_Get( _city, CityAssetID.MONEY )
	local totalHas = tax + hasMoney
	local totalUse = cost + salary
	
	ratio = totalHas * 100 / totalUse
	if ratio < 1 then
		return false
	end

	local item

	local feeScores = 
	{
		{ ratio = 110, score = -10 },
		{ ratio = 120, score = 0   },
		{ ratio = 150, score = 20  },
	}
	item = MathUtil_Approximate( ratio, feeScores, "ratio", true )
	score = score + item.score
	
	ratio = _city:GetDevelopScore( params.assetId )
	local devScores = 
	{
		{ ratio = 40,   score = 100 },
		{ ratio = 50,   score = 80 },
		{ ratio = 60,   score = 60 },
		{ ratio = 70,   score = 40 },
		{ ratio = 80,   score = 30 },
		{ ratio = 90,   score = 20 },
	}
	item = MathUtil_Approximate( ratio, devScores, "ratio", true )
	score = score + item.score

	if Random_GetInt_Sync( 1, 100 ) < score then
		return true 
	end

	--InputUtil_Pause( "dev", score, totalHas / totalUse, ratio )

	return false
end

local function CanResearch()
	if _actor:IsBusy() then return false end

	if _city:IsCapital() == false then return false end

	if Asset_Get( _city, CityAssetID.RESEARCH ) ~= nil then return false end
	
	if _proposer:IsGroupLeader() == false and not _city:IsCharaOfficer( CityJob.TECHNICIAN, _proposer ) then
		return false
	end

	local techList = {}
	local techData = Scenario_GetData( "TECH_DATA" )
	for _, tech in pairs( techData ) do
		local valid = true
		if tech.prerequisite then
			if valid == true and tech.prerequisite.tech then
				for _, id in ipairs( tech.prerequisite.tech ) do
					if _group:HasTech( id ) == false then valid = false break end
				end
			end
		end
		if valid == true then
			table.insert( techList, tech )
		end
	end

	if #techList == 0 then return false end

	--print( "resear", g_Time:CreateCurrentDateDesc(), _city.name, _proposer.name )

	local tech = techList[Random_GetInt_Sync( 1, #techList )]
	_registers["TARGET_TECH"] = tech

	return true
end

------------------------------

local function CanReconnoitre()
	if _actor:IsBusy() then return false end

	--whether to reconnoitre
	local list = {}
	Asset_Foreach( _city, CityAssetID.SPY_LIST, function( spy )
		if spy.grade <= CitySpyParams.MAX_GRADE then
			table.insert( list, spy )
		end
	end )
	if #list == 0 then return false end

	local desc = ""
	for _, spy in ipairs( list ) do
		desc = desc .. " " .. spy.city.name
	end

	local index = Random_GetInt_Sync( 1, #list, desc )
	local spy   = list[index]
	_registers["TARGET_CITY"] = spy.city

	return true
end

local function CanSabotage()
	if _actor:IsBusy() then return false end

	local destCity
	local group = Asset_Get( _city, CityAssetID.GROUP )
	local goal = _group:GetGoal( GroupGoalType.OCCUPY_CITY )
	
	if goal then
		destCity = goal.city
		if destCity == _city then return false end

	else
		local list = {}
		Asset_Foreach( _city, CityAssetID.SPY_LIST, function( spy )
			if _city:IsEnemeyCity( spy.city ) == false then return end
			if spy.grade < CitySpyParams.REQ_GRADE then return end
			table.insert( list, spy )
		end )
		if #list == 0 then return false end

		local index = Random_GetInt_Sync( 1, #list )
		destCity = list[index].city
	end
	_registers["TARGET_CITY"] = destCity

	return true
end

local function CanDestoryDefensive()
	if _actor:IsBusy() then return false end

	local destCity
	local group = Asset_Get( _city, CityAssetID.GROUP )
	local goal = _group:GetGoal( GroupGoalType.OCCUPY_CITY )
	
	if goal then
		destCity = goal.city
		if destCity == _city then return false end	

	else
		local list = {}
		Asset_Foreach( _city, CityAssetID.SPY_LIST, function( spy )
			if _city:IsEnemeyCity( spy.city ) == false then return end
			if spy.grade < CitySpyParams.REQ_GRADE then return end
			if Asset_FindItem( spy.city, CityAssetID.CONSTR_LIST, function ( constr, index )
				--if constr.type == "DEFENSIVE" then
					return true
				--end
			end ) then
				table.insert( list, spy )
			end
		end )
		if #list == 0 then return false end

		local index = Random_GetInt_Sync( 1, #list )
		destCity = list[index].city
	end

	if not destCity then return false end

	_registers["TARGET_CITY"] = destCity

	return true
end

local function CanAssassinate()
	if _actor:IsBusy() then return false end

	local assassinate = _actor:GetEffectValue( CharaSkillEffect.ASSASSINATE )
	if assassinate < 0 then return false end

	local curLv = Asset_Get( _actor, CharaAssetID.LEVEL )

	local list = {}
	Asset_Foreach( _city, CityAssetID.SPY_LIST, function( spy )
		if _city:IsEnemeyCity( spy.city ) == false then return end
		--if spy.grade < CitySpyParams.REQ_GRADE then return end
		Asset_Foreach( spy.city, CityAssetID.CHARA_LIST, function ( chara )
			local lv = Asset_Get( chara, CharaAssetID.LEVEL )
			--level
			if curLv <= lv then return end
			--nojob
			if spy.city:GetCharaJob( chara ) ~= CityJob.NONE then return end			
			table.insert( list, { city = spy.city, target = chara } )
		end)
	end )
	if #list == 0 then return false end

	local index = Random_GetInt_Sync( 1, #list )
	_registers["TARGET_CITY"] = list[index].city
	_registers["TARGET_CHARA"] = list[index].target

	 return true
end

local function DetermineDefendGoal( ... )
	local goalData = _group:GetGoal( GroupGoalType.DEFEND_CITY )
	if not goalData or not goalData then
		return false
	end

	local baseList = {}
	Asset_Foreach( _group, GroupAssetID.CITY_LIST, function ( city )
		--print( city:ToString( "STATUS" ) )
		--InputUtil_Pause( city.name, goalData.city.name )
		if goalData.city == city then
			table.insert( baseList, { city = city, type = CityStatus.ADVANCED_BASE } )
		
		elseif city:GetStatus( CityStatus.SAFETY ) then
			--where support the advanced base
			if city:IsAdjaCity( goalData.city ) then
				table.insert( baseList, { city = city, type = CityStatus.MILITARY_BASE } )
			elseif city:GetStatus( CityStatus.SAFETY ) then
				table.insert( baseList, { city = city, type = CityStatus.PRODUCTION_BASE } )
			end

		else
			table.insert( baseList, { city = city, type = nil } )
		end
	end)

	_registers["INSTRUCT_CITY_LIST"] = baseList

	return true	
end

local function DetermineEnhanceGoal( ... )
	local goalData = _group:GetGoal( GroupGoalType.ENHANCE_CITY )
	if not goalData or not goalData then
		return false
	end

	local baseList = {}
	Asset_Foreach( _group, GroupAssetID.CITY_LIST, function ( city )
		if goalData.city == city then
			table.insert( baseList, { city = city, type = CityStatus.MILITARY_BASE } )

		elseif city:GetStatus( CityStatus.SAFETY ) then
			table.insert( baseList, { city = city, type = CityStatus.PRODUCTION_BASE } )

		else
			table.insert( baseList, { city = city, type = nil } )
		end		
	end)

	_registers["INSTRUCT_CITY_LIST"] = baseList

	return true
end


local function DetermineDevelopGoal( ... )
	local goalData = _group:GetGoal( GroupGoalType.DEVELOP_CITY )
	if not goalData or not goalData then
		return false
	end

	local baseList = {}
	Asset_Foreach( _group, GroupAssetID.CITY_LIST, function ( city )
		if goalData.city == city then
			table.insert( baseList, { city = city, type = CityStatus.PRODUCTION_BASE } )

		elseif city:GetStatus( CityStatus.SAFETY ) then
			table.insert( baseList, { city = city, type = CityStatus.PRODUCTION_BASE } )
		
		else
			table.insert( baseList, { city = city, type = nil } )
		end
	end)

	_registers["INSTRUCT_CITY_LIST"] = baseList

	return true
end

local function DetermineOccupyGoal( ... )
	local goalData = _group:GetGoal( GroupGoalType.OCCUPY_CITY )
	if not goalData or not goalData.city then
		return false
	end

	local baseList = {}	
	local cityList = {}

	--set advanced base
	local advanceBase = Asset_FindItem( goalData.city, CityAssetID.ADJACENTS, function ( adjaCity )
		if Asset_Get( adjaCity, CityAssetID.GROUP ) ~= _group then
			return
		end
		if adjaCity:GetStatus( CityStatus.ADVANCED_BASE ) then
			return true
		end
		table.insert( cityList, adjaCity )
		return false
	end )
	if not advanceBase and #cityList > 0 then
		advanceBase = Random_GetListItem( cityList )
		table.insert( baseList, { city = advanceBase, type = CityStatus.ADVANCED_BASE } )
	end

	--for all city, determine what kind of base they are.
	--basically, battlefront is none, safety is production, frontier is military
	cityList = {}
	Asset_Foreach( _group, GroupAssetID.CITY_LIST, function ( city )
		if city == goalData.city then return end

		if city:GetStatus( CityStatus.SAFETY ) then
			table.insert( baseList, { city = city, type = CityStatus.PRODUCTION_BASE } )
		
		elseif city:GetStatus( CityStatus.BATTLEFRONT ) then
			table.insert( baseList, { city = city, type = CityStatus.MILITARY_BASE } )
		
		elseif city:GetStatus( CityStatus.FRONTIER ) then
			table.insert( baseList, { city = city, type = nil } )
		
		else
			table.insert( baseList, { city = city, type = nil } )	
		end
	end)

	_registers["INSTRUCT_CITY_LIST"] = baseList	

	return true
end

local function CanImproveRelation()
	if _actor:IsBusy() then return false end

	--1. self isn't at war
	--2. target isn't at war
	if Dipl_IsAtWar( _group ) == true then return false end	

	--only group leader or diplomatic can execute the task
	if _proposer:IsGroupLeader() == false and not _city:IsCharaOfficer( CityJob.DIPLOMATIC, _proposer ) then return false end

	local list = Dipl_GetRelations( _group )
	if not list then return false end
	local groupList = {}
	for _, relation in pairs( list ) do
		local opp = relation:GetOppGroup( _group )
		if Dipl_IsAtWar( opp ) == false then
			table.insert( groupList, opp )
		end
	end
	if #groupList == 0 then return false end

	local target = Random_GetListItem( groupList )
	_registers["TARGET_GROUP"] = target

	--InputUtil_Pause( "find dip target" )

	return true
end

local function CanDeclareWar()
	if _actor:IsBusy() then return false end

	local list = Dipl_GetRelations( _group )
	if not list then return false end
	local groupList = {}
	for _, relation in pairs( list ) do
		if Dipl_CanDeclareWar( relation, _group ) == true then
			local opp = relation:GetOppGroup( _group )
			table.insert( groupList, opp )
		end
	end
	if #groupList == 0 then return false end

	local target = Random_GetListItem( groupList )
	_registers["TARGET_GROUP"] = target

	--InputUtil_Pause( "find dip target" )
end

local function CanSignPact()
	if _actor:IsBusy() then return false end

	local list = Dipl_GetRelations( _group )
	if not list then return  false end	

	local pactList = {}
	for _, relation in pairs( list ) do
		Dipl_GetPossiblePact( relation, pactList )
	end
	if #pactList == 0 then return false end

	local sign     = Random_GetListItem( pactList )
	local oppGroup = relation:GetOppGroup( _group )

	--local target = Random_GetListItem( groupList )
	_registers["TARGET_GROUP"] = oppGroup
	_registers["PACT"]         = RelationPact[sign.pact]
	_registers["TIME"]         = sign.time

	--InputUtil_Pause( "find pact", MathUtil_FindName( RelationPact, RelationPact[pact] ), oppGroup:ToString() )

	return true
end

------------------------------

local function CanImproveGroupGrade()
	local grade = Asset_Get( _group, GroupAssetID.GRADE )
	local fitGrade = Group_FindFitGrade( _group )
	if grade >= fitGrade then return false end

	_registers["GRADE"] = fitGrade

	return true
end

------------------------------

local function DetermineGoal()
	local goals = {}
	local totalProb = 0

	local devScore   = _city:GetDevelopScore()
	local soldier    = _city:GetSoldier()
	local incScore
	local incSoldier

	function AddGoal( goalType, prob )
		if goals[goalType] then
			goals[goalType] = goals[goalType] + prob
		else
			goals[goalType] = prob			
		end
		totalProb = totalProb + prob
	end

	local trait
	
	trait = _proposer:GetTrait( CharaTraitType.AGGRESSIVE )
	if trait then AddGoal( GroupGoalType.OCCUPY_CITY, trait ) end

	trait = _proposer:GetTrait( CharaTraitType.CONSERVATIVE )
	if trait then AddGoal( GroupGoalType.OCCUPY_CITY, trait ) end

	AddGoal( GroupGoalType.OCCUPY_CITY, 50 )

	local job = _city:GetCharaJob( _proposer )		
	if job == CityJob.COMMANDER then
		AddGoal( GroupGoalType.OCCUPY_CITY,  100 )
	
	elseif job == CityJob.STAFF then
		AddGoal( GroupGoalType.ENHANCE_CITY, 50 )
	
	elseif job == CityJob.HR then
	
	elseif job == CityJob.OFFICIAL then
		AddGoal( GroupGoalType.DEVELOP_CITY, 100 )
	
	elseif job == CityJob.DIPLOMATIC then
		AddGoal( GroupGoalType.DEFEND_CITY, 50 )
	
	elseif job == CityJob.TECHNICIAN then
		AddGoal( GroupGoalType.DEVELOP_CITY, 50 )
	
	elseif job == CityJob.EXECUTIVE then
		AddGoal( GroupGoalType.ENHANCE_CITY, 50 )
		AddGoal( GroupGoalType.DEFEND_CITY, 50 )
	end

	--choice one
	--print( "totalProb =", totalProb )

	--MathUtil_Dump( goals )

	local findGoalType
	local prob = Random_GetInt_Sync( 1, totalProb )
	for goalType, goalProb in pairs( goals ) do
		if prob <= goalProb then
			findGoalType = goalType
			break
		else
			prob = prob - goalProb
		end
	end

	if not findGoalType then
		return false
	end

	local goalData = {}
	goalData.time = DAY_IN_YEAR

	if findGoalType == GroupGoalType.OCCUPY_CITY then
		local cityList = {}
		Asset_Foreach( _group, GroupAssetID.CITY_LIST, function ( city )
			if not city:GetStatus( CityStatus.BATTLEFRONT ) then
				return
			end
			Asset_Foreach( city, CityAssetID.ADJACENTS, function ( adjaCity )
				if city:IsEnemeyCity( adjaCity ) then
					table.insert( cityList, adjaCity )
				end
			end)
		end)
		if #cityList > 0 then
			goalData.city = Random_GetListItem( cityList )
		else
			findGoalType = GroupGoalType.DEFEND_CITY
		end
	end

	if findGoalType == GroupGoalType.DEFEND_CITY then
		local cityList = {}
		Asset_Foreach( _group, GroupAssetID.CITY_LIST, function ( city )
			if city:GetStatus( CityStatus.BATTLEFRONT ) == true then
				table.insert( cityList, city )
			end
		end)
		if #cityList > 0 then
			goalData.city = Random_GetListItem( cityList )
		else
			findGoalType = GroupGoalType.DEVELOP_CITY
		end
	end
	
	if findGoalType == GroupGoalType.ENHANCE_CITY then
		local cityList = {}
		local minSoldier = Scenario_GetData( "TROOP_PARAMS" ).MIN_TROOP_SOLDIER
		Asset_Foreach( _group, GroupAssetID.CITY_LIST, function ( city )
			--print( "enhance", city:GetPopu( CityPopu.RESERVES ), minSoldier )
			if city:GetStatus( CityStatus.FRONTIER ) == true or city:GetStatus( CityStatus.BATTLEFRONT ) == true then
				table.insert( cityList, city )
			end
		end )
		if #cityList > 0 then
			goalData.city    = Random_GetListItem( cityList )
			goalData.soldier = soldier + goalData.city:GetPopu( CityPopu.RESERVES )
			--InputUtil_Pause( "find enhance CITY", goalData.city.name, goalData.soldier )
		else
			findGoalType = GroupGoalType.DEVELOP_CITY
		end
	end

	local devTargets = 
	{
		{ dev = 100, target = 10 },
		{ dev = 150, target = 8 },
		{ dev = 200, target = 5 },
		{ dev = 240, target = 3 },
		{ dev = 270, target = 0 },
		{ dev = 300, target = 0 },
	}
	if findGoalType == GroupGoalType.DEVELOP_CITY then
		local cityList = {}
		Asset_Foreach( _group, GroupAssetID.CITY_LIST, function ( city )
			local developScore = city:GetDevelopScore()
			local item = MathUtil_Approximate( developScore, devTargets, "dev", true )
			if item.target > 0 then
				table.insert( cityList, { city = city, target = item.target } )
			end
		end )
		if #cityList > 0 then
			local item = Random_GetListItem( cityList )
			goalData.city     = item.city
			goalData.devScore = devScore + item.target
		else
			findGoalType = nil
		end
	end

	if not findGoalType then
		--InputUtil_Pause( "none goal" )
		return false
	end

	goalData.time = DAY_IN_YEAR
	--print( "goal", MathUtil_FindName( GroupGoalType, findGoalType ), goalData )
	
	_registers["GOALTYPE"] = findGoalType
	_registers["GOALDATA"] = goalData

	return true
end

------------------------------
-- AI

local LeadCorpsProposal = 
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CheckProposer, params = { type = "LEAD_CORPS" } },
		{ type = "FILTER", condition = CanLeadCorps },		
		{ type = "ACTION", action = SubmitProposal, params = { type = "LEAD_CORPS" } },
	},
}

local EstablishCorpsProposal = 
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CheckProposer, params = { type = "ESTABLISH_CORPS" } },
		{ type = "FILTER", condition = CanEstablishCorps },		
		{ type = "ACTION", action = SubmitProposal, params = { type = "ESTABLISH_CORPS" } },
	},
}

local ReinforceProposal = 
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CheckProposer, params = { type = "REINFORCE_CORPS" } },
		{ type = "FILTER", condition = CanReinforceCorps },		
		{ type = "ACTION", action = SubmitProposal, params = { type = "REINFORCE_CORPS" } },
	},
}

local EnrollProposal = 
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CheckProposer, params = { type = "ENROLL_CORPS" } },
		{ type = "FILTER", condition = CanEnrollCorps },
		{ type = "ACTION", action = SubmitProposal, params = { type = "ENROLL_CORPS" } },
	},
}

local TrainProposal = 
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CheckProposer, params = { type = "TRAIN_CORPS" } },
		{ type = "FILTER", condition = CanTrainCorps },
		{ type = "ACTION", action = SubmitProposal, params = { type = "TRAIN_CORPS" } },
	},
}

local RegroupProposal =
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CheckProposer, params = { type = "REGROUP_CORPS" } },
		{ type = "FILTER", condition = CanRegroupCorps },
		{ type = "ACTION", action = SubmitProposal, params = { type = "REGROUP_CORPS" } },
	},	
}

local EnhanceMilitaryBaseProposal =
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CheckProposer, params = { type = "DISPATCH_CORPS" } },
		{ type = "FILTER", condition = CanEnhanceMilitaryBase },
		{ type = "ACTION", action = SubmitProposal, params = { type = "DISPATCH_CORPS" } },
	},
}

local DispatchCorpsProposal =
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CheckProposer, params = { type = "DISPATCH_CORPS" } },
		{ type = "SELECTOR", children = 
			{
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = HasCityStatus, params = { status = "MILITARY_BASE" } },
						{ type = "FILTER", condition = HasGroupGoal, params = { goal = "DEFEND_CITY", excludeCity = true } },						
						{ type = "FILTER", condition = CanReinforceAdvancedBase },						
						{ type = "ACTION", action = SubmitProposal, params = { type = "DISPATCH_CORPS" } },
					}
				},
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = CanCorpsBack2Capital },
						{ type = "ACTION", action = SubmitProposal, params = { type = "DISPATCH_CORPS" } },
					}
				},
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = CanDispatchCorps },
						{ type = "ACTION", action = SubmitProposal, params = { type = "DISPATCH_CORPS" } },
					}
				},
			},
		}
	},
}

--Conscript will establish troop immediately, mostly conscript militia/reserves that can be upgrade into 
local ConscriptProposal =
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CheckProposer, params = { type = "CONSCRIPT" } },
		{ type = "FILTER", condition = CanConscript },
		{ type = "ACTION", action = SubmitProposal, params = { type = "CONSCRIPT" } },
	},
}

local RecruitProposal = 
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CheckProposer, params = { type = "RECRUIT" } },
		{ type = "FILTER", condition = CanRecruit },
		{ type = "ACTION", action = SubmitProposal, params = { type = "RECRUIT" } },
	},
}

local HireGuardProposal = 
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CheckProposer, params = { type = "HIRE_GUARD" } },
		{ type = "FILTER", condition = CanHireGuard },
		{ type = "ACTION", action = SubmitProposal, params = { type = "HIRE_GUARD" } },
	},
}

local _BuildProposal = 
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CheckProposer, params = { type = "BUILD_CITY" } },
		{ type = "FILTER", condition = CanBuildCity },
		{ type = "ACTION", action = SubmitProposal, params = { type = "BUILD_CITY" } },
	},
}

local _BuildDefensiveProposal = 
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CheckProposer, params = { type = "BUILD_CITY" } },
		{ type = "FILTER", condition = CanBuildDefensive },
		{ type = "ACTION", action = SubmitProposal, params = { type = "BUILD_CITY" } },
	},	
}

local _TransportProposal = 
{
	type = "SEQUENCE", children = 
	{		
		{ type = "FILTER", condition = CheckProposer, params = { type = "TRANSPORT" } },
		{ type = "FILTER", condition = CanTransport },
		{ type = "ACTION", action = SubmitProposal, params = { type = "TRANSPORT" } },
	},
}

local _TaxProposal =
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CheckProposer, params = { type = "LEVY_TAX" } },
		{ type = "FILTER", condition = ShouldLevyTax },
		{ type = "ACTION", action = SubmitProposal, params = { type = "LEVY_TAX" } },
	},
}

local _FoodProposal = 
{
	type = "SELECTOR", children =
	{
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = CheckProposer, params = { type = "SELL_FOOD" } },
				{ type = "FILTER", condition = CanSellFood },
				{ type = "ACTION", action = SubmitProposal, params = { type = "SELL_FOOD" } },
			},
		},
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = CheckProposer, params = { type = "BUY_FOOD" } },
				{ type = "FILTER", condition = CanBuyFood },
				{ type = "ACTION", action = SubmitProposal, params = { type = "BUY_FOOD" } },
			},
		},
	}
}

local _DevelopProposal = 
{
	type = "SELECTOR", children =
	{
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = CheckProposer, params = { type = "DEV_AGRICULTURE" } },
				{ type = "FILTER", condition = CanDevelop, params = { assetId = CityAssetID.AGRICULTURE } },
				{ type = "ACTION", action = SubmitProposal, params = { type = "DEV_AGRICULTURE" } },
			},
		},
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = CheckProposer, params = { type = "DEV_COMMERCE" } },
				{ type = "FILTER", condition = CanDevelop, params = { assetId = CityAssetID.COMMERCE } },
				{ type = "ACTION", action = SubmitProposal, params = { type = "DEV_COMMERCE" } },
			},
		},
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = CheckProposer, params = { type = "DEV_PRODUCTION" } },
				{ type = "FILTER", condition = CanDevelop, params = { assetId = CityAssetID.PRODUCTION } },
				{ type = "ACTION", action = SubmitProposal, params = { type = "DEV_PRODUCTION" } },
			},
		},
	}
}

-------------------------------------------------------

local _SubmitHRProposal =
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CanSubmitPlan, params = { topic = "HR" } },
		{ type = "RANDOM_SELECTOR", children = 
			{
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = CheckProposer, params = { type = "MOVE_CAPITAL" } },
						{ type = "FILTER", condition = CanMoveCapital },
						{ type = "ACTION", action = SubmitProposal, params = { type = "MOVE_CAPITAL" } },
					},
				},
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = CheckProposer, params = { type = "DISPATCH_CHARA" } },
						{ type = "FILTER", condition = CanCharaBack2Capital },
						{ type = "ACTION", action = SubmitProposal, params = { type = "DISPATCH_CHARA" } },
					},
				},
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = CheckProposer, params = { type = "CALL_CHARA" } },
						{ type = "FILTER", condition = CanCallChara },
						{ type = "ACTION", action = SubmitProposal, params = { type = "CALL_CHARA" } },
					},
				},
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = CheckProposer, params = { type = "DISPATCH_CHARA" } },
						{ type = "FILTER", condition = CanDispatchChara },
						{ type = "ACTION", action = SubmitProposal, params = { type = "DISPATCH_CHARA" } },
					},
				},
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = CheckProposer, params = { type = "HIRE_CHARA" } },
						{ type = "FILTER", condition = CanHireChara },
						{ type = "ACTION", action = SubmitProposal, params = { type = "HIRE_CHARA" } },
					},
				},
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = CheckProposer, params = { type = "PROMOTE_CHARA" } },
						{ type = "FILTER", condition = CanPromoteChara },
						{ type = "ACTION", action = SubmitProposal, params = { type = "PROMOTE_CHARA" } },
					},
				},
					--ENCOURGAE CHARA
					--SUPERVISE CHARA
			}
		},
	},
}

local _SubmitStaffProposal =
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CanSubmitPlan, params = { topic = "STAFF" } },	
		{ type = "RANDOM_SELECTOR", children = 
			{
				--COLLECT INTELS
				--EXECUTE OP
				--[[]]
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = CheckProposer, params = { type = "RECONNOITRE" } },
						{ type = "FILTER", condition = CanReconnoitre },
						{ type = "ACTION", action = SubmitProposal, params = { type = "RECONNOITRE" } },
					},
				},
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = CheckProposer, params = { type = "SABOTAGE" } },
						{ type = "FILTER", condition = CanSabotage },
						{ type = "ACTION", action = SubmitProposal, params = { type = "SABOTAGE" } },
					},
				},
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = CheckProposer, params = { type = "DESTROY_DEF" } },
						{ type = "FILTER", condition = CanDestoryDefensive },
						{ type = "ACTION", action = SubmitProposal, params = { type = "DESTROY_DEF" } },
					},
				},
				--]]
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = CheckProposer, params = { type = "ASSASSINATE" } },
						{ type = "FILTER", condition = CanAssassinate },
						{ type = "ACTION", action = SubmitProposal, params = { type = "ASSASSINATE" } },
					},
				},
			}
		},
	}
}

local _SubmitOfficialProposal =
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CanSubmitPlan, params = { topic = "OFFICIAL" } },				
		{ type = "SELECTOR", children = 
			{
				{ type = "SEQUENCE", children =
					{
						{ type = "FILTER", condition = CheckProbablity, params = { prob = 50 } },
						_BuildProposal,
					},
				},
				{ type = "SEQUENCE", children =
					{
						{ type = "FILTER", condition = HasCityStatus, params = { status = "PRODUCTION_BASE" } },
						_DevelopProposal,
					},
				},
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = HasCityStatus, params = { status = "PRODUCTION_BASE" } },
						{ type = "FILTER", condition = HasGroupGoal, params = { goal = "DEFEND_CITY" , excludeCity = true } },
						_TransportProposal,
					}
				},
				_FoodProposal,			
				{ type = "RANDOM_SELECTOR", children =
					{
						_FoodProposal,
						_TransportProposal,
						_DevelopProposal,
						_BuildProposal,
						_TaxProposal,
					}
				},	
			},
		},
	}
}

local _SubmitCommanderProposal =
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CanSubmitPlan, params = { topic = "COMMANDER" } },		
		{ type = "SELECTOR", children = 
			{
				--self security
				LeadCorpsProposal,
				EnrollProposal,
				ReinforceProposal,				
				DispatchCorpsProposal,
				EstablishCorpsProposal,
				--ConscriptProposal,
				RecruitProposal,
				HireGuardProposal,
				TrainProposal,
				RegroupProposal,
				EnhanceMilitaryBaseProposal,
			},
		},
	}
}

local _SubmitDiplomaticProposal =
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = IsCityCapital },
		{ type = "FILTER", condition = CanSubmitPlan, params = { topic = "DIPLOMATIC" } },
		{ type = "RANDOM_SELECTOR", children =
			{
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = CheckProposer, params = { type = "IMPROVE_RELATION" } },
						{ type = "FILTER", condition = CanImproveRelation },
						{ type = "ACTION", action = SubmitProposal, params = { type = "IMPROVE_RELATION" } },
					},
				},
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = CheckProposer, params = { type = "DECLARE_WAR" } },
						{ type = "FILTER", condition = CanDeclareWar },
						{ type = "ACTION", action = SubmitProposal, params = { type = "DECLARE_WAR" } },
					},
				},
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = CheckProposer, params = { type = "SIGN_PACT" } },
						{ type = "FILTER", condition = CanSignPact },
						{ type = "ACTION", action = SubmitProposal, params = { type = "SIGN_PACT" } },
					},
				},
			}
		},
	}
}

local _SubmitTechnicianProposal =
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CanSubmitPlan, params = { topic = "TECHNICIAN" } },
		{ type = "RANDOM_SELECTOR", children = 
			{
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = CheckProposer, params = { type = "RESEARCH" } },
						{ type = "FILTER", condition = CanResearch },
						{ type = "ACTION", action = SubmitProposal, params = { type = "RESEARCH" } },
					},
				},
			}
		},
	},
}

local _SubmitStrategyProposal =
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CanSubmitPlan, params = { topic = "STRATEGY" } },
		{ type = "FILTER", condition = CheckWarWeariness, params = { topic = "STRATEGY" } },
		{ type = "SELECTOR", children = 
			{
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = CheckProposer, params = { type = "ATTACK_CITY" } },
						{ type = "FILTER", condition = CanAttackCity },
						{ type = "ACTION", action = SubmitProposal, params = { type = "ATTACK_CITY" } },
					},
				},
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = CheckProposer, params = { type = "ATTACK_CITY" } },
						{ type = "FILTER", condition = CanExpedition },
						{ type = "ACTION", action = SubmitProposal, params = { type = "ATTACK_CITY" } },
					},
				},
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = CheckProposer, params = { type = "HARASS_CITY" } },
						{ type = "FILTER", condition = CanHarassCity },
						{ type = "ACTION", action = SubmitProposal, params = { type = "HARASS_CITY" } },
					},
				},
			},
		},
	}
}

local _QualificationChecker = 
{
	type = "SEQUENCE", children = 
	{
		--{ type = "FILTER", condition = IsProposalCD },
		{ type = "NEGATE", children = 
			{
				{ type = "FILTER", condition = IsResponsible },
			}
		},
		{ type = "FAILURE" },
	},
}

local _UnderAttackProposal =
{
	type = "SELECTOR", children = 
	{
		-----------------------------
		--under attack
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = CheckProposer, params = { type = "INTERCEPT" } },
				{ type = "FILTER", condition = IsTopic, params = { topic = "UNDER_HARASS" } },
				{ type = "FILTER", condition = CanIntercept },
				{ type = "ACTION", action = SubmitProposal, params = { type = "INTERCEPT" } },
			},
		},

		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = CheckProposer, params = { type = "INTERCEPT" } },
				{ type = "FILTER", condition = IsTopic, params = { topic = "UNDER_ATTACK" } },				
				{ type = "FILTER", condition = CanIntercept },
				{ type = "ACTION", action = SubmitProposal, params = { type = "INTERCEPT" } },
			},
		},
	}
}

local _GoalProposal = 
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CheckProposer, params = { type = "SET_GOAL" } },
		{ type = "FILTER", condition = IsCityCapital },
		{ type = "FILTER", condition = IsTopic, params = { topic = "DETERMINE_GOAL" } },
		{ type = "FILTER", condition = DetermineGoal },	
		{ type = "ACTION", action = SubmitProposal, params = { type = "SET_GOAL" } },
	},
}

local function CheckCommand()
	if not _city:IsCharaOfficer( CityJob.EXECUTIVE, _proposer ) then return false end

	local findChara = Asset_FindItem( _city, CityAssetID.CHARA_LIST, function ( chara )
		if chara:IsBusy() then return end

		local cmd = Cmd_Query( chara )
		if not cmd then return end

		if cmd.type == "MOVE_TO_CITY" then
			if Asset_Get( chara, CharaAssetID.CORPS ) then return end
			if not CheckProposer( { type = "DISPATCH_CHARA" } ) then return end
			_registers["TARGET_CITY"] = cmd.city
			_registers["ACTOR"]       = chara
			_registers["PROPOSAL"]    = "DISPATCH_CHARA"
			--print("execute cmd", g_Time:ToString(), chara:ToString("LOCATION"), cmd.city:ToString(), cmd.type )
			return true
		
		--elseif cmd.type == "" then
		end
	end )
	return findChara ~= nil
end

local _CommandProposal =
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = IsTopic, params = { topic = "COMMAND" } },
		{ type = "FILTER", condition = CheckCommand },
		{ type = "ACTION", action = SubmitProposal },
	},
}

local _PriorityProposals = 
{
	type = "SELECTOR", children = 
	{
		-----------------------------
		-- goal priority

		--startegy priority
		--build defensive in DEFEND_CITY goal	
		--receive resources
		{ type = "SELECTOR", children =
			{
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = HasCityStatus, params = { status = "ADVANCED_BASE" } },
						{ type = "FILTER", condition = HasGroupGoal, params = { goal = "DEFEND_CITY" } },
						_BuildDefensiveProposal,
					}
				},
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = HasCityStatus, params = { status = "ADVANCED_BASE" } },
						{ type = "FILTER", condition = HasGroupGoal, params = { goal = "OCCUPY_CITY", excludeCity = true } },
						_SubmitStrategyProposal,
					}
				},
			}
		},

		--official priority
		--transport resource to advanced_base
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = HasCityStatus, params = { status = "MILITARY_BASE" } },
				_SubmitCommanderProposal,
			},
		},

		--commander priority
		--dispatch corps to adanvaced_base
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = HasCityStatus, params = { status = "PRODUCTION_BASE" } },
				_SubmitOfficialProposal,
			}
		},

		-----------------------------
		-- status priority
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = HasCityStatus, params = { status = "DEFENSIVE_DANGER" } },
				_SubmitCommanderProposal,
			},
		},

		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = HasCityStatus, params = { status = "DEVELOPMENT_DANGER" } },
				_SubmitOfficialProposal,
			}
		},
	}
	-----------------------------
}

local _InstructProposal =
{
	type = "SELECTOR", children = 			
	{
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = CheckProposer, params = { type = "INSTRUCT_CITY" } },
				{ type = "FILTER", condition = DetermineOccupyGoal },
				{ type = "ACTION", action = SubmitProposal, params = { type = "INSTRUCT_CITY" } }
			}
		},
		{ type = "SEQUENCE", children = 
			{

				{ type = "FILTER", condition = CheckProposer, params = { type = "INSTRUCT_CITY" } },
				{ type = "FILTER", condition = DetermineDefendGoal },
				{ type = "ACTION", action = SubmitProposal, params = { type = "INSTRUCT_CITY" } }
			}
		},
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = CheckProposer, params = { type = "INSTRUCT_CITY" } },
				{ type = "FILTER", condition = DetermineEnhanceGoal },
				{ type = "ACTION", action = SubmitProposal, params = { type = "INSTRUCT_CITY" } }
			}
		},
		{ type = "SEQUENCE", children = 
			{

				{ type = "FILTER", condition = CheckProposer, params = { type = "INSTRUCT_CITY" } },
				{ type = "FILTER", condition = DetermineDevelopGoal },
				{ type = "ACTION", action = SubmitProposal, params = { type = "INSTRUCT_CITY" } }
			}
		},
	},
}

local _GroupGradePropsal = 
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = CheckProposer, params = { type = "IMPROVE_GRADE" } },
		{ type = "FILTER", condition = IsCityCapital },
		{ type = "FILTER", condition = IsGroupLeader },
		{ type = "FILTER", condition = IsTopic, params = { topic = "CAPITAL" } },
		{ type = "FILTER", condition = CanImproveGroupGrade },	
		{ type = "ACTION", action = SubmitProposal, params = { type = "IMPROVE_GRADE" } },
	},	
}

local _CapitalProposal =
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = IsTopic, params = { topic = "CAPITAL" } },
		--{ type = "FILTER", condition = CheckDate, params = { day="1" } },		
		_InstructProposal,
		_GroupGradePropsal,
	}
}

--Main entrance to submit proposal
local _MeetingProposal = 
{
	type = "SELECTOR", desc = "entrance", children = 
	{
		_QualificationChecker,
		_UnderAttackProposal,
		_GoalProposal,
		_CapitalProposal,

		_CommandProposal,
		--_PriorityProposals,

		--Test
		--_SubmitOfficialProposal,

		--default
		--[[]]
		_SubmitTechnicianProposal,
		_SubmitDiplomaticProposal,
		_SubmitHRProposal,
		_SubmitOfficialProposal,
		_SubmitStaffProposal,
		_SubmitCommanderProposal,
		_SubmitStrategyProposal,
		--]]
	},
}

----------------------------------------

local _behavior = Behavior()

--submit proposal in meeting
_meetingProposal = BehaviorNode( true )
_meetingProposal:BuildTree( _MeetingProposal )

local function Init( params )
	_registers = {}

	_proposer = params.chara
	_actor    = _proposer
	_city  = Asset_Get( _proposer, CharaAssetID.HOME )
	_group = Asset_Get( _city, CityAssetID.GROUP )

	--sanity checker
	if _group ~= Asset_Get( _actor, CharaAssetID.GROUP ) then
		print( Asset_Get( _actor, CharaAssetID.GROUP ):ToString("CHARA") )
		error( _actor:ToString() .. " isn't belong to group=" .. _group:ToString() )
	end

	_meeting = params.meeting	
	if _meeting then				
		_topic = Asset_Get( _meeting, MeetingAssetID.TOPIC )
	else
		_topic = nil
	end
	if typeof( _proposer ) == "number" then
		print( "propoer is number" )
		return false
	end
	if not _city or typeof( _city ) == "number" then
		DBG_Error( "invalid city data", _proposer:ToString(), _city )
		return false
	end
	if not _group or typeof( _group ) == "number" then
		DBG_Error( "invalid group data," .. _proposer:ToString() )
		return false
	end
	return true
end

function CharaAI_SubmitMeetingProposal( chara, meeting )
	if not chara then
		InputUtil_Pause( "invalid chara" )
		return
	end
	if Init( { chara = chara, meeting = meeting } ) then
		Stat_Add( "CharaAI@Run_Times", nil, StatType.TIMES )
		--DBG_Watch( "Debug_Meeting", chara.name .. " try proposal, topic=" .. MathUtil_FindName( MeetingTopic, _topic ) )
		Log_Write( "charaai", chara.name .. " is thinking proposal" .. " " .. g_Time:ToString() )
		return _behavior:Run( _meetingProposal )
	end
	Log_Write( "meeting", "    chara=" .. chara.name .. " cann't submit proposal" )
	return false
end