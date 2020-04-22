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

local function GroupHasActionPts( params )
	local affairParams = GROUP_AFFAIRS[params.affair]

	--action points
	if affairParams.actionpts then
		--group modification
		local ratio = 1
		if affairParams.size_mod then ratio = affairParams.size_mod[_targetGroupCmp.size] end
		for type, value in pairs( affairParams.actionpts ) do
			local need =  math.ceil( value * ratio )
			local has = _targetGroupCmp.actionpts[type]
			if has < need then
				print( params.affair, "not enough ", type, has .. "/" .. need )
				return false
			end
		end
	end

	print( _targetGroupCmp.name .. " has action pts for", params.affair )
	return true
end

----------------------------------------
local function GroupHasConstruction( params )
	local num = 0
	if params.construction then
		num = _targetGroupCmp:GetNumOfConstruction( params.construction )
		--should reduce the construction occpuied by the affairs
		if num > 0 then
			if params.affair then
				num = num - _targetGroupCmp:GetNumOfAffairsByParams( params.affair )
			end	
		else
			--We don't have the construction, we put it into the wishlish
			_targetGroupCmp:AddWishConstruction( params.construction )
			--InputUtilf( "building", params.construction, num )
		end
	else
		for itemType, data in pairs( _targetGroupCmp._itemWishList ) do
			
		end
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

		--Stat_Add( "RoleDecision", _roleCmp.name .. "=" .. params.cmd, StatType.LIST )
		Stat_Add( _roleCmp.name .. "_" .. params.cmd, 1, StatType.TIMES )
	else
		DBG_Trace( _targetRoleCmp.name .. " decide to do=" .. params.cmd )

		--Stat_Add( "RoleDecision", _targetRoleCmp.name .. "=" .. params.cmd, StatType.LIST )
		Stat_Add( _targetRoleCmp.name .. "_" .. params.cmd, 1, StatType.TIMES )
	end
end


----------------------------------------
local function AddAffair( params )
	if params.type == "BUILD_CONSTRUCTION" then
		Group_StartBuildingConstruction( _targetGroupCmp, _variables.construction )		
	elseif params.type == "UPGRADE_CONSTRUCTION" then
		Group_StartUpgradingConstruction( _targetGroupCmp, _variables.construction, _variables.target )
	elseif params.type == "DESTROY_CONSTRUCTION" then

	elseif params.type == "MAKE_ITEM" then
		if _variables.maketype and _variables.makeid then
			Group_StartMakeItem( _targetGroupCmp, _variables.maketype, _variables.makeid )
		else
			DBG_Error( "unspecified making item" )
		end
	elseif params.type == "PROCESS"	then
		if _variables.processtype then
			Group_StartProcess( _targetGroupCmp, _variables.processtype )
			InputUtil_Pause( "PROCESS" )
		end
	elseif params.type == "PRODUCE" then
		if _variables.producetype then
			Group_StartProduce( _targetGroupCmp, _variables.producetype )
		else
			DBG_Error( "unspecified produce type" )
		end

	elseif params.type == "RECONN" then
		if _variables.targetgroup then
			Group_StartReconn( _targetGroupCmp, _variables.targetgroup )
		end
	elseif params.type == "SABOTAGE" then
		if _variables.targetgroup then
			Group_Sabotage( _targetGroupCmp, _variables.targetgroup )
		end
	elseif params.type == "ATTACK" then
		if _variables.targetgroup then
			Group_Attack( _targetGroupCmp, _variables.targetgroup )
		end
	elseif params.type == "STOLE" then
		if _variables.targetgroup then
			Group_Stole( _targetGroupCmp, _variables.targetgroup )
		end

	elseif params.type == "GRANT_GIFT" then
		if _variables.targetgroup then
			Group_StartGrantGift( _targetGroupCmp, _variables.targetgroup )
		end
	elseif params.type == "SIGN_PACT" then
		if _variables.targetgroup and _variables.pact then
			Group_StartSignPact( _targetGroupCmp, _variables.targetgroup, _variables.pact )
		end

	elseif params.type == "REWARD_FOLLOWER" then
		if _variables.targetrole and _variables.targettype and _variables.targetid then
			Group_RewardFollower( _targetGroupCmp, _variables.targetrole, _variables.targettype, _variables.targetid )
		end

	elseif params.type == "TAKE_ENTRUST" then
		if _variables.entrustindex then
			Group_TakeEntrust( _targetGroupCmp, _variables.entrustindex )
		end

	elseif params.type == "RECRUIT_FOLLOWER" then
		Group_RecruitFollower( _targetGroupCmp )

	else
		DBG_Error( "unhandle", params.type )
	end

	local affairParams = GROUP_AFFAIRS[params.type]
	--action points
	if affairParams and affairParams.actionpts then
		--group modification
		local ratio = 1
		if affairParams.size_mod then ratio = affairParams.size_mod[_targetGroupCmp.size] end
		for type, value in pairs( affairParams.actionpts ) do			
			_targetGroupCmp.actionpts[type] = _targetGroupCmp.actionpts[type] - math.ceil( value * ratio )			
			if _targetGroupCmp.actionpts[type] < 0 then DBG_Error( _targetGroupCmp.name .. " doesn't have enough actionpts=", type ) end
		end
	end

	DBG_Trace( _targetGroupCmp.name .. " add affair=" .. params.type )
	--InputUtil_Pause( "Add affair", params.type )
	--Stat_Add( "GroupAffair", _targetGroupCmp.name .. "=" .. params.type, StatType.LIST )
	Stat_Add( _targetGroupCmp.name .. "_" .. params.type, 1, StatType.TIMES )
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

