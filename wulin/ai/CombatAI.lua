----------------------------------------
-- Enviroment & Variables

CombatAIEnviroment = 
{
	COMBAT_INSTANCE = 1,
}

local _combat = nil
local _troop = nil

local _registers = {}

local _task  = nil

local function pause()
	InputUtil_Pause( "debug combat ai~" )
	return true
end

local bp = { type = "FILTER", condition = pause }

----------------------------------------
-- Setter funcitons

local function IsCategory( params )
	local table = Asset_Get( _troop, TroopAssetID.TABLEDATA )
	local category = table and table.category
	return category == TroopCategory[params.category]
end

local function IsFieldCombat()
	return Asset_Get( _combat, CombatAssetID.TYPE ) == CombatType.FIELD_COMBAT
end

local function IsSiegeCombat()
	local type = Asset_Get( _combat, CombatAssetID.TYPE )
	return type == CombatType.SIEGE_COMBAT or type == CombatType.CAMP_FIELD
end

local function IsSiegeAttacker()
	if _troop:GetCombatData( TroopCombatData.SIDE ) == CombatSide.DEFENDER then return false end	
	local type = Asset_Get( _combat, CombatAssetID.TYPE )
	return type == CombatType.SIEGE_COMBAT or type == CombatType.CAMP_FIELD
end

local function IsSiegeDefender()
	if _troop:GetCombatData( TroopCombatData.SIDE ) == CombatSide.ATTACKER then return false end	
	local type = Asset_Get( _combat, CombatAssetID.TYPE )
	return type == CombatType.SIEGE_COMBAT or type == CombatType.CAMP_FIELD
end

local function IsAttacker()
	return _troop:GetCombatData( TroopCombatData.SIDE ) == CombatSide.ATTACKER
end

local function IsDefender()
	return _troop:GetCombatData( TroopCombatData.SIDE ) == CombatSide.DEFENDER
end

local function IsDefenseBroken()
	local oppSide = _combat:GetOppSide( _troop:GetCombatData( TroopCombatData.SIDE ) )
	local ret = _combat:GetStatus( oppSide, CombatStatus.DEFENSE_BROKEN ) == true
	return ret
end

local function IsTargetInRange()
	if _registers["DISTANCE"] > 1 then return false end
	return true
end

local function IsAdvantageous()
	local intense = _combat:GetStat( _troop:GetCombatData( TroopCombatData.SIDE ), CombatStatistic.COMBAT_INTENSE ) or 0
	
	local purpose
	if _troop:GetCombatData( TroopCombatData.SIDE ) == CombatSide.ATTACKER then 
		if _combat:GetStatus( CombatSide.DEFENDER, CombatStatus.SURROUNDED ) == true then
			return true
		end
		purpose = Asset_Get( _combat, CombatAssetID.ATK_PURPOSE )
	elseif _troop:GetCombatData( TroopCombatData.SIDE ) == CombatSide.DEFENDER then
		if _combat:GetStatus( CombatSide.ATTACKER, CombatStatus.SURROUNDED ) == true then
			return true
		end
		purpose = Asset_Get( _combat, CombatAssetID.DEF_PURPOSE )
	end

	--attack when it's advantageous
	if purpose == CombatPurpose.CONSERVATIVE then
		if intense > 0.85 then return true end
	elseif purpose == CombatPurpose.MODERATE then
		if intense > 0.75 then return true end
	elseif purpose == CombatPurpose.AGGRESSIVE then
		if intense > 0.70 then return true end
	end

	--small probability to attack
	local rand = Random_GetInt_Sync( 1, 100 )
	--print( "atck intense=" .. intense * 50, rand )
	if rand < intense * 50 then
		return true
	end
	return false
end

local function IsDowncast( params )
	local morale = Asset_Get( _troop, TroopAssetID.MORALE )
	if morale <= 20 then return true end
	if morale > 50 then return false end
	local ret = Random_GetInt_Sync( 1, 100 ) < ( morale + 20 )
	--if ret == false then InputUtil_Pause( _troop:ToString(), "low morale" ) end
	return ret
end

local function NeedSurrender()	
	local morale = Asset_Get( _troop, TroopAssetID.MORALE )
	return morale <= 0
end

