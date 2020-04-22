---------------------------------------
---------------------------------------
GROUP_TYPE = 
{
	GROUP_MAIN   = 0,
	GROUP_BRANCH = 1,	
}


GROUP_SIZE = 
{
	FAMILY     = 1,
	SMALL      = 2,
	MID        = 3,
	BIG        = 4, --branch
	HUGE       = 5,	--
}


------------------------------------------------------------------------------
-- The end of game:
--   1. Time End 
--     1.1 20 years in Single Generation
--     1.2 40 years in Two Generations 
--   2. Any group become Overload 
--     1.1 No enemy group( other group is vassal or subject or ally )
--     1.2 Group controls over 50% power ( subject + vassal )
--     1.3 No other group over 25% power
--
-- The winner of the game:
--   1. The Overlord
--   2. The High Score
--
-- Goal is the object that group chasing for, then score will be calculated.
--
-- The rule of score:
--   1. Overload 
--   2. First 3 Reach any goal( Survive, Independent, Alliance Leader )
--   3. Power : Power in all groups's Percent * 1000 
--   4. Ranking : First 20 fighters score bonus
--   5. Make any vassal at first time
------------------------------------------------------------------------------
GROUP_GOAL = 
{
	NONE            = 0,

	--NORMAL
	SURVIVE         = 1,

	INDEPENDENT     = 2,
	
	--other is SUBJECT or ALLY
	ALLIANCE_LEADER = 100,

	--other is VASSAL
	OVERLORD        = 101,
}

---------------------------------------
-- Virtual Asset
---------------------------------------
GROUP_ASSET = 
{
	MONEY      = 2,
	
	REPUTATION = 10, --determine command
	EVALUATION = 11,
	INFLUENCE  = 12, --determine diplomacy success	
}


---------------------------------------
-- Reality Asset
---------------------------------------
GROUP_DEPOT =
{
	BOOK       = 1,
	VEHICLE    = 2,
	EQUIPMENT  = 3,
	ITEM       = 4,
}


GROUP_DATA =
{
	MAX_MEMBER       = 1,
	MAX_SENIOR       = 2,
	MAX_ELDER        = 3,
	
	MAX_CONSTRUCTION = 10,
	MAX_ARMS         = 11,
	MAX_VEHICLES     = 12,
	MAX_ITEM         = 13,
	MAX_BOOK         = 14,
	MAX_RESOURCE     = 15,

	MAX_COOK_LV      = 20,
	MAX_DRILL_LV     = 21,	
	MAX_SECLUDE_LV   = 22,
	MAX_STUDY_LV     = 23,
	MAX_SMITHY_LV    = 24,
	MAX_RAISE_LV     = 25,

	MAX_LIVESTOCK_YIELD = 30,
	MAX_FOOD_YIELD      = 31,
	MAX_HERB_YIELD      = 32,

	MAX_ALLY         = 100,
	MAX_VASSAL       = 101,
	MAX_SUBJECT      = 102,

	ESTIMATE_MONEY   = 200,
	ESTIMATE_INCOME  = 201,
	ESTIMATE_EXPEND  = 202,

	POWER            = 1000,
}


GROUP_ACTIONPOINT = 
{
	---------------------------------------
	-- Assign Internal Affairs
	--   BUILD_CONSTRUCTION
	--   PRODUCE
	--   PROCESS
	--   MAKE_ITEM
	---------------------------------------
	MANAGEMENT = 1,

	---------------------------------------
	-- Assign Diplomacy Affairs
	--   GRANT_GIFT
	--   SIGNPACT
	--   TASK
	--   BuyLA/SELL
	---------------------------------------
	STRATEGIC  = 2,

	---------------------------------------
	-- Assign Extern Affairs
	--   RECONNAISSANCE
	--   SABOTAGE
	--   STOLE
	--   TACTIC
	---------------------------------------
	TACTIC     = 3,
}

--
GROUP_TEMPSTATUS =
{
	DRILL_MEMBER    = 1,
	SECLUDE_MEMBER  = 2,
	READBOOK_MEMBER = 3,

	NEED_CONSTRUCTION = 4,

	NEED_CONTEST      = 5,

	NEED_RECRUITFOLLOWER = 6,
}


GROUP_STATUS = 
{
	--
	UNDER_ATTACK       = 100,
}

--MANAGEMENT
--STRATEGIC
--TACTIC

