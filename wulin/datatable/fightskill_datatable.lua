--------------------------------------------------
--------------------------------------------------
local FIGHTSKILL_DATATABLE = 
{
	[100] =
	{
		name    = "武当长拳",
		lv      = 1,
		cost    = { type="ST", using=10, defend=10 },
		weapon  = { type="CLOSE", subtype="FIST" },
		acttime = 1000,
		actions = {
                    { attack=100, accuracy=50, defense=50, pose="UPPER", element="PHY" },
                    { attack=100, accuracy=50, defense=50, pose="UPPER", element="PHY" },
                    { attack=100, accuracy=50, defense=50, pose="UPPER", element="PHY" },
                    { attack=100, accuracy=50, defense=50, pose="UPPER", element="PHY" },
                    { attack=100, accuracy=50, defense=50, pose="UPPER", element="PHY" },
				  },
	},

	[120] =
	{
		name    = "太极拳",
		lv      = 1,
		cost    = { type="MP", using=20, defend=10 },
		weapon  = { type="CLOSE", subtype="FIST" },
		acttime = 1000,
		actions = {
                    { attack=100, accuracy=50, defense=50, pose="UPPER", element="INT" },
                    { attack=100, accuracy=50, defense=50, pose="UPPER", element="INT" },
                    { attack=100, accuracy=50, defense=50, pose="UPPER", element="INT" },
                    { attack=100, accuracy=50, defense=50, pose="UPPER", element="INT" },
                    { attack=100, accuracy=50, defense=50, pose="UPPER", element="INT" },
				  },
	},
}


--------------------------------------------------
--------------------------------------------------
function FIGHTSKILL_DATATABLE_Get( id )
	return FIGHTSKILL_DATATABLE[id]
end