local _Msg = 
{
	type="MESSAGE", desc="Pause message",
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
		local map = CurrentMap
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
local function GroupNeedMakeItem( params )
	local makeType
	local list
	if params and params.type then
		makeType = params.type
		list = EQUIPMENT_DATATABLE_Find( _targetGroupCmp, params.type )
	else
		for itemType, data in pairs( _targetGroupCmp._itemWishList ) do
			for itemId, quantity in pairs( data ) do				
				list = PROCESS_DATATABLE_FindByItem( _targetGroupCmp, itemType, itemId )
				--print( "find item", itemId, quantity, #list )
				if #list ~= 0 then
					--print( "find item in wishlist=", itemType, itemId, quantity )
					break					
				end
			end
		end
		if not list then return false end
	end

	local num = #list
	if num == 0 then return false end
	
	local index = Random_GetInt_Sync( 1, num )
	local equip = list[index]
	_variables.maketype = params.type
	_variables.makeid   = equip.id

	return true
end


--------------------------------------------------------------------------------
-- Check group whether to process.
-- Process materials will get some resource( herb )
--------------------------------------------------------------------------------
local function GroupNeedProcess( params )
	local processType
	local list
	if params and params.action then
		processType = params.action
		list = PROCESS_DATATABLE_Find( _targetGroupCmp, processType )
	else
		local total = MathUtil_Sum( _targetGroupCmp._resourceWishList )
		if total > 0 then
			local value = Random_GetInt_Sync( 1, total )
			local resourceType = MathUtil_FindNameByAccum( _targetGroupCmp._resourceWishList, value )
			list = PROCESS_DATATABLE_FindByResource( _targetGroupCmp, resourceType )
		else
			--InputUtil_Pause( "no action" )
			return false
		end
	end

	local num = #list
	if num == 0 then return false end

	local index = Random_GetInt_Sync( 1, num )
	local id = list[index]
	_variables.process = id	
	
	InputUtil_Pause( "Need Process", processType )
	return true
end


----------------------------------------
-- Produce resource from the natural
----------------------------------------
local function GroupNeedProduceResource( params )
	--affairs need follower to do
	if _targetGroupCmp:GetNumOfAffairs( "PRODUCE" ) >= #_targetGroupCmp.members then return false end

	local producetype
	if params and params.type then
		producetype = params.type
	else
		--check wishlist first		
		local total = MathUtil_Sum( _targetGroupCmp._resourceWishList )
		if total > 0 then
			local value = Random_GetInt_Sync( 1, total )
			producetype = MathUtil_FindNameByAccum( _targetGroupCmp._resourceWishList, value )
		else
			return false
		end
	end

	if _targetGroupCmp:GetNumOfAffairsByParams( { type="PRODUCE", produce=producetype } ) > 0 then
		return false
	end

	local produce = PRODUCE_DATATABLE_Get( producetype )
	if produce then
		if not PRODUCE_DATATABLE_MatchCondition( _targetGroupCmp, produce ) then
			return false
		end
		_variables.producetype = producetype
		return true
	end

	--find from process datatable
	local list = PROCESS_DATATABLE_FindByResource( _targetGroupCmp, producetype )
	--print( "find process by res", producetype, #list )
	local num = #list
	if num == 0 then return false end

	local index = Random_GetInt_Sync( 1, num )
	local id = list[index]
	_variables.process = id

	InputUtil_Pause( "find process", producetype )

	return true
end


----------------------------------------
----------------------------------------
local _GroupMakeAccessory =
{
	type="SEQUENCE", desc="", children = 
	{
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="MAKE_ITEM" } },
		{ type="FILTER", condition=GroupHasConstruction, params={ construction="ARMORY", affair={ type="MAKE_ITEM" } } },
		{ type="FILTER", condition=GroupNeedMakeItem, params={ type="ACCESSORY" } },
		{ type="ACTION", action = AddAffair, params={ type="MAKE_ITEM" } },
	}
}


local _GroupMakeEquip =
{
	type="SEQUENCE", desc="", children = 
	{
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="MAKE_ITEM" } },
		{ type="FILTER", condition=GroupHasConstruction, params={ construction="ARMORY", affair={ type="MAKE_ITEM" } } },
		{ type="FILTER", condition=GroupNeedMakeItem, params={ type="WEAPON" } },
		{ type="ACTION", action = AddAffair, params={ type="MAKE_ITEM" } },
	}
}


