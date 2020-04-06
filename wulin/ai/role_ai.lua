----------------------------------------
local _behavior = Behavior()

local _roleEntity
local _roleCmp
local _roleGroupCmp
local _targetEntity
local _targetGroupCmp
local _targetRoleCmp
local _targetFighterCmp

local _variables = {}


----------------------------------------
-- Tree data
----------------------------------------
local function NearDistrct( params )
	return true
end


local function IsInGroup()
	return _targetRoleCmp.groupid
end


local function CanDo( params )
	--check whether role can be teacher
	local _follower = _targetEntity:GetComponent( "FOLLOWER_COMPONENT" )
	local abilities = FOLLOWER_RANK_ABILITY[_follower.rank]
	if not abilities then return false end
	print( "check", _roleCmp.name, _targetRoleCmp.name )
	return abilities[params.action] == 1
end


local function MakeDecision( params )
	Stat_Add( "MakeDecidsion", params.cmd, StatType.LIST )	

	_decision = { type = params.cmd }	

	_actorCmp = ECS_GetComponent( _targetEntity.ecsid, "ACTOR_COMPONENT" )
	_actorCmp.task = params.cmd

	if params.cmd == "DRILL" then
		if _targetGroupCmp then _targetGroupCmp:IncStatusValue( "HAS_DRILL_FOLLOWER" ) end
	end
	
	if _roleCmp ~= _targetRoleCmp then
		DBG_Trace( _roleCmp.name .. " order " .. _targetRoleCmp.name .. " to do=" .. params.cmd )
	else
		DBG_Trace( _targetRoleCmp.name .. " decide to do=" .. params.cmd )
	end
end


local function StayInGroup()
	return _targetFighterCmp ~= nil
end


local function TestProbability( params )
	if params.prob then
		local max = params.maxprob or 100
		if Random_GetInt_Sync( 1, max ) > params.prob then return false end
	end
	return true
end


local _DefaultDecision = 
{
	type = "ACTION", desc="Decision", action = MakeDecision, params = { cmd = "IDLE" },
}


----------------------------------------
----------------------------------------
local function TargetNeedRest()
	--check hp	
	if _targetFighterCmp.hp < _targetFighterCmp.maxhp * 0.5 then return true end

	--hurt or sick	
	if _targetRoleCmp:GetMentalValue( "SICK" ) > 0 then return true end	

	return false
end


local function TargetNeedStroll()	
	--lazy
	if Random_GetInt_Sync( 1, 100 ) < _targetRoleCmp:GetMentalValue( "LAZY" ) then return true end

	--dissatisfaction
	if Random_GetInt_Sync( 1, 100 ) < _targetRoleCmp:GetMentalValue( "DISSATISFACTION" ) then return true end

	--tired
	if Random_GetInt_Sync( 1, 100 ) < _targetRoleCmp:GetMentalValue( "TIRENESS" ) then return true end

	return false
end


local function TargetNeedTravel()
	return false
end


local _PersonalRest = 
{
	type = "SEQUENCE", desc="personal_rest", children = 
	{
		{ type = "FILTER", condition = TargetNeedRest },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "REST" } },
	},	
}


local _PersonalStroll = 
{
	type = "SEQUENCE", desc="personal_stroll", children = 
	{
		{ type = "FILTER", condition = NearDistrct, params = { districts = { "VILLAGE", "TOWN", "CITY" } } },
		{ type = "FILTER", condition = TargetNeedStroll },		
		{ type = "ACTION", action = MakeDecision, params = { cmd = "REST" } },
	},	
}


local _PersonalTravel = 
{
	type = "SEQUENCE", desc="personal_travel", children = 
	{
		{ type = "FILTER", condition = TargetNeedTravel },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "REST" } },
	},	
}


local _PersonalHealthy = 
{
	type = "SELECTOR", desc="personal_healthy", children = 
	{
		_PersonalRest,
		_PersonalStroll,
		_PersonalTravel,
	}
}


----------------------------------------
--
-- Train
--
----------------------------------------
local function TargetNeedDrill()
	--[[
	local gap = _targetRoleCmp:GetMentalValue( "LAZY" ) - _targetRoleCmp:GetMentalValue( "AGGRESION" )
	--aggresion v.s. lazy
	if Random_GetInt_Sync( 1, 50 ) > 0 then return false end
	]]
	return true
end


local function TargetNeedTeach()
	if not _targetGroupCmp and _targetGroupCmp:GetStatusValue( "HAS_DRILL_FOLLOWER" ) == 0 then
		return false
	end

	if Random_GetInt_Sync( 1, 100 ) < 50 then return true end

	return false