GROUP_AFFAIRS = 
{
	BUILD_CONSTRUCTION   = { actionpts={ MANAGEMENT=5 } },
	UPGRADE_CONSTRUCTION = { actionpts={ MANAGEMENT=5 } },
	DESTROY_CONSTRUCTION = { actionpts={ MANAGEMENT=3 } },

	MAKE_ITEM       = { actionpts={ MANAGEMENT=10 } },
	PROCESS         = { actionpts={ MANAGEMENT=10 } },
	PRODUCE         = { actionpts={ MANAGEMENT=5 } },

	RECONN          = { actionpts={ TACTIC=10, STRATEGIC=10 } },
	SABOTAGE        = { actionpts={ TACTIC=20 } },
	ATTACK          = { actionpts={ TACTIC=20, STRATEGIC=20 } },
	STOLE           = { actionpts={ TACTIC=20 } },

	GRANT_GIFT      = { actionpts={ STRATEGIC=10 } },
	SIGN_PACT       = { actionpts={ STRATEGIC=10 } },
	REWARD_FOLLOWER = { actionpts={ MANAGEMENT=2 } },
	TAKE_ENTRUST    = { actionpts={ MANAGEMENT=5 } },

	RECRUIT_FOLLOWER = { actionpts={ MANAGEMENT=5, TACTIC=5, STRATEGIC=5 }, size_mod={ FAMILY=1, SMALL=1.5, MID=2, BIG=3, HUGE=4 } },
}

