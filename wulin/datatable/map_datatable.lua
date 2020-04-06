--------------------------------------------------
--------------------------------------------------
local MAP_DATATABLE =
{
	[1] = 
	{
		name    = "江南",
		width   = 10,
		height  = 10,
		grid_array =
		{
			{ }, { }, { }, {},
		},
	},
}

--------------------------------------------------
--------------------------------------------------
function MAP_DATATABLE_Get( id )
	return MAP_DATATABLE[id]
end


--------------------------------------------------
--------------------------------------------------
function MAP_DATATABLE_Foreach( fn )
	for id, role in pairs( MAP_DATATABLE ) do
		role.id = id
		fn( role )
	end
end