end


local function TargetNeedSeclude()
	if Random_GetInt_Sync( 1, 100 ) < 50 then return true end

	_traveler = ECS_GetComponent( _targetEntity.ecsid, "TRAVELER_COMPONENT" )
		
	if _targetGroupCmp then
		if _traveler.location ~= _targetGroupCmp.location then return false end
		if _targetGroupCmp:GetNumOfConstruction( "BACKROOM" ) <= _targetGroupCmp:GetStatusValue( "HAS_SECLUDE_MEMBER" ) then return false end
	else
		--in a secrect area
		local map = ECS_SendEvent( "MAP_COMPONENT", "Get" )		
		local plot = map:GetPlotById( _traveler.location )
		if not plot then return false end
		if plot.type == "MOUNTAIN" then
			return true
		end
	end

	return false
end


----------------------------------------
local _GroupDrill = 
{
	type = "SEQUENCE", desc="group_drill", children = 
	{
		{ type = "FILTER", condition = TargetNeedDrill },
		{ type = "FILTER", condition = TestProbability, params = { prob = 100 } },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "DRILL" } },
	}
}


----------------------------------------
local _GroupTeach = 
{
	type = "SEQUENCE", desc="group_teach", children = 
	{
		{ type = "FILTER", condition = CanDo, params = { action="TEACH" } },
		{ type = "FILTER", condition = TargetNeedTeach },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "TEACH" } },
	}
}


----------------------------------------
local _GroupSeclude = 
{
	type = "SEQUENCE", desc="group_seclude", children = 
	{
		{ type = "FILTER", condition = CanDo, params = { action="SECLUDE" } },
		{ type = "FILTER", condition = TargetNeedSeclude },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "SECLUDE" } },
	}
}


----------------------------------------
local _GroupTraining = 
{
	type = "SELECTOR", desc="group_Training", children = 
	{
		_GroupTeach,
		_GroupDrill,
		_GroupLearn,
		_GroupSeclude,
	}
}


----------------------------------------
----------------------------------------
local function TargetNeedAttendSkirimmage()
	--at least two followr
	if #_targetGroupCmp.members < 2 then return false end

	local list = _targetGroupCmp:FindMember( function ( ecsid )		

		return Role_IsMatch( ecsid, { status_excludes={ "BUSY", "OUTING" } } )
	end)

	if #list < 2 then return end	

	return false
end


local function TargetNeedAttendChamiponship()
	return false
end


local _GroupSkirimmage = 
{
	type = "SEQUENCE", desc="group_skirimmage", children = 
	{
		{ type = "FILTER", condition = TargetNeedAttendSkirimmage },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "SECLUDE" } },
	}
}


local _GroupChampionship = 
{
	type = "SEQUENCE", desc="group_championship", children = 
	{
		{ type = "FILTER", condition = TargetNeedAttendChamiponship },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "SECLUDE" } },
	}
}


local _GroupFight = 
{
	type = "SELECTOR", desc="group_fight", children = 
	{
		_GroupSkirimmage,
		_GroupChampionship,
	}
}


----------------------------------------
----------------------------------------


local _GroupCollect =
{
	type = "SEQUENCE", desc="group_collect", children = 
	{
		{ type = "FILTER", condition = TestProbability, params = { prob=20 } },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "COLLECT" } },
	}
}



local _GroupFish =
{
	type = "SEQUENCE", desc="group_fish", children = 
	{
		{ type = "FILTER", condition = TestProbability, params = { prob=20 } },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "FISH" } },
	}
}



local _GroupFarm =
{
	type = "SEQUENCE", desc="", children = 
	{
		{ type = "FILTER", condition = TestProbability, params = { prob=20 } },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "FARM" } },
	}
}


local _GroupMineStone =
{
	type = "SEQUENCE", desc="", children = 
	{
		{ type = "FILTER", condition = TestProbability, params = { prob=20 } },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "MINE" } },
	}
}


local _GroupMineMineral =
{
	type = "SEQUENCE", desc="", children = 
	{
		{ type = "FILTER", condition = TestProbability, params = { prob=20 } },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "MINE" } },
	}
}


local _GroupToolMake =
{
	type = "SEQUENCE", desc="", children = 
	{
		{ type = "FILTER", condition = TestProbability, params = { prob=20 } },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "TOOLMAKE" } },
	}
}


local _GroupSmelta =
{
	type = "SEQUENCE", desc="", children =
	{
		{ type = "FILTER", condition = TestProbability, params = { prob=20 } },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "SMELT" } },
	}
}


