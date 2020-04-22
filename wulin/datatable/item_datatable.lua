--------------------------------------------------
--
--
-- Recover bleeding
-- Recover hurt
-- Restore hp,st,mp
-- Cure poison
-- Cure blind
-- Add Buff
-- Add Debuff( poison, blind )
-- Respawn
-- Cure disabled
-- Improve Maximum
--------------------------------------------------
local ITEM_DATATABLE = 
{
	[110] =
	{
		name = "纱布",
		type = "MEDICINE",
		lv   = 1,
		desc = "止血",
		effect = { remove_status={ status="BLEEDING" }, add_status={ status="MEDICINE_RESISTENCE", value=1 } },
	},

	[111] =
	{
		name = "金创药",
		type = "MEDICINE",
		lv   = 2,
		desc = "止血",
		effect = { remove_status={ status="BLEEDING" }, add_status={ status="MEDICINE_RESISTENCE", value=2 } },
	},
	[112] =
	{
		name = "强效金创药",
		type = "MEDICINE",
		lv   = 2,
		effect = { remove_status={ status="BLEEDING" }, add_status={ status="MEDICINE_RESISTENCE", value=3 } },
	},

	[120] =
	{
		name = "跌打丸",
		type = "MEDICINE",
		lv   = 1,
		desc = "治疗损伤",
		effect = { remove_status={ status="BLEEDING" }, add_status={ status="MEDICINE_RESISTENCE", value=1 } },
	},
	[121] =
	{
		name = "大力跌打丸",
		type = "MEDICINE",
		lv   = 2,
		value  = { money=100 },
		effect = { remove_status={ status="BLEEDING" }, add_status={ status="MEDICINE_RESISTENCE", value=2 } },
	},

	[130] =
	{
		name = "大补丸",
		type = "MEDICINE",
		lv   = 2,
		desc = "回复精力内力",
		effect = { st={percent=0.2, limit=0.6}, mp={percent=0.2, limit=0.6}, add_status={ status="MEDICINE_RESISTENCE", value=3 } },
	},
	[131] =
	{
		name = "十全大补丸",
		type = "MEDICINE",
		lv   = 3,
		effect = { st={percent=0.35, limit=0.8}, mp={percent=0.35, limit=0.8}, add_status={ status="MEDICINE_RESISTENCE", value=4 } },
	},

	[140] =
	{
		name = "续命丸",
		type = "MEDICINE",
		lv   = 2,
		desc = "回复生命",
		effect = { hp={percent=0.25, limit=0.7}, add_status={ status="MEDICINE_RESISTENCE", value=3 } },
	},

	[200] =
	{
		name = "解毒药",
		type = "MEDICINE",
		lv   = 2,
		effect = { remove_status={ status="BLEEDING" }, add_status={ status="MEDICINE_RESISTENCE", value=3 } },
	},
	[201] =
	{
		name = "天心解毒丹",
		type = "MEDICINE",
		lv   = 3,
		effect = { hp={percent=0.2, limit=0.8}, add_status={ status="MEDICINE_RESISTENCE", value=4 } },
	},

	[1000] =
	{
		name = "黑玉断续膏",
		type = "MEDICINE",
		lv   = 4,
		desc = "治疗残疾",
		effect = { hp={percent=0.2, limit=0.8}, add_status={ status="MEDICINE_RESISTENCE", value=5 } },
	},
	[1010] =
	{
		name = "九转还魂丹",
		type = "MEDICINE",
		lv   = 4,
		desc = "复活",
		effect = { hp={percent=0.45, limit=0.9}, add_status={ status="MEDICINE_RESISTENCE", value=5 } },
	},

	[3000] =
	{
		name = "青鱼",
		type = "FOOD",
		lv   = 1,
		desc = "食材",
		effect = {},
	},
	[4000] =
	{
		name = "熊肉",
		type = "FOOD",
		lv   = 1,
		desc = "食材",
		effect = {},
	},
	[5000] =
	{
		name = "珍果",
		type = "FOOD",
		lv   = 1,
		desc = "食材",
		effect = {},
	},
}


--------------------------------------------------
function ITEM_DATATABLE_Get( id )
	return ITEM_DATATABLE[id]
end


--------------------------------------------------
function ITEM_DATATABLE_Find( group, type )
	local list = {}
	for _, item in pairs( ITEM_DATATABLE ) do
		if not types or type == item.type then
			table.insert( list, item )
		end
	end
	return list
end
