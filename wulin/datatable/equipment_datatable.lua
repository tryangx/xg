--------------------------------------------------
--------------------------------------------------
local EQUIPMENT_DATATABLE =
{
	[1000] =
	{
		name       = "倚天剑", 		
		type       = "WEAPON",
		value      = { money=1000 },
		condition  = { commonskill="BLACKSMITH" },
		costs      = { time=100, resources={ IRON_ORE={value=100} } },
		atkAction  = { hit={mod=10}, agi={ratio=0.8}, dmg={} },
	},
	--[[
	[1001] =
	{
		name       = "屠龙刀",
		type       = "WEAPON",
		atkAction  = {dmg={}}
	},
	[2000] =
	{
		name       = "软猬甲",
		type       = "ARMOR",
		defAction  = {hit={mod=1}},
	},
	[3000] =
	{
		name       = "鹿皮靴",
		type       = "SHOES",		
	},
	[4000] =
	{
		name       = "玉佩",
		type       = "ACCESSORY",		
	},
	[10000] =
	{
		name       = "汗血宝马",
		type       = "VEHICLE",
		moveAction = {reduce_time=0.5},
	},
	]]
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
local function Equipment_MatchCondition( group, equip )
	if equip.conditions then
		if equip.conditions.constructions then
			for type, value in pairs( equip.conditions.constructions ) do
				if group:GetNumOfConstruction( nil, id ) <= 0 then return false end
			end		
		end
	end

	if equip.costs then
		if equip.costs.resources then
			for type, data in pairs( equip.costs.resources ) do
				if group:GetNumOfResource( type ) < data.value then return false end
			end
		end
	end

	return true
end


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