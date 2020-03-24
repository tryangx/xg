local ROLETEMPLATE_DATATABLE =
{
	[1] =
	{
		name    = "", 
	},
	[2] =
	{
		name    = "",
	},
	[3] =
	{
		name    = "丐帮",
	},
}

--------------------------------------------------
--------------------------------------------------
function ROLETEMPLATE_DATATABLE_Get( id )
	return ROLETEMPLATE_DATATABLE[id]
end


--------------------------------------------------
--------------------------------------------------
function ROLETEMPLATE_DATATABLE_Add( data )
	ROLETEMPLATE_DATATABLE[data.id] = data
end

