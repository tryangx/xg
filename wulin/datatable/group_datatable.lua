--------------------------------------------------
-- ID: xxx-yyy
--     xxx scenario id
--     yyy group
-- e.g.
--     001001001 Shaolin Luohan Fist
--     002002001 Wudang Fist
--------------------------------------------------
local GROUP_DATATABLE =
{
	[1] =
	{
		name     = "少林派",
		size     = "MID",
		assets   = { land=200 },
		lands    = { JUNGLELAND=20, FARMLAND=100, WOODLAND=10, STONELAND=10, MINELAND=10 },
		--constructions = { 400, 410, 500, 510, 600, 610, 700, 710 },
	},
	--[[
	[2] =
	{
		name    = "武当派",
		size     = "MID",
		assets   = { land=200 },
		lands    = { FARMLAND=100, WOODLAND=10, STONELAND=10, MINELAND=10 },
	},
	[3] =
	{
		name    = "丐帮",
		size     = "MID",
		assets   = { land=200 },
		lands    = { FARMLAND=100, WOODLAND=10, STONELAND=10, MINELAND=10 },
	},
	--]]
}
--[[
{
	--------------------------------------------------
	--     Org   Size   
	-- 门  +     +
	-- 派  +     ++
	-- 帮  -     +++
	-- 会  ++    ++
	--------------------------------------------------
	[1] =
	{
		name    = "少林派", 
	},
	[2] =
	{
		name    = "武当派",
	},
	[3] =
	{
		name    = "丐帮",
	},
	[10] =
	{
		name    = "华山派",
	},
	[11] =
	{
		name    = "恒山派",
	},
	[12] =
	{
		name    = "嵩山派",
	},
	[13] =
	{
		name    = "泰山派",
	},
	[15] =
	{
		name    = "衡山派",
	},
	[20] =
	{
		name    = "崆峒派",
	},
	[21] =
	{
		name    = "青城派",
	},
	[22] =
	{
		name    = "昆仑派",
	},
	[23] =
	{
		name    = "天山派",
	},
	--------------------------------------------------
	--天龙八部
	--------------------------------------------------
	[30] =
	{
		name    = "逍遥派",
	},
	[31] =
	{
		name    = "灵鹫宫",
	},
	[32] =
	{
		name    = "星宿派",
	},	
	[33] =
	{
		name    = "无量剑派",
	},				
	[34] =
	{
		name    = "大理天龙寺",
	},
	[35] =
	{
		name    = "姑苏慕容",
	},
	[36] =
	{
		name    = "西夏一品堂",
	},	
	[37] =
	{
		name    = "大轮寺",
	},
	[38] =
	{
		name    = "蓬莱派",
	},	
	[39] =
	{
		name    = "伏牛派",
	},
}

]]


--------------------------------------------------
--------------------------------------------------
function GROUP_DATATABLE_Get( id )
	return GROUP_DATATABLE[id]
end


--------------------------------------------------
--------------------------------------------------
function GROUP_DATATABLE_Foreach( fn )
	for id, group in pairs( GROUP_DATATABLE ) do
		fn( group )
	end
end