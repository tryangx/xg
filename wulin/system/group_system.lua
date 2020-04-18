--------------------------------------- -- Group Prepare
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
			vehicles={ num={min=1,max=1, tot_lv=10}, pool={5000}},
			arms={ num={min=3, max=5, tot_lv=10}, pool={ 1000, 1001, 2000, 3000, 4000 } },
			items={num={min=1,max=2,tot_lv=2}, pool={100,110}},
			books= { num={min=3,max=5,tot_lv=10}, pool={20,30,40,100,110,120,130,140,150,160,170,180,190,200,210,220,230,400,410,420,430,440,1000,2000}, },
			constrs={ HOUSE=1 },
			lands={},
			goal={name="SURVIVE", day=360*20},
			},
		SMALL      =
			{
			member={min=4,max=8,ELDER=1},
			assets={ LAND={init=10}, REPUTATION={min=200,max=500}, INFLUENCE={min=200,max=500}, MONEY={min=1000,max=2000} },
			resources=
				{
				CLOTH={min=100,max=200}, FOOD={min=100,max=200}, MEAT={min=100,max=200}, WOOD={min=100,max=200}, LEATHER={min=100,max=200}, STONE={min=100,max=200}, IRON_ORE={min=100,max=200}, DRAKSTEEL={min=100,max=200},
				},
			vehicles={ num={min=1,max=1, tot_lv=10}, pool={5000}},
			arms={ num={min=3, max=5, tot_lv=10}, pool={ 1000, 1001, 2000, 3000, 4000 } },
			items={num={min=1,max=2,tot_lv=2}, pool={100,110}},
			books= { num={min=3,max=5,tot_lv=10}, pool={20,30,40,100,110,120,130,140,150,160,170,180,190,200,210,220,230,400,410,420,430,440,1000,2000}, },
			constrs={ HOUSE=1 },
			lands={},
			goal={name="SURVIVE", day=360*20},
			},
		MID        =
			{
			member={min=8,max=20,ELDER=1},
			assets={ LAND={init=30}, REPUTATION={min=300,max=1000}, INFLUENCE={min=0,max=100}, MONEY={min=1000,max=2000} },
			resources=
				{
				CLOTH={min=100,max=200}, FOOD={min=100,max=200}, MEAT={min=100,max=200}, WOOD={min=100,max=200}, LEATHER={min=100,max=200}, STONE={min=100,max=200}, IRON_ORE={min=100,max=200}, DRAKSTEEL={min=100,max=200},
				},
			vehicles={ num={min=1,max=1, tot_lv=10}, pool={5000}},
			arms={ num={min=3, max=5, tot_lv=10}, pool={ 1000, 1001, 2000, 3000, 4000 } },
			items={num={min=1,max=2,tot_lv=2}, pool={100,110}},
			books= { num={min=3,max=5,tot_lv=10}, pool={20,30,40,100,110,120,130,140,150,160,170,180,190,200,210,220,230,400,410,420,430,440,1000,2000}, },
			constrs={ HOUSE=1 },
			lands={},
			goal={name="INDEPENDENT", day=360*20},
			},			
		BIG        =
			{
			member={min=16,max=30,ELDER=1},
			assets={ LAND={init=100}, REPUTATION={min=500,max=3000}, INFLUENCE={min=0,max=100}, MONEY={min=1000,max=2000} },
			resources=
				{
				CLOTH={min=100,max=200}, FOOD={min=100,max=200}, MEAT={min=100,max=200}, WOOD={min=100,max=200}, LEATHER={min=100,max=200}, STONE={min=100,max=200}, IRON_ORE={min=100,max=200}, DRAKSTEEL={min=100,max=200},
				},
			vehicles={ num={min=1,max=1, tot_lv=10}, pool={5000}},
			arms={ num={min=3, max=5, tot_lv=10}, pool={ 1000, 1001, 2000, 3000, 4000 } },
			items={num={min=1,max=2,tot_lv=2}, pool={100,110}},
			books= { num={min=3,max=5,tot_lv=10}, pool={20,30,40,100,110,120,130,140,150,160,170,180,190,200,210,220,230,400,410,420,430,440,1000,2000}, },
			constrs={ HOUSE=1 },
			lands={},
			goal={name="ALLIANCE_LEADER", day=360*20},
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
			vehicles={ num={min=1,max=1, tot_lv=10}, pool={5000}},
			arms={ num={min=3, max=5, tot_lv=10}, pool={ 1000, 1001, 2000, 3000, 4000 } },
			items={num={min=1,max=2,tot_lv=2}, pool={100,110}},
			books= { num={min=3,max=5,tot_lv=10}, pool={20,30,40,100,110,120,130,140,150,160,170,180,190,200,210,220,230,400,410,420,430,440,1000,2000}, },
			constrs={ HOUSE=1 },
			lands={},
			goal={name="OVERLORD", day=360*20},
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
		local index = Random_GetInt_Unsync( 1, #CurrentMap.cities )
		local city = CurrentMap.cities[index]
		group.location = city.id

		local cityCmp = ECS_SendEvent( "CITY_COMPONENT", "Get", city.id )
		cityCmp:GroupAffect( group )

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
		local num = start.books.num.init or 0
		if start.books.num.min and start.books.num.max then
			num = Random_GetInt_Sync( start.books.num.min, start.books.num.max )
		end
		local leftLv = start.books.num.tot_lv
		local pool = MathUtil_Shuffle_Sync( start.books.pool )
		for _, id in ipairs( pool ) do
			local book = BOOK_DATATABLE_Get( id )
			group:ObtainBook( "BOOK", id )
			leftLv = leftLv - book.lv			
			if leftLv and leftLv <= 0 then break end
			num = num - 1
			if num <= 0 then break end
		end
	end

	--vehicles
	if start.vehicles and #group.vehicles == 0 then
		local num = start.vehicles.num.init or 0
		if start.vehicles.num.min and start.vehicles.num.max then
			num = Random_GetInt_Sync( start.vehicles.num.min, start.vehicles.num.max )
		end
		local leftLv = start.vehicles.num.tot_lv
		local pool = MathUtil_Shuffle_Sync( start.vehicles.pool )
		for _, id in ipairs( pool ) do
			local vehicle = EQUIPMENT_DATATABLE_Get( id )
			group:ObtainVehicle( vehicle.type, id )
			leftLv = leftLv - vehicle.lv			
			if leftLv and leftLv <= 0 then break end
			num = num - 1
			if num <= 0 then break end
		end
	end

	--arms
	if start.arms and #group.arms == 0 then		
		local num = start.arms.num.init or 0
		if start.arms.num.min and start.arms.num.max then
			num = Random_GetInt_Sync( start.arms.num.min, start.arms.num.max )
		end
		local leftLv = start.arms.num.tot_lv
		local pool = MathUtil_Shuffle_Sync( start.arms.pool )
		for _, id in ipairs( pool ) do
			local arm = EQUIPMENT_DATATABLE_Get( id )
			group:ObtainArm( arm.type, id )
			leftLv = leftLv - arm.lv
			if leftLv and leftLv <= 0 then break end
			num = num - 1
			if num <= 0 then break end
		end
	end

	--items
	if start.items and #group.items == 0 then		
		local num = start.items.num.init or 0
		if start.items.num.min and start.items.num.max then
			num = Random_GetInt_Sync( start.items.num.min, start.items.num.max )
		end
		local leftLv = start.items.num.tot_lv
		local pool = MathUtil_Shuffle_Sync( start.items.pool )
		for _, id in ipairs( pool ) do			
			local item = ITEM_DATATABLE_Get( id )
			group:ObtainItem( item.type, id )
			leftLv = leftLv - item.lv
			if leftLv and leftLv <= 0 then break end
			num = num - 1
			if num <= 0 then break end
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

	--relations & intels initialized
	ECS_Foreach( "GROUP_COMPONENT", function ( target )
		if group.entityid == target.entityid then return end

		ECS_FindComponent( group.entityid, "RELATION_COMPONENT" ):GetRelation( target.entityid )
		ECS_FindComponent( target.entityid, "RELATION_COMPONENT" ):GetRelation( group.entityid )

		ECS_FindComponent( group.entityid, "INTEL_COMPONENT" ):GetGroupIntel( target.entityid )
		ECS_FindComponent( target.entityid, "INTEL_COMPONENT" ):GetGroupIntel( group.entityid )
	end )

	--goal
	group.goal = MathUtil_Copy( start.goal )

	--Dump( group )
	--InputUtil_Pause()

	DBG_Trace( group.name, "PrepareStart=", group.size )
end


function Group_Terminate( ecsid )	
	local entity = ECS_FindEntity( ecsid )
	if not entity then DBG_Error( "Group entity is invalid! Id=" .. ecsid ) end
	
	local group = entity:GetComponent( "GROUP_COMPONENT" )
	if not group then DBG_Error( "No group component" ) end

	group.statuses["TERMINATED"] = 1

	--remove all members

	--remove all affects
	local city = CurrentMap:GetCity( group.location )
	local cityCmp = ECS_SendEvent( "CITY_COMPONENT", "Get", city.id )
	cityCmp:RemoveEffect( cityCmp )

	--remove all relations
	Relation_EndRelation( group )

	--remove from group
	
	Stat_Add( "GroupTerminate", group.name, StatType.LIST )	
	DBG_AddData( group.entityid )
	DBG_Trace( group.name .. "[" .. ecsid .. "] is Terminated" )

	ECS_DestroyEntity( entity )
end

---------------------------------------
---------------------------------------
local memberidx = 1
function Group_AddMember( group, entity )
	local role = entity:GetComponent( "ROLE_COMPONENT" )
	if not role then DBG_Error( "Can't find role component, Failed to AddMember()" ) end

	Prop_Add( group, "members", entity.ecsid )

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
	if ecsid == group.leaderid then
		group.leaderid = nil
		--InputUtil_Pause( group.name, "lose leader" )
	end

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
	if ROLE_EQUIP[type] then
		target = EQUIPMENT_DATATABLE_Get( id )
	else
	end
	if not target then DBG_Error( "Item is invalid! ID=", id ) return end

	local affair = {}
	affair.type = "MAKE_ITEM"
	affair.maketype = type
	affair.makeid   = id
	affair.time = 1 --target.costs.time

	if target.costs then
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
	end
	table.insert( group.affairs, affair )
	DBG_Trace( group.name, " start making item=" .. target.name )

	--InputUtil_Pause( "start make item, remaintime=", affair.time )
end


function Group_MakeItem( group, affair, deltaTime )
	affair.time = affair.time - deltaTime
	if affair.time > 0 then return end

--[[
	local target
	if affair.maketype == "WEAPON"        then target = EQUIPMENT_DATATABLE_Get( affair.makeid )
	elseif affair.maketype == "ARMOR"     then target = EQUIPMENT_DATATABLE_Get( affair.makeid )
	elseif affair.maketype == "SHOES"     then target = EQUIPMENT_DATATABLE_Get( affair.makeid )
	elseif affair.maketype == "ACCESSORY" then target = EQUIPMENT_DATATABLE_Get( affair.makeid )
	elseif affair.maketype == "VEHICLE"   then target = EQUIPMENT_DATATABLE_Get( affair.makeid )
	else
	end
	if not target then DBG_Error( "Item is invalid! ID=", affair.makeid ) return end

	--InputUtil_Pause( "finish make item", target.name )
]]
	--finished
	if affair.maketype == "WEAPON"        then group:ObtainArm( affair.maketype, affair.makeid )		
	elseif affair.maketype == "ARMOR"     then group:ObtainArm( affair.maketype, affair.makeid )
	elseif affair.maketype == "SHOES"     then group:ObtainItem( affair.maketype, affair.makeid )
	elseif affair.maketype == "ACCESSORY" then group:ObtainItem( affair.maketype, affair.makeid )
	elseif affair.maketype == "VEHICLE"   then group:ObtainVehicle( affair.maketype, affair.makeid )
	else
	end
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

	DBG_Trace( group.name .. " produce=" .. produce.name .. " remaintime=" .. affair.time .. " yield=" .. affair.yield )

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

	local process = PROCESS_DATATABLE_Get( affair.process )
	if not process then return end	

	error( "todo" )
	--local number = 10
	--group:ObtainResource( affair.produce, number )
end


---------------------------------------
---------------------------------------
function Group_StartGrantGift( group, target )
	local affair   = {}
	affair.type    = "GRANT_GIFT"
	affair.groupid = target
	affair.time    = 1 --target.costs.time

	table.insert( group.affairs, affair )
	DBG_Trace( group.name, " start grant gift", ECS_FindComponent( affair.groupid, "GROUP_COMPONENT ") )
end


function Group_GrantGift( group, affair, deltaTime )
	affair.time = affair.time - deltaTime	
	if affair.time > 0 then return end

	local target = ECS_FindComponent( affair.groupid, "GROUP_COMPONENT" )
	if not target then DBG_Trace( group.name .. " end GRANT_GIFT, because target is terminated" ) return end

	local eval = 10
	local relationCmp = ECS_FindComponent( group.entityid, "RELATION_COMPONENT" )
	Relation_AlterRelationship( relationCmp:GetRelation( affair.groupid ), eval )

	--InputUtil_Pause( group.name, " grant gift to", ECS_FindComponent( affair.groupid, "GROUP_COMPONENT" ).name )
end


function Group_StartSignPact( group, target, pact )
	local affair   = {}
	affair.type    = "SIGN_PACT"
	affair.groupid = target
	affair.pact    = pact
	affair.time    = 1 --target.costs.time

	table.insert( group.affairs, affair )
	DBG_Trace( group.name, " start sign pact=" .. pact )
end

function Group_SignPact( group, affair, deltaTime )
	affair.time = affair.time - deltaTime	
	if affair.time > 0 then return end

	local target = ECS_FindComponent( affair.groupid, "GROUP_COMPONENT" )
	if not target then DBG_Trace( group.name .. " end GRANT_GIFT, because target is terminated" ) return end

	local relationCmp = ECS_FindComponent( group.entityid, "RELATION_COMPONENT" )
	HandlePactResult( relationCmp:GetRelation( affair.groupid ), affair.pact )

	--InputUtil_Pause( "Sign pact", affair.pact )
end


---------------------------------------
---------------------------------------
function Group_StartReconn( group, target )
	local affair  = {}
	affair.type   = "RECONN"
	affair.time   = 1 --need calcualte distance
	affair.groupid = target

	table.insert( group.affairs, affair )
	DBG_Trace( group.name, " start reconn=" .. affair.type )
end

function Group_Reconn( group, affair, deltaTime )
	--actor should stay at the destination
	--but for test procedure, we ignore 
	affair.time = affair.time - deltaTime	
	if affair.time > 0 then return end

	local intelCmp = ECS_FindComponent( group.entityid, "INTEL_COMPONENT" )
	intelCmp:AcquireGroupIntel( affair.groupid, 10 )

	DBG_Trace( group.name, "end reconn" )
end

function Group_Sabotage( group, target )
end

function Group_Stole( group, target )	
end


---------------------------------------
function Group_RewardFollower( group, roleid, invtype, invid )
	local roleCmp = ECS_FindComponent( roleid, "ROLE_COMPONENT" )
	if ROLE_EQUIP[invtype] then
		--puton equipment		
		--roleCmp:SetupEquip( invid )
		roleCmp:AddToBag( invtype, invid )
	else
		--add into bag
		roleCmp:AddToBag( invtype, invid )
	end
end


---------------------------------------
local function Group_UpdateEntrustAffair( group, affair )
	local entrustData = ENTRUST_DATATABLE_Get( affair.entrustid )
	local poolData    = entrustData.pool[affair.poolindex]
	local needNum = poolData.need_follower or 1
	if #affair.followers < needNum then
		if affair.entrustType == "NEED_SKILL" then
			local match = true
			local list = {}
			for _, ecsid in ipairs( group.members )	 do
				if Entrust_IsFollowerMatch( ecsid, entrustData, affair.poolindex ) then table.insert( list, ecsid ) end
			end
			local num = #list
			if num == 0 then return end
			while needNum > 1 and num > 0 do
				local index = Random_GetInt_Sync( 1, num )
				table.insert( affair.followers, table.remove( list, index ) )
				num = #list
				needNum = needNum - 1
				InputUtil_Pause( "add follower", ECS_FindComponent( affair.followers[#affair.followers], "ROLE_COMPONENT" ).name )
			end

		elseif affair.entrustType == "NEED_PROTECT" then
			error( "todo" )

		elseif affair.entrustType == "ASSASIN" then
			error( "todo" )

		end
	end

	--InputUtil_Pause( "execute entrust", affair.entrustType )

	if affair.entrustType == "NEED_ITEM" then
		group:AddWishItem( poolData.itemtype, poolData.itemid, poolData.quantity or 1 )

	elseif affair.entrustType == "NEED_RESOURCE" then
		group:AddWishResource( poolData.restype, poolData.quantity )

	elseif affair.entrustType == "NEED_EQUIPMENT" then
		group:AddWishItem( poolData.itemtype, poolData.itemid, poolData.quantity )
	end
end

function Group_TakeEntrust( group, entrustIndex )
	local city        = CurrentMap:GetCity( group.location )
	local cityCmp     = ECS_SendEvent( "CITY_COMPONENT", "Get", city.id )
	local entrustCmp  = ECS_FindComponent( cityCmp.entityid, "ENTRUST_COMPONENT" )
	local entrust     = entrustCmp.entrusts[entrustIndex]
	local entrustData = ENTRUST_DATATABLE_Get( entrust.id )
	local poolData    = entrustData.pool[entrust.poolindex]

	local affair     = {}
	affair.type      = "ENTRUST"
	affair.entrustType = entrustData.type
	affair.entrustid = entrust.id
	affair.poolindex = entrust.poolindex
	affair.time      = poolData.time or entrustData.time.finish
	affair.followers = {}
	table.insert( group.affairs, affair )

	--check the followers
	Group_UpdateEntrustAffair( group, affair )
	
	--group has take the entrust, so remove it from the list	
	entrustCmp:Remove( entrustIndex )

	DBG_Trace( group.name, " take entrust=" .. entrustData.name )
end

local function Group_ExecuteEntrust( group, affair, deltaTime )
	affair.time = affair.time - deltaTime

	Group_UpdateEntrustAffair( group, affair )

	if affair.time > 0 then return end

	--entrust failed!
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

	elseif affair.type == "RECONN" then
		Group_Reconn( group, affair, deltaTime )
	elseif affair.type == "SABOTAGE" then
		Group_Sabotage( group, affair, deltaTime )
	elseif affair.type == "STOLE" then
		Group_Stole( group, affair, deltaTime )

	elseif affair.type == "GRANT_GIFT" then
		Group_GrantGift( group, affair, deltaTime )
	elseif affair.type == "SIGN_PACT" then
		Group_SignPact( group, affair, deltaTime )

	elseif affair.type == "ENTRUST" then
		Group_ExecuteEntrust( group, affair, deltaTime )

	else
		DBG_Error( "Unhandletype=", affair.type )
	end
end

function Group_UpdateAffairs( group, deltaTime )
	--print( group.name, "affairs=" .. #group.affairs )
	MathUtil_RemoveListItemIf( group.affairs, function ( affair )
		Group_DealAffair( group, affair, deltaTime )
		return affair.time <= 0
	end )
end


---------------------------------------
---------------------------------------
function Group_UpdateActionPoints( group )
	local role = ECS_FindComponent( group.leaderid, "ROLE_COMPONENT" )

	local param = GROUP_PARAMS.ACTION_PTS[group.size]
	group.MANAGEMENT = param.std + ( role and role.commonSkills.MANAGEMENT or 0 )
	group.STRATEGIC  = param.std + ( role and role.commonSkills.STRATEGIC or 0 )
	group.TACTIC     = param.std + ( role and role.commonSkills.TACTIC or 0 )
end

function Group_UpdateGoal( group, day )
	group.goal.day = group.goal.day - day 
	if group.goal.day <= 0 then
		--finish
		CurrentGame:ReachAchievement( group.entityid, "FINISH_GOAL", group.goal.name )
	end
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
-- @return the ecsid list of members match conditions
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
function Group_Attack( group, id )
	if #group.members == 0 then return end

	if group:GetStatusValue( "UNDER_ATTACK" ) > 0 then
		--print( group.name .. " is under attack! Cann't attack other!" )
		return
	end

	local target
	if not target then
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
		target = list[index]
	else
		target = ECS_FindComponent( id, "GROUP_COMPONENT" )
	end

	--choice follower to attack
	local atkeids = Group_ListRoles( group, nil, { "OUTING" } )
	local defeids = Group_ListRoles( target, nil, { "OUTING" } )

	local num = #atkeids
	if num == 0 then DBG_Error( target.name .. "doesn't have enough followr to attack" ) return end

	if #group.members == num then
		--remove at least one
		local index = Random_GetInt_Sync( 1, num )
		table.remove( atkeids, index )
		--print( "should rmeove one" )
	end

	--InputUtil_Pause( group.name .. "(" .. #atkeids ..  ") "  .. "attack" .. " " .. target.name .. "(".. #defeids .. ")" )
	
	--[[
	print( "atk eids", #atk_eids )
	Dump( atk_eids )
	print( "def eids", #def_eids )
	Dump( def_eids )
	--]]

	--process status
	target:IncStatusValue( "UNDER_ATTACK", 1 )
	for _, ecsid in ipairs( atkeids ) do Role_SetStatus( ecsid, { BUSY=1, OUTING=1 } ) end
	for _, ecsid in ipairs( defeids ) do Role_SetStatus( ecsid, { BUSY=1 } ) end

	ECS_GetSystem( "FIGHT_SYSTEM" ):CreateFight( { issiege=true, atkgroupid=group.entityid, defgroupid=target.entityid, atkeids=atkeids, defeids=defeids } )

	--print( target.name .. " is been attack by " .. group.name )
	return true
end


---------------------------------------
---------------------------------------
function Group_HoldMeeting( group )
	--No leader
	if not group.leaderid then return end

	--Determine affair for group
	AI_DetermineGroupAffair( group.leaderid )
	
	--Determine follower's action
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

	--InputUtil_Pause( group.name, "Hold meeting" )
end


function Group_AffectCity( group )
	local city = CurrentMap:GetCity( group.location )
	local cityCmp = ECS_SendEvent( "CITY_COMPONENT", "Get", city.id )
	cityCmp:GroupAffect( group )
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
	if not CurrentGame:IsNewDay() then return end
	--print( "update group", ECS_GetNum( "GROUP_COMPONENT" ) )
	local sys = self
	ECS_Foreach( "GROUP_COMPONENT", function ( group )
		print( "[GROUP]" .. group.name .. " action......" )		
		group:Update()
		
		Group_UpdateGoal( group, 1 )

		Group_UpdateActionPoints( group )

		Group_AffectCity( group )
		
		Group_UpdateAffairs( group, deltaTime )

		if GAME_RULE.SELECT_LEADER( CurrentGame.time ) then Group_SelectLeader( group ) end

		if GAME_RULE.HOLD_MEETING( CurrentGame.time ) then Group_HoldMeeting( group ) end
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