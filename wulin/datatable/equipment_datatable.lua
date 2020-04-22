--------------------------------------------------
--------------------------------------------------
local EQUIPMENT_DATATABLE =
{
	[1000] =
	{
		name       = "倚天剑", 		
		type       = "WEAPON",
		lv         = 4,
		value      = { money=1000 },
		condition  = { commonskill={type="BLACKSMITH"} },
		costs      = { time=100, resources={ IRON_ORE={value=100} } },
		atkAction  = { hit={mod=10}, agi={ratio=0.8}, dmg={} },
	},
	[1001] =
	{
		name       = "屠龙刀",
		type       = "WEAPON",
		lv         = 4,
		value      = { money=1000 },
		condition  = { construction={type="SMITHY"} },
		costs      = { time=100, resources={ IRON_ORE={value=100} } },
		atkAction  = { hit={mod=10}, agi={ratio=0.8}, dmg={} },
	},

	[2000] =
	{
		name       = "软猬甲",
		type       = "ARMOR",
		lv         = 4,
		value      = { money=1000 },
		condition  = { construction={type="SMITHY"} },
		costs      = { time=100, resources={ IRON_ORE={value=100} } },
		defAction  = { hit={mod=10}, agi={ratio=0.8}, dmg={} },
	},

	[3000] =
	{
		name       = "鹿皮靴",
		type       = "SHOES",
		lv         = 4,
		value      = { money=1000 },
		condition  = { construction={type="LETHER_FACTORY"} },
	},

	[4000] =
	{
		name       = "玉佩",
		type       = "ACCESSORY",		
		lv         = 2,
		value      = { money=1000 },
		condition  = { construction={type="FACTORY"} },
	},

	[5000] =
	{
		name       = "普通马",
		type       = "VEHICLE",
		lv         = 1,
		value      = { money=500 },
		condition  = { construction={type="PASTURE"} },
		moveAction = { reduce_time=0.3 },
	},
	[5000] =
	{
		name       = "骏马",
		type       = "VEHICLE",
		lv         = 2,
		value      = { money=1500 },
		condition  = { construction={type="PASTURE"} },
		moveAction = { reduce_time=0.45 },
	},
	[5000] =
	{
		name       = "汗血宝马",
		type       = "VEHICLE",
		lv         = 3,
		value      = { money=4000 },
		condition  = { construction={type="PASTURE"} },
		moveAction = { reduce_time=0.6 },
	},
}


for id, equip in pairs( EQUIPMENT_DATATABLE ) do
	equip.id = id
end


--------------------------------------------------
--------------------------------------------------
function EQUIPMENT_DATATABLE_Get( id )
	return EQUIPMENT_DATATABLE[id]
end


--------------------------------------------------
function Equipment_MatchCondition( group, equip )
	--constructions
	if equip.conditions then
		if equip.conditions.constructions then
			for type, value in pairs( equip.conditions.constructions ) do
				if group:GetNumOfConstruction( nil, id ) <= 0 then return false end
			end		
		end
	end

	--costs
	if equip.costs then
		if equip.costs.resources then
			for type, data in pairs( equip.costs.resources ) do
				if group:GetNumOfResource( type ) < data.value then return false end
			end
		end
	end

	return true
end


--------------------------------------------------
function EQUIPMENT_DATATABLE_Find( group, type )
	local list = {}
	for _, equip in pairs( EQUIPMENT_DATATABLE ) do
		if not types or type == equip.type then
			if Equipment_MatchCondition( group, equip ) then
				table.insert( list, equip )
			end
		end
	end
	return list
end