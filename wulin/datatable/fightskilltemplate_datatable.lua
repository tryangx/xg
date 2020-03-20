local FIGHTSKILLTEMPLATE_DATATABLE =
{
	[100] =
	{
		name   = "初级拳法",
		lv     = 1,
		weapon = { range="CLOSE", subtype="FIST" },
		step   = { min=6, max=8 },
		cost   = { st_std=4, mp_std=0 },
		actions=
		{
			atk={ std=60, min=-4, max=6, step=5 },
			def={ std=50, min=-2, max=5, step=5 },
			acc={ std=40, min=-2, max=5, step=5 },
			pose={ CENTER=400, LOWER=-200, UPPER=200 },
			elem={ INTERNAL=-1000 },
		},
	},	
	[101] =
	{
		name    = "中级拳法",
		lv     = 4,
		weapon = { range="CLOSE", subtype="FIST" },
		step   = { min=8, max=10 },
		cost   = { st_std=6, mp_std=4 },
		actions=
		{
			atk={ std=80, min=-3, max=6, step=5 },
			def={ std=60, min=-2, max=4, step=5 },
			acc={ std=45, min=-2, max=4, step=5 },
			pose={ CENTER=300, LOWER=-100, UPPER=100 },
			elem={ INTERNAL=-500 },
		},
	},
	[102] =
	{
		name = "高级拳法",
		lv     = 7,
		weapon = { range="CLOSE", subtype="FIST" },
		step   = { min=8, max=12 },
		cost   = { st_std=6, mp_std=6 },
		actions=
		{
			atk={ std=100, min=-3, max=6, step=5 },
			def={ std=80, min=-2, max=4, step=5 },
			acc={ std=50, min=-2, max=4, step=5 },
			pose={ CENTER=0, LOWER=0, UPPER=0 },
			elem={ INTERNAL=-200 },
		},
	},
	[103] =
	{
		name = "顶级拳法",
		lv     = 7,
		weapon = { range="CLOSE", subtype="FIST" },
		step   = { min=9, max=12 },
		cost   = { st_std=8, mp_std=8 },
		actions=
		{
			atk={ std=100, min=-4, max=4, step=5 },
			def={ std=85, min=-2, max=4, step=5 },
			acc={ std=60, min=-2, max=4, step=5 },
			pose={ CENTER=0, LOWER=0, UPPER=0 },
			elem={},
		},
	},
	[100002100] =
	{
		name = "太极拳",
		lv     = 9,
		weapon = { range="CLOSE", subtype="FIST" },
		step   = { min=8, max=8 },
		cost   = { st_std=10, mp_std=15 },
		actions=
		{
			atk={ std=90, min=-2, max=4, step=5 },
			def={ std=90, min=-2, max=4, step=5 },
			acc={ std=70, min=-2, max=2, step=5 },
			pose={ CENTER=0, LOWER=0, UPPER=0 },
			elem={ STRENGTH=-500 },
		},
	},
	[100003100] =
	{
		name = "降龙十八掌",
		lv     = 4,
		weapon = { range="CLOSE", subtype="PALM" },
		step   = { min=18, max=18 },
		cost   = { st_std=15, mp_std=5 },
		actions=
		{
			atk={ std=100, min=-2, max=4, step=5 },
			def={ std=80, min=-2, max=4, step=5 },
			acc={ std=45, min=-2, max=2, step=5 },
			pose={ CENTER=0, LOWER=0, UPPER=0 },
			elem={ INTERNAL=-500 },
		},
	},
	[100030100] =
	{
		name = "天山六阳掌",
		lv     = 4,
		weapon = { range="CLOSE", subtype="PALM" },
		step   = { min=11, max=11 },
		cost   = { st_std=10, mp_std=10 },
		actions=
		{
			atk={ std=100, min=-8, max=6, step=5 },
			def={ std=120, min=-2, max=4, step=5 },
			acc={ std=60, min=-2, max=4, step=5 },
			pose={ CENTER=-900, LOWER=-900, UPPER=-900, ALL=2400, NONE=300 },
			elem={},
		},
	},
	[100030101] =
	{
		name = "天山折梅手",
		lv     = 4,
		weapon = { range="CLOSE", subtype="PALM" },
		step   = { min=11, max=11 },
		cost   = { st_std=10, mp_std=10 },
		actions=
		{
			atk={ std=100, min=-8, max=6, step=5 },
			def={ std=120, min=-2, max=4, step=5 },
			acc={ std=60, min=-2, max=4, step=5 },
			pose={ CENTER=-900, LOWER=-900, UPPER=-900, ALL=2400, NONE=300 },
			elem={},
		},
	},
	[100034100] =
	{
		name = "六脉神剑",
		lv     = 4,
		weapon = { range="FLY", subtype="FINGER" },
		step   = { min=12, max=12 },
		cost   = { st_std=5, mp_std=20 },
		actions=
		{
			atk={ std=120, min=-10, max=6, step=5 },
			def={ std=80, min=-2, max=4, step=5 },
			acc={ std=50, min=-2, max=4, step=5 },
			cri={ std=20 },
			pose={ CENTER=0, LOWER=0, UPPER=0 },
			elem={ STRENGTH=-1000 },
		},
	},

	[300] =
	{
		name = "低级剑法",
		lv     = 1,
		weapon = { range="MID", subtype="SWORD" },
		step   = { min=6, max=8 },
		cost   = { st_std=4, mp_std=2 },
		actions=
		{
			atk={ std=70, min=-6, max=6, step=5 },
			def={ std=50, min=-2, max=4, step=5 },
			acc={ std=40, min=-2, max=2, step=5 },
			pose={ CENTER=0, LOWER=0, UPPER=0 },
			elem={ INTERNAL=-500 },
		},
	},

	[301] =
	{
		name = "中级剑法",
		lv     = 2,
		weapon = { range="MID", subtype="SWORD" },
		step   = { min=6, max=8 },
		cost   = { st_std=6, mp_std=4 },
		actions=
		{
			atk={ std=70, min=-6, max=6, step=5 },
			def={ std=60, min=-2, max=4, step=5 },
			acc={ std=45, min=-2, max=2, step=5 },
			pose={ CENTER=0, LOWER=0, UPPER=0 },
			elem={ INTERNAL=-500 },
		},
	},

	[302] =
	{
		name = "高级剑法",
		lv     = 3,
		weapon = { range="MID", subtype="SWORD" },
		step   = { min=6, max=8 },
		cost   = { st_std=6, mp_std=8 },
		actions=
		{
			atk={ std=80, min=-6, max=6, step=5 },
			def={ std=70, min=-2, max=4, step=5 },
			acc={ std=50, min=-2, max=2, step=5 },
			pose={ CENTER=0, LOWER=0, UPPER=0 },
			elem={ INTERNAL=-500 },
		},
	},

	[200000310] =
	{
		name = "独孤九剑",
		lv     = 4,
		weapon = { range="MID", subtype="SWORD" },
		step   = { min=9, max=9 },
		cost   = { st_std=10, mp_std=5 },
		actions=
		{
			atk={ std=100, min=-2, max=2, step=5 },
			def={ std=100, min=-2, max=2, step=5 },
			acc={ std=70, min=-2, max=2, step=5 },
			pose={ CENTER=0, LOWER=0, UPPER=0, ALL=4000, NONE=1000 },
			elem={ INTERNAL=-500 },
		},
	},
}

function FIGHTSKILLTEMPLATE_DATATABLE_Get( id )
	return FIGHTSKILLTEMPLATE_DATATABLE[id]
end