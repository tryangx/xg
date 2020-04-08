---------------------------------------
--
-- Passive skill
--
--   (Learning)Conditions
--     Level     
--     level
--     knowledge
--
--   beforeAction: trigger before execute action
--   afterAction : trigger after execute action
--   atkAction   : trigger before attack
--   defAction   : trigger before defend. 
--   restAction  : trigger when rest
--   buffAction  : trigger when gain buff?
--   debuffAction: trigger when gain debuff?
--
--
--   restAction
--
--   AllAction
--     max_cd   when delay assumed
--     step_cd  when skill trigger every time
--     hp.limit
--
---------------------------------------
local PASSIVESKILL_DATATABLE =
{
	[100] =
	{
		name         = "凌波微步",
		type         = "MOVEMENT",
		conditions   = { knowledge=100, lv=20 },
		beforeAction = {},
		atkAction    = {},
		defAction    = {},
	},

	[1000] =
	{
		name         = "混合内功",
		type         = "RESIDENT",
		conditions   = {},
		beforeAction = {},
		restAction   = { max_cd=100, step_cd=30, hp={ max=0.5, percent=0.05 }, mp={ max=0.5, percent=0.05 } },
	},
	[1001] =
	{
		name         = "纯阳内功",
		type         = "RESIDENT",
		conditions   = {},
		afterAction  = {},
		restAction   = { cd={ limit=100, step=30 }, hp={ max=0.5, percent=0.05 }, mp={ max=0.5, percent=0.05 } },
	},
	[1002] =
	{
		name         = "纯阴内功",
		type         = "RESIDENT",
		conditions   = {},
		afterAction  = {},
		restAction   = { delay={ limit=100, step=30 }, hp={ max=0.5, percent=0.05 }, mp={ max=0.5, percent=0.06 } },
	},	

	[2000] =
	{
		name         = "九阴真经",
		type         = "RESIDENT",
		conditions   = {},
		atkAction    = { damage={ modulus={ min=110, max=130 } } },
		restAction   = { delay={ limit=100, step=30 }, hp={ max=0.5, percent=0.05 }, mp={ max=0.5, percent=0.06 } },
	},

	[2001] =
	{
		name         = "九阳真经",
		type         = "RESIDENT",
		conditions   = {},
		buffAction   = { buff={ resist_prob=50, reduce_time=0.5 } },
		restAction   = { delay={ limit=100, step=30 }, hp={ max=0.5, percent=0.05 }, mp={ max=0.5, percent=0.06 } },
	},
}
--------------------------------------------------
--------------------------------------------------
function PASSIVESKILL_DATATABLE_Get( id )
	return PASSIVESKILL_DATATABLE[id]
end
