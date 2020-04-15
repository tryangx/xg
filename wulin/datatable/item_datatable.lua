--------------------------------------------------
--------------------------------------------------
local ITEM_DATATABLE = 
{
	[100] =
	{
		name = "跌打丸",
		type = "MEDICINE",
		lv   = 2,
		effect = { hp={percent=0.2, limit=0.8}},
	},
	[110] =
	{
		name = "大力跌打丸",
		type = "MEDICINE",
		lv   = 3,
		effect = { hp={percent=0.2, limit=0.8}},
	},
	[120] =
	{
		name = "神奇跌打丸",
		type = "MEDICINE",
		lv   = 5,
		effect = { hp={percent=0.2, limit=0.8}},
	},
}


--------------------------------------------------
function ITEM_DATATABLE_Get( id )
	return ITEM_DATATABLE[id]
end


--------------------------------------------------
function ITEM_DATATABLE_Find( group, type )
	local list = {}
	for _, item in pairs( ITEM_DATATABLE ) do
		if not types or type == item.type then
			table.insert( list, equip )
		end
	end
	return list
end