local _GroupMakeCloth =
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="MAKE_ITEM" } },
		{ type="FILTER", condition=GroupHasConstruction, params={ construction="ARMORY", affair={ type="MAKE_ITEM" } } },
		{ type="FILTER", condition=GroupNeedMakeItem, params={ type="ARMOR" } },
		{ type="ACTION", action = AddAffair, params={ type="MAKE_ITEM" } },
	}
}

local _GroupRaiseHorse =
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="MAKE_ITEM" } },
		{ type="FILTER", condition=GroupHasConstruction, params={ construction="PASTURE", affair={ type="MAKE_ITEM" } } },
		{ type="FILTER", condition=GroupNeedMakeItem, params={ type="VEHICLE" } },
		{ type="ACTION", action = AddAffair, params={ type="MAKE_ITEM" } },
	}
}


local _GroupSmelt =
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="PROCESS" } },
		{ type="FILTER", condition=GroupHasConstruction, params={ construction="SMITHY", affair={ type="PROCESS", process="SMELT" } } },
		{ type="FILTER", condition=GroupNeedProcess, params={ type="SMELT" } },
		{ type="ACTION", action = AddAffair, params={ type="PROCESS" } },
	}
}

local _GroupRaiseLivestock =
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="PROCESS" } },
		{ type="FILTER", condition=GroupHasConstruction, params={ construction="FARM", affair={ type="PROCESS", process="RAISELIVESTOCK" } } },
		{ type="FILTER", condition=GroupNeedProcess, params={ action="RAISELIVESTOK" } },
		{ type="ACTION", action = AddAffair, params={ type="PROCESS" } },
	}
}


local _GroupPlantHerb =
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="PROCESS" } },
		{ type="FILTER", condition=GroupHasConstruction, params={ construction="GARDEN", affair={ type="PROCESS",process="PLANTHERB" } } },
		{ type="FILTER", condition=GroupNeedProcess, params={ action="PLANTHERB" } },
		{ type="ACTION", action = AddAffair, params={ type="PROCESS" } },
	}
}


local _GroupMakeMedicine =
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="PROCESS" } },
		{ type="FILTER", condition=GroupHasConstruction, params={ construction="PHARMACY", affair={ type="PROCESS", process="MAKEMEDICINE" } } },
		{ type="FILTER", condition=GroupNeedProcess, params={ action="MAKEMEDICINE" } },
		{ type="ACTION", action = AddAffair, params={ type="PROCESS" } },
	}
}


local _GroupProcess = 
{
	--type="RANDOM_SELECTOR", desc="", children =
	type="SELECTOR", desc="", children =
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


------------------------------------------------
------------------------------------------------
local _GroupCollect =
{
	type="SEQUENCE", desc="group_collect", children = 
	{
		--{ type="FILTER", condition=GroupHasLand, params={ type="JUNGLELAND", lv=1 } },
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="MAKE_ITEM" } },
		{ type="FILTER", condition=GroupNeedProduceResource, params={ type="PRODUCE" } },
		{ type="ACTION", action = AddAffair, params={ type="PRODUCE" } },
	}
}

