--------------------------------------------------
--------------------------------------------------
local ROLE_DATATALBE = 
{
	[100] =
	{
		--FOLLOWER DATA
		name      = "萧峰",
		age       = 35,

		--FIGHTER DATA
		hp        = 9000,
		mp        = 260,
		st        = 280,
 
		vital     = 85,
		physical  = 85,
		internal  = 70,
		strength  = 85,
		technique = 75,
		agility   = 65,
	
		mentals   = {},

		statuses  = {},

		skills    = { 100, 120 },
	},

	[101] =
	{
		--FOLLOWER DATA
		name      = "肖峰",
		age       = 35,

		--FIGHTER DATA
		hp        = 1000,
		mp        = 260,
		st        = 280,
 
		vital     = 150,
		physical  = 100,
		internal  = 100,
		strength  = 150,
		technique = 150,
		agility   = 150,
	
		mentals   = {},

		statuses  = {},

		skills    = { 100, 120 },
	},

	[110] =
	{
		--FOLLOWER DATA
		name      = "慕容复",
		age       = 30,

		--FIGHTER DATA
		hp        = 5000,
		mp        = 60,
		st        = 60,
 
		vital     = 65,
		physical  = 65,
		internal  = 65,
		strength  = 65,
		technique = 80,
		agility   = 70,
	
		mentals   = {},

		statuses  = {},

		skills    = { 100, 120 },
	},

	[111] =
	{
		--FOLLOWER DATA
		name      = "邓百川",
		age       = 36,

		--FIGHTER DATA
		hp        = 400,
		mp        = 30,
		st        = 40,
 
		vital     = 40,
		physical  = 50,
		internal  = 35,
		strength  = 50,
		technique = 40,
		agility   = 30,
	
		mentals   = {},

		statuses  = {},

		skills    = { 100 },
	},
}


--------------------------------------------------
--------------------------------------------------
function ROLE_DATATABLE_Get( id )
	return ROLE_DATATALBE[id]
end