--------------------------------------------------
--
-- ID: xxx-yyy-zz
--     xxx is the scenario id
--     yyy is the group
--     zz is the index
--
--
--------------------------------------------------
local ROLE_DATATALBE = 
{
	[1] =
	{
		--FOLLOWER DATA
		name      = "甲等弟子",
		age       = 16,
		template  = 1000120,
		mentals   = {},
		statuses  = {},
	},
	[2] =
	{
		--FOLLOWER DATA
		name      = "乙等弟子",
		age       = 14,
		template  = 1000120,
		mentals   = {},
		statuses  = {},
	},
	[3] =
	{
		--FOLLOWER DATA
		name      = "丙等弟子",
		age       = 14,
		template  = 1000120,
		mentals   = {},
		statuses  = {},
	},

	[1003001] =
	{
		--FOLLOWER DATA
		name      = "肖峰",
		age       = 35,
		lv        = 70,
		template  = 1003001,
		mentals   = {},
		statuses  = {},
	},

	[101] =
	{
		--FOLLOWER DATA
		name      = "虚竹",
		age       = 28,
		template  = 1001001,
		mentals   = {},
		statuses  = {},
	},

	[102] =
	{
		--FOLLOWER DATA
		name      = "段誉",
		age       = 25,		
		template  = 1034001,
		mentals   = {},
		statuses  = {},
	},


	[110] =
	{
		--FOLLOWER DATA
		name      = "慕容复",
		age       = 30,
		template  = 1000101,
		mentals   = {},
		statuses  = {},
	},

	[111] =
	{
		--FOLLOWER DATA
		name      = "邓百川",
		age       = 36,
		template  = 1000110,
		mentals   = {},
		statuses  = {},
	},
}


--------------------------------------------------
--------------------------------------------------
function ROLE_DATATABLE_Get( id )
	return ROLE_DATATALBE[id]
end


--------------------------------------------------
--------------------------------------------------
function ROLE_DATATABLE_Foreach( fn )
	for id, role in pairs( ROLE_DATATALBE ) do
		role.id = id
		fn( role )
	end
end