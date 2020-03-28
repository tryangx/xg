--------------------------------------------------
--
-- ID: xxx-yyy-zz
--     xxx is the scenario id
--     yyy is the group
--     zz is the index
-- e.g.
--     001001001 Shaolin Luohan Fist
--     002002001 Wudang Fist
--
--------------------------------------------------
local FIGHTSKILL_DATATABLE = 
{
	--------------------------------------------------
	[100] =
	{
		name    = "太祖长拳",
		groupidx=1,
		template= 100,
	},


	[101] =
	{
		name    = "初级拳法",
		groupidx=1,
		template= 100,
	},
	[102] =
	{
		name    = "中级拳法",
		groupidx=1,
		template= 101,
	},
	[103] =
	{
		name    = "高级拳法",
		groupidx=1,
		template= 102,
	},
	[104] =
	{
		name    = "顶级拳法",
		groupidx=1,
		template= 103,
	},

	--------------------------------------------------
	[1100] =
	{
		name    = "罗汉拳",
		groupidx=1,
		template= 100,
	},

	[1101] =
	{
		name    = "金刚拳",
		groupidx=1,
		template= 100,		
	},
	[1102] =
	{
		name    = "金刚掌",
		groupidx=1,
		template= 100,
		weapon  = { range="CLOSE", subtype="PALM" },
	},
	[1103] =
	{
		name    = "金刚指",
		groupidx=1,
		template= 100,
		weapon  = { range="CLOSE", subtype="FINGER" },
	},
	[1110] =
	{
		name    = "摩诃指",
		groupidx=1,
		template= 101,
		weapon  = { range="CLOSE", subtype="FINGER" },
	},
	[1111] =
	{
		name    = "拈花指",
		groupidx=1,
		template= 101,
		weapon  = { range="CLOSE", subtype="FINGER" },
	},	
	[1112] =
	{
		name    = "伏虎拳",
		groupidx=1,
		template= 101,
		weapon  = { range="CLOSE", subtype="FINGER" },
	},
	[1113] =
	{
		name    = "无相劫指",
		groupidx=1,
		template= 101,
		weapon  = { range="CLOSE", subtype="FINGER" },
	},
	[1114] =
	{
		name    = "多罗叶指",
	},
	[1120] =
	{
		name    = "韦陀掌",
	},
	[1500] =
	{
		name    = "少林棍法",
	},


	--------------------------------------------------
	[2001] =
	{
		name    = "武当长拳",
		groupidx=1,
		template= 100,
	},

	[2010] =
	{
		name    = "绵掌",
		groupidx=1,
		template= 101,
	},

	[2011] =
	{
		name    = "八卦游龙掌",
		groupidx=1,
		template= 101,
	},

	[2012] =
	{
		name    = "虎爪绝户手",
		groupidx=2,
		template= 101,
	},

	[2013] =
	{
		name    = "倚天屠龙功",
		groupidx=2,
		template= 101,
	},
	[2014] =
	{
		name    = "无极玄功拳",
		groupidx=2,
		template= 101,
	},
	[2015] =
	{
		name    = "绕指柔指",
	},
	[2100] =
	{
		name    = "太极拳",
		groupidx=2,
		template= 100002100,
	},
	[2300] =
	{
		name    = "柔云剑",
		groupidx=2,
		template= 300,
	},
	[2301] =
	{
		name    = "神门十三剑",
	},
	[2302] =
	{
		name    = "两仪剑法",
	},
	[2310] =
	{
		name    = "太极剑",
	},
	[2400] =
	{
		name    = "玄虚刀法",
	},

	--------------------------------------------------
	[3000] =
	{
		name    = "莲花掌",
		groupidx=3,
		template= 101,
	},
	[3001] =
	{
		name    = "铜锤手",
		groupidx=3,
		template= 102,
	},
	[3002] =
	{
		name    = "铁帚腿法",
	},
	[3010] =
	{
		name    = "降龙十八掌",
		groupidx=3,
		template= 100003100,
	},
	[3011] =
	{
		name    = "擒龙功",
		groupidx=3,
		template= 103,
	},
	[3200] =
	{
		name    = "打狗杖法",
	},
	[3210] =
	{
		name    = "打狗棍法",
	},

	--------------------------------------------------
	[30000] =
	{
		name    = "天山六阳掌",
		groupidx=30,
		template= 100030100,
	},
	[30001] =
	{
		name    = "天山折梅手",
		groupidx=30,
		template= 100030101,
	},


	--------------------------------------------------
	[34001] =
	{
		name    = "段氏剑法",
		groupidx=34,
		template= 300,
	},
	[34002] =
	{
		name    = "一阳指",
		groupidx=34,
		template= 103,
	},

	[34001] =
	{
		name    = "六脉神剑",
		groupidx=34,
		template= 100034100,
	},

	--------------------------------------------------
}
--]]
--[[
		comboeffects = {
                     { name="卸力", cate="120_1", prob=1000, combo=2,
                       buffs={
                       			{ target="SELF", effects = {
												            { status="STRENGTH_ENHNACED", value_percent=20, value=0, duration=10 },
												            { status="INTERNAL_ENHANCED", value_percent=20, value=0, duration=10 },
												            { status="TECHNIQUE_ENHANCED", value_percent=0, value=100, duration=8 },
                       				 		               },
                       			},
                    			{ target="TARGET", effects = {
																{ status="STRENGTH_WEAKEN", value_percent=20, value=0, duration=10 },
																{ status="INTERNAL_WEAKEN", value_percent=20, value=0, duration=10 },
															},
                                },
							},
                     },                     
	              },
	              --]]


--------------------------------------------------
--------------------------------------------------
function FIGHTSKILL_DATATABLE_Get( id )
	return FIGHTSKILL_DATATABLE[id]
end


--------------------------------------------------
--------------------------------------------------
function FIGHTSKILL_DATATABLE_Foreach( fn )
	for id, skill in pairs( FIGHTSKILL_DATATABLE ) do
		skill.id = id
		fn( skill )
	end
end


--------------------------------------------------
function FIGHTSKILL_DATATABLE_Add( id, skill )
	FIGHTSKILL_DATATABLE[id] = skill
end