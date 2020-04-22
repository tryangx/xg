---------------------------------------
--[[
	
	type:  门派帮会
	
	size        : determine how many construction
	organization: determine how many follower, fictions
	
	action points:
	Management Point: Use to change schedule, reward
	Strategic Point : Use to send envy
	Tacic Point     : Use to execute task, recon	
--]]
---------------------------------------
GROUP_COMPONENT = class()

---------------------------------------
GROUP_PROPERTIES = 
{
	type            = { type="NUMBER", },

	name            = { type="STRING", },

	size            = { type="STRING", default="FAMILY" },
	location        = { type="NUMBER" },	

	statuses        = { type="DICT" },	

	members         = { type="LIST", }, --list of role entity id
	leaderid        = { type="ECSID", }, --role entity id

	--goal
	--{ type=GROUP_GOAL, remaintime=0 }
	goal            = { type="OBJECT" },
	ranking         = { type="NUMBER" },

	--actions
	actionpts       = { type="DICT" },
	
	--land asset
	lands           = { type="DICT" },	
	
	--virtual assets
	assets          = { type="DICT" },

	--reality mass assets, reference to RESOURCE_TYPE
	resources       = { type="DICT" },	
	
	--books
	--{ id=id, ... }
	books           = { type="LIST" },
	
	--horse
	--{ id=id, ... }
	vehicles        = { type="LIST" },	
	
	--weapon/armor
	--{ id=id, ... }
	arms            = { type="LIST" },
	
	--accessory,shoes,medicine
	--{ id=id, ... }
	items           = { type="LIST" },
	
	--construction
	--{ id=id, ... }
	constructions   = { type="LIST" },

	--runtime data
	affairs         = { type="LIST" }, 

	--datatable
	membertemplates = { type="LIST" }, --list of number	
}

---------------------------------------
function GROUP_COMPONENT:__init()
	--temporary data
	self._datas = {}
end


---------------------------------------
function GROUP_COMPONENT:Activate()
end


---------------------------------------
function GROUP_COMPONENT:Deactivate()
end


---------------------------------------
function GROUP_COMPONENT:Update()
	if #self.members == 0 then DBG_Error( self.name, "should be terminated" ) end
end

