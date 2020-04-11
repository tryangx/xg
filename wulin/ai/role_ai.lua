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
	return abilities[params.action] == 1
end


local function MakeDecision( params )
	Stat_Add( "MakeDecidsion", params.cmd, StatType.TIMES )

	_decision = { type = params.cmd }	

	_taskCmp = ECS_GetComponent( _targetEntity.ecsid, "TASK_COMPONENT" )
	_taskCmp.task = params.cmd

	if params.cmd == "DRILL" then
		if _targetGroupCmp then _targetGroupCmp:IncTempStatusValue( "DRILL_MEMBER" ) end
	elseif params.cmd == "READBOOK" then
		if _targetGroupCmp then _targetGroupCmp:IncTempStatusValue( "SECLUDE_MEMBER" ) end
	elseif params.cmd == "TESTFIGHT" then
		_targetGroupCmp:IncTempStatusValue( "TESTFIGHT_MEMBER" )		
	elseif params.cmd == "TESTFIGHT_OFFICER" then
		_targetGroupCmp:IncTempStatusValue( "TESTFIGHT_MEMBER" )
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


----------------------------------------
----------------------------------------
local function GroupHasConstruction( params )
	local num = _targetGroupCmp:GetNumOfConstruction( params.construction )
	--should reduce the construction occpuied by the affairs
	if num > 0 then
		if params.affair then
			num = num - _targetGroupCmp:GetNumOfAffairsByParams( params.affair )
		end	
	else
		_targetGroupCmp._constructionWishList[params.construction] = _targetGroupCmp._constructionWishList[params.construction] and _targetGroupCmp._constructionWishList[params.construction] + 1 or 1
		--InputUtil_Pause( "building", params.construction, num )
	end	
	return num > 0
end

local function GroupHasLand( params )
	--if not _targetGroupCmp then return false end	local usin
	if _targetGroupCmp:GetNumOfLand( params.type ) <= ( params.value or 0 ) then return false end
	return true
end


local function GroupHasAffairs( params )
	if _roleGroupCmp:GetNumOfAffairs( params.type ) >= params.max then return false end
	return true
end

----------------------------------------
local function AddAffair( params )
	if params.type == "BUILD_CONSTRUCTION" then
		Group_StartBuildingConstruction( _roleGroupCmp, _variables.construction )		
	elseif params.type == "UPGRADE_CONSTRUCTION" then
		Group_StartUpgradingConstruction( _roleGroupCmp, _variables.construction, _variables.target )
	elseif params.type == "DESTROY_CONSTRUCTION" then

	elseif params.type == "SMELT" then
		Group_Smelt( _roleGroupCmp, _variables.material )

	elseif params.type == "MAKE_ITEM" then
		if _variables.maketype and _variables.makeid then
			Group_StartMakeItem( _roleGroupCmp, _variables.maketype, _variables.makeid )			
		else
			DBG_Error( "unspecified making item" )
		end
	elseif params.type == "PROCESS"	then
		if _variables.processtype then
			Group_StartProcess( _roleGroupCmp, _variables.processtype )
		end		
	elseif params.type == "PRODUCE" then
		if _variables.producetype then
			Group_StartProduce( _roleGroupCmp, _variables.producetype )
		else
			DBG_Error( "unspecified produce type" )
		end

	else
		DBG_Error( "unhandle", params.type )
	end

	DBG_Trace( _targetGroupCmp.name .. " add affair=" .. params.type )
	--InputUtil_Pause( "Add affair", params.type )
end


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

----------------------------------------
local _DefaultDecision = 
{
	type="ACTION", desc="Decision", action = MakeDecision, params={ cmd="IDLE" },
}

local _Pause = 
{
	type="PAUSE", desc="Pause to debug",
}


local _PersonalRest = 
{
	type="SEQUENCE", desc="personal_rest", children = 
	{
		{ type="FILTER", condition=TargetNeedRest },
		{ type="ACTION", action = MakeDecision, params={ cmd="REST" } },
	},	
}


