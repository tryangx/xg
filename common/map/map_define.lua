----------------------------------------------------------------------------------------
--
-- Plot & Terrain & Feature & Addition 
--
----------------------------------------------------------------------------------------
PLOTTYPE = 
{
	NONE     = 0,
	LAND     = 1,
	HILLS    = 2,
	MOUNTAIN = 3,
	WATER    = 4,
}

PlotTerrainType =
{
	NONE      = 0,
	PLAINS    = 1,
	GRASSLAND = 2,	
	DESERT    = 3,
	TUNDRA    = 4,
	SNOW      = 5,
	LAKE      = 6,
	COAST     = 7,
	OCEAN     = 8,
}

PlotFeatureType = 
{
	ALL         = -1,
	NONE        = 0,
	WOODS       = 1,
	RAIN_FOREST = 2,
	MARSH       = 3,
	OASIS       = 4,
	FLOOD_PLAIN = 5,
	ICE         = 6,
	FALLOUT     = 7,
}

PlotAddition = 
{
	NONE      = 0,

	--natrual	
	RIVER     = 1,
	CLIFFS    = 2,

	--arificial
	DISTRICT  = 100,

	--traffic
	ROAD      = 200,
	SHIPPING  = 201,

	--[[
	--agriculture
	FARM      = 210,
	PASTURE   = 211,
	FISHERY   = 212,

	--industry
	SAWMILL   = 220,
	QUARRY    = 221,
	--]]
}

----------------------------------------------------------------------------------------
--
-- Resource Definition
--
----------------------------------------------------------------------------------------
ResourceCategory = 
{
	NONE       = 0,
	STRATEGIC  = 1,
	BONUS      = 2,
	LUXURY     = 3,
	NATURAL    = 4,
	ARTIFICIAL = 5,
}

ResourceCondition =
{
	CONDITION_BRANCH         = 1,
	PROBABILITY              = 2,
	PLOT_TYPE                = 10,	
	PLOT_TERRAIN_TYPE        = 11,	
	PLOT_FEATURE_TYPE        = 12,
	PLOT_TYPE_EXCEPT         = 13,
	PLOT_TERRAIN_TYPE_EXCEPT = 14,
	PLOT_FEATURE_TYPE_EXCEPT = 15,
	NEAR_PLOT_TYPE           = 20,
	NEAR_TERRAIN_TYPE        = 21,
	NEAR_FEATURE_TYPE        = 22,
	AWAY_FROM_CITY_TYPE      = 23,
	AWAY_FROM_TERRAIN_TYPE   = 24,
	AWAY_FROM_FEATURE_TYPE   = 25,
}

ResourceBonus = 
{
	--traffic
	LAND_TRANS  = 10,
	WATER_TRANS = 11,
	MOUNT       = 12,

	--agriculture
	CROP        = 20,
	LIVESTOCK   = 21,
	AQUATIC     = 22,

	LUMBER      = 31,

	ORE         = 32,
	NOBLE_METAL = 33,

	--other
	SATISFACTION=100,
}

----------------------------------------------------------------------------------------
--
--
--
----------------------------------------------------------------------------------------
DISTRICT_TYPE = 
{
	--human
	VILLAGE   = 100,
	TRIBE     = 101,	
	
	TOWN      = 110,
	
	CITY      = 120,
	METRO     = 121,
	
	FORT      = 130,
	BARRACKS  = 131,
}