local function IssueTroopTask( params )
	_task = {}
	_task.type   = params.type
	_task.troop  = _troop
	_task.weapon = _registers["WEAPON"]
	--if _task.type ~= CombatTask.STAY and not _task.weapon then InputUtil_Pause( "no weapon", MathUtil_FindName( CombatTask, _task.type ) ) end
	if params.target == true then
		_task.target = _registers["TARGET"]
	end	
	if params.grid == true then
		_task.target = _registers["GRID"]
	end
end

local function SetTroopStatus( params )	
	_troop[params.type] = params.value	
	--InputUtil_Pause( _troop.id, "status=", params.type, params.value )
end

local function SetTroopOrder( params )	
	_troop:SetCombatData( TroopCombatData.ORDER, CombatOrder[params.order] )
	--print( _troop.id, MathUtil_FindName( CombatSide, _troop:GetCombatData( TroopCombatData.SIDE ) ), "order=" .. params.order )
end

----------------------------------------

local function IsFlee()
	return _troop:GetCombatData( TroopCombatData.FLEE ) == true
end

local function IsRetreat()
	return _troop:GetCombatData( TroopCombatData.RETREAT ) == true
end

----------------------------------------

local function CanForcedAttack( ... )
	local morale = Asset_Get( _troop, TroopAssetID.MORALE )
	if morale < 60 then return false end

	local purpose
	if _troop:GetCombatData( TroopCombatData.SIDE ) == CombatSide.ATTACKER then
		purpose = Asset_Get( _combat, CombatAssetID.ATK_PURPOSE )
	elseif _troop:GetCombatData( TroopCombatData.SIDE ) == CombatSide.DEFENDER then
		purpose = Asset_Get( _combat, CombatAssetID.DEF_PURPOSE )
	end

	if purpose == CombatPurpose.CONSERVATIVE then
		return false
	elseif purpose == CombatPurpose.MODERATE then
		return false
	end
	local intense = 0
	if _troop:GetCombatData( TroopCombatData.SIDE ) == CombatSide.ATTACKER then
		intense = _combat:GetStat( CombatSide.ALL, CombatStatistic.ATK_INTENSE )
	elseif _troop:GetCombatData( TroopCombatData.SIDE ) == CombatSide.DEFENDER then
		intense = _combat:GetStat( CombatSide.ALL, CombatStatistic.DEF_INTENSE )
	end
	--InputUtil_Pause( "intense=" .. intense )
	if purpose == CombatPurpose.AGGRESSIVE then
		return intense > 0.4
	end
	return false
end

----------------------------------------
-- Target relative functions

local function ClearTarget()
	_registers["TARGET"] = nil
	return true
end

local function FindNearbyTarget()
	local target = _combat:FindNearbyTarget( _troop )
	if not target then return false end
	_registers["TARGET"] = target
	return true
end

local function FindNearestTarget( ... )
	local target = _combat:FindNearestTarget( _troop )
	if not target then return false end
	_registers["TARGET"] = target
	return true
end

local function FindSiegeTaget( ... )
	local target = _combat:FindSiegeTaget( _troop )
	if not target then return false end
	_registers["GRID"] = target
	return true	
end

local function IsSiegeTargetGate( ... )
	local target = _registers["GRID"]
	return target and target.isGate == true
end

local function CalculateDistanceFromTarget()
	local target = _registers["TARGET"]
	local distance = _combat:CalcDistance( _troop, target )
	_registers["DISTANCE"] = distance
	return true
end

local function CalculateDistanceFromGrid()
	local target = _registers["GRID"]
	local distance = _combat:CalcDistance2( _troop:GetCombatData( TroopCombatData.X_POS ), _troop:GetCombatData( TroopCombatData.Y_POS ), target.x, target.y )
	_registers["DISTANCE"] = distance
	return true
end

----------------------------------------
-- Condition functions

-- Charge Condition
-- 1. Not in defended status
-- 2. Distance is far away
local function CanCharge( ... )
	if _troop:GetCombatData( TroopCombatData.DEFENDED ) == true or _troop:GetCombatData( TroopCombatData.MOVED ) == false then return false end

	if _troop:GetCombatData( TroopCombatData.GRID ) and _troop:GetCombatData( TroopCombatData.GRID ).isWall == true then return false end

	local weapon = _troop:GetWeaponByTask( CombatTask.CHARGE )
	if not weapon then return false end	

	local morale = Asset_Get( _troop, TroopAssetID.MORALE )

	local order = _troop:GetCombatData( TroopCombatData.ORDER )
	if order == CombatOrder.FORCED_ATTACK then
		if morale < 40 then return false end
	elseif order == CombatOrder.ATTACK then
		if morale < 40 then return false end
	elseif order == CombatOrder.DEFEND then
		return false
	elseif order == CombatOrder.SURVIVE then
		return false
	end

	_registers["WEAPON"] = weapon

	return true