local _PersonalStroll = 
{
	type="SEQUENCE", desc="personal_stroll", children = 
	{
		{ type="FILTER", condition=NearDistrct, params={ districts = { "VILLAGE", "TOWN", "CITY" } } },
		{ type="FILTER", condition=TargetNeedStroll },		
		{ type="ACTION", action = MakeDecision, params={ cmd="REST" } },
	},	
}


local _PersonalTravel = 
{
	type="SEQUENCE", desc="personal_travel", children = 
	{
		{ type="FILTER", condition=TargetNeedTravel },
		{ type="ACTION", action = MakeDecision, params={ cmd="REST" } },
	},	
}


local _PersonalHealthy = 
{
	type="SELECTOR", desc="personal_healthy", children = 
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
	if not _targetGroupCmp or _targetGroupCmp:GetTempStatusValue( "DRILL_MEMBER" ) == 0 then
		return false
	end

	if Random_GetInt_Sync( 1, 100 ) < 50 then return true end

	return false
end


local function TargetNeedSeclude()
	if Random_GetInt_Sync( 1, 100 ) < 100 then return true end

	_traveler = ECS_GetComponent( _targetEntity.ecsid, "TRAVELER_COMPONENT" )
	
	if _targetGroupCmp then
		if _traveler.location ~= _targetGroupCmp.location then return false end
		if _targetGroupCmp:GetNumOfConstruction( "BACKROOM" ) <= _targetGroupCmp:GetTempStatusValue( "SECLUDE_MEMBER" ) then return false end
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


local function TargetNeedReadBook( ... )
	if Random_GetInt_Sync( 1, 100 ) < 100 then return true end

	--has construction
	if not _targetGroupCmp then
		--check bags
	else
		if _targetRoleCmp:GetNumOfConstruction( "STUDY_ROOM" ) <= _targetGroupCmp:GetTempStatusValue( "READBOOK_MEMBER" ) then return false end
		return true
	end
	return false
end


----------------------------------------
local _GroupDrill = 
{
	type="SEQUENCE", desc="group_drill", children = 
	{
		{ type="FILTER", condition=TargetNeedDrill },
		{ type="FILTER", condition=TestProbability, params={ prob = 100 } },
		{ type="ACTION", action = MakeDecision, params={ cmd="DRILL" } },
	}
}


----------------------------------------
local _GroupTeach = 
{
	type="SEQUENCE", desc="group_teach", children = 
	{
		{ type="FILTER", condition=CanDo, params={ action="TEACH" } },
		{ type="FILTER", condition=TargetNeedTeach },
		{ type="ACTION", action = MakeDecision, params={ cmd="TEACH" } },
	}
}

----------------------------------------
local _GroupSeclude = 
{
	type="SEQUENCE", desc="group_seclude", children = 
	{
		{ type="FILTER", condition=CanDo, params={ action="SECLUDE" } },
		{ type="FILTER", condition=TargetNeedSeclude },
		{ type="ACTION", action = MakeDecision, params={ cmd="SECLUDE" } },
	}
}

----------------------------------------
local _GroupReadBook = 
{
	type="SEQUENCE", desc="group_seclude", children = 
	{
		{ type="FILTER", condition=CanDo, params={ action="READBOOK" } },
		{ type="FILTER", condition=TargetNeedReadBook },
		{ type="ACTION", action = MakeDecision, params={ cmd="READBOOK" } },
	}
}

----------------------------------------
local _GroupTraining = 
{
	type="SELECTOR", desc="group_Training", children = 
	{
		_GroupSeclude,
		_GroupTeach,
		_GroupDrill,
		_GroupReadBook,
	}
}


----------------------------------------
----------------------------------------
local function TargetNeedAttendSkirimmage()
	--at least two followr
	if not _targetGroupCmp then return false end

	if #_targetGroupCmp.members < 2 then return false end

	local list = _targetGroupCmp:FindMember( function ( ecsid )
		return Role_MatchStatus( ecsid, { status_excludes={ "BUSY", "OUTING" } } )
	end)

	if #list < 2 then return false end

	return false
end


local function TargetNeedTestFight()
	if not _targetGroupCmp then return false end
	
	--Need testfight
	--if _targetRoleCmp:GetStatusValue( "TESTFIGHT_INTERVAL" ) < 1 then return false end

	--Wheter his master is idle
	local _follower = ECS_FindComponent( _targetEntity.ecsid, "FOLLOWER_COMPONENT" )
	if not _follower.masterid then return false end

	local master = ECS_FindComponent( _follower.masterid, "ROLE_COMPONENT" )
	--check deads for debug
	if not master then
		--if DBG_FindData( _follower.masterid ) then error( "Find in debugger data" ) end
		return
	end
	if not master:MatchStatus( { status_excludes={ "BUSY", "OUTING" } } ) then return false end

	master:IncStatusValue( "TESTFIGHT_APPLY", 1 )

	return true
end


local function TargetNeedAttendChamiponship()
	return false
end


local _GroupSkirimmage = 
{
	type="SEQUENCE", desc="group_skirimmage", children = 
	{
		{ type="FILTER", condition=TargetNeedAttendSkirimmage },
		{ type="ACTION", action = MakeDecision, params={ cmd="SKIRIMMAGE" } },
	}
}

local _GroupTestFight = 
{
	type="SEQUENCE", desc="group_championship", children = 
	{
		{ type="FILTER", condition=TargetNeedTestFight },
		{ type="ACTION", action = MakeDecision, params={ cmd="TESTFIGHT" } },
	}
}


local _GroupChampionship = 
{
	type="SEQUENCE", desc="group_championship", children = 
	{
		{ type="FILTER", condition=TargetNeedAttendChamiponship },
		{ type="ACTION", action = MakeDecision, params={ cmd="CHAMPIONSHIP" } },
	}
}


local _GroupFight = 
{
	type="SELECTOR", desc="group_fight", children = 
	{
		_GroupSkirimmage,
		_GroupTestFight,
		_GroupChampionship,
	}
}


----------------------------------------
----------------------------------------
local function TargetCanBeTestFightOfficer()
	if not _roleGroupCmp then return false end

	error( "2" )

	if _targetRoleCmp:GetStatusValue( "TESTFIGHT_APPLY" ) then
		return true
	end
	
	return false
end


local _GroupTestFightOfficer =
{
	type="SEQUENCE", desc="test_officer", children = 
	{
		{ type="FILTER", condition=TargetCanBeTestFightOfficer },
		{ type="ACTION", action = MakeDecision, params={ cmd="TESTFIGHT_OFFICER" } },
	}
}


local _GroupDuty = 
{
	type="SELECTOR", desc="group_elder", children = 
	{
		--teach/testfight
		_GroupTestFightOfficer,
	}
}


----------------------------------------
----------------------------------------
local function GroupNeedProduceResource( params )
	--affairs need follower to do
	if _targetGroupCmp:GetNumOfAffairs( "PRODUCE" ) >= #_targetGroupCmp.members then return false end

	--check wishlist first
	local producetype
	local total = MathUtil_Sum( _targetGroupCmp._resourceWishList )
	if params.type then
		producetype = params.type
	else
		if total > 0 then
			local value = Random_GetInt_Sync( 1, total )
			producetype = MathUtil_FindNameByAccum( _targetGroupCmp._resourceWishList, value )	
		else
			return false
		end
	end

	if _targetGroupCmp:GetNumOfAffairsByParams( { type="PRODUCE", produce=params.type } ) > 0 then
		--Dump( _targetGroupCmp.affairs ) print( "already has", params.type )
		return false
	end

	local produce = PRODUCE_DATATABLE_Get( producetype )
	if not produce then DBG_Error( "Produce is invalid! Type=", type ) end
	if produce.conditions then
		if produce.conditions.land then
			for type, value in pairs( produce.conditions.land ) do
				if _targetGroupCmp:GetNumOfLand( type ) < value then
					return false
				end
			end
		end
		if produce.conditions.resources then
			for type, value in pairs( produce.conditions.resources ) do
				if _targetGroupCmp:GetNumOfResource( type ) < value then
					return false
				end
			end
		end
	end

	_variables.producetype = producetype

	return true
end


local _GroupProducePriority =
{
	type="SEQUENCE", desc="group_priority", children = 
	{
		{ type="FILTER", condition=GroupNeedProduceResource, params={} },
		{ type="ACTION", action = AddAffair, params={ type="PRODUCE" } },
	}
}


local _GroupCollect =
{
	type="SEQUENCE", desc="group_collect", children = 
	{
		--{ type="FILTER", condition=GroupHasLand, params={ type="JUNGLELAND", lv=1 } },
		{ type="FILTER", condition=GroupNeedProduceResource, params={ type="FRUIT" } },
		{ type="ACTION", action = AddAffair, params={ type="PRODUCE" } },
	}
}

local _GroupFish =
{
	type="SEQUENCE", desc="group_fish", children = 
	{
		--{ type="FILTER", condition=GroupHasLand, params={ type="WATERLAND", lv=1 } },
		{ type="FILTER", condition=GroupNeedProduceResource, params={ type="FISH" } },
		{ type="ACTION", action = AddAffair, params={ type="PRODUCE" } },
	}
}

local _GroupFarm =
{
	type="SEQUENCE", desc="", children = 
	{
		--{ type="FILTER", condition=GroupHasLand, params={ type="FARMLAND", lv=1 } },
		{ type="FILTER", condition=GroupNeedProduceResource, params={ type="FOOD" } },
		{ type="ACTION", action = AddAffair, params={ type="PRODUCE" } },
	}
}

local _GroupCutWood =
{
	type="SEQUENCE", desc="", children =
	{
		--{ type="FILTER", condition=GroupHasLand, params={ type="WOODLAND" } },
		{ type="FILTER", condition=GroupNeedProduceResource, params={ type="WOOD" } },
		{ type="ACTION", action = AddAffair, params={ type="PRODUCE" } },
	}
}

local _GroupMineStone =
{
	type="SEQUENCE", desc="", children = 
	{
		--{ type="FILTER", condition=GroupHasLand, params={ type="STONEELAND", lv=1 } },
		{ type="FILTER", condition=GroupNeedProduceResource, params={ type="STONE" } },
		{ type="ACTION", action = AddAffair, params={ type="PRODUCE" } },
	}
}

local _GroupMineMineral =
{
	type="SEQUENCE", desc="", children = 
	{
		--{ type="FILTER", condition=GroupHasLand, params={ type="MINELAND", lv=1 } },
		{ type="FILTER", condition=GroupNeedProduceResource, params={ type="MINERAL" } },
		{ type="ACTION", action = AddAffair, params={ type="PRODUCE" } },
	}
}

local _GroupProduce = 
{
	--type="RANDOM_SELECTOR", desc="", children =
	type="SELECTOR", desc="", children =
	{
		_GroupCollect,
		_GroupFish,
		_GroupFarm,
		_GroupCutWood,
		_GroupMineStone,
		_GroupMineMineral,
	}		
}


----------------------------------------
----------------------------------------
local function GroupNeedMakeEquip( params )
	if not _targetGroupCmp then return false end	
	local list = EQUIPMENT_DATATABLE_Find( _targetGroupCmp, params.type )
	local num = #list
	if num == 0 then return false end
	local index = Random_GetInt_Sync( 1, num )
	local equip = list[index]
	_variables.maketype = params.type
	_variables.makeid   = equip.id
	return true
end


local function GroupNeedProcess( params )
	--if not GroupHasAffairs( { type="PROCESS", max=1 } ) then return false end
	if not params.action then DBG_Error( "no action" ) return false end
	local list = PROCESS_DATATABLE_Find( _targetGroupCmp, params.action )
	local num = #list
	if num == 0 then error( "no process" .. num )return false end
	local index = Random_GetInt_Sync( 1, num )
	local id = list[index]
	_variables.process = id	
	--print( "Need Process", params.action )
	return true
end


local _GroupMakeAccessory =
{
	type="SEQUENCE", desc="", children = 
	{
		{ type="FILTER", condition=GroupHasConstruction, params={ construction="ARMORY", affair={ type="MAKE_ITEM" } } },
		{ type="FILTER", condition=GroupNeedMakeEquip, params={ type="ACCESSORY" } },
		{ type="ACTION", action = AddAffair, params={ type="MAKE_ITEM" } },
	}
}


local _GroupMakeEquip =
{
	type="SEQUENCE", desc="", children = 
	{
		{ type="FILTER", condition=GroupHasConstruction, params={ construction="ARMORY", affair={ type="MAKE_ITEM" } } },
		{ type="FILTER", condition=GroupNeedMakeEquip, params={ type="WEAPON" } },
		{ type="ACTION", action = AddAffair, params={ type="MAKE_ITEM" } },
	}
}


local _GroupMakeCloth =
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupHasConstruction, params={ construction="ARMORY", affair={ type="MAKE_ITEM" } } },
		{ type="FILTER", condition=GroupNeedMakeEquip, params={ type="ARMOR" } },
		{ type="ACTION", action = AddAffair, params={ type="MAKE_ITEM" } },
	}
}

