--------------------------------------------------
--------------------------------------------------
local CONSUMABLE_DATATABLE = 
{
	[10] =
	{
		name = "药品",
		type = "MEDICINE",
		effect = { hp={percent=0.2, limit=0.8}},
	},
}


--------------------------------------------------
function CONSUMABLE_DATATABLE_Get( id )
	return CONSUMABLE_DATATABLE[id]
end


--------------------------------------------------
function CONSUMABLE_DATATABLE_Find( group, type )
	local list = {}
	for _, consumable in pairs( CONSUMABLE_DATATABLE ) do
		if not types or type == consumable.type then
			table.insert( list, equip )
		end
	end
	return list
end