end

local function CanFight( ... )
	if _troop:GetCombatData( TroopCombatData.GRID ) and _troop:GetCombatData( TroopCombatData.GRID ).isWall == true then return false end

	local weapon = _troop:GetWeaponByTask( CombatTask.FIGHT )
	if not weapon then return false end

	local morale = Asset_Get( _troop, TroopAssetID.MORALE )

	local order = _troop:GetCombatData( TroopCombatData.ORDER )
	if order == CombatOrder.FORCED_ATTACK then
		if morale < 30 then return false end
	elseif order == CombatOrder.ATTACK then
		if morale < 30 then return false end
	elseif order == CombatOrder.DEFEND then
		if morale < 40 then return false end
	elseif order == CombatOrder.SURVIVE then
		return false
	end

	_registers["WEAPON"] = weapon
	return true
end

local function NeedShoot()	
	local morale = Asset_Get( _troop, TroopAssetID.MORALE )

	local order = _troop:GetCombatData( TroopCombatData.ORDER )
	if order == CombatOrder.FORCED_ATTACK then
		if morale < 20 then return false end
	elseif order == CombatOrder.ATTACK then
		if morale < 20 then return false end
	elseif order == CombatOrder.DEFEND then
		if morale < 20 then return false end
	elseif order == CombatOrder.SURVIVE then
		if morale < 20 then return false end
	end
	return true	
end

local function CanShoot( ... )
	local weapon = _troop:GetWeaponByTask( CombatTask.SHOOT )
	if not weapon then return false end
	_registers["WEAPON"] = weapon
	return true
end

local function CanDestroyDefense( ... )
	local weapon = _troop:GetWeaponByTask( CombatTask.DESTROY )
	if not weapon then return false end
	_registers["WEAPON"] = weapon
	return true
end

local function NeedStay( ... )
	--nearby target
	local tar = _combat:FindNearbyTarget( _troop )
	return _combat:FindNearbyTarget( _troop ) ~= nil
end

local function NeedMoveBackward( ... )
	local backGrid = _combat:GetBackGrid( _troop )
	if backGrid ~= nil and backGrid.side ~= _troop:GetCombatData( TroopCombatData.SIDE ) then return false end

	local maxsoldier = Asset_Get( _troop, TroopAssetID.MAX_SOLDIER )
	local soldier = Asset_Get( _troop, TroopAssetID.SOLDIER )
	local org     = Asset_Get( _troop, TroopAssetID.ORGANIZATION )
	local morale  = Asset_Get( _troop, TroopAssetID.MORALE )

	local soldierRatio = soldier / maxsoldier
	local orgRatio = org / soldier

	local order = _troop:GetCombatData( TroopCombatData.ORDER )
	if order == CombatOrder.FORCED_ATTACK then
		if soldierRatio <= 0.6 and org <= 0 then return true end
	elseif order == CombatOrder.ATTACK then
		if soldierRatio <= 0.8 and org <= 0 then return true end
	elseif order == CombatOrder.DEFEND then
		if orgRatio <= 0 then return true end
	elseif order == CombatOrder.SURVIVE then
		if orgRatio <= 0.25 then return true end
	end
	return false
end