---------------------------------------
-- Get group's temporary data
-- @param type reference to GROUP_DATA
---------------------------------------
function GROUP_COMPONENT:GetData( type )
	local ret = self._datas[type]
	if ret then return ret end

	function GetConstructionEffect( effType )
		local v = 0
		for _, data in ipairs( self.constructions ) do
			local constr = CONSTRUCTION_DATATABLE_Get( data.id )
			v = v + ( constr.effects[effType] or 0 )
		end
		return v
	end

	--need to calculated
	local value = 0
	if type == "POWER" then		
		local value = 0
		self:ForeachMember( function ( ecsid )
			local fighter = ECS_FindComponent( ecsid, "FIGHTER_COMPONENT" )
			if fighter then value = value + fighter.fighteff end
		end)
	
	elseif type == "MAX_MEMBER" then value = GetConstructionEffect( "max_member" ) + 5
	elseif type == "MAX_SENIOR" then value = GetConstructionEffect( "max_senior" )
	elseif type == "MAX_ELDER"  then value = GetConstructionEffect( "max_elder" )

	elseif type == "MAX_CONSTRUCTION" then value = self.lands[FLATLAND]

	elseif type == "MAX_ARMS" then     value = GetConstructionEffect( "arms_slot" )
	elseif type == "MAX_VEHICLES" then value = GetConstructionEffect( "vehicle_slot" )
	elseif type == "MAX_ITEM" then     value = GetConstructionEffect( "item_slot" )
	elseif type == "MAX_BOOK" then     value = GetConstructionEffect( "book_slot" )
	elseif type == "MAX_RESOURCE" then value = GetConstructionEffect( "res_slot" )

	elseif type == "MAX_COOK_LV" then    value = GetConstructionEffect( "book_lv" )
	elseif type == "MAX_DRILL_LV" then   value = GetConstructionEffect( "drill_lv" )
	elseif type == "MAX_SECLUDE_LV" then value = GetConstructionEffect( "seclude_lv" )
	elseif type == "MAX_STUDY_LV" then   value = GetConstructionEffect( "study_lv" )
	elseif type == "MAX_SMITHY_LV" then  value = GetConstructionEffect( "smithy_lv" )
	elseif type == "MAX_RAISE_LV" then   value = GetConstructionEffect( "raise_lv" )

	elseif type == "MAX_LIVESTOCK_YIELD" then value = GetConstructionEffect( "livestock_yield" )
	elseif type == "MAX_FOOD_YIELD"      then value = GetConstructionEffect( "food_yield" )
	elseif type == "MAX_HERB_YIELD"      then value = GetConstructionEffect( "herb_yield" )

	elseif type == "MAX_ALLY"            then value = GetConstructionEffect( "max_ally" ) + GROUP_PARAMS.DIPLOMACY.ally[self.size]
	elseif type == "MAX_VASSAL"          then value = GetConstructionEffect( "max_vassal" ) + GROUP_PARAMS.DIPLOMACY.vassal[self.size]
	elseif type == "MAX_SUBJECT"         then value = GetConstructionEffect( "max_subject" ) + GROUP_PARAMS.DIPLOMACY.subject[self.size]

	elseif type == "ESTIMATE_MONEY"      then value = self.assets["MONEY"]
	elseif type == "ESTIMATE_INCOME"     then
		value = GetConstructionEffect( "sell_quantity" ) 
	elseif type == "ESTIMATE_EXPEND"     then
		self:ForeachMember( function ( ecsid )
			local follower = ECS_FindComponent( ecsid, "FOLLOEWR_COMPONENT" )
			if follower then value = value + follower.salary end
		end)
	end

	self._datas[type] = value
	return value
end

---------------------------------------
function GROUP_COMPONENT:GetTempStatusValue( type )
	return self._tempStatuses[type] or 0
end

function GROUP_COMPONENT:IncTempStatusValue( type )
	return self._tempStatuses[type] or 0
end

function GROUP_COMPONENT:AddWishConstruction( constructionType )
	local number = 1
	self._constructionWishList[constructionType] = self._constructionWishList[constructionType] and self._constructionWishList[constructionType] + number or number
end

function GROUP_COMPONENT:AddWishItem( itemType, itemId, quantity )
	if not self._itemWishList then return end
	if not self._itemWishList[itemType] then self._itemWishList[itemType] = {} end
	if not quantity then DBG_Error( "no quantity" ) end
	self._itemWishList[itemType][itemId] = self._itemWishList[itemType][itemId] and self._itemWishList[itemType][itemId] + quantity or quantity
end

function GROUP_COMPONENT:AddWishResource( resType, quantity )
	if not self._resourceWishList then return end
	self._resourceWishList[resType] = self._resourceWishList[resType] and self._resourceWishList[resType] + quantity or quantity	
end

function GROUP_COMPONENT:AddFollowerReserveList( roleid, affair )
	if not self._followerReserveList then return end
	self._followerReserveList[roleid] = affair
end

function GROUP_COMPONENT:AddWishLand( type, quantity )
	if not self._landWishList then return end
	self._landWishList[type] = ( self._landWishList[type] or 0 ) + quantity
end

---------------------------------------
--
-- @return default value is 0
--
---------------------------------------
function GROUP_COMPONENT:GetStatusValue( type )
	return self.statuses[type] or 0
end


function GROUP_COMPONENT:IncStatusValue( type, value )
	if not value then value = 1 end	
	self.statuses[type] = self.statuses[type] and self.statuses[type] + value or value
	--InputUtil_Pause( self.name, "inc status", self.statuses[type], value )
end


