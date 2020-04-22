------------------------------------------------------------------------------------
--
--
-- Effect
--   max_member ==> Allow group recruit more follower
--   max_senior ==> Allow group improve more senior followers
--   max_elder  ==> Allow group improve more elder followers
--   max_drill  ==> Allow group drill more followr at the same time or it'll leads drill penality
--   seclude    ==> Affect the highest skill level when follower seclude
------------------------------------------------------------------------------------
local CONSTRUCTION_DATATABLE =
{
	[100] =
	{
		name       = "草房",
		type       = "HOUSE",
		lv         = 1,
		conditions = { size="FAMILY", assets = {}, numbers = { FAMILY=4, SMALL=4, MID=5, BIG=5, HUGE=6 } },
		effects    = { max_member=2 },
		costs      = { lands={ flatland=2 }, time=15, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
		maintain   = { MONEY={ value=5 }, resource={ WOOD=5 } },
	},
	[101] =
	{
		name       = "平房",
		type       = "HOUSE",
		lv         = 2,
		conditions = { size="SMALL", assets = {}, upgrades={100}, numbers = { FAMILY=0, SMALL=4, MID=5, BIG=6, HUGE=6 } },
		effects    = { max_member=5 },
		costs      = { lands={ flatland=2 }, time=30, assets={ LAND={ value=4 }, MONEY={ value=300 } }, resources={ WOOD={ value=300 } } },
		maintain   = { MONEY={ value=10 }, resource={ WOOD=10 } },
	},
	[102] =
	{
		name       = "大通铺",
		type       = "HOUSE",
		lv         = 3,
		conditions = { size="MID", assets = {}, upgrades={101}, numbers = { FAMILY=0, SMALL=0, MID=4, BIG=5, HUGE=6 } },
		effects    = { max_member=10 },
		costs      = { lands={ flatland=2 }, time=45, assets={ LAND={ value=6 }, MONEY={ value=1000 } }, resources={ WOOD={ value=100 } } },
		maintain   = { MONEY={ value=20 }, resource={ WOOD=20 } },
	},


	[110] =
	{
		name       = "厢房",
		type       = "LIVING_ROOM",
		lv         = 2,
		conditions = { size="SMALL", assets = {}, numbers = { FAMILY=0, SMALL=1, MID=4, BIG=6, HUGE=8 } },
		effects    = { max_senior=2, },
		costs      = { lands={ flatland=2 }, time=30, lands={ FLATLAND=2}, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[111] =
	{
		name       = "卧室",
		type       = "LIVING_ROOM",
		lv         = 3,
		conditions = { size="MID", assets = {}, numbers = { FAMILY=0, SMALL=0, MID=1, BIG=3, HUGE=6 } },
		effects    = { max_elder=1 },
		costs      = { lands={ flatland=2 }, time=45, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},


	[200] =
	{
		name       = "练习场Lv1",
		type       = "DRILL_GROUND",
		lv         = 1,		
		conditions = { size="FAMILY", assets = {}, numbers = { FAMILY=1, SMALL=2, MID=3, BIG=4, HUGE=4 } },
		effects    = { max_drill=5, drill_lv=20 },
		costs      = { lands={ flatland=2 }, time=60, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 }, STONE={ value=100 } } },
	},
	[201] =
	{
		name       = "练习场Lv2",
		type       = "DRILL_GROUND",
		lv         = 2,
		conditions = { size="MID", assets = {}, upgrades={200}, numbers = { FAMILY=0, SMALL=0, MID=1, BIG=2, HUGE=2 } },		
		effects    = { max_drill=15, drill_lv=30 },
		costs      = { lands={ flatland=2 }, time=90, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 }, STONE={ value=100 } } }, },
	[202] =
	{
		name       = "练习场Lv3",
		type       = "DRILL_GROUND",
		lv         = 3,
		conditions = { size="BIG", assets = {}, upgrades={201}, numbers = { FAMILY=0, SMALL=0, MID=0, BIG=1, HUGE=2 } },		
		effects    = { max_drill=40, drill_lv=40 },
		costs      = { lands={ flatland=2 }, time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},


	[210] =
	{
		name       = "练功房",
		type       = "BACKROOM",
		lv         = 2,
		conditions = { size="SMALL", assets = {}, numbers = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=2 } },		
		effects    = { seclude_lv=2 },
		costs      = { lands={ flatland=2 }, time=60, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[211] =
	{
		name       = "密室",
		type       = "BACKROOM",
		lv         = 3,
		conditions = { size="BIG", assets = {}, upgrades={210}, numbers = { FAMILY=0, SMALL=0, MID=0, BIG=1, HUGE=2 } },		
		effects    = { seclude_lv=3 },
		costs      = { lands={ flatland=2 }, time=90, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[212] =
	{
		name       = "山洞",
		type       = "BACKROOM",
		lv         = 4,
		conditions = { size="BIG", assets = { REPUTATION={ value=500 } }, upgrades={210}, numbers = { FAMILY=0, SMALL=0, MID=0, BIG=1, HUGE=1 } },		
		effects    = { seclude_lv=4 },
		costs      = { lands={ flatland=2 }, time=999, assets={ MONEY={ value=9999 } }, resources={ STONE={ value=9999 } } },
	},


	[220] =
	{
		name       = "书房",
		type       = "STUDY_ROOM",
		lv         = 2,
		conditions = { size="SMALL", assets = {}, numbers = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=2 } },		
		effects    = { study_lv=1, book_slot=20 },
		costs      = { lands={ flatland=2 }, time=30, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[221] =
	{
		name       = "高阶书房",
		type       = "STUDY_ROOM",
		lv         = 2,
		conditions = { size="BIG", assets = {}, upgrades={220}, numbers = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=2 } },
		effects    = { study_lv=2, book_slot=40 },
		costs      = { lands={ flatland=2 }, time=60, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},	


	[230] =
	{
		name       = "演武堂",
		type       = "TRAINING_ROOM",
		lv         = 2,
		conditions = { size="SMALL", assets = {}, numbers = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=2 } },
		effects    = { drill_lv=50 },
		costs      = { lands={ flatland=2 }, time=45, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[231] =
	{
		name       = "论武堂",
		type       = "TRAINING_ROOM",
		lv         = 3,
		conditions = { size="MID", assets = {}, upgrades={230}, numbers = { FAMILY=0, SMALL=0, MID=1, BIG=1, HUGE=2 } },
		effects    = { drill_lv=60 },
		costs      = { lands={ flatland=2 }, time=90, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},


	[300] =
	{
		name       = "厨房",
		type       = "KITCHEN",
		lv         = 1,
		conditions = { size="SMALL", assets = {}, numbers = { FAMILY=0, SMALL=1, MID=1, BIG=1, HUGE=1 } },
		effects    = { cook_lv=1, res_slot=50 },
		costs      = { lands={ flatland=2 }, time=30, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[301] =
	{
		name       = "食堂",
		type       = "KITCHEN",
		lv         = 2,
		conditions = { size="MID", assets = {}, upgrades={300}, numbers = { FAMILY=0, SMALL=0, MID=1, BIG=1, HUGE=1 } },
		effects    = { cook_lv=2, res_slot=100 },
		costs      = { lands={ flatland=2 }, time=60, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},


	[310] =
	{
		name       = "库房",
		type       = "DEPOSITORY",
		lv         = 1,
		conditions = { size="FAMILY", assets = {}, numbers = { FAMILY=1, SMALL=2, MID=3, BIG=4, HUGE=5 } },
		effects    = { item_slot=20 },
		costs      = { lands={ flatland=2 }, time=60, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[311] =
	{
		name       = "库房",
		type       = "DEPOSITORY",
		lv         = 2,
		conditions = { size="SMALL", assets = {}, upgrades={310}, numbers = { FAMILY=0, SMALL=0, MID=1, BIG=1, HUGE=1 } },
		effects    = { res_slot=300 },
		costs      = { lands={ flatland=2 }, time=120, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[312] =
	{
		name       = "仓库",
		type       = "DEPOSITORY",
		lv         = 3,
		conditions = { size="MID", assets = {}, upgrades={311}, numbers = { FAMILY=0, SMALL=0, MID=1, BIG=1, HUGE=1 } },
		effects    = { res_slot=500 },
		costs      = { lands={ flatland=2 }, time=240, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},	


	[320] =
	{
		name       = "藏宝室",
		type       = "TREASURE_HOUSE",
		lv         = 1,
		conditions = { size="SMALL", assets = {}, upgrades={311}, numbers = { FAMILY=0, SMALL=1, MID=2, BIG=2, HUGE=3 } },
		effects    = { item_slot=100 },
		costs      = { lands={ flatland=2 }, time=60, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[321] =
	{
		name       = "大藏宝室",
		type       = "TREASURE_HOUSE",
		lv         = 1,
		conditions = { size="BIG", assets = {}, upgrades={311}, numbers = { FAMILY=0, SMALL=0, MID=0, BIG=1, HUGE=2 } },
		effects    = { item_slot=300 },
		costs      = { lands={ flatland=2 }, time=120, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	

	[400] =
	{
		name       = "小铁匠铺",
		type       = "SMITHY",
		lv         = 1,
		conditions = { size="MID", assets = {}, numbers = { FAMILY=0, SMALL=0, MID=1, BIG=2, HUGE=2 }  },		
		effects    = { smithy_lv=1 },
		costs      = { lands={ flatland=2 }, time=45, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[401] =
	{
		name       = "中铁匠铺",
		type       = "SMITHY",
		lv         = 2,
		conditions = { size="BIG", assets = {}, upgrades={400}, numbers = { FAMILY=0, SMALL=0, MID=0, BIG=1, HUGE=2 }  },		
		effects    = { smithy_lv=2 },
		costs      = { lands={ flatland=2 }, time=90, assets={ MONEY={ value=500 } }, resources={ WOOD={ value=100 } } },
	},
	[402] =
	{
		name       = "大铁匠铺",
		type       = "SMITHY",
		lv         = 3,
		conditions = { size="HUGE", assets = {}, upgrades={401}, numbers = { FAMILY=0, SMALL=0, MID=0, BIG=0, HUGE=1 }  },
		effects    = { smithy_lv=3 },
		costs      = { lands={ flatland=2 }, time=180, assets={ MONEY={ value=1000 } }, resources={ WOOD={ value=100 } } },
	},


	[410] =
	{
		name       = "兵器库",
		type       = "ARMORY",
		lv         = 1,
		conditions = { size="MID", assets = {}, numbers = { FAMILY=0, SMALL=0, MID=1, BIG=2, HUGE=2 }  },
		effects    = { arms_slot=10 },
		costs      = { lands={ flatland=2 }, time=45, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[410] =
	{
		name       = "兵器库",
		type       = "ARMORY",
		lv         = 2,
		conditions = { size="BIG", assets = {}, upgrades={401}, numbers = { FAMILY=0, SMALL=0, MID=0, BIG=1, HUGE=2 } },
		effects    = { arms_slot=30 },
		costs      = { lands={ flatland=2 }, time=90, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},

	[500] =
	{
		name       = "牧场",
		type       = "PASTURE",
		lv         = 2,
		conditions = { size="BIG", assets = {}, numbers = { FAMILY=0, SMALL=0, MID=0, BIG=1, HUGE=2 } },		
		effects    = { raise_lv=2 },
		costs      = { lands={ flatland=2 }, time=180, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[500] =
	{
		name       = "牧场",
		type       = "PASTURE",
		lv         = 3,
		conditions = { size="HUGE", assets = {}, upgrades={500}, numbers = { FAMILY=0, SMALL=0, MID=0, BIG=0, HUGE=1 } },
		effects    = { raise_lv=3 },
		costs      = { lands={ flatland=2 }, time=360, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=1000 } } },
	},

	[510] =
	{
		name       = "马厩",
		type       = "STABLE",
		lv         = 2,
		conditions = { size="BIG", assets = {}, numbers = { FAMILY=0, SMALL=0, MID=0, BIG=1, HUGE=2 } },
		effects    = { vehicle_slot=10 },
		costs      = { lands={ flatland=2 }, time=60, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[511] =
	{
		name       = "大马厩",
		type       = "STABLE",
		lv         = 3,
		conditions = { size="HUGE", assets = {}, upgrades={510}, nnumbers = { FAMILY=0, SMALL=0, MID=0, BIG=0, HUGE=1 } },
		effects    = { vehicle_slot=20 },
		costs      = { lands={ flatland=2 }, time=120, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},

	[600] =
	{
		name       = "小农场",
		type       = "FARM",
		lv         = 1,
		conditions = { size="SMALL", assets = {}, numbers = { FAMILY=0, SMALL=0, MID=0, BIG=0, HUGE=1 } },
		effects    = { livestock_yield=100 },
		costs      = { lands={ flatland=2 }, time=40, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[602] =
	{
		name       = "农场",
		type       = "FARM",
		lv         = 2,
		conditions = { size="MID", assets = {}, upgrades={601}, numbers = { FAMILY=0, SMALL=0, MID=0, BIG=0, HUGE=1 } },		
		effects    = { livestock_yield=300 },
		costs      = { lands={ flatland=2 }, time=80, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[603] =
	{
		name       = "大农场",
		type       = "FARM",
		lv         = 3,
		conditions = { size="BIG", assets = {}, upgrades={602}, numbers = { FAMILY=0, SMALL=0, MID=0, BIG=0, HUGE=1 } },		
		effects    = { livestock_yield=500 },
		costs      = { lands={ flatland=2 }, time=160, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},

	[610] =
	{
		name       = "农田",
		type       = "FIELD",
		lv         = 1,
		conditions = { size="SMALL", assets = {}, numbers = { FAMILY=0, SMALL=2, MID=3, BIG=4, HUGE=5 } },
		effects    = { food_yield=300 },
		costs      = { lands={ flatland=2 }, time=60, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[611] =
	{
		name       = "大型农田",
		type       = "FIELD",
		lv         = 2,
		conditions = { size="MID", assets = {}, upgrades={610}, numbers = { FAMILY=0, SMALL=0, MID=1, BIG=2, HUGE=3 }},		
		effects    = { food_yield=600 },
		costs      = { lands={ flatland=2 }, time=120, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[612] =
	{
		name       = "农庄",
		type       = "FIELD",
		lv         = 3,
		conditions = { size="BIG", assets = {}, upgrades={611}, numbers = { FAMILY=0, SMALL=0, MID=0, BIG=1, HUGE=2 } },
		effects    = { food_yield=1200 },
		costs      = { lands={ flatland=2 }, time=240, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},

	[700] =
	{
		name       = "花葡",
		type       = "GARDEN",
		lv         = 1,
		conditions = { size="SMALL", assets = {}, numbers = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=2 } },		
		effects    = { herb_yield=100 },
		costs      = { lands={ flatland=2 }, time=30, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[701] =
	{
		name       = "花园",
		type       = "GARDEN",
		lv         = 2,
		conditions = { size="MID", assets = {}, upgrades={700}, numbers = { FAMILY=0, SMALL=0, MID=1, BIG=2, HUGE=3 } },
		effects    = { herb_yield=300 },
		costs      = { lands={ flatland=2 }, time=60, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},

	[710] =
	{
		name       = "药房",
		type       = "PHARMACY",
		lv         = 1,
		conditions = { size="SMALL", assets = {}, numbers = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=2 }},		
		effects    = { res_slot=100 },
		costs      = { lands={ flatland=2 }, time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[711] =
	{
		name       = "炼丹房",
		type       = "PHARMACY",
		lv         = 2,
		conditions = { size="BIG", assets = {}, upgrades={710}, numbers = { FAMILY=0, SMALL=0, MID=0, BIG=1, HUGE=2 } },
		effects    = { res_slot=100 },
		costs      = { lands={ flatland=2 }, time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},

	[800] =
	{
		name       = "商铺",
		type       = "SHOP",
		lv         = 2,
		conditions = { size="MID", assets = {}, upgrades={710}, numbers = { FAMILY=0, SMALL=0, MID=1, BIG=2, HUGE=3 } },
		effects    = { sell_quantity=100 },
		costs      = { lands={ flatland=2 }, time=60, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
}


--------------------------------------------------
--------------------------------------------------
function CONSTRUCTION_DATATABLE_Get( id )
	return CONSTRUCTION_DATATABLE[id]
end


--------------------------------------------------
--------------------------------------------------
function CONSTRUCTION_DATATABLE_Add( data )
	CONSTRUCTION_DATATABLE[data.id] = data
end

--------------------------------------------------
--------------------------------------------------
local function Construction_Compare( source, conditions )
	for name, data in pairs( conditions ) do
		local method = data.method
		if not data.method then
			local t = typeof(data.value)
			if t == "string" then
				method = "EQUAL"
			elseif t == "number" then
				method = "MORE_THAN"
			end
		end		
		if MathUtil_Compare( source[name], data.value, method ) == false then
			--print( "failed", name, source[name], data.value, method )
			return false
		end
	end
	return true
end

--------------------------------------------------
--------------------------------------------------
local function Construction_MatchCondition( constr, group, params )
	if not group then return true end
	if not params then DBG_Error( "need params" ) end

	--size
	if constr.size and GROUP_SIZE[group.size] < GROUP_SIZE[constr.size] then return false end
	
	--conditions
	if constr.conditions then
		if constr.conditions.upgrades then
			--need to upgrade from a exist construction
			if not params.upgrade then return false end
			for _, id in ipairs( constr.conditions.upgrades ) do
				if group:GetNumOfConstruction( nil, id ) < 1 then return false end
			end
		elseif params.upgrade then
				--only find upgraded constructions
			return
		end
		if constr.conditions.assets then
			if not Construction_Compare( group.assets, constr.conditions.assets ) then return false end
		end
	end

	--cost
	if constr.costs then
		if constr.costs.assets then
			if not Construction_Compare( group.assets, constr.costs.assets ) then return false end
		end
		
		if constr.costs.resources then
			if not Construction_Compare( group.resources, constr.costs.resources ) then
				if params.wishlist then
					for type, data in pairs( constr.costs.resources ) do
						group:AddWishResource( type, data.value )
					end
				end
				return false
			end
		end

		if constr.costs.lands then
			for type, value in pairs( constr.costs.lands ) do
				if group:GetNumOfLand( type ) < value then
					if params.wishlist then
						group:AddWishLand( type, data.value )
					end
					return false
				end
			end
		end
	end

	--number
	if constr.conditions.numbers then
		if not constr.conditions.numbers[group.size] or group:GetNumOfConstruction( nil, constr.id ) >= constr.conditions.numbers[group.size] then
			return false
		end
	end

	--print( "Suc", constr.name )

	return true
end

--------------------------------------------------
--
-- Find the construction that can be built in the group
--
-- @params type can be nil
-- @params group can be nil
-- @return construction object data
--
--------------------------------------------------
function CONSTRUCTION_DATATABLE_Find( type, group, params )
	if type and not addWishList then addWishList = true end
	local list = {}
	for id, constr in pairs( CONSTRUCTION_DATATABLE ) do
		if not type or constr.type == type then
			if params.immed or Construction_MatchCondition( constr, group, params ) then
				constr.id = id
				table.insert( list, constr )
			else
				--print( constr.name, "failed" )
			end
		end
	end
	return list
end