local function NeedMoveForward( ... )
	local order = _troop:GetCombatData( TroopCombatData.ORDER )
	if order ~= CombatOrder.FORCED_ATTACK and order ~= CombatOrder.ATTACK then
		--print( "order not atk", MathUtil_FindName( CombatOrder, order ) )
		return false
	end

	local oppSide = _combat:GetOppSide( _troop:GetCombatData( TroopCombatData.SIDE ) )
	local frontGrid = _combat:GetFrontGrid( _troop )
	if frontGrid == nil or frontGrid.side == oppSide then		
		return false
	end
	
	local curGrid = _combat:GetGrid( _troop:GetCombatData( TroopCombatData.X_POS ), _troop:GetCombatData( TroopCombatData.Y_POS ) )

	--check grid situation
	local orgRatio = frontGrid.organization / curGrid.organization
	local soldierRatio = frontGrid.soldier / curGrid.soldier

	--print( curGrid.organization, curGrid.soldier, curGrid.x, curGrid.y )
	--print( frontGrid.organization, frontGrid.soldier, frontGrid.x, frontGrid.y )
	--print( orgRatio, soldierRatio )
	
	local order = _troop:GetCombatData( TroopCombatData.ORDER )
	if order == CombatOrder.FORCED_ATTACK then
		if orgRatio <= 1.5 or soldierRatio <= 1.5 then return true end
	elseif order == CombatOrder.ATTACK then
		if orgRatio <= 1.2 or soldierRatio <= 1.2 then return true end
	elseif order == CombatOrder.DEFEND then
		if orgRatio <= 1 or soldierRatio <= 1 then return true end
	elseif order == CombatOrder.SURVIVE then
		if orgRatio <= 1 and soldierRatio <= 1 then return true end
	end
	--InputUtil_Pause( TroopToString(_troop), _troop:GetCombatData( TroopCombatData.X_POS ), _troop:GetCombatData( TroopCombatData.Y_POS ), "move foward" )
	return false
end

local function NeedMoveTowardGrid( ... )
	local oppSide = _combat:GetOppSide( _troop:GetCombatData( TroopCombatData.SIDE ) )
	local frontGrid = _combat:GetFrontGrid( _troop )	
	if frontGrid == nil or frontGrid.side == oppSide then return false end

	local tarGrid = _combat:FindContactGrid( _troop )
	if tarGrid == nil then return false end

	--InputUtil_Pause( _troop:GetCombatData( TroopCombatData.X_POS ), _troop:GetCombatData( TroopCombatData.Y_POS ), "find toward grid", tarGrid.x, tarGrid.y )

	_registers["GRID"] = tarGrid

	return true
end

----------------------------------------

-- Determine to do what in MOVEMENT STEP
local CombatTroopAI_DetermineMovement =
{
	type = "SELECTOR", children = 
	{
		{ type = "SEQUENCE", desc="", children = 
			{
				{ type = "FILTER", condition = IsFlee },
				{ type = "ACTION", action = IssueTroopTask, params = { type = CombatTask.FLEE } },
			}
		},
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = IsSiegeDefender },
				{ type = "ACTION", action = IssueTroopTask, params = { type = CombatTask.STAY } },
			}
		},
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = IsDowncast },
				{ type = "ACTION", action = IssueTroopTask, params = { type = CombatTask.STAY } },
			}
		},
		{ type = "SEQUENCE", desc="", children = 
			{
				{ type = "FILTER", condition = IsRetreat },
				{ type = "ACTION", action = IssueTroopTask, params = { type = CombatTask.BACKWARD } },
			}
		},
		{ type = "SEQUENCE", children =
			{
				{ type = "FILTER", condition = NeedMoveBackward },
				{ type = "ACTION", action = IssueTroopTask, params = { type = CombatTask.BACKWARD } },
			}
		},
		{ type = "SEQUENCE", children =
			{
				{ type = "FILTER", condition = NeedMoveForward },
				{ type = "ACTION", action = IssueTroopTask, params = { type = CombatTask.FORWARD } },
			}
		},
		{ type = "SEQUENCE", children =
			{
				{ type = "FILTER", condition = NeedMoveTowardGrid },
				{ type = "ACTION", action = IssueTroopTask, params = { type = CombatTask.TOWARD_GRID, grid = true } },
			}
		},
		{ type = "ACTION", action = IssueTroopTask, params = { type = CombatTask.STAY } },
	},
}

-- Determine to do what in ATTACK step
--
-- In siege: Use siege_weapon attack priority or surrounded, 
-- In 
--
--