local _GroupBuild =
{
	type = "SEQUENCE", desc="", children =
	{
		{ type = "FILTER", condition = TestProbability, params = { prob=20 } },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "BUILD" } },
	}
}


local _GroupMakeCloth =
{
	type = "SEQUENCE", desc="", children =
	{
		{ type = "FILTER", condition = TestProbability, params = { prob=20 } },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "MAKECLOTH" } },
	}
}


local _GroupCutWood =
{
	type = "SEQUENCE", desc="", children =
	{
		{ type = "FILTER", condition = TestProbability, params = { prob=20 } },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "CUTWOOD" } },
	}
}


local _GroupSawWood =
{
	type = "SEQUENCE", desc="", children =
	{
		{ type = "FILTER", condition = TestProbability, params = { prob=20 } },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "SAWWOOD" } },
	}
}


local _GroupRaiseLivestock =
{
	type = "SEQUENCE", desc="", children =
	{
		{ type = "FILTER", condition = TestProbability, params = { prob=20 } },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "RAISELIVESTOCK" } },
	}
}


local _GroupPlantHerb =
{
	type = "SEQUENCE", desc="", children =
	{
		{ type = "FILTER", condition = TestProbability, params = { prob=20 } },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "PLANTHERB" } },
	}
}


local _GroupMakeMedicine =
{
	type = "SEQUENCE", desc="", children =
	{
		{ type = "FILTER", condition = TestProbability, params = { prob=20 } },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "MAKEMEDICINE" } },
	}
}


local _GroupProduce = 
{
	type = "SELECTOR", desc="", children =
	{
		_GroupCollect,
	}		
}


----------------------------------------
-- Task
--   Entrust( NPC )
--   Event( scenario )
--	 
----------------------------------------


----------------------------------------
-- Diplomacy
--
-- Send envy
--   Friend
--   Threaten
--   Sign pact
--   Declare war
--   Make peace
----------------------------------------


----------------------------------------
-- Operation
--   Reconnaissance
--   Sabotage
--	 Attack
----------------------------------------


----------------------------------------
local function AddAffair( params )
	if params.type == "BUILD_CONSTRUCTION" then
		Group_StartBuildingConstruction( _roleGroupCmp, _variables.construction )		
	elseif params.type == "UPGRADE_CONSTRUCTION" then
		Group_StartUpgradingConstruction( _roleGroupCmp, _variables.construction, _variables.target )
	end
end


----------------------------------------
local function GroupNeedToBuildConstruction()
	if _roleGroupCmp:GetNumOfAffairs( "BUILD_CONSTRUCTION" ) > 0 or
		_roleGroupCmp:GetNumOfAffairs( "UPGRADE_CONSTRUCTION" ) > 0 or
		_roleGroupCmp:GetNumOfAffairs( "DESTROY_CONSTRUCTION" ) > 0 then
		return false
	end

	--find all constructions can be built
	local list = CONSTRUCTION_DATATABLE_Find( nil, _roleGroupCmp )
	local num = #list
	if num == 0 then return false end

	--Dump( list )
	local index = Random_GetInt_Sync( 1, num )
	local id = list[index].id
	_variables.construction = id
	return true
end


