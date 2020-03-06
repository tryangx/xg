--------------------------------------------------
--------------------------------------------------
local FIGHTSKILL_DATATABLE = 
{
	[100] =
	{
		name    = "武当长拳",
		lv      = 1,
		cost    = { type="STAMINA", value=2 },
		weapon  = { type="CLOSE", subtype="FIST" },
		actions = {
                    { power=100, hit=50, block=50, pose="UPPER" },
                    { power=100, hit=50, block=50, pose="UPPER" },
                    { power=100, hit=50, block=50, pose="UPPER" },
                    { power=100, hit=50, block=50, pose="UPPER" },
                    { power=100, hit=50, block=50, pose="UPPER" },
				  },
	},
}


--------------------------------------------------
--------------------------------------------------
function FIGHTSKILL_DATATABLE_Get( id )
	return FIGHTSKILL_DATATABLE[id]
end