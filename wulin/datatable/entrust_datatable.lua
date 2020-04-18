--------------------------------------------------
--------------------------------------------------
local ENTRUST_DATATABLE = 
{
	[1000] = 
	{
		name = "收购药品",
		type = "NEED_ITEM",
		pool =
		{
			{ itemtype="MEDICINE", itemid=100, reward=100, prob=30 },
			{ itemtype="MEDICINE", itemid=110, reward=150, prob=20 },
			{ itemtype="MEDICINE", itemid=120, reward=200, prob=10 },
		},
		time = { valid=30, finish=30, cd=10, maxcd=100 }, conditions = { eval={ min=0, max=200 }, facility={} },
	},

	[1100] = 
	{
		name = "收购资源",
		type = "NEED_RESOURCE",
		pool =
		{
			{ restype="FOOD",      quantity=100, reward=100, prob=30 },
			{ restype="MEAT",      quantity=100, reward=100, prob=30 },
			{ restype="FISH",      quantity=100, reward=100, prob=30 },
			{ restype="FRUIT",     quantity=100, reward=100, prob=30 },
			{ restype="HERB",      quantity=100, reward=100, prob=30 },
			{ restype="LIVESTOCK", quantity=100, reward=100, prob=30 },
			{ restype="CLOTH",     quantity=100, reward=100, prob=30 },
			{ restype="LEATHER",   quantity=100, reward=100, prob=30 },
			{ restype="LUMBER",    quantity=100, reward=100, prob=30 },
			{ restype="WOOD",      quantity=100, reward=100, prob=30 },
			{ restype="STONE",     quantity=100, reward=100, prob=30 },
			{ restype="MABLE",     quantity=100, reward=100, prob=30 },
			{ restype="IRON_ORE",  quantity=100, reward=100, prob=30 },
			{ restype="STEEL",     quantity=100, reward=100, prob=30 },
			{ restype="DARKSTEEL", quantity=100, reward=100, prob=30 },
		},
		time = { valid=90, finish=30, cd=10, maxcd=100 },
		conditions = { eval={ min=0, max=200 }, },
	},

	[1100] = 
	{
		name = "收购装备",
		type = "NEED_EQUIPMENT",
		pool =
		{
			{ itemtype="WEAPON", itemid=1000, quantity=1, reward=100, prob=30 },
			{ itemtype="WEAPON", itemid=1001, quantity=1, reward=100, prob=30 },
			{ itemtype="ARMOR",  itemid=2000, quantity=1, reward=100, prob=30 },
		},
		time = { valid=90, finish=30, cd=10, maxcd=100 },
		conditions = { eval={ min=0, max=200 }, },
	},

--[[
	[2000] = 
	{
		name = "支援请求",
		type = "NEED_SKILL",
		pool = 
		{
			{ need_commonskill={type="STRATEGIC", lv=1}, need_fightskill={id=100}, need_lv=10, need_follower=1, reward=100, prob=100 },
		},
		time = { valid=30, finish=30, cd=10, maxcd=100 },
		conditions = { eval={ min=0, max=200 }, },
	},

	[3000] = 
	{
		name = "护卫",
		type = "NEED_PROTECT",
		pool = 
		{
			{ diffculty=10, need_follower=1, reward=100, prob=100 },
			{ diffculty=20, need_follower=1, reward=100, prob=100 },
			{ diffculty=30, need_follower=2, reward=100, prob=100 },
			{ diffculty=40, need_follower=2, reward=100, prob=100 },
		},
		time = { valid=30, finish=30, cd=10, maxcd=100 },
		conditions = { eval={ min=0, max=200 }, },
	},

	[4000] = 
	{
		name = "刺杀",
		type = "ASSASIN",
		pool = 
		{
			{ diffculty=10, need_follower=1, reward=100, prob=100 },
		},
		time = { valid=60, finish=30, cd=10, maxcd=100 },
		conditions = { eval={ min=0, max=200 }, },
	},
	]]
}

for id, entrust in pairs( ENTRUST_DATATABLE ) do
	entrust.id = id
end

---------------------------------------
---------------------------------------
function ENTRUST_DATATABLE_Get( id )
	return ENTRUST_DATATABLE[id]
end


---------------------------------------
---------------------------------------
local function Entrust_MatchCondition( cityCmp, entrust )
	if not entrust.conditions then return false end

	if entrust.conditions.facility then
		for _, data in ipairs( entrust.conditions.facility ) do
			cityCmp:GetNumOfFacility( data.type, data.id )
		end
	end

	return true
end


function ENTRUST_DATATABLE_Find( cityCmp, entrustCmp )
	local list = {}
	for _, entrust in pairs( ENTRUST_DATATABLE ) do
		if not entrustCmp:IsInCooldown( entrust.type ) then
			if Entrust_MatchCondition( cityCmp, entrust ) then
				table.insert( list, entrust )
			end
		end
	end
	return list
end


function Entrust_CanTake( groupCmp, cityCmp, entrust )
	if entrust.conditions.eval then
		local viewpoint = cityCmp:GetGroupViewPoint( groupCmp )
		--print( "can take", viewpoint.eval, entrust.conditions.eval.min, entrust.conditions.eval.max )
		if viewpoint.eval < entrust.conditions.eval.min or viewpoint.eval > entrust.conditions.eval.max then return false end			
	end

	return true
end


function Entrust_IsFollowerMatch( ecsid, entrust, poolIndex )		
	local role = ECS_FindComponent( ecsid, "ROLE_COMPONENT" )
	local fighter = ECS_FindComponent( ecsid, "FIGHTER_COMPONENT" )
	local poolData = entrust.pool[poolIndex]
	
	if poolData.need_commonskill and not role:HasCommonSkill( poolData.need_commonskill.type, poolData.need_commonskill.id ) then return false end
	if poolData.need_fightskill and not fighter:HasFightSkill( poolData.need_commonskill.id ) then return false end
	if poolData.need_lv and fighter.lv < poolData.need_lv then return false end

	return true
end