local CombatTroopAI_DefaultAttack = 
{
	type = "SEQUENCE", children = 
	{
		{ type = "FILTER", condition = FindNearbyTarget },
		{ type = "FILTER", condition = CalculateDistanceFromTarget },
		{ type = "SELECTOR", children = 
			{
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = IsTargetInRange },
						{ type = "FILTER", condition = CanCharge },
						{ type = "ACTION", action = IssueTroopTask, params = { type = CombatTask.CHARGE, target = true } },
					}
				},
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = IsTargetInRange },
						{ type = "FILTER", condition = CanFight },
						{ type = "ACTION", action = IssueTroopTask, params = { type = CombatTask.FIGHT, target = true } },
					}
				},
				{ type = "SEQUENCE", children = 
					{
						{ type = "FILTER", condition = IsTargetInRange },
						{ type = "FILTER", condition = CanShoot },
						{ type = "FILTER", condition = NeedShoot },
						{ type = "ACTION", action = IssueTroopTask, params = { type = CombatTask.SHOOT, target = true } },
					}
				},
			}
		},
	},
}

local CombatTroopAI_SiegeAttacker = 
{
	type = "SEQUENCE", children =
	{
		{ type = "FILTER", condition = IsSiegeCombat },
		{ type = "FILTER", condition = IsAttacker },
		{ type = "SEQUENCE", children =
			{
				{ type = "FILTER", condition = FindSiegeTaget },
				{ type = "FILTER", condition = CalculateDistanceFromGrid },				
				{ type = "SELECTOR", children = 
					{
						{ type = "SEQUENCE", children =
							{							
								{ type = "FILTER", condition = IsCategory, params = { category = "SIEGE_WEAPON" } },
								{ type = "FILTER", condition = CanDestroyDefense },
								{ type = "ACTION", action = IssueTroopTask, params = { type = CombatTask.DESTROY, grid = true } },
							},
						},
					},
				},
			},
		},
	},
}

local CombatTroopAI_DetermineAttack =
{
	type = "SELECTOR", children = 
	{
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = IsDowncast },
				{ type = "ACTION", action = IssueTroopTask, params = { type = CombatTask.PASS } },
			}
		},
		CombatTroopAI_SiegeAttacker,
		CombatTroopAI_DefaultAttack,
		--{ type = "ACTION", action = IssueTroopTask, params = { type = CombatTask.DEFEND } },
	},
	
}

----------------------------------------
-- Status condition functions

local function NeedFlee()
	local org = Asset_Get( _troop, TroopAssetID.ORGANIZATION )
	if org > 0 then return false end

	local soldier = Asset_Get( _troop, TroopAssetID.SOLDIER )
	local maxsoldier = Asset_Get( _troop, TroopAssetID.MAX_SOLDIER )
	local soldierRatio = soldier * 100 / maxsoldier
	local morale = Asset_Get( _troop, TroopAssetID.MORALE )

	local ret = false
	local order = _troop:GetCombatData( TroopCombatData.ORDER )
	if order == CombatOrder.FORCED_ATTACK then
		ret = soldierRatio + morale < 130 and soldierRatio < 40
	elseif order == CombatOrder.ATTACK then
		ret = soldierRatio + morale < 120 and soldierRatio < 45
	elseif order == CombatOrder.DEFEND then
		ret = soldierRatio + morale < 110 and soldierRatio < 50
	elseif order == CombatOrder.SURVIVE then
		ret = soldierRatio + morale < 100 and soldierRatio < 55
	end
	return ret
end

local function NeedRetreat()
	if _troop:GetCombatData( TroopCombatData.RETREAT ) then return false end

	local org = Asset_Get( _troop, TroopAssetID.ORGANIZATION )
	--no organization, retreat immediately
	if org <= 0 then return true end

	local mor = Asset_Get( _troop, TroopAssetID.MORALE )	
	local ret = false
	local order = _troop:GetCombatData( TroopCombatData.ORDER )
	if order == CombatOrder.FORCED_ATTACK then
		ret = mor < 30
	elseif order == CombatOrder.ATTACK then
		ret = mor < 35
	elseif order == CombatOrder.DEFEND then
		ret = mor < 35
	elseif order == CombatOrder.SURVIVE then
		ret = mor < 40
	end

	return false
end

local CombatTroopAI_CheckStatus = 
{
	type = "SELECTOR", children = 
	{
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = IsFieldCombat },
				{ type = "FILTER", condition = NeedRetreat },
				{ type = "ACTION", action = SetTroopStatus, params = { type = "_retreat", value = true } },
			},
		},
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = IsAttacker },
				{ type = "FILTER", condition = NeedRetreat },
				{ type = "ACTION", action = SetTroopStatus, params = { type = "_retreat", value = true } },
			},
		},
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = NeedFlee },
				--{ type = "FILTER", condition = CanFlee },
				{ type = "ACTION", action = SetTroopStatus, params = { type = "_flee", value = true } },
			},
		},
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = NeedSurrender },
				{ type = "ACTION", action = SetTroopStatus, params = { type = "_surrender", value = true } },
			},
		},
	}
}

