----------------------------------------
local _behavior = Behavior()

local _roleEntity
local _roleCmp
local _targetEntity
local _targetGroupCmp
local _targetRoleCmp
local _targetFighterCmp

local _decision

----------------------------------------
-- Tree data
----------------------------------------
local function NearDistrct( params )
	return true
end


local function MakeDecision( params )
	Stat_Add( "MakeDecidsion", params.cmd, StatType.LIST )	

	_decision = { type = params.cmd }	

	_roleCmp.instruction = _decision
	
	--InputUtil_Pause( "make decision", params.cmd )
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


local function TargetNeedTeacher()
	local group = ECS_FindEntity( _targetRoleCmp.groupid )
	--has teacher
	return false
end


local function TargetNeedSeclude()
	local group = ECS_FindEntity( _targetRoleCmp.groupid )
	return false
end


local _GroupDrill = 
{
	type = "SEQUENCE", desc="group_drill", children = 
	{
		{ type = "FILTER", condition = TargetNeedDrill },
		{ type = "FILTER", condition = TestProbability, params = { prob = 100 } },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "DRILL" } },
	}
}


local _GroupTeach = 
{
	type = "SEQUENCE", desc="group_teach", children = 
	{
		{ type = "FILTER", condition = TargetNeedTeacher },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "TEACH" } },
	}
}


local _GroupSeclude = 
{
	type = "SEQUENCE", desc="group_seclude", children = 
	{
		{ type = "FILTER", condition = TargetNeedSeclude },
		{ type = "ACTION", action = MakeDecision, params = { cmd = "SECLUDE" } },
	}
}


local _GroupTrainning = 
{
	type = "SELECTOR", desc="group_trainning", children = 
	{
		_GroupDrill,
		_GroupTeach,
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
----------------------------------------
local _ScheduleArrangement = 
{
	--find the right one
	type = "SELECTOR", desc = "scheudle_arrangement", children = 
	{
		_PersonalHealthy,
		_GroupTrainning,
		_GroupFight,
		_GroupProduce,
		_DefaultDecision,
	}
}

_scheduleTree = BehaviorNode( true )
_scheduleTree:BuildTree( _ScheduleArrangement )


----------------------------------------
----------------------------------------
local _DetermineAction = 
{
	type = "SELECTOR", desc = "scheudle_arrangement", children = 
	{
		_PersonalHealthy,
		_GroupTrainning,
		_GroupFight,
		_GroupProduce,
		_DefaultDecision,
	}
}

_actionTree = BehaviorNode( true )
_actionTree:BuildTree( _DetermineAction )

----------------------------------------
----------------------------------------
local function InitBehavior( role_ecsid, params )
	_roleEntity   = ECS_FindEntity( role_ecsid )

	if not _roleEntity then print( "[AI]Role ecsid is invalid! ID=", role_ecsid ) return end

	if params and params.target then
		_targetEntity = ECS_FindEntity( params.target )
	else
		_targetEntity = _roleEntity
	end

	_roleCmp          = _roleEntity:GetComponent( "ROLE_COMPONENT" )
	_targetRoleCmp    = _targetEntity:GetComponent( "ROLE_COMPONENT" )
	_targetFighterCmp = _targetEntity:GetComponent( "FIGHTER_COMPONENT" )
	_targetGroupCmp   = ECS_FindComponent( _targetRoleCmp.groupid, "GROUP_COMPONENT" )

	_decision = nil

	return true
end


----------------------------------------
--
-- Group master suggest follower to do
--
----------------------------------------
function AI_DetermineSchedule( role_ecsid, params )	
	if not InitBehavior( role_ecsid, params ) then DBG_TraceBug( "Init role's ai failed" ) return end

	if not _targetGroupCmp then DBG_Error( "Target isn't in group!" ) end

	Stat_Add( "RoleAI@Run_Times", nil, StatType.TIMES )

	Log_Write( "roleai", _roleCmp.name .. " is thinking schedule" )

	return _behavior:Run( _scheduleTree )
end


function AI_DetermineAction( role_ecsid, params )
	if not InitBehavior( role_ecsid, params ) then DBG_TraceBug( "Init role's ai failed" ) return end

	Stat_Add( "RoleAI@Run_Times", nil, StatType.TIMES )

	Log_Write( "roleai", _roleCmp.name .. " is thinking action" )

	return _behavior:Run( _actionTree )
end


function AI_GetDecision()
	return _decision
end


----------------------------------------
----------------------------------------