function GROUP_COMPONENT:DecStatusValue( type, value )
	self.statuses[type] = self.statuses[type] and math.max( 0, self.statuses[type] - value ) or 0
	--InputUtil_Pause( self.name, "dec status", self.statuses[type], value )
end


---------------------------------------
function GROUP_COMPONENT:FindMember( fn )
	local roles = {}
	for _, memberid in pairs( self.members ) do
		if fn( memberid ) == true then table.insert( roles, memberid ) end
	end
	return roles
end


function GROUP_COMPONENT:ForeachMember( fn )	
	for _, memberid in pairs( self.members ) do
		fn( memberid )
	end
end


---------------------------------------
-- rank
---------------------------------------
function GROUP_COMPONENT:GetNumOfMember( params )
	local num = 0
	for _, id in ipairs( self.members ) do
		local match = true
		if params.rank then
			local follower = ECS_FindComponent( id, "FOLLOWER_COMPONENT" )
			if match and params.rank and follower.rank ~= params.rank then match = false end
			if match and params.rank_ge and FOLLOWER_RANK[followr.rank] >= FOLLOWER_RANK[params.rank_ge] then match = false end
		end
		if params.ability then
			local follower = ECS_FindComponent( id, "FOLLOWER_COMPONENT" )
			if match and not FOLLOWER_RANK_ABILITY[follower.rank][params.ability] then match = false end
		end
		if match then num = num + 1 end
	end
	return num
end


---------------------------------------
function GROUP_COMPONENT:GetNumOfAffairs( type )
	local num = 0
	for _, affair in ipairs( self.affairs ) do
		if affair.type == type then num = num + 1 end
	end
	return num
end

function GROUP_COMPONENT:GetNumOfAffairsByParams( params )
	local num = 0	
	for _, affair in ipairs( self.affairs ) do
		local isMatch = true
		if params then
			for type, value in pairs( params ) do
				if not affair[type] or affair[type] ~= value then isMatch = false break end
			end
		end
		if isMatch then num = num + 1 end
	end
	return num
end


---------------------------------------
function GROUP_COMPONENT:GetNumOfLand( type )
	return self.lands[type] or 0
end

function GROUP_COMPONENT:ObtainLand( type, value )
	self.lands[type] = ( self.lands[type] or 0 ) + value
end

function GROUP_COMPONENT:LostLand( type, value )
	if not self.lands[type] then self.lands[type] = 0 end
	if self.lands[type] < value then
		value = self.lands[type]
		self.lands[type] = 0
	else
		self.lands[type] = self.lands[type] - value
	end
	return value
end


---------------------------------------
-- 
-- Get number of the exist constructions
-- @params type can be nil, has higher priority than id
-- @params id can be nil
--
---------------------------------------
function GROUP_COMPONENT:GetNumOfConstruction( type, id )
	if type and id then DBG_Error( "Only one condition works at the same time" ) end
	local num = 0
	if type then id = nil end
	for _, data in ipairs( self.constructions ) do
		if data.id == id then
			num = num + 1
		else
			local constr = CONSTRUCTION_DATATABLE_Get( data.id )
			if constr and constr.type == type then num = num + 1 end
		end
	end
	return num
end

---------------------------------------
function GROUP_COMPONENT:GetPlot()
	local city = CurrentMap:GetCity( self.location )
	return city and CurrentMap:GetPlot( city.x, city.y )
end


---------------------------------------
function GROUP_COMPONENT:GetNumOfResource( type )
	return self.resources[type] or 0
end

function GROUP_COMPONENT:RemoveResource( type, value )
	if not self.resources[type] then self.resources[type] = 0 end
	if value > 0 then
		if self.resources[type] < value then
			DBG_Error( self.name .. " doesn't have " .. type .. "=" .. math.abs( value ) )
			self.resources[type] = 0
		end
	else
		self.resources[type] = self.resources[type] + value
	end
end

function GROUP_COMPONENT:ObtainResource( type, value )
	Prop_Add( self, "resources", value, type )
	DBG_Trace( self.name .. " obtain resource=" .. type .. "+" .. value )