local _GroupFish =
{
	type="SEQUENCE", desc="group_fish", children = 
	{
		--{ type="FILTER", condition=GroupHasLand, params={ type="WATERLAND", lv=1 } },
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="PRODUCE" } },
		{ type="FILTER", condition=GroupNeedProduceResource, params={ type="FISH" } },
		{ type="ACTION", action = AddAffair, params={ type="PRODUCE" } },
	}
}

local _GroupFarm =
{
	type="SEQUENCE", desc="", children = 
	{
		--{ type="FILTER", condition=GroupHasLand, params={ type="FARMLAND", lv=1 } },
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="PRODUCE" } },
		{ type="FILTER", condition=GroupNeedProduceResource, params={ type="FOOD" } },
		{ type="ACTION", action = AddAffair, params={ type="PRODUCE" } },
	}
}

local _GroupCutWood =
{
	type="SEQUENCE", desc="", children =
	{
		--{ type="FILTER", condition=GroupHasLand, params={ type="WOODLAND" } },
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="PRODUCE" } },
		{ type="FILTER", condition=GroupNeedProduceResource, params={ type="WOOD" } },
		{ type="ACTION", action = AddAffair, params={ type="PRODUCE" } },
	}
}

local _GroupMineStone =
{
	type="SEQUENCE", desc="", children = 
	{
		--{ type="FILTER", condition=GroupHasLand, params={ type="STONEELAND", lv=1 } },
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="PRODUCE" } },
		{ type="FILTER", condition=GroupNeedProduceResource, params={ type="STONE" } },
		{ type="ACTION", action = AddAffair, params={ type="PRODUCE" } },
	}
}

local _GroupMineMineral =
{
	type="SEQUENCE", desc="", children = 
	{
		--{ type="FILTER", condition=GroupHasLand, params={ type="MINELAND", lv=1 } },
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="PRODUCE" } },
		{ type="FILTER", condition=GroupNeedProduceResource, params={ type="MINERAL" } },
		{ type="ACTION", action = AddAffair, params={ type="PRODUCE" } },
	}
}

local _GroupProduce = 
{
	--type="RANDOM_SELECTOR", desc="", children =
	type="PARALLEL", desc="", children =
	{
		--Still have some thing need to produce at first
		_GroupCollect,
		_GroupFish,
		_GroupFarm,
		_GroupCutWood,
		_GroupMineStone,
		_GroupMineMineral,
	}		
}


----------------------------------------
-- Task
--   Entrust( NPC )
--   Event( scenario )
--	 
----------------------------------------
local function GroupNeedEntrust()
	local city = CurrentMap:GetCity( _targetGroupCmp.location )
	local cityCmp = ECS_SendEvent( "CITY_COMPONENT", "Get", city.id )
	local entrustCmp = ECS_FindComponent( cityCmp.entityid, "ENTRUST_COMPONENT" )

	local list = {}
	for index, data in pairs( entrustCmp.entrusts ) do
		local entrust = ENTRUST_DATATABLE_Get( data.id )
		if Entrust_CanTake( _targetGroupCmp, cityCmp, entrust ) then
			table.insert( list, entrust )
		end
	end

	local num = #list
	if num == 0 then return false end

	local index = Random_GetInt_Sync( 1, num )
	_variables.entrustindex = index

	return true
end

local _GroupTakeEntrust = 
{
	type="SEQUENCE", desc="Entrust", children =
	{
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="TAKE_ENTRUST" } },
		{ type="FILTER", condition=GroupNeedEntrust },
		{ type="ACTION", action = AddAffair, params={ type="TAKE_ENTRUST" } },
	}	
}

local _GroupTaskExecute = 
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupHasTask },
		{ type="ACTION", action = AddAffair, params={ type="EXECUTETASK" } },
	}
}

