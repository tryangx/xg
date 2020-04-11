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
	CONSUMABLE = 4,
}


GROUP_ATTR =
{
	MAX_MEMBER       = 1,
	MAX_CONSTRUCTION = 2,
	MAX_INVENTORY    = 3,
}


GROUP_ACTIONPOINT = 
{
	MANAGEMENT = 1,
	STRATEGIC  = 2,
	TACTIC     = 3,
}

--
GROUP_TEMPSTATUS =
{
	DRILL_MEMBER    = 1,
	SECLUDE_MEMBER  = 2,
	READBOOK_MEMBER = 3,

	NEED_CONSTRUCTION = 4,
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