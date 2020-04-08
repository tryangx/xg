--------------------------------------------------
--------------------------------------------------
local BOOK_DATATABLE = 
{
	[20] =
	{
		name         = "管理学",
		lv           = 1,
		commonskill  = "MANAGEMENT",
	},
	[30] =
	{
		name         = "战略入门",
		lv           = 1,
		commonskill  = "STRATEGIC",
	},
	[40] =
	{
		name         = "战术入门",
		lv           = 1,
		commonskill  = "TACTIC",
	},

	[100] =
	{
		name         = "采集",
		lv           = 1,
		commonskill  = "COLLLECTING",
	},
	[110] =
	{
		name         = "钓鱼",
		lv           = 1,
		commonskill  = "FISHER",
	},
	[120] =
	{
		name         = "农耕",
		lv           = 1,
		commonskill  = "FARMER",
	},
	[130] =
	{
		name         = "采矿",
		lv           = 1,
		commonskill  = "MINER",
	},
	[140] =
	{
		name         = "冶炼",
		lv           = 1,
		commonskill  = "BLACKSMITH",
	},
	[150] =
	{
		name         = "工具制造",
		lv           = 1,
		commonskill  = "TOOLMAKER",
	},
	[160] =
	{
		name         = "建筑",
		lv           = 1,
		commonskill  = "BUILDER",
	},
	[170] =
	{
		name         = "裁缝",
		lv           = 1,
		commonskill  = "TAILOR",
	},
	[180] =
	{
		name         = "木工",
		lv           = 1,
		commonskill  = "CARPENTER",
	},
	[190] =
	{
		name         = "放牧",
		lv           = 1,
		commonskill  = "HERDSMAN",
	},
	[200] =
	{
		name         = "畜牧",
		lv           = 1,
		commonskill  = "STOCKMAN",
	},
	[210] =
	{
		name         = "种植",
		lv           = 1,
		commonskill  = "GROWER",
	},
	[220] =
	{
		name         = "医术",
		lv           = 1,
		commonskill  = "MEDIC",
	},
	[230] =
	{
		name         = "草药学",
		lv           = 1,
		commonskill  = "APOTHECARIES",
	},

	[400] =
	{
		name         = "领导力",
		lv           = 1,
		commonskill  = "LEADERSHIP",
	},
	[410] =
	{
		name         = "教育",
		lv           = 1,
		commonskill  = "TEACHER",
	},
	[420] =
	{
		name         = "说客",
		lv           = 1,
		commonskill  = "LOBBYIST",
	},
	[430] =
	{
		name         = "谈判术",
		lv           = 1,
		commonskill  = "NEGOTIATION",
	},
	[440] =
	{
		name         = "骗术",
		lv           = 1,
		commonskill  = "CHEATER",
	},

	[1000] =
	{
		name         = "九阴真经",
		lv           = 1,
		passiveskill = 100,
	},

	[2000] =
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