----------------------------------------
-- Diplomacy
--
-- Send envy
--   GrantGift
--   Threaten
--   Sign pact
--   Declare war
--   Make peace
----------------------------------------
local function GroupNeedGrantGift()
	--conditions
	--  1.has diplomatic with enough points
	--  2.has gift
	--target
	--  1.friend with our neighbor low power
	--  2.the enemy of the enemy is our friend
	--  3.potential to be ally
	local power = _targetGroupCmp:GetData( "POWER" )
	local list = {}
	local totalprob = 0
	local intelCmp = ECS_FindComponent( _targetGroupCmp.entityid, "INTEL_COMPONENT" )
	local relationCmp = ECS_FindComponent( _targetGroupCmp.entityid, "RELATION_COMPONENT" )
	relationCmp:Foreach( function ( relation )
		--is at war
		if not Relation_CanGrantGift( relation ) then return end
		local prob = 0
		local opp_power = Intel_GetGroupPower( intelCmp:GetGroupIntel( relation.id ) )
		if Relation_HasSameEnemy( relation ) then			
			prob = opp_power * 100 / ( opp_power + power )			
			table.insert( list, { id=relation.id, prob=prob } )
		elseif Relation_IsPotentialAlly( relation ) then
			 prob = opp_power * 100 / ( opp_power + power )
			table.insert( list, { id=relation.id, prob=prob } )
		else
			if power < opp_power * 2 then
				prob = opp_power * 100 / ( opp_power + power )
				table.insert( list, { id=relation.id, prob=prob } )
			end
		end
		totalprob = totalprob + prob
	end )

	local prob = Random_GetInt_Sync( 1, totalprob )
	for _, data in ipairs( list ) do
		if prob < data.prob then
			_variables.targetgroup = data.id
			return true
		end
		prob = prob - data.prob
	end

	return false	
end


local function GroupNeedSignPact()
	local power = _targetGroupCmp:GetData( "POWER" )
	local list = {}
	local totalprob = 0
	local intelCmp = ECS_FindComponent( _targetGroupCmp.entityid, "INTEL_COMPONENT" )
	local relationCmp = ECS_FindComponent( _targetGroupCmp.entityid, "RELATION_COMPONENT" )

	function HandleRelation( relation )
		local oppRelationCmp = ECS_FindComponent( relation.id, "RELATION_COMPONENT" )
		local oppRelation = oppRelationCmp:GetRelation( _targetGroupCmp.entityid )
		local opp_power = Intel_GetGroupPower( intelCmp:GetGroupIntel( relation.id ) )

		function MatchPactCondition( pact, relation )
			if not pact.conditions then return false end
			local condition = pact.conditions

			if condition.status then
				if relation.status ~= condition.status then return false end
			end

			if condition.elapsed then
				if relation.elapsed < condition.elapsed then return false end
			end
			if condition.adv_prop then
				local prop = math.abs( relation.advantage / ( relation.advantage + oppRelation.advantage ) )
				if prop < condition.adv_prop.min or prop > condition.adv_prop.max then return false end
			end				
			if condition.power_prop then
				local prop = math.abs( power / ( power + opp_power ) )
				if prop < condition.power_prop.min or prop > condition.power_prop.max then return false end
			end
			return true
		end

		--reference RELATION_STATUSCAPACITY
		local capacity = RELATION_STATUSCAPACITY[relation.status]
		if capacity.diplomacy == 0 then return end

		for pactname, pact in pairs( RELATION_PACT ) do
			--check conditions
			if MatchPactCondition( pact, relation ) then
				local prob=50
				totalprob = totalprob + prob
				table.insert( list, { targetgroup=relation.id, pact=pactname, prob=prob } )
			end
		end
	end

	relationCmp:Foreach( HandleRelation )

	--mod=1 means should select a pact
	--mod>1 means we may not choice any pact
	local mod = 1
	local prob = Random_GetInt_Sync( 1, totalprob * mod )
	for _, data in ipairs( list ) do
		if prob < data.prob then
			_variables.targetgroup = data.targetgroup
			_variables.pact = data.pact
			return true
		end
		prob = prob - data.prob
	end

	return false
end


local function GroupNeedDeclareWar()
	--need expand
end


local _GroupGrantGift = 
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupNeedGrantGift },
		{ type="ACTION", action = AddAffair, params={ type="GRANT_GIFT" } },
	}
}

local _GroupSignPact = 
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupNeedSignPact },
		{ type="ACTION", action = AddAffair, params={ type="SIGN_PACT" } },
	}
}

local _GroupDipomacy = 
{
	type="SELECTOR", desc="Diplomacy Branch", children =	
	{
		_GroupSignPact,
		_GroupGrantGift,
	}
}

----------------------------------------
-- Operation
--   Reconnaissance
--   Sabotage
--	 Attack
----------------------------------------
local function GroupNeedReconn( params )
	local list = {}
	local totalprob = 0
	local intelCmp = ECS_FindComponent( _targetGroupCmp.entityid, "INTEL_COMPONENT" )
	intelCmp:ForeachGroupIntel( function ( intel )
		local eval = Intel_GetEval( intel )
		if eval < INTEL_GRADE["MID"] then
			local prob = INTEL_GRADE["FULL"] - eval
			totalprob = totalprob + prob
			table.insert( list, { intel=intel, prob=prob } )
		else
			local prob = ( eval - INTEL_GRADE["MID"] ) * 0.25
			totalprob = totalprob + prob
			table.insert( list, { intel=intel, prob=prob } )
		end
	end )

	local prob = Random_GetInt_Sync( 1, totalprob * 2 )
	for _, data in ipairs( list ) do
		if prob < data.prob then
			_variables.targetgroup = data.intel.id
			return true
		end
		prob = prob - data.prob
	end

	return false