local _GroupRaiseHorse =
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupHasConstruction, params={ construction="PASTURE", affair={ type="MAKE_ITEM" } } },
		{ type="FILTER", condition=GroupNeedMakeEquip, params={ type="VEHICLE" } },
		{ type="ACTION", action = AddAffair, params={ type="MAKE_ITEM" } },
	}
}


local _GroupSmelt =
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupHasConstruction, params={ construction="SMITHY", affair={ type="PROCESS", process="SMELT" } } },
		{ type="FILTER", condition=GroupNeedProduceResource, params={ type="STEEL" } },
		{ type="ACTION", action = AddAffair, params={ type="PROCESS" } },
	}
}

local _GroupRaiseLivestock =
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupHasConstruction, params={ construction="FARM", affair={ type="PROCESS", process="RAISELIVESTOCK" } } },
		{ type="FILTER", condition=GroupNeedProcess, params={ action="RAISELIVESTOK" } },
		{ type="ACTION", action = AddAffair, params={ type="PROCESS" } },
	}
}


local _GroupPlantHerb =
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupHasConstruction, params={ construction="GARDEN", affair={ type="PROCESS",process="PLANTHERB" } } },
		{ type="FILTER", condition=GroupNeedProcess, params={ action="PLANTHERB" } },
		{ type="ACTION", action = AddAffair, params={ type="PROCESS" } },
	}
}