----------------------------------------

local CombatTroopAI_Order = 
{
	type = "SELECTOR", children = 
	{
		--long range siege weapon never move
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = IsCategory, params = { category = "SIEGE_WEAPON" } },
				{ type = "FILTER", condition = CanShoot },
				{ type = "ACTION", action = SetTroopOrder, params = { order = "DEFEND" } },
			}
		},
		--missile unit prefer to stay
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = IsCategory, params = { category = "MISSILE_UNIT" } },
				--{ type = "FILTER", condition = function ( ... ) print( "missile unit defend" ) end },
				{ type = "ACTION", action = SetTroopOrder, params = { order = "DEFEND" } },
			}
		},
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = IsSiegeCombat },
				{ type = "FILTER", condition = IsSiegeAttacker },
				{ type = "SELECTOR", children =
					{
						--check forced attack intense
						{ type = "SEQUENCE", children = 
							{
								{ type = "FILTER", condition = CanForcedAttack },
								{ type = "ACTION", action = SetTroopOrder, params = { order = "FORCED_ATTACK" } },
							}
						},
						{ type = "SEQUENCE", children = 
							{
								{ type = "FILTER", condition = IsDefenseBroken },
								{ type = "ACTION", action = SetTroopOrder, params = { order = "ATTACK" } },
							},
						},
						{ type = "SEQUENCE", children = 
							{
								{ type = "FILTER", condition = IsAdvantageous },
								{ type = "ACTION", action = SetTroopOrder, params = { order = "ATTACK" } },
							},
						},
						{ type = "SEQUENCE", children = 
							{
								{ type = "ACTION", action = SetTroopOrder, params = { order = "DEFEND" } },
							},
						},
					},
				},
			},
		},
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = IsAttacker },
				{ type = "ACTION", action = SetTroopOrder, params = { order = "ATTACK" } },
			}
		},
		{ type = "SEQUENCE", children = 
			{
				{ type = "FILTER", condition = IsDefender },
				{ type = "ACTION", action = SetTroopOrder, params = { order = "DEFEND" } },
			}
		},
		{ type = "ACTION", action = SetTroopOrder, params = { order = "SURVIVE" } },
	}
}


local CombatAI_CheckCombatStatus = 
{
	type = "SELECTOR", children = 
	{
		{ type = "SEQUENCE", children = 
			{
			}
		},
	},
}
----------------------------------------

local _behavior = Behavior()

_checkCombatAI = BehaviorNode( true )
_checkCombatAI:BuildTree( CombatAI_CheckCombatStatus )

local _determineMoveAI = BehaviorNode( true )
_determineMoveAI:BuildTree( CombatTroopAI_DetermineMovement )

local _determineAttackAI = BehaviorNode( true )
_determineAttackAI:BuildTree( CombatTroopAI_DetermineAttack )

local _checkTroopStatusAI = BehaviorNode( true )
_checkTroopStatusAI:BuildTree( CombatTroopAI_CheckStatus )

local _orderTroopAI = BehaviorNode()
_orderTroopAI:BuildTree( CombatTroopAI_Order )

function CombatAI_SetEnviroment( type, data )
	if type == CombatAIEnviroment.COMBAT_INSTANCE then
		_combat = data
	end
end

local function Init( troop )
	_task = nil
	_registers = {}
	_troop = troop
end

function CombatAI_CheckCombatStatus()
	Init( nil )
	_behavior:Run( _checkCombatAI )
end

function CombatAI_DetermineTroopMove( troop )
	Init( troop )
	_behavior:Run( _determineMoveAI )
	return _task
end

function CombatAI_DetermineTroopAttack( troop )
	Init( troop )	
	_behavior:Run( _determineAttackAI )
	return _task
end

function CombatAI_CheckTroopStatus( troop )
	Init( troop )
	_behavior:Run( _checkTroopStatusAI )
end

function CombatAI_Order( troop )
	Init( troop )
	_behavior:Run( _orderTroopAI )
end