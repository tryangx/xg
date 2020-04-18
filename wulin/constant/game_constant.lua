GAME_RULE = 
{
	PASS_TIME = 24,


	WEEK_IN_MONTH = 3,

	------------------------------------
	-- Week time
	--   Week time used for schedule
	------------------------------------
	WEEK_TIME = 24 * 10,

	------------------------------------
	-- Day time
	--   Day time used for role action
	------------------------------------
	DAY_TIME  = 24,


	------------------------------------
	-- Hour time
	--   Hour time used for event-scenario
	------------------------------------
	HOUR_TIME  = 1,


	------------------------------------
	HOLD_MEETING  = function ( time )
		if true then return true end
		return time:GetDay() == 1
	end,

	SELECT_LEADER = function ( time )
		if true then return true end
		local day = time:GetDay()
		return day == 1 or day == 10 or day == 20
	end,
}


GAME_ACHIEVEMENT_SCORE = 
{
	FINISH_GOAL         = { SURVIVE=500, INDEPENDENT=600, ALLIANCE_LEADER=1500, OVERLORD=3000 },

	------------------------------------
	FINISH_GOAL_RANKING = { 500, 300, 200, 100 },

	--score = ranking.score
	--e.g.
	-- ranking=1 ==> score = 500
	-- ranking=100 ==> score = not
	PERSON_RANKING      = { { ranking=1, score=400 }, { ranking=5, score=250 }, { ranking=10, score=200 }, { ranking=20, score=100 }, { ranking=9999, score=0 } },

	------------------------------------
	--score = powre_percent * POWER_PERCENT_MOD
	--e.g.
	--   score = 25% * 1000 = 250
	POWER_PERCENT_MOD   = 1000,

	HAS_VASSAL          = { { num=1, score=200 }, { num=3, score=250 }, { num=5, score=300 } },
}