local function GroupNeedToUpgradeConstruction()
	if _roleGroupCmp:GetNumOfAffairs( "BUILD_CONSTRUCTION" ) > 0 or
		_roleGroupCmp:GetNumOfAffairs( "UPGRADE_CONSTRUCTION" ) > 0 or
		_roleGroupCmp:GetNumOfAffairs( "DESTROY_CONSTRUCTION" ) > 0 then
		return false
	end

	local list = CONSTRUCTION_DATATABLE_Find( nil, _roleGroupCmp, true )
	local num = #list
	if num == 0 then return false end

	local index = Random_GetInt_Sync( 1, num )
	local id = list[index].id
	_variables.construction = id

	local constr = CONSTRUCTION_DATATABLE_Get( id )

	index = Random_GetInt_Sync( 1, #constr.conditions.upgrades )
	_variables.target = constr.conditions.upgrades[index]

	return true
end


local function GroupNeedToDestroyConstruction()
	if _roleGroupCmp:GetNumOfAffairs( "BUILD_CONSTRUCTION" ) > 0 or
		_roleGroupCmp:GetNumOfAffairs( "UPGRADE_CONSTRUCTION" ) > 0 or
		_roleGroupCmp:GetNumOfAffairs( "DESTROY_CONSTRUCTION" ) > 0 then
		return false
	end

	--for priority construction in ai_tendency

	return false
end


local _GroupBuildConstruction = 
{
	type = "SEQUENCE", desc="", children =
	{
		{ type = "FILTER", condition = GroupNeedToBuildConstruction },
		{ type = "ACTION", action = AddAffair, params = { type="BUILD_CONSTRUCTION" } },
	}
}

local _GroupUpgradeConstruction = 
{
	type = "SEQUENCE", desc="", children =
	{
		{ type = "FILTER", condition = GroupNeedToUpgradeConstruction },
		{ type = "ACTION", action = AddAffair, params = { type="UPGRADE_CONSTRUCTION" } },
	}
}

local _GroupDestroyConstruction = 
{
	type = "SEQUENCE", desc="", children =
	{
		{ type = "FAILURE" },
	}
}

----------------------------------------
----------------------------------------
local GroupAffair = 
{
	type = "SELECTOR", desc = "scheudle_arrangement", children = 
	{
		--_GroupBuildConstruction,
		_GroupUpgradeConstruction,
		_GroupDestroyConstruction,
	}
}
_groupAffairTree = BehaviorNode( true )
_groupAffairTree:BuildTree( GroupAffair )

----------------------------------------
----------------------------------------
local ScheduleArrangement = 
{
	--find the right one
	type = "SELECTOR", desc = "scheudle_arrangement", children = 
	{
		_PersonalHealthy,
		_GroupTraining,
		_GroupFight,
		_GroupProduce,
		_DefaultDecision,
	}
}
_scheduleTree = BehaviorNode( true )
_scheduleTree:BuildTree( ScheduleArrangement )


----------------------------------------
----------------------------------------
local DetermineAction = 
{
	type = "SELECTOR", desc = "scheudle_arrangement", children = 
	{
		_PersonalHealthy,
		_GroupTraining,
		_GroupFight,
		_GroupProduce,
		_DefaultDecision,
	}
}
_actionTree = BehaviorNode( true )
_actionTree:BuildTree( DetermineAction )

----------------------------------------
----------------------------------------
local function InitBehavior( role_ecsid, params )
	_roleEntity   = ECS_FindEntity( role_ecsid )

	if not _roleEntity then print( "[AI]Role ecsid is invalid! ID=", role_ecsid ) error("") return end

	if params and params.target then
		_targetEntity = ECS_FindEntity( params.target )
	else
		_targetEntity = _roleEntity
	end

	_roleCmp          = _roleEntity:GetComponent( "ROLE_COMPONENT" )
	_roleGroupCmp     = ECS_FindComponent( _roleCmp.groupid, "GROUP_COMPONENT" )

	_targetRoleCmp    = _targetEntity:GetComponent( "ROLE_COMPONENT" )
	_targetFighterCmp = _targetEntity:GetComponent( "FIGHTER_COMPONENT" )
	_targetGroupCmp   = ECS_FindComponent( _targetRoleCmp.groupid, "GROUP_COMPONENT" )

	return true
end


----------------------------------------
-- Group master
----------------------------------------
function AI_DetermineGroupAffair( role_ecsid, params )
	if not InitBehavior( role_ecsid, params ) then DBG_TraceBug( "Init role's ai failed" ) return end

	if not _targetGroupCmp then DBG_Error( "Target isn't in group!" ) end

	DBG_Trace( _roleCmp.name, "is thinking about group affairs" )
	Stat_Add( "RoleAI@Run_Times", nil, StatType.TIMES )
	Log_Write( "roleai", _roleCmp.name .. " is thinking schedule" )

	return _behavior:Run( _groupAffairTree )
end


----------------------------------------
-- Group master
----------------------------------------
function AI_DetermineSchedule( role_ecsid, params )	
	if not InitBehavior( role_ecsid, params ) then DBG_TraceBug( "Init role's ai failed" ) return end

	if not _targetGroupCmp then DBG_Error( "Target isn't in group!" ) end

	DBG_Trace( _roleCmp.name, "is thinking about schedule. target=" .. _targetRoleCmp.name )
	Stat_Add( "RoleAI@Run_Times", nil, StatType.TIMES )

	return _behavior:Run( _scheduleTree )
end


----------------------------------------
-- All roles
----------------------------------------
function AI_DetermineAction( role_ecsid, params )
	if not InitBehavior( role_ecsid, params ) then DBG_TraceBug( "Init role's ai failed" ) return end

	DBG_Trace( _roleCmp.name, "is thinking about action" )
	Stat_Add( "RoleAI@Run_Times", nil, StatType.TIMES )

	return _behavior:Run( _actionTree )
end


----------------------------------------
----------------------------------------