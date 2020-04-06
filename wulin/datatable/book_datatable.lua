--------------------------------------------------
--------------------------------------------------
local BOOK_DATATABLE = 
{
	[100] =
	{
		name         = "医术",
		lv           = 1,
		commonskill  = "MEDIC",
	},

	[1000] =
	{
		name         = "太祖长拳",
		lv           = 1,
		fightskill   = 100,
	},
}

--------------------------------------------------
--------------------------------------------------
function BOOK_DATATABLE_Get( id )
	return BOOK_DATATABLE[id]
end


--------------------------------------------------
function BOOK_DATATABLE_Add( id, book )
	BOOK_DATATABLE[id] = book
end