---------------------------------------
--   Init group data by params
--   Now just for test
---------------------------------------
GROUP_PARAMS = 
{
	START = 
	{
		FAMILY     = 
			{
			member={min=3,max=5,ELDER={num=1}},
			assets={ LAND={init=3}, REPUTATION={min=100,max=300}, INFLUENCE={min=100,max=300}, MONEY={min=1000,max=2000} },
			resources=
				{				
				CLOTH={min=100,max=200}, FOOD={min=100,max=200}, MEAT={min=100,max=200}, WOOD={min=100,max=200}, LEATHER={min=100,max=200}, STONE={min=100,max=200}, IRON_ORE={min=100,max=200}, DRAKSTEEL={min=100,max=200},
				},
			vehicles={ num={min=1,max=1, tot_lv=10}, pool={5000}},
			arms={ num={min=3, max=5, tot_lv=10}, pool={ 1000, 1001, 2000, 3000, 4000 } },
			items={num={min=1,max=2,tot_lv=2}, pool={110}},
			books= { num={min=3,max=5,tot_lv=10}, pool={20,30,40,100,110,120,130,140,150,160,170,180,190,200,210,220,230,400,410,420,430,440,1000,2000}, },
			constrs={ HOUSE=2 },
			lands={ JUNGLELAND=20, FARMLAND=100, WOODLAND=10, STONELAND=10, MINELAND=10 },
			goal={name="SURVIVE", day=360*20},
			},
		SMALL      =
			{
			member={min=4,max=8,ELDER=1},
			assets={ LAND={init=10}, REPUTATION={min=200,max=500}, INFLUENCE={min=200,max=500}, MONEY={min=1000,max=2000} },
			resources=
				{
				CLOTH={min=100,max=200}, FOOD={min=100,max=200}, MEAT={min=100,max=200}, WOOD={min=100,max=200}, LEATHER={min=100,max=200}, STONE={min=100,max=200}, IRON_ORE={min=100,max=200}, DRAKSTEEL={min=100,max=200},
				},
			vehicles={ num={min=1,max=1, tot_lv=10}, pool={5000}},
			arms={ num={min=3, max=5, tot_lv=10}, pool={ 1000, 1001, 2000, 3000, 4000 } },
			items={num={min=1,max=2,tot_lv=2}, pool={110}},
			books= { num={min=3,max=5,tot_lv=10}, pool={20,30,40,100,110,120,130,140,150,160,170,180,190,200,210,220,230,400,410,420,430,440,1000,2000}, },
			constrs={ HOUSE=3 },
			lands={ JUNGLELAND=20, FARMLAND=100, WOODLAND=10, STONELAND=10, MINELAND=10 },
			goal={name="SURVIVE", day=360*20},
			},
		MID        =
			{
			member={min=8,max=12,ELDER=1},
			assets={ LAND={init=30}, REPUTATION={min=300,max=1000}, INFLUENCE={min=0,max=100}, MONEY={min=5000,max=20000} },
			resources=
				{
				--CLOTH={min=100,max=200}, FOOD={min=100,max=200}, MEAT={min=100,max=200}, WOOD={min=100,max=200}, LEATHER={min=100,max=200}, STONE={min=100,max=200}, IRON_ORE={min=100,max=200}, DRAKSTEEL={min=100,max=200},
				},
			vehicles={ num={min=1,max=1, tot_lv=10}, pool={5000}},
			arms={ num={min=3, max=5, tot_lv=10}, pool={ 1000, 1001, 2000, 3000, 4000 } },
			items={num={min=1,max=2,tot_lv=2}, pool={110}},
			books= { num={min=3,max=5,tot_lv=10}, pool={20,30,40,100,110,120,130,140,150,160,170,180,190,200,210,220,230,400,410,420,430,440,1000,2000}, },
			constrs={ HOUSE=5 },
			lands={ JUNGLELAND=20, FARMLAND=100, WOODLAND=10, STONELAND=10, MINELAND=10 },
			goal={name="INDEPENDENT", day=360*20},
			},			
		BIG        =
			{
			member={min=16,max=30,ELDER=1},
			assets={ LAND={init=100}, REPUTATION={min=500,max=3000}, INFLUENCE={min=0,max=100}, MONEY={min=10000,max=20000} },
			resources=
				{
				CLOTH={min=100,max=200}, FOOD={min=100,max=200}, MEAT={min=100,max=200}, WOOD={min=100,max=200}, LEATHER={min=100,max=200}, STONE={min=100,max=200}, IRON_ORE={min=100,max=200}, DRAKSTEEL={min=100,max=200},
				},
			vehicles={ num={min=1,max=1, tot_lv=10}, pool={5000}},
			arms={ num={min=3, max=5, tot_lv=10}, pool={ 1000, 1001, 2000, 3000, 4000 } },
			items={num={min=1,max=2,tot_lv=2}, pool={110}},
			books= { num={min=3,max=5,tot_lv=10}, pool={20,30,40,100,110,120,130,140,150,160,170,180,190,200,210,220,230,400,410,420,430,440,1000,2000}, },
			constrs={ HOUSE=5 },
			lands={ JUNGLELAND=20, FARMLAND=100, WOODLAND=10, STONELAND=10, MINELAND=10 },
			goal={name="ALLIANCE_LEADER", day=360*20},
			},		
		HUGE       =
			{
			member={min=30,max=50,ELDER=1},
			assets={ LAND={init=300}, REPUTATION={min=2000,max=5000}, INFLUENCE={min=0,max=100}, MONEY={min=20000,max=40000} },
			resources=
				{
				CLOTH={min=100,max=200}, FOOD={min=100,max=200}, MEAT={min=100,max=200}, WOOD={min=100,max=200}, 
				LEATHER={min=100,max=200}, STONE={min=100,max=200}, IRON_ORE={min=100,max=200}, DRAKSTEEL={min=100,max=200},
				},
			vehicles={ num={min=1,max=1, tot_lv=10}, pool={5000}},
			arms={ num={min=3, max=5, tot_lv=10}, pool={ 1000, 1001, 2000, 3000, 4000 } },
			items={num={min=1,max=2,tot_lv=2}, pool={110}},
			books= { num={min=3,max=5,tot_lv=10}, pool={20,30,40,100,110,120,130,140,150,160,170,180,190,200,210,220,230,400,410,420,430,440,1000,2000}, },
			constrs={ HOUSE=5 },
			lands={ JUNGLELAND=20, FARMLAND=100, WOODLAND=10, STONELAND=10, MINELAND=10 },
			goal={name="OVERLORD", day=360*20},
			},
	},

	ACTION_PTS = 
	{
		FAMILY     = { std=3, max=400 },
		SMALL      = { std=4, max=500 },
		MID        = { std=5, max=600 },
		BIG        = { std=6, max=800 },
		HUGE       = { std=8, max=1000 },
	},

	LEVELUP =
	{
		FAMILY     = { members=8,   tot_memberlv=120 },
		SMALL      = { members=20,  tot_memberlv=450 },
		MID        = { members=30,  tot_memberlv=700 },
		BIG        = { members=40,  tot_memberlv=1000 },
		HUGE       = { members=100, tot_memberlv=10000 },
	},

	FOLLOWER_SALARY = 
	{
		rank  = { NONE=10, JUNIOR=30, SENIOR=100, ELDER=1000 },
		--size  = { FAMILY=10, SMALL=1, MID=1.4, BIG=1.6, HUGE=2 },
		grade = { 1, 1.2, 1.5, 1.8, 2.1, 2.5 }
	},

	DIPLOMACY = 
	{
		subject = { FAMILY=1, SMALL=1, MID=2, BIG=3, HUGE=4 },
		vassal  = { FAMILY=1, SMALL=1, MID=2, BIG=3, HUGE=4 },
		ally    = { FAMILY=1, SMALL=1, MID=2, BIG=3, HUGE=4 },
	},
}