local _GroupMakeMedicine =
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupHasConstruction, params={ construction="PHARMACY", affair={ type="PROCESS", process="MAKEMEDICINE" } } },
		{ type="FILTER", condition=GroupNeedProcess, params={ action="MAKEMEDICINE" } },
		{ type="ACTION", action = AddAffair, params={ type="PROCESS" } },
	}
}


local _GroupProcess = 
{
	type="RANDOM_SELECTOR", desc="", children =
	{
		_GroupMakeEquip,
		_GroupMakeTool,
		_GroupSmelt,
		_GroupMakeCloth,
		_GroupRaiseLivestock,
		_GroupPlantHerb,
		_GroupMakeMedicine,
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
local function GroupNeedBuildConstruction()
	if _roleGroupCmp:GetNumOfAffairs( "BUILD_CONSTRUCTION" ) > 0 or
		_roleGroupCmp:GetNumOfAffairs( "UPGRADE_CONSTRUCTION" ) > 0 or
		_roleGroupCmp:GetNumOfAffairs( "DESTROY_CONSTRUCTION" ) > 0 then
		return false
	end

	--check wishlist first
	local constrtype
	local total = MathUtil_Sum( _targetGroupCmp._constructionWishList )
	if total > 0 then
		local value = Random_GetInt_Sync( 1, total )
		constrtype = MathUtil_FindNameByAccum( _targetGroupCmp._constructionWishList, value )
		--InputUtil_Pause( "need build", constrtype )
	end

	--find all constructions can be built
	local list = CONSTRUCTION_DATATABLE_Find( constrtype, _targetGroupCmp )
	local num = #list
	if num == 0 then return false end

	local index = Random_GetInt_Sync( 1, num )
	local id = list[index].id
	_variables.construction = id

	--InputUtil_Pause( "try to build", list[index].name )

	return true
end


local function GroupNeedUpgradeConstruction()
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


local function GroupNeedDestroyConstruction()
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
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupNeedBuildConstruction },
		{ type="ACTION", action = AddAffair, params={ type="BUILD_CONSTRUCTION" } },
	}
}

