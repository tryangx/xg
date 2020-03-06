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
		hp        = 100,
		mp        = 60,
		st        = 80,
 
		vital     = 85,
		physical  = 85,
		internal  = 70,
		strength  = 80,
		technique = 70,
		agility   = 60,
	
		mental    = {},

		status    = {},
	},

	[101] =
	{
		--FOLLOWER DATA
		name      = "慕容复",
		age       = 30,

		--FIGHTER DATA
		hp        = 70,
		mp        = 60,
		st        = 60,
 
		vital     = 65,
		physical  = 65,
		internal  = 65,
		strength  = 65,
		technique = 80,
		agility   = 70,
	
		mental    = {},

		status    = {},
	},
}


--------------------------------------------------
--------------------------------------------------
function ROLE_DATATABLE_Get( id )
	return ROLE_DATATALBE[id]
end