end


local function GroupNeedAttack()
	if #_targetGroupCmp.members == 0 then return end

	local atkeids = Group_ListRoles( _targetGroupCmp, nil, { "OUTING" } )
	if #atkeids == 0 then return false end

	local intelCmp = ECS_FindComponent( _targetGroupCmp.entityid, "INTEL_COMPONENT" )

	--find the target which match
	--  1.at war
	--  2.has enough power
	local power = _targetGroupCmp:GetData( "POWER" )
	local list = {}	
	local relationCmp = ECS_FindComponent( _targetGroupCmp.entityid, "RELATION_COMPONENT" )
	relationCmp:Foreach( function ( relation )
		--is at war
		if not Relation_CanAttack( relation ) then return end

		--power compare
		local intel = intelCmp:GetGroupIntel( relation.id )

		local opp_power = Intel_GetGroupPower( intel )
		--print( _targetGroupCmp.entityid, relation.id )
		if power > opp_power * 0.5 then
			table.insert( list, relation )
		end
	end )

	local num = #list
	if num == 0 then return false end
	local index = Random_GetInt_Sync( 1, num )
	local id = list[index].id
	_variables.targetgroup = id

	return true
end

local function GroupNeedSabotage( group )
	--find the most highest hostility
	local targetgroup
	local maxEval = 0
	local relationCmp = ECS_FindComponent( _targetGroupCmp.entityid, "RELATION_COMPONENT" )
	relationCmp:Foreach( function ( relation )
		if not targetgroup then targetgroup = relation.id end
		local eval = Relation_GetEval( relation )
		if eval < maxEval then
			targetgroup = relation.id
			maxEval = eval
		end
	end )

	--enough power

	return false
end


local function GroupNeedStole( params )
	--find the most highest hostility
	local targetgroup
	local maxEval = 0
	local relationCmp = ECS_FindComponent( _targetGroupCmp.entityid, "RELATION_COMPONENT" )
	relationCmp:Foreach( function ( relation )
		if not targetgroup then targetgroup = relation.id end
		local eval = Relation_GetEval( relation )
		if eval < maxEval then
			targetgroup = relation.id
			maxEval = eval
		end
	end )

	--enough intel

	--low power

	--very strong person	
	return false
end


local _GroupReconnaissance = 
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupNeedReconn },		
		{ type="ACTION", action = AddAffair, params={ type="RECONN" } },
	}
}

local _GroupSabotage = 
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupNeedSabotage },
		{ type="ACTION", action = AddAffair, params={ type="SABOTAGE" } },
	}
}

local _GroupAttack = 
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupNeedAttack },
		{ type="ACTION", action = AddAffair, params={ type="ATTACK" } },
	}
}

local _GroupStole = 
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupNeedStole },
		{ type="ACTION", action = AddAffair, params={ type="STOLE" } },
	}
}

local _GroupOperation = 
{
	type="SELECTOR", desc="Opeartion Branch", children =	
	{
		_GroupReconnaissance,
		--_GroupSabotage,
		
		_GroupAttack,
		--_GroupStole,
	}
}


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
		--DBG_Trace( "need wishlist construction=" .. constrtype )
	end

	--find all constructions can be built
	local list = CONSTRUCTION_DATATABLE_Find( constrtype, _targetGroupCmp, { wishlist=true } )
	local num = #list
	if num == 0 then
		--print( "not match building conditions" )
		return false
	end

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

	local list = CONSTRUCTION_DATATABLE_Find( nil, _roleGroupCmp, { upgrade=true } )
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
	type="SEQUENCE", desc="build construction", children =
	{
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="BUILD_CONSTRUCTION" } },
		{ type="FILTER", condition=GroupNeedBuildConstruction },
		{ type="ACTION", action = AddAffair, params={ type="BUILD_CONSTRUCTION" } },
	}
}

