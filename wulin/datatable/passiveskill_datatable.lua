---------------------------------------
--
-- Passive skill
--
--   (Learning)Conditions
--     Level     
--     level
--     knowledge
--
--   atkAction   : trigger before attack
--   defAction   : trigger before defend. 
--   restAction  : trigger when rest
--   buffAction  : trigger when gain buff?
--   debuffAction: trigger when gain debuff?
--
---------------------------------------
local PASSIVESKILL_DATATABLE =
{
	[100] =
	{
		name         = "梯云纵",
		type         = "MOVEMENT",
		conditions   = {knowledge=100, lv=20},
		defAction    = {prob=45, cd={max=100,step=30}, dodge={times=3, mod=10}},
	},
	[101] =
	{
		name         = "凌波微步",
		type         = "MOVEMENT",
		conditions   = {knowledge=100, lv=20},
		defAction    = {prob=65, cd={max=100,step=30}, dodge={times=1, mod=20}},
	},

	[1000] =
	{
		name         = "混合内功",
		type         = "RESIDENT",
		conditions   = {},
		atkAction    = {cd={max=100,step=30}, hit={times=1,mod=10}, dmg={mod=1.1}},
		restAction   = {cd={max=100,step=30}, hp={max=0.5, ratio=0.05}, mp={max=0.5, ratio=0.05}},
	},
	[1001] =
	{
		name         = "纯阳内功",
		type         = "RESIDENT",
		conditions   = {},		
		restAction   = {cd={max=100,step=30}, hp={max=0.5, ratio=0.05}, mp={max=0.5, ratio=0.05}},
		debuffAction = {cd={max=100,step=30}, buff={reduce_time=0.5, resist_prob=30}},
	},
	[1002] =
	{
		name         = "纯阴内功",
		type         = "RESIDENT",
		conditions   = {},
		afterAction  = {},
		restAction   = {cd={max=100,step=30}, hp={max=0.5, ratio=0.05}, mp={max=0.5, ratio=0.06}},
	},	

	[2000] =
	{
		name         = "九阴真经",
		type         = "RESIDENT",
		conditions   = {},
		atkAction    = {dmg={mod=1.1}},
		restAction   = {cd={max=100,step=30}, hp={max=0.5, ratio=0.05}, mp={max=0.5, ratio=0.06}},
	},

	[2001] =
	{
		name         = "九阳真经",
		type         = "RESIDENT",
		conditions   = {},
		buffAction   = {resist_prob=50, reduce_time=0.5},
		restAction   = {cd={max=100,step=30}, hp={max=0.5, ratio=0.05}, mp={max=0.5, ratio=0.06}},
	},
}


for id, skill in pairs( PASSIVESKILL_DATATABLE ) do
	skill.id = id
end

--------------------------------------------------
--------------------------------------------------
function PASSIVESKILL_DATATABLE_Get( id )
	return PASSIVESKILL_DATATABLE[id]
end