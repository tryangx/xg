local CONSTRUCTION_DATATABLE =
{
	[100] =
	{
		name       = "平房",
		type       = "HOUSE",
		lv         = 1,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		effects    = { max_member=5 },
		costs      = { time=2, assets={ LAND={ value=2 }, MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[101] =
	{
		name       = "大通铺",
		type       = "HOUSE",
		lv         = 3,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1, upgrades={100} },
		effects    = { max_member=5 },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},

	[110] =
	{
		name       = "厢房",
		type       = "LIVING_ROOM",
		lv         = 1,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		effects    = { max_member=5, },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[111] =
	{
		name       = "卧室",
		type       = "LIVING_ROOM",
		lv         = 1,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		effects    = { max_member=5 },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},

	[200] =
	{
		name       = "练习场Lv1",
		type       = "DRILL_GROUND",
		lv         = 1,		
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		effects    = { drill_slot=5 },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[201] =
	{
		name       = "练习场Lv2",
		type       = "DRILL_GROUND",
		lv         = 2,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		limits     = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=3 },
		effects    = { drill_slot=10 },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[202] =
	{
		name       = "练习场Lv3",
		type       = "DRILL_GROUND",
		lv         = 3,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		limits     = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=3 },
		effects    = { drill_slot=20 },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},

	[210] =
	{
		name       = "练功房",
		type       = "BACKROOM",
		lv         = 2,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		limits     = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=3 },
		effects    = { seclude=1 },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[211] =
	{
		name       = "密室",
		type       = "BACKROOM",
		lv         = 3,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		limits     = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=3 },
		effects    = { seclude=2 },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},

	[220] =
	{
		name       = "书房",
		type       = "STUDY_ROOM",
		lv         = 2,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		limits     = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=3 },
		effects    = { },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},

	[230] =
	{
		name       = "讲演堂",
		type       = "TRAINING_ROOM",
		lv         = 3,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		limits     = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=3 },
		effects    = { },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},

	[300] =
	{
		name       = "厨房",
		type       = "KITCHEN",
		lv         = 1,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		limits     = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=3 },
		effects    = { food_bonus=1 },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},

	[310] =
	{
		name       = "仓库",
		type       = "DEPOSITORY",
		lv         = 1,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		limits     = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=3 },
		effects    = { store_slot=100 },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},

	[400] =
	{
		name       = "铁匠铺",
		type       = "SMITHY",
		lv         = 1,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		limits     = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=3 },
		effects    = { store_slot=100 },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[410] =
	{
		name       = "兵器库",
		type       = "ARMORY",
		lv         = 1,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		limits     = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=3 },
		effects    = { store_slot=100 },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},

	[500] =
	{
		name       = "牧场",
		type       = "PASTURE",
		lv         = 1,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		limits     = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=3 },
		effects    = { store_slot=100 },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[510] =
	{
		name       = "马厩",
		type       = "STABLE",
		lv         = 1,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		limits     = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=3 },
		effects    = { store_slot=100 },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},

	[610] =
	{
		name       = "农田",
		type       = "FIELD",
		lv         = 1,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		limits     = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=3 },
		effects    = { store_slot=100 },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[600] =
	{
		name       = "农场",
		type       = "FARM",
		lv         = 1,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		limits     = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=3 },
		effects    = { store_slot=100 },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},

	[700] =
	{
		name       = "花园",
		type       = "GARDEN",
		lv         = 1,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		limits     = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=3 },
		effects    = { store_slot=100 },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
	},
	[710] =
	{
		name       = "药房",
		type       = "PHARMACY",
		lv         = 1,
		conditions = { size="FAMILY", assets = { REPUTATION={ value=100 } }, number = 1 },
		limits     = { FAMILY=0, SMALL=1, MID=1, BIG=2, HUGE=3 },
		effects    = { store_slot=100 },
		costs      = { time=2, assets={ MONEY={ value=100 } }, resources={ WOOD={ value=100 } } },
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
local function Construction_MatchCondition( constr, group, upgrade )
	if not group then return true end

	--size
	if constr.size and GROUP_SIZE[group.size] < GROUP_SIZE[constr.size] then return false end
	
	--conditions
	if constr.conditions then
		if constr.conditions.upgrades then
			--need to upgrade from a exist construction
			if not upgrade then return false end
			for _, id in ipairs( constr.conditions.upgrades ) do if group:GetNumOfConstruction( nil, id ) < 1 then return false end end			
		elseif upgrade then
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
				for type, data in pairs( constr.costs.resources ) do
					group:AddWishResource( type, data.value )
				end				
				return false
			end
		end
	end

	--number
	if constr.conditions.number and group:GetNumOfConstruction( nil, constr.id ) >= constr.conditions.number then return false end

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
function CONSTRUCTION_DATATABLE_Find( type, group, upgrade )
	local list = {}
	for id, constr in pairs( CONSTRUCTION_DATATABLE ) do
		if not type or constr.type == type then
			if Construction_MatchCondition( constr, group, upgrade ) then
				constr.id = id
				table.insert( list, constr )
			else
				--print( constr.name, "failed" )
			end
		end
	end
	return list
end