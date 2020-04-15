--------------------------------------------------
--------------------------------------------------
local BOOK_DATATABLE = 
{
	[20] =
	{
		name         = "管理学",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "MANAGEMENT",
	},
	[30] =
	{
		name         = "战略入门",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "STRATEGIC",
	},
	[40] =
	{
		name         = "战术入门",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "TACTIC",
	},

	[100] =
	{
		name         = "采集",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "COLLLECTER",
	},
	[110] =
	{
		name         = "钓鱼",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "FISHER",
	},
	[120] =
	{
		name         = "农耕",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "FARMER",
	},
	[130] =
	{
		name         = "采矿",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "MINER",
	},
	[140] =
	{
		name         = "冶炼",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "BLACKSMITH",
	},
	[150] =
	{
		name         = "工具制造",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "TOOLMAKER",
	},
	[160] =
	{
		name         = "建筑",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "BUILDER",
	},
	[170] =
	{
		name         = "裁缝",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "TAILOR",
	},
	[180] =
	{
		name         = "木工",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "CARPENTER",
	},
	[190] =
	{
		name         = "放牧",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "HERDSMAN",
	},
	[200] =
	{
		name         = "畜牧",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "STOCKMAN",
	},
	[210] =
	{
		name         = "种植",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "GROWER",
	},
	[220] =
	{
		name         = "医术",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "MEDIC",
	},
	[230] =
	{
		name         = "草药学",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "APOTHECARIES",
	},

	[400] =
	{
		name         = "领导力",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "LEADERSHIP",
	},
	[410] =
	{
		name         = "教育",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "TEACHER",
	},
	[420] =
	{
		name         = "说客",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "LOBBYIST",
	},
	[430] =
	{
		name         = "谈判术",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "NEGOTIATION",
	},
	[440] =
	{
		name         = "骗术",
		lv           = 1,
		type         = "BOOK",
		commonskill  = "CHEATER",
	},

	[1000] =
	{
		name         = "九阴真经",
		lv           = 1,
		type         = "BOOK",
		passiveskill = 100,
	},

	[2000] =
	{
		name         = "太祖长拳",
		lv           = 1,
		type         = "BOOK",
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