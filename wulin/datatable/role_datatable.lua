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
		category  = 0,
		rank      = "SENIOR",
		template  = 1000120,
		mentals   = {},
		statuses  = {},
		passiveSkills = { 100, 1000 },
	},
	[2] =
	{
		--FOLLOWER DATA
		name      = "乙等弟子",
		age       = 14,
		category  = 0,
		rank      = "JUNIOR",
		template  = 1000120,
		mentals   = {},
		statuses  = {},
		passiveSkills = { 100, 1000 },
	},
	[3] =
	{
		--FOLLOWER DATA
		name      = "丙等弟子",
		age       = 14,
		category  = 0,
		rank      = "JUNIOR",
		template  = 1000120,
		mentals   = {},
		statuses  = {},
		passiveSkills = { 100, 1000 },
	},
	[10] =
	{
		--FOLLOWER DATA
		name      = "掌门",
		age       = 42,
		category  = 0,
		rank      = "ELDER",
		template  = 1000120,
		mentals   = {},
		statuses  = {},
		passiveSkills = { 100, 1000 },
	},
	[11] =
	{
		--FOLLOWER DATA
		name      = "长老",
		age       = 41,
		category  = 0,
		rank      = "ELDER",
		template  = 1000120,
		mentals   = {},
		statuses  = {},
		passiveSkills = { 100, 1000 },
	},

	[1003001] =
	{
		--FOLLOWER DATA
		name      = "肖峰",
		age       = 35,
		lv        = 70,
		category  = 1,
		template  = 1003001,
		mentals   = {},
		statuses  = {},
	},

	[101] =
	{
		--FOLLOWER DATA
		name      = "虚竹",
		age       = 28,
		category  = 1,
		template  = 1001001,
		mentals   = {},
		statuses  = {},
	},

	[102] =
	{
		--FOLLOWER DATA
		name      = "段誉",
		age       = 25,		
		category  = 1,
		template  = 1034001,
		mentals   = {},
		statuses  = {},
	},


	[110] =
	{
		--FOLLOWER DATA
		name      = "慕容复",
		age       = 30,
		category  = 1,
		template  = 1000101,
		mentals   = {},
		statuses  = {},
	},

	[111] =
	{
		--FOLLOWER DATA
		name      = "邓百川",
		age       = 36,
		category  = 1,
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

--[[
木婉清（结发）
钟灵（贤妃）
晓蕾（淑妃）
段正明
段正淳
段延庆（恶贯满盈）
刀白凤(皇妃)
秦红棉
甘宝宝
阮星竹
王夫人（阿萝）
王语嫣
高升泰
巴天石
华赫艮
范骅
褚万里
古笃诚
傅思归
朱丹臣
南海鳄神（凶神恶煞）
云中鹤（穷凶极恶）
钟万仇
崔百泉
过彦之
枯荣大师
本因
本观
本相
本参
黄眉大师
破疑
破嗔
鸠摩智

]]