end


---------------------------------------
function GROUP_COMPONENT:ObtainAssets( type, value )
	self.assets[type] = ( self.assets[type] or 0 ) + value
end

function GROUP_COMPONENT:ConsumeAssets( type, value )
	if not self.assets[type] then self.assets[type] = 0 end
	if self.assets[type] < value then
		DBG_Trace( self.name .. " doesn't have " .. type .. "=" .. math.abs( value ) )
		value = self.assets[type]
		self.assets[type] = 0
	else
		self.assets[type] = self.assets[type] - value
	end
	return value
end


---------------------------------------
function GROUP_COMPONENT:GetNumOfItem( type, id )
	if id then
		return MathUtil_GetNumOfData( self.items, id, "id" )
	end
	return MathUtil_GetNumOfData( self.items, type, "type" )
end

function GROUP_COMPONENT:ObtainItem( type, id )
	Prop_Add( self, "items", { type=type, id=id } )
	DBG_Trace( self.name .. " obtain item=" .. ITEM_DATATABLE_Get( id ).name )
end

function GROUP_COMPONENT:RemoveItem( type, id )
	for inx, data in ipairs( self.items ) do
		if data.type == type and data.id == id then
			table.remove( self.items, inx )
			DBG_Trace( self.name .. " remove item=" .. ITEM_DATATABLE_Get( id ).name )
			return
		end
	end	
end


---------------------------------------
function GROUP_COMPONENT:GetNumOfBook( type, id )
	if id then
		return MathUtil_GetNumOfData( self.books, id, "id" )
	end
	return MathUtil_GetNumOfData( self.books, type, "type" )
end

function GROUP_COMPONENT:ObtainBook( type, id )
	Prop_Add( self, "books", { type=type, id=id } )	
	DBG_Trace( self.name .. " obtain book=" .. BOOK_DATATABLE_Get( id ).name )
end

function GROUP_COMPONENT:RemoveBook( id )
	Prop_Remove( self, "books", id, "id" )
	DBG_Trace( self.name .. " remove book=" .. BOOK_DATATABLE_Get( id ).name )
end


---------------------------------------
function GROUP_COMPONENT:GetNumOfArm( type, id )
	if id then
		return MathUtil_GetNumOfData( self.arms, id, "id" )
	end
	return MathUtil_GetNumOfData( self.arms, type, "type" )
end

function GROUP_COMPONENT:ObtainArm( type, id )
	Prop_Add( self, "arms", { type=type, id=id } )
	DBG_Trace( self.name .. " obtain arm=" .. EQUIPMENT_DATATABLE_Get( id ).name )
end

function GROUP_COMPONENT:RemoveArm( id )
	Prop_Remove( self, "arms", id, "id" )
	DBG_Trace( self.name .. " remove arm=" .. EQUIPMENT_DATATABLE_Get( id ).name )
end


---------------------------------------
function GROUP_COMPONENT:GetNumOfVehicle( type, id )
	if id then
		return MathUtil_GetNumOfData( self.vehicles, id, "id" )
	end
	return MathUtil_GetNumOfData( self.vehicles, type, "type" )
end

function GROUP_COMPONENT:ObtainVehicle( type, id )
	Prop_Add( self, "vehicles", { type=type, id=id } )
	DBG_Trace( self.name .. " obtain vehicle=" .. EQUIPMENT_DATATABLE_Get( id ).name )
end

function GROUP_COMPONENT:RemoveVehicle( id )
	Prop_Remove( self, "vehicles", id, "id" )
	DBG_Trace( self.name .. " remove vehicle=" .. EQUIPMENT_DATATABLE_Get( id ).name )
end


---------------------------------------
-- Obtain resource, book, arm, item, vehicle
---------------------------------------
function GROUP_COMPONENT:CompleteConstruction( id )
	Prop_Add( self, "constructions", { id=id } )
	DBG_Trace( self.name .. " complete construction=" .. CONSTRUCTION_DATATABLE_Get( id ).name )