local _GroupUpgradeConstruction = 
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="UPGRADE_CONSTRUCTION" } },
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
local _GroupMakePriority =
{
	type="SEQUENCE", desc="make priority", children = 
	{
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="MAKE_ITEM" } },
		{ type="FILTER", condition=GroupNeedMakeItem },
		{ type="ACTION", action = AddAffair, params={ type="MAKE_ITEM" } },
	}
}

local _GroupProcessPriority =
{
	type="SEQUENCE", desc="process priority", children =
	{
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="PROCESS" } },
		{ type="FILTER", condition=GroupNeedProcess },
		{ type="ACTION", action = AddAffair, params={ type="PROCESS" } },
	}
}

local _GroupProducePriority =
{
	type="SEQUENCE", desc="produce priority", children = 
	{
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="PRODUCE" } },
		{ type="FILTER", condition=GroupNeedProduceResource },
		{ type="ACTION", action = AddAffair, params={ type="PRODUCE" } },
	}
}


local _GroupPriorityAffair = 
{
	type="PARALLEL", desc="", children = 
	{
		_GroupMakePriority,
		_GroupProcessPriority,
		_GroupBuildConstruction,
		_GroupProducePriority,
	}
}


----------------------------------------
local function GroupNeedRewardFollower()
	if #_targetGroupCmp.arms == 0 and #_targetGroupCmp.items == 0 then return false end
	
	--local list = Group_ListRoles( _targetGroupCmp, { "NEED_REWARD" }, { "OUTING" } )
	local list = Group_ListRoles( _targetGroupCmp, {}, { "OUTING" } )
	if #list == 0 then return false end

	local needs = {}
	for _, ecsid in ipairs( list ) do
		local roleCmp = ECS_FindComponent( ecsid, "ROLE_COMPONENT" )
		--equipment
		for type, _ in pairs( ROLE_EQUIP ) do 
			if not roleCmp.equips[type] then
				if not needs[type] then needs[type] = {} end
				table.insert( needs[type], roleCmp )
			end
		end
		--items
		if roleCmp:CanAddToBag() then
			if not needs["MEDICINE"] then needs["MEDICINE"] = {} end
			table.insert( needs["MEDICINE"], roleCmp )
		end
	end

	--equpiment
	for _, inv in ipairs( _targetGroupCmp.arms ) do
		local data = EQUIPMENT_DATATABLE_Get( inv.id )
		if needs[data.type] then
			local index = Random_GetInt_Sync( 1, #needs[data.type] )
			_variables.targetrole = needs[data.type][index].entityid
			_variables.targettype = data.type
			_variables.targetid   = inv.id
			return true
		end
	end

	--vehicle
	for _, inv in ipairs( _targetGroupCmp.vehicles ) do			
		local data = EQUIPMENT_DATATABLE_Get( inv.id )
		if needs[data.type] then
			local index = Random_GetInt_Sync( 1, #needs[data.type] )
			_variables.targetrole = needs[data.type][index].entityid
			_variables.targettype = data.type
			_variables.targetid   = inv.id
			return true
		end
	end

	--item
	for _, inv in ipairs( _targetGroupCmp.items ) do
		local data = ITEM_DATATABLE_Get( inv.id )
		if needs[data.type] then
			local index = Random_GetInt_Sync( 1, #needs[data.type] )
			_variables.targetrole = needs[data.type][index].entityid
			_variables.targettype = data.type
			_variables.targetid   = inv.id
			return true
		end
	end

	return false
end

local function GroupNeedRecruitFollower()
	--member number cap
	--print( "follower", #_targetGroupCmp.members .. "/" .. _targetGroupCmp:GetData( "MAX_MEMBER" ) )
	if #_targetGroupCmp.members >= _targetGroupCmp:GetData( "MAX_MEMBER" ) then return false end

	--salary space
	local space = Group_CalcFollowerSalary( { rank="SENIOR", size=_targetGroupCmp.size, grade=FIGHTERTEMPLATE_GRADE.ULTRA_RARE } )
	local cap   = ( _targetGroupCmp:GetData( "ESTIMATE_EXPEND" ) + space ) * 3	
	local has = _targetGroupCmp:GetData( "ESTIMATE_MONEY" )
	--Dump( _targetGroupCmp.assets ) InputUtil_Pause( has, cap, space )
	if has < cap then return false end

	return true
end

local function GroupNeedSellItem()
	return false
end

local function GroupBuyItem()
	return false
end


local _GroupRecruitFollower = 
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="RECRUIT_FOLLOWER" } },
		{ type="FILTER", condition=GroupNeedRecruitFollower },
		{ type="ACTION", action = AddAffair, params={ type="RECRUIT_FOLLOWER" } },
	}
}


