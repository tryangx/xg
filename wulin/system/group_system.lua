---------------------------------------
-- Group Prepare
--   Init group data by params
--   Now just for test
---------------------------------------
local GROUP_PARAMS = 
{
	START = 
	{
		FAMILY     = 
			{
			member={min=3,max=5,ELDER={num=1}},
			assets={ LAND={init=3}, REPUTATION={min=100,max=300}, INFLUENCE={min=100,max=300}, MONEY={min=1000,max=2000} },
			resources=
				{				
				CLOTH={min=100,max=200}, FOOD={min=100,max=200}, MEAT={min=100,max=200}, WOOD={min=100,max=200}, LEATHER={min=100,max=200}, STONE={min=100,max=200}, IRON_ORE={min=100,max=200}, DRAKSTEEL={min=100,max=200},
				},
			books= { num={min=3,max=5,tot_lv=10}, pool={20,30,40,100,110,120,130,140,150,160,170,180,190,200,210,220,230,400,410,420,430,440,1000,2000}, },
			constrs={ HOUSE=1 },
			lands={},
			},
		SMALL      =
			{
			member={min=4,max=8,ELDER=1},
			assets={ LAND={init=10}, REPUTATION={min=200,max=500}, INFLUENCE={min=200,max=500}, MONEY={min=1000,max=2000} },
			resources=
				{
				CLOTH={min=100,max=200}, FOOD={min=100,max=200}, MEAT={min=100,max=200}, WOOD={min=100,max=200}, LEATHER={min=100,max=200}, STONE={min=100,max=200}, IRON_ORE={min=100,max=200}, DRAKSTEEL={min=100,max=200},
				},
			books= { num={min=3,max=5,tot_lv=10}, pool={20,30,40,100,110,120,130,140,150,160,170,180,190,200,210,220,230,400,410,420,430,440,1000,2000}, },
			constrs={ HOUSE=1 },
			lands={},
			},
		MID        =
			{
			member={min=8,max=20,ELDER=1},
			assets={ LAND={init=30}, REPUTATION={min=300,max=1000}, INFLUENCE={min=0,max=100}, MONEY={min=1000,max=2000} },
			resources=
				{
				CLOTH={min=100,max=200}, FOOD={min=100,max=200}, MEAT={min=100,max=200}, WOOD={min=100,max=200}, LEATHER={min=100,max=200}, STONE={min=100,max=200}, IRON_ORE={min=100,max=200}, DRAKSTEEL={min=100,max=200},
				},
			books= { num={min=3,max=5,tot_lv=10}, pool={20,30,40,100,110,120,130,140,150,160,170,180,190,200,210,220,230,400,410,420,430,440,1000,2000}, },
			constrs={ HOUSE=1 },
			lands={},
			},			
		BIG        =
			{
			member={min=16,max=30,ELDER=1},
			assets={ LAND={init=100}, REPUTATION={min=500,max=3000}, INFLUENCE={min=0,max=100}, MONEY={min=1000,max=2000} },
			resources=
				{
				CLOTH={min=100,max=200}, FOOD={min=100,max=200}, MEAT={min=100,max=200}, WOOD={min=100,max=200}, LEATHER={min=100,max=200}, STONE={min=100,max=200}, IRON_ORE={min=100,max=200}, DRAKSTEEL={min=100,max=200},
				},
			books= { num={min=3,max=5,tot_lv=10}, pool={20,30,40,100,110,120,130,140,150,160,170,180,190,200,210,220,230,400,410,420,430,440,1000,2000}, },
			constrs={ HOUSE=1 },
			lands={},
			},		
		HUGE       =
			{
			member={min=30,max=50,ELDER=1},
			assets={ LAND={init=300}, REPUTATION={min=2000,max=5000}, INFLUENCE={min=0,max=100}, MONEY={min=1000,max=2000} },
			resources=
				{
				CLOTH={min=100,max=200}, FOOD={min=100,max=200}, MEAT={min=100,max=200}, WOOD={min=100,max=200}, 
				LEATHER={min=100,max=200}, STONE={min=100,max=200}, IRON_ORE={min=100,max=200}, DRAKSTEEL={min=100,max=200},
				},
			books= { num={min=3,max=5,tot_lv=10}, pool={20,30,40,100,110,120,130,140,150,160,170,180,190,200,210,220,230,400,410,420,430,440,1000,2000}, },
			constrs={ HOUSE=1 },
			lands={},
			},
	},

	ACTION_PTS = 
	{
		FAMILY     = { std=2, max=1000 },
		SMALL      = { std=3, max=1000 },
		MID        = { std=3, max=1000 },
		BIG        = { std=4, max=1000 },
		HUGE       = { std=5, max=1000 },
	},
}

