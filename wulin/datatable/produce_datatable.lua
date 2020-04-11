--------------------------------------------------
-- Produce will be affected by 2 factors
--   1. land
--   2. resource lv
--   3. commonskill
--   4. time
--------------------------------------------------
local PRODUCE_DATATABLE =
{
	FRUIT =
	{
		name        = "采集",
		conditions  = { land={JUNGLELAND=1} },
		time        = { base=15, commonskill={{type="COLLLECTER",lv=1, acc=1.2}}},
		yield       = { base=1,  land={{type="JUNGLELAND",num=10, eff=1.2}}, resource={{type="",lv=1, eff=1}}, commonskill={{type="COLLLECTER",lv=1, eff=1}}},
	},
	FISH =
	{
		name        = "钓鱼",
		conditions  = { land={WATERLAND=1} },
		time        = { base=10, commonskill={{type="FISHER",lv=1, acc=1.2}}},
		yield       = { base=1,  land={{type="WATERLAND",num=10, eff=1.2}}, resource={{type="",lv=1, eff=1}}, commonskill={{type="COLLLECTER",lv=1, eff=1}}},
	},
	FOOD =
	{
		name        = "种粮",
		conditions  = { land={FARMLAND=1} },
		time        = { base=180, commonskill={{type="COLLLECTER",lv=1, acc=1.2}}},
		yield       = { base=1,  land={{type="JUNGLELAND",num=10, eff=1.2}}, resource={{type="",lv=1, eff=1}}, commonskill={{type="COLLLECTER",lv=1, eff=1}}},
	},
	WOOD =
	{
		name        = "伐木",
		conditions  = { land={WOODLAND=1} },
		time        = { base=10, commonskill={{type="COLLLECTER",lv=1, acc=1.2}}},
		yield       = { base=1,  land={{type="JUNGLELAND",num=10, eff=1.2}}, resource={{type="",lv=1, eff=1}}, commonskill={{type="COLLLECTER",lv=1, eff=1}}},
	},
	STONE =
	{
		name        = "采石",
		conditions  = { land={STONEELAND=1} },
		time        = { base=20, commonskill={{type="COLLLECTER",lv=1, acc=1.2}}},
		yield       = { base=1,  land={{type="JUNGLELAND",num=10, eff=1.2}}, resource={{type="",lv=1, eff=1}}, commonskill={{type="COLLLECTER",lv=1, eff=1}}},
	},
	MINERAL =
	{
		name        = "采矿",
		conditions  = { land={MINELAND=1} },
		time        = { base=20, commonskill={{type="COLLLECTER",lv=1, acc=1.2}}},
		yield       = { base=1,  land={{type="JUNGLELAND",num=10, eff=1.2}}, resource={{type="",lv=1, eff=1}}, commonskill={{type="COLLLECTER",lv=1, eff=1}}},
	},
	STEEL =
	{
		name        = "炼钢",
		conditions  = { resource={IRON_ORE=1} },
		time        = { base=20, commonskill={{type="COLLLECTER",lv=1, acc=1.2}}},
		yield       = { base=1,  land={{type="JUNGLELAND",num=10, eff=1.2}}, resource={{type="",lv=1, eff=1}}, commonskill={{type="COLLLECTER",lv=1, eff=1}}},
	},
}

--------------------------------------------------
--------------------------------------------------
function PRODUCE_DATATABLE_Get( type )
	return PRODUCE_DATATABLE[type]
end


--------------------------------------------------
--------------------------------------------------
