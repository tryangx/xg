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
	LAND       = 2, --determine how many construction can build
	REPUTATION = 3, --determine command
	INFLUENCE  = 4, --determine diplomacy success	
	MONEY      = 5,
}


---------------------------------------
-- 1 Land means 100m2
---------------------------------------
GROUP_LAND = 
{
	FLATLAND   = 1,
	FARMLAND   = 2,	
	WATERLAND  = 3,
	JUNGLELAND = 4,
	GRASSLAND  = 5,
	WOODLAND   = 10,
	STONELAND  = 11,
	MINELAND   = 12,	
}


---------------------------------------
-- Reality Asset
---------------------------------------
GROUP_RESOURCE = 
{
	FOOD       = 20,
	MEAT       = 21,
	FISH       = 22,
	FRUIT      = 23,
	HERBS      = 30,
	LIVESTOCK  = 40,
	CLOTH      = 41,
	LEATHER    = 42,
	LUMBER     = 60,
	WOOD       = 61,
	STONE      = 70,
	MABLE      = 71,
	IRON_ORE   = 80,
	STEEL      = 81,
	DARKSTEEL  = 82,
}


GROUP_DEPOT =
{
	BOOK       = 1,
	VEHICLE    = 2,
	EQUIPMENT  = 3,
	ITEM       = 4,
}


GROUP_ATTR =
{
	MAX_MEMBER       = 1,
	MAX_CONSTRUCTION = 2,
	MAX_INVENTORY    = 3,

	MAX_ALLY         = 10,
	MAX_VASSAL       = 11,
	MAX_SUBJECT      = 12,

	POWER            = 100,
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
}


GROUP_STATUS = 
{
	--
	UNDER_ATTACK       = 100,
}


GROUP_AFFAIRS = 
{
	--constructions
	BUILD_CONSTRUCTION   = 10,
	UPGRADE_CONSTRUCTION = 11,
	DESTROY_CONSTRUCTION = 12,

	--
}

---------------------------------------
---------------------------------------