function Group_Prepare( group )
	local start = GROUP_PARAMS.START[group.size]

	if group.location == 0 then
		--we should find a location
		local map = ECS_SendEvent( "MAP_COMPONENT", "Get" )
		local index = Random_GetInt_Unsync( 1, #map.cities )
		local city = map.cities[index]		
		group.location = city.id
		DBG_Trace( group.name .. " set base at " .. city.name )
	end

	group.leaderid = Group_RecruitMember( group, 10 )
	--InputUtil_Pause( ECS_FindComponent( group.leaderid, "ROLE_COMPONENT" ).name, "select member" )
	--Group_RecruitMember( group, 11 )

	--members
	local need = Random_GetInt_Sync( start.member.min, start.member.max )
	local needRecruit = need - #group.members
	Log_Write( "game", group.name .. " need recruit " .. needRecruit .. "members" )
	while needRecruit > 0 do
		Group_RecruitMember( group )
		needRecruit = needRecruit - 1
	end

	--rank
	for rank, _ in pairs( FOLLOWER_RANK ) do
		if start.member[rank] then
			local num = start.member[rank]
			if num > 0 then
				for _, memberid in pairs( group.members ) do				
					follower = ECS_FindComponent( memberid, "FOLLOWER_COMPONENT" )
					if not FOLLOWER_RANK[follower.rank] then
						follower.rank = rank
						DBG_Trace( ECS_FindComponent( memberid, "ROLE_COMPONENT" ).name .. " is promoted to " .. rank, "Left=" .. num )
						num = num - 1
						if num <= 0 then break end
					end
				end
			end
		end
	end

	--assets
	if start.assets then
		for name, value in pairs( start.assets ) do
			if not group.assets[name] then
				if value.init then
					group.assets[name] = value.init
				elseif value.min and value.max then
					group.assets[name] = Random_GetInt_Sync( value.min, value.max )				
				else
					group.assets[name] = 0
				end
				DBG_Trace( group.name .. " asset " .. name .. "=" .. group.assets[name] )
			end
		end
	end

	--resources
	if start.resources then
		for name, value in pairs( start.resources ) do
			if value.init then
				group.resources[name] = value.init
			elseif value.min and value.max then
				group.resources[name] = Random_GetInt_Sync( value.min, value.max )				
			else
				group.resources[name] = 0
			end
			DBG_Trace( group.name .. " resource " .. name .. "=" .. group.resources[name] )
		end
	end

	--books
	if start.books and #group.books == 0 then		
		local numOfBook = start.books.num.init or 0
		if start.books.num.min and start.books.num.max then
			numOfBook = Random_GetInt_Sync( start.books.num.min, start.books.num.max )
		end
		local leftLv = start.books.num.tot_lv
		local pool = MathUtil_Shuffle_Sync( start.books.pool )
		for _, id in ipairs( pool ) do
			local book = BOOK_DATATABLE_Get( id )
			leftLv = leftLv - book.lv
			group:ObtainBook( id )
			if leftLv and leftLv <= 0 then break end
		end
	end

	--constructions
	if start.constrs then
		for type, num in pairs( start.constrs ) do
			local list = CONSTRUCTION_DATATABLE_Find( type, group )
			if #list == 0 then
				DBG_TraceBug( "Is group=" .. group.name .. " has enough constructions=" .. #group.constructions )
			else
				local index = Random_GetInt_Sync( 1, #list )
				local id = list[index].id
				DBG_Trace( group.name .. "need construction=" .. CONSTRUCTION_DATATABLE_Get( id ).name )
				group:CompleteConstruction( id )
			end
		end
	end

	--leader
	--Group_SelectLeader( group )

	--choose leader as default master
	for _, id in ipairs( group.members ) do
		if id ~= group.leaderid then
			local follower = ECS_FindComponent( id, "FOLLOWER_COMPONENT" )
			follower.masterid = group.leaderid
			DBG_Trace( ECS_FindComponent( id, "ROLE_COMPONENT" ).name, "masterid=", follower.masterid )
		end
	end

	--Dump( group )
	--InputUtil_Pause()

	DBG_Trace( group.name, "Start=", group.size )
end


---------------------------------------
---------------------------------------
local memberidx = 1
function Group_AddMember( group, entity )
	local role = entity:GetComponent( "ROLE_COMPONENT" )
	if not role then DBG_Error( "Can't find role component, Failed to AddMember()" ) end

	Prop_Add( group, "members", entity.ecsid )
	--table.insert( group.members, entity.ecsid )

	role.groupid = group.entityid
	role.name = group.name .. role.name .. memberidx
	memberidx = memberidx + 1
	print( group.name .. " recruit " .. role.name )
end


---------------------------------------
---------------------------------------
function Group_RemoveMember( group, ecsid )	
	if not Prop_Remove( group, "members", ecsid ) then
		error( "remove member failed! ID=", ecsid )
	end

	--need to select new leader
	if ecsid == group.leaderid then group.leaderid = nil end

	--need a new master
	for _, id in ipairs( group.members ) do
		local follower = ECS_FindComponent( id, "FOLLOWER_COMPONENT" )
		if follower and follower.masterid == ecsid then
			follower.masterid = group.masterid
		end
	end
end


---------------------------------------
---------------------------------------
function Group_CreateByTableData( groupTable )
	local groupEntity, groupComponent
	
	--create root role entity
	groupEntity = ECS_CreateEntity( "Group" )

	--create role
	local group = DataTable_CreateComponent( "GROUP_COMPONENT", groupTable )
	groupEntity:AddComponent( group )
	
	return groupEntity
end


---------------------------------------
---------------------------------------
function Group_TrainFollower()
	-- body
end


---------------------------------------
---------------------------------------
function Group_EducateFollwer()
end



---------------------------------------
---------------------------------------
function Group_MakeSchedule( group )
	local role = ECS_FindComponent( group.leaderid, "ROLE_COMPONENT" )
	if not role then DBG_Error( "No group master role component!" ) end

	MathUtil_Foreach( group.members, function ( _, ecsid )
		if group.leaderid == ecsid then return end local target = ECS_FindComponent( ecsid )
		AI_DetermineSchedule( group.leaderid, { follower=ecsid } )
	end )
end


---------------------------------------
---------------------------------------
function Group_RecruitMember( group, id )
	if #group.members > 5 then return end

	if not id then
		group.membertemplates = { 1, 2, 3 }
		local idx = Random_GetInt_Sync( 1, #group.membertemplates )
		id = group.membertemplates[idx]
	end
	local data = ROLE_DATATABLE_Get( id )		
	local entity = Role_CreateByTableData( data )	
	Data_AddEntity( "ROLE_DATA", entity )
	Group_AddMember( group, entity )
	return entity.ecsid
end


---------------------------------------
---------------------------------------
function Group_StartBuildingConstruction( group, id )
	local constr = CONSTRUCTION_DATATABLE_Get( id )
	if not constr then DBG_Error( "Construction is invalid! ID=", id ) return end
	local affair = {}
	affair.type  = "BUILD_CONSTRUCTION"
	affair.construction = id
	affair.time  = constr.costs.time or 1
	--use the assets and resources one time
	if constr.costs.assets then
		for name, data in pairs( constr.costs.assets ) do
			group:UseAssets( name, data.value )
		end
	end
	if constr.costs.resources then
		for name, data in pairs( constr.costs.resources ) do
			group:UseResources( name, data.value )
		end
	end

	table.insert( group.affairs, affair )
	DBG_Trace( group.name, " start building construction=" .. constr.name )
end

function Group_StartUpgradingConstruction( group, id, target_id )
	local target = CONSTRUCTION_DATATABLE_Get( id )
	if not target then DBG_Error( "Construction is invalid! ID=", id ) return end

	local affair = {}
	affair.type = "UPGRADE_CONSTRUCTION"
	affair.construction = id
	affair.target = target_id
	affair.time = target.costs.time or 1

	--use the assets and resources one time
	if target.costs.assets then
		for name, data in pairs( target.costs.assets ) do
			group:UseAssets( name, data.value )
		end
	end
	if target.costs.resources then
		for name, data in pairs( target.costs.resources ) do
			group:UseResources( name, data.value )
		end
	end
	table.insert( group.affairs, affair )
	DBG_Trace( group.name, " start upgrading construction=" .. target.name )
end

function Group_BulidConstruction( group, affair, deltaTime )
	affair.time = affair.time - deltaTime
	if affair.time > 0 then return end

	local constr = CONSTRUCTION_DATATABLE_Get( affair.construction )
	if not constr then DBG_Error( "Construction is invalid! ID=", id ) return end

	if affair.target then
		--destroy the old one
		group:DestroyConstruction( affair.target )
	end

	--finished
	group:CompleteConstruction( affair.construction )
	--remove affair
	--InputUtil_Pause( group.name, " finished building construction=" .. constr.name, affair.target and "Upgrade" or "" )
	return true
end


---------------------------------------
---------------------------------------
function Group_StartMakeItem( group, type, id )
	local target
	if type == "EQUIPMENT" then
		target = EQUIPMENT_DATATABLE_Get( id )
	else
	end
	if not target then DBG_Error( "Item is invalid! ID=", id ) return end

	local affair = {}
	affair.type = "MAKE_ITEM"
	affair.maketype = type
	affair.makeid   = id
	affair.time = 1 --target.costs.time

	if target.costs.assets then
		for name, data in pairs( target.costs.assets ) do
			group:UseAssets( name, data.value )
		end
	end
	if target.costs.resources then
		for name, data in pairs( target.costs.resources ) do			
			group:UseResources( name, data.value )
		end
	end
	table.insert( group.affairs, affair )
	DBG_Trace( group.name, " start making item=" .. target.name )

	--InputUtil_Pause( "start make item, remaintime=", affair.time )
end


function Group_MakeItem( group, affair, deltaTime )
	affair.time = affair.time - deltaTime
	if affair.time > 0 then return end

	local target
	if affair.maketype == "WEAPON"        then target = EQUIPMENT_DATATABLE_Get( affair.makeid )
	elseif affair.maketype == "ARMOR"     then target = EQUIPMENT_DATATABLE_Get( affair.makeid )
	elseif affair.maketype == "SHOES"     then target = EQUIPMENT_DATATABLE_Get( affair.makeid )
	elseif affair.maketype == "ACCESSORY" then target = EQUIPMENT_DATATABLE_Get( affair.makeid )
	elseif affair.maketype == "VEHICLE"   then target = EQUIPMENT_DATATABLE_Get( affair.makeid )
	else
	end
	if not target then DBG_Error( "Item is invalid! ID=", affair.makeid ) return end

	--finished
	if affair.maketype == "WEAPON"        then group:ObtainArm( affair.maketype, affair.makeid )		
	elseif affair.maketype == "ARMOR"     then group:ObtainArm( affair.maketype, affair.makeid )
	elseif affair.maketype == "SHOES"     then group:ObtainItem( affair.maketype, affair.makeid )
	elseif affair.maketype == "ACCESSORY" then group:ObtainItem( affair.maketype, affair.makeid )
	elseif affair.maketype == "VEHICLE"   then group:ObtainVehicle( affair.maketype, affair.makeid )
	else
	end

	InputUtil_Pause( "finish make item", target.name )
end


---------------------------------------
function Group_StartProduce( group, type )
	local produce = PRODUCE_DATATABLE_Get( type )
	if not produce then DBG_Error( "Produce is invalid! Type=", type ) end

	local affair = {}
	affair.type = "PRODUCE"
	affair.produce = type
	affair.time    = produce.time.base	
	affair.yield   = 0

	table.insert( group.affairs, affair )
	DBG_Trace( group.name, " start produce=" .. type )

	--InputUtil_Pause( "start produce, remaintime=", affair.time )
end


function Group_Produce( group, affair, deltaTime, actor )
	local produce = PRODUCE_DATATABLE_Get( affair.produce )
	if not produce then DBG_Error( "Produce is invalid! Type=", type ) return end

	if actor then
		--commonskill
		local timeEff = 0
		if produce.time.commonskill then
			for _, data in ipairs( produce.time.commonskill ) do
				if actor:HasCommonSkill( data.type, data.lv ) then
					timeEff = math.max( timeEff, data.acc )
				end
			end
		end
		deltaTime = deltaTime * timeEff
	end
	affair.time = affair.time - deltaTime

	local yieldEff = 1	
	--land
	if produce.yield.land then
		for _, land in ipairs( produce.yield.land ) do
			if land.num <= group:GetNumOfLand( land.type ) then
				yieldEff = math.max( yieldEff, land.eff )
			end
		end
	end
	--resource
	if produce.yield.resource then
		local plot = group:GetPlot()
		if plot and plot.resource then
			for _, res in ipairs( produce.yield.resource ) do
				if plot.resource[res.type] and plot.resource[res.type] <= res.lv then
					yieldEff = math.max( yieldEff, res.eff )
				end
			end
		end
	end
	--commonskill
	if actor then
		if produce.yield.commonskill then
			for _, data in ipairs( produce.yield.commonskill ) do
				if actor:HasCommonSkill( data.type, data.lv ) then
					yieldEff = math.max( yieldEff, data.acc )
				end
			end
		end
	end
	
	local product = math.ceil( produce.yield.base * yieldEff )
	affair.yield = affair.yield + product

	DBG_Trace( "produce=" .. produce.name .. " ramintime=" .. affair.time .. " yield=" .. affair.yield )

	if affair.time > 0 then return end

	group:ObtainResource( affair.produce, affair.yield )

	--InputUtil_Pause( "finish produce", affair.produce, affair.yield )
end


---------------------------------------
---------------------------------------
function Group_StartProcess( group, type )
	local affair = {}
	affair.type = "PROCESS"
	affair.process = type
	affair.time = 1 --target.costs.time

	table.insert( group.affairs, affair )
	DBG_Trace( group.name, " start produce=" .. type )
end


function Group_Process( group, affair, deltaTime )
	affair.time = affair.time - deltaTime	
	if affair.time > 0 then return end

	error( "todo" )
	--local number = 10
	--group:ObtainResource( affair.produce, number )
end

---------------------------------------
---------------------------------------
local function Group_DealAffair( group, affair, deltaTime )
	if affair.type == "BUILD_CONSTRUCTION" or affair.type == "UPGRADE_CONSTRUCTION" then
		return Group_BulidConstruction( group, affair, deltaTime )
	elseif affair.type == "MAKE_ITEM" then
		Group_MakeItem( group, affair, deltaTime )
	elseif affair.type == "PROCESS" then
		Group_Process( group, affair, deltaTime )
	elseif affair.type == "PRODUCE" then
		Group_Produce( group, affair, deltaTime )
	else
		DBG_Error( "Unhandletype=", affair.type )
	end
end

function Group_UpdateAffairs( group, deltaTime )
	--print( group.name, "affairs=" .. #group.affairs )
	MathUtil_RemoveListItemIf( group.affairs, function ( affair )
		Group_DealAffair( group, affair, deltaTime )
	end )
end


---------------------------------------
---------------------------------------
function Group_UpdateActionPoints( group )
	if not group.leaderid or group.leaderid == "" then return end
	local entity = ECS_FindEntity( group.leaderid )	
	if not entity then DBG_TraceBug( "Group master is invalid!" ) return end
	local role = entity:GetComponent( "ROLE_COMPONENT" )
	if not role then DBG_Error( "No role component" ) end
	local param = GROUP_PARAMS.ACTION_PTS[group.size]
	group.MANAGEMENT = param.std + ( role.commonSkills.MANAGEMENT or 0 )
	group.STRATEGIC  = param.std + ( role.commonSkills.STRATEGIC or 0 )
	group.TACTIC     = param.std + ( role.commonSkills.TACTIC or 0 )
end


---------------------------------------
-- 
-- Select the master of group
--   Occured when master is dead
--
---------------------------------------
function Group_SelectLeader( group )
	if group.leaderid then return end

	local list
	local HighestRank
	local totalProb = 0

	local nomasterFollowers = {}

	function CalcMasterProb( follower )
		return 1 + ( follower.seniority or 0 ) + ( follower.contribution and follower.contribution.value or 0 )
	end

	MathUtil_Foreach( group.members, function ( _, ecsid )
		local entity = ECS_FindEntity( ecsid )
		if not entity then DBG_Error( "Role entity is invalid! Id=" .. ecsid ) end
		local follower = entity:GetComponent( "FOLLOWER_COMPONENT" )
		if not follower then DBG_Error( "No follower component" ) end
		local role = entity:GetComponent( "ROLE_COMPONENT" )
		if not role then DBG_Error( "No role component" ) end

		if not follower.masterid then
			table.insert( nomasterFollowers, follower )
		end

		if not HighestRank or HighestRank < follower.rank then
			HighestRank = follower.rank
			list = {}
			totalProb  = CalcMasterProb( follower )
			table.insert( list, { entity=entity, prob=totalProb } )
		elseif HighestRank == follower.rank then
			totalProb = totalProb + CalcMasterProb( follower )
			table.insert( list, { entity=entity, prob=totalProb } )
		end
	end )

	if not list or #list == 0 then return end

	local prob = Random_GetInt_Sync( 1, totalProb )	
	for _, data in ipairs( list ) do
		if prob <= data.prob then
			group.leaderid = data.entity.ecsid			
			break
		end
	end

	for _, follower in ipairs( nomasterFollowers ) do follower:Apprenticed( group.leaderid ) end
end


---------------------------------------
---------------------------------------
function Group_ListRoles( group, status_includes, status_excludes )
	local roles = {}
	MathUtil_Foreach( group.members, function ( _, ecsid )
		if Role_MatchStatus( ecsid, { status_includes=status_includes, status_excludes=status_excludes } ) == true then
			table.insert( roles, ecsid )
		end
	end )
	return roles
end


---------------------------------------
---------------------------------------
function Group_Attack( group )
	if #group.members == 0 then return end

	if group:GetStatusValue( "UNDER_ATTACK" ) > 0 then
		--print( group.name .. " is under attack! Cann't attack other!" )
		return
	end

	local list = {}
	ECS_Foreach( "GROUP_COMPONENT", function ( target )
		if group == target then return end
		if target:GetStatusValue( "UNDER_ATTACK" ) > 0 then
			--print( target.name .. "is under attack! Cann't be the target" )
			return
		end
		table.insert( list, target )
	end )
	local num = #list
	if num == 0 then
		--print( group.name .. "doesn't have activate target" )
		return
	end
	local index = Random_GetInt_Sync( 1, num )
	local target = list[index]

	--choice follower to attack
	local atk_eids = Group_ListRoles( group, nil, { "OUTING" } )
	local def_eids = Group_ListRoles( target, nil, { "OUTING" } )

	if #atk_eids == 0 then
		--DBG_Trace( target.name .. "doesn't have enough followr to attack" )
		return
	end

	print( group.name .. "(" .. #atk_eids ..  ") "  .. "attack" .. " " .. target.name .. "(".. #def_eids .. ")" )
	
	--[[
	print( "atk eids", #atk_eids )
	Dump( atk_eids )
	print( "def eids", #def_eids )
	Dump( def_eids )
	--]]

	--process status
	target:IncStatusValue( "UNDER_ATTACK", 1 )
	for _, ecsid in ipairs( atk_eids ) do Role_SetStatus( ecsid, { BUSY=1, OUTING=1 } ) end
	for _, ecsid in ipairs( def_eids ) do Role_SetStatus( ecsid, { BUSY=1 } ) end

	ECS_GetSystem( "FIGHT_SYSTEM" ):CreateFight( group.entityid, target.entityid, atk_eids, def_eids )

	--print( target.name .. " is been attack by " .. group.name )
end


---------------------------------------
---------------------------------------
function Group_HoldMeeting( group )
	if not group.leaderid then return end

	--Determine affair for group
	AI_DetermineGroupAffair( group.leaderid )
	
	local list = {}
	function CheckPriority( follower )
		--InputUtil_Pause( ECS_FindComponent( follower.entityid, "ROLE_COMPONENT" ).name, follower.rank )
		return follower.rank == "JUNIOR" or follower.rank == "NONE"
	end

	--arrange the schedule for follower
	MathUtil_Foreach( group.members, function ( _, ecsid )
		local follower = ECS_FindComponent( ecsid, "FOLLOWER_COMPONENT" )
		if CheckPriority( follower ) then
			AI_DetermineSchedule( group.leaderid, { target=ecsid } )
		end
	end )

	--[[
	MathUtil_Foreach( group.members, function ( _, ecsid )
		local follower = ECS_FindComponent( ecsid, "FOLLOWER_COMPONENT" )
		if not CheckPriority( follower ) then
			AI_DetermineSchedule( group.leaderid, { target=ecsid } )
		end
	end )
	]]
end


---------------------------------------
---------------------------------------
GROUP_SYSTEM = class()


---------------------------------------
---------------------------------------
function GROUP_SYSTEM:__init( ... )
	local args = ...
	self._name = args and args.name or "GROUP_SYSTEM"
end


---------------------------------------
---------------------------------------
function GROUP_SYSTEM:Update( deltaTime )
	--print( "update group", ECS_GetNum( "GROUP_COMPONENT" ) )
	local sys = self
	ECS_Foreach( "GROUP_COMPONENT", function ( group )
		print( "[GROUP]" .. group.name .. " action......" )
		group:Update()
		Group_UpdateActionPoints( group )
		Group_UpdateAffairs( group, deltaTime )
		Group_SelectLeader( group )
		Group_HoldMeeting( group )
		--Group_Attack( group )
	end )
	--print( "Update group", ECS_GetNum( "GROUP_COMPONENT" ) )	
end


---------------------------------------
---------------------------------------
function GROUP_SYSTEM:Dump()
	ECS_Foreach( "GROUP_COMPONENT", function ( group )
		group:Dump()
	end )
end