end

function GROUP_COMPONENT:DestroyConstruction( id )
	Prop_Remove( self, "constructions", id, "id" )
	DBG_Trace( self.name .. " destroy construction=" .. CONSTRUCTION_DATATABLE_Get( id ).name )
end

---------------------------------------
function GROUP_COMPONENT:ToString()
	local content = ""
	content = content .. "[" .. self.name .. "]\n"

	--leader
	if self.leaderid then
		content = content .. " Leader=" .. ECS_FindComponent( self.leaderid, "ROLE_COMPONENT" ).name
	end

	--members
	content = content .. " " .. "Member=" .. #self.members
	if #self.members > 0 then
		content = content .. "["
		local num = 0
		for _, ecsid in ipairs( self.members ) do
			local entity = ECS_FindEntity( ecsid )
			local role = entity and entity:GetComponent( "ROLE_COMPONENT" )
			if role then
				if num > 0 then content = content .. "," end
				content = content .. role.name
				num = num + 1
			end
		end
		content = content .. "]\n"
	end

	--actionpts
	content = content .. " actpts=["
	for type, pts in pairs( self.actionpts ) do
		content = content .. " " .. type .. "=" .. pts
	end
	content = content .. "]\n"

	--statues
	content = content .. " statuses=["
	for type, status in pairs( self.statuses ) do
		content = content .. " " .. type .. "=" .. status
	end
	content = content .. "]\n"

	--resource
	content = content ..  " assets=["
	for type, quantity in pairs( self.assets ) do
		content = content .. " " .. type .. "=" .. quantity
	end
	content = content .. "]\n"

	--resource
	content = content ..  " res=["
	for type, quantity in pairs( self.resources ) do
		content = content .. " " .. type .. "=" .. quantity
	end
	content = content .. "]\n"

	--books
	content = content ..  " books=["
	for _, data in ipairs( self.books ) do
		content = content .. " " .. BOOK_DATATABLE_Get( data.id ).name
	end
	content = content .. "]\n"

	--vehicle
	content = content ..  " vehicles=["
	for _, data in ipairs( self.vehicles ) do
		content = content .. " " .. EQUIPMENT_DATATABLE_Get( data.id ).name
	end
	content = content .. "]\n"

	--arms
	content = content ..  " arms=["
	for _, data in pairs( self.arms ) do
		content = content .. " " .. EQUIPMENT_DATATABLE_Get( data.id ).name
	end
	content = content .. "]\n"

	--items
	content = content ..  " items=["
	for _, data in pairs( self.items ) do
		content = content .. " " .. ITEM_DATATABLE_Get( data.id ).name
	end
	content = content .. "]\n"

	--constructions
	content = content .. " constrs=["
	for inx, data in ipairs( self.constructions ) do
		content = content .. ( inx > 1 and "," or "" ) .. CONSTRUCTION_DATATABLE_Get( data.id ).name
	end
	content = content .. "]\n"

	--affairs
	content = content .. " affairs=["
	for inx, affair in ipairs( self.affairs ) do
		content = content .. ( inx > 1 and "," or "" ) .. affair.type
		if affair.type == "ENTRUST" then
			local entrust = ENTRUST_DATATABLE_Get( affair.entrustid )
			content = content .. " " .. entrust.name
		elseif affair.type == "BUILD_CONSTRUCTION" then
			content = content .. " " .. CONSTRUCTION_DATATABLE_Get( affair.construction ).name

		end
		content = content .. " time=" .. affair.time
	end
	content = content .. " ]\n"

	--data
	content = content .. " data=["
	for type, data in pairs( self._datas ) do
		content = content .. type .. "=" .. data .. " "
	end
	content = content .. "]\n"

	return content
end


---------------------------------------
function GROUP_COMPONENT:Dump()
	print( self:ToString() )
end