local _GroupUpgradeConstruction = 
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupNeedUpgradeConstruction },
		{ type="ACTION", action = AddAffair, params={ type="UPGRADE_CONSTRUCTION" } },
	}
}

local _GroupDestroyConstruction = 
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FAILURE" },
	}
}

----------------------------------------
----------------------------------------
local _GroupConstruction = 
{
	type="SEQUENCE", desc="", children =	
	{
		_GroupBuildConstruction,
		_GroupUpgradeConstruction,
		_GroupDestroyConstruction,
	}
}

----------------------------------------
----------------------------------------
local GroupAffair = 
{
	type="PARALLEL", desc = "scheudle_arrangement", children = 
	{
		--PROCESS always has the higher priority
		_GroupProcess,

		--CONSTRUCTION should be considered after the PROCESS
		_GroupConstruction,

		--PRODUCE should be the last thing to consider about.
		_GroupProducePriority,		
		_GroupProduce,
	}
}
_groupAffairTree = BehaviorNode( true )
_groupAffairTree:BuildTree( GroupAffair )

----------------------------------------
----------------------------------------
local ScheduleArrangement = 
{
	--find the right one
	type="SELECTOR", desc = "scheudle_arrangement", children = 
	{
		--normal priority
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
	type="SELECTOR", desc = "scheudle_arrangement", children = 
	{
		_PersonalHealthy,
		_GroupDuty,
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

	if not _roleEntity then
		--check deads for debug
		if DBG_FindData( role_ecsid ) then
			print( "Find in debugger data" )
		else
			print( "[AI]Role ecsid is invalid! ID=", role_ecsid )
			error("")
		end
		return
	end

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

	_targetGroupCmp._tempStatuses = {}
	_targetGroupCmp._constructionWishList = {}
	_targetGroupCmp._resourceWishList = {}

	--DBG_Trace( _roleCmp.name, "is thinking about group affairs" )
	Stat_Add( "RoleAI@Run_Times", nil, StatType.TIMES )

	_behavior:Run( _groupAffairTree )
end


----------------------------------------
-- Group master
----------------------------------------
function AI_DetermineSchedule( role_ecsid, params )	
	if not InitBehavior( role_ecsid, params ) then DBG_TraceBug( "Init role's ai failed" ) return end

	if not _targetGroupCmp then DBG_Error( "Target isn't in group!" ) end

	--DBG_Trace( _roleCmp.name, "is thinking about schedule. target=" .. _targetRoleCmp.name )
	Stat_Add( "RoleAI@Run_Times", nil, StatType.TIMES )

	return _behavior:Run( _scheduleTree )
end


----------------------------------------
-- All roles
----------------------------------------
function AI_DetermineAction( role_ecsid, params )
	if not InitBehavior( role_ecsid, params ) then DBG_TraceBug( "Init role's ai failed" ) return end

	--DBG_Trace( _roleCmp.name, "is thinking about action" )
	Stat_Add( "RoleAI@Run_Times", nil, StatType.TIMES )

	return _behavior:Run( _actionTree )
end


----------------------------------------
----------------------------------------