local _GroupRewardFollower = 
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupHasActionPts, params={ affair="REWARD_FOLLOWER" } },
		{ type="FILTER", condition=GroupNeedRewardFollower },
		{ type="ACTION", action = AddAffair, params={ type="REWARD_FOLLOWER" } },
	}
}

local _GroupSellItem = 
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupNeedSellItem },
		{ type="ACTION", action = AddAffair, params={ type="SELL_ITEM" } },
	}
}

local _GroupBuyItem = 
{
	type="SEQUENCE", desc="", children =
	{
		{ type="FILTER", condition=GroupBuyItem },
		{ type="ACTION", action = AddAffair, params={ type="BUY_ITEM" } },
	}
}


local _GroupHRManagement = 
{
	type="SEQUENCE", desc="", children =	
	{
		_GroupRecruitFollower,
		_GroupRewardFollower,
		_GroupSellItem,
		_GroupBuyItem,
	}
}


--------------------------------------------------------------------------------
-- Group Affairs
--   1. Entrust should be consider at first
--      Entrust will leads construction, inventory, resource requirement
--
--
--
--------------------------------------------------------------------------------
local GroupAffair = 
{
	type="PARALLEL", desc = "scheudle_arrangement", children = 
	{
		--Take entrust
		_GroupTakeEntrust,

		--Priority
		_GroupPriorityAffair,

		--PROCESS always has the higher priority, it needs construction and resource materials
		_GroupProcess,

		--CONSTRUCTION should be considered after the PROCESS
		_GroupConstruction,

		--Still have some thing need to produce at first.
		_GroupProducePriority,

		--PRODUCE should be the last thing to consider about.		
		_GroupProduce,

		--Reward inventory to follower
		_GroupHRManagement,

		--External
		_GroupDipomacy,
		_GroupOperation,
	}
}
_groupAffairTree = BehaviorNode( true )
_groupAffairTree:BuildTree( GroupAffair )

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
		_DefaultDecision,
	}
}
_scheduleTree = BehaviorNode( true )
_scheduleTree:BuildTree( ScheduleArrangement )

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


--------------------------------------------------------------------------------
-- Group master determine group's affair
--------------------------------------------------------------------------------
function AI_DetermineGroupAffair( role_ecsid, params )
	if not InitBehavior( role_ecsid, params ) then DBG_TraceBug( "Init role's ai failed" ) return end
	if not _targetGroupCmp then DBG_Error( "Target isn't in group!" ) end

	_targetGroupCmp._tempStatuses = {}
	--{ constr=value, ... }
	_targetGroupCmp._constructionWishList = {}
	--{ restype=value, ... }
	_targetGroupCmp._resourceWishList = {}
	--{ itemtype={ itemid=value }, ... }
	_targetGroupCmp._itemWishList = {}
	--{ roleid={affair}, ... }
	_targetGroupCmp._followerReserveList = {}
	--{ { type=quantity } }
	_targetGroupCmp._landWishList = {}

	DBG_Trace( _roleCmp.name, "is thinking about group affairs" )
	Stat_Add( "RoleAI@Run_Times", nil, StatType.TIMES )

	_behavior:Run( _groupAffairTree )
end


--------------------------------------------------------------------------------
-- Group master or Elder determine follower's schedule
--------------------------------------------------------------------------------
function AI_DetermineSchedule( role_ecsid, params )	
	if not InitBehavior( role_ecsid, params ) then DBG_TraceBug( "Init role's ai failed" ) return end

	if not _targetGroupCmp then DBG_Error( "Target isn't in group!" ) end

	--DBG_Trace( _roleCmp.name, "is thinking about schedule. target=" .. _targetRoleCmp.name )
	Stat_Add( "RoleAI@Run_Times", nil, StatType.TIMES )

	return _behavior:Run( _scheduleTree )
end


----------------------------------------
-- Role determine his action
----------------------------------------
function AI_DetermineAction( role_ecsid, params )
	if not InitBehavior( role_ecsid, params ) then DBG_TraceBug( "Init role's ai failed" ) return end

	--DBG_Trace( _roleCmp.name, "is thinking about action" )
	Stat_Add( "RoleAI@Run_Times", nil, StatType.TIMES )

	return _behavior:Run( _actionTree )
end


----------------------------------------
----------------------------------------