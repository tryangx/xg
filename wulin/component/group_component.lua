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
	self._attrs = {}
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
function GROUP_COMPONENT:GetAttr( type )
	local ret = self._attrs[type]
	if not ret then
		--need to calculated
		if type == "POWER" then			
			local power = 0
			self:ForeachMember( function ( ecsid )
				local fighter = ECS_FindComponent( ecsid, "FIGHTER_COMPONENT" )
				if fighter then power = power + fighter.fighteff end
			end)
			self._attrs[type] = power
		elseif type == "" then
		end
		ret = self._attrs[type]
	end
	return ret
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
	print( "add wish contruction", constructionType )
end

function GROUP_COMPONENT:AddWishItem( itemType, itemId, quantity )
	if not self._itemWishList[itemType] then self._itemWishList[itemType] = {} end
	if not quantity then DBG_Error( "no quantity" ) end
	self._itemWishList[itemType][itemId] = self._itemWishList[itemType][itemId] and self._itemWishList[itemType][itemId] + quantity or quantity
	print( "add wish item", itemType, itemId, quantity )
end

function GROUP_COMPONENT:AddWishResource( resType, quantity )
	self._resourceWishList[resType] = self._resourceWishList[resType] and self._resourceWishList[resType] + quantity or quantity
	print( "add wish res", resType )
end

function GROUP_COMPONENT:AddFollowerReserveList( roleid, affairid)
	self._followerReserveList[roleid] = affairid
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

function GROUP_COMPONENT:UseResources( type, value )
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

---------------------------------------
function GROUP_COMPONENT:UseAssets( type, value )
	if not self.assets[type] then self.assets[type] = 0 end
	if value > 0 then
		if self.assets[type] < value then
			Dump( self.assets )
			DBG_Error( self.name .. " doesn't have " .. type .. "=" .. math.abs( value ) )
			self.assets[type] = 0
		end
	else
		self.assets[type] = self.assets[type] + value
	end
end


---------------------------------------
-- Obtain resource, book, arm, item, vehicle
---------------------------------------
function GROUP_COMPONENT:ObtainResource( type, value )
	Prop_Add( self, "resources", value, type )
	DBG_Trace( self.name .. " obtain resource=" .. type .. "+" .. value )
end

function GROUP_COMPONENT:ObtainBook( type, id )
	Prop_Add( self, "books", { type=type, id=id } )	
	DBG_Trace( self.name .. " obtain book=" .. BOOK_DATATABLE_Get( id ).name )
end

function GROUP_COMPONENT:ObtainArm( type, id )
	Prop_Add( self, "arms", { type=type, id=id } )
	DBG_Trace( self.name .. " obtain arm=" .. EQUIPMENT_DATATABLE_Get( id ).name )
end

function GROUP_COMPONENT:ObtainItem( type, id )
	Prop_Add( self, "items", { type=type, id=id } )
	DBG_Trace( self.name .. " obtain item=" .. ITEM_DATATABLE_Get( id ).name )
end

function GROUP_COMPONENT:ObtainVehicle( type, id )
	Prop_Add( self, "vehicles", { type=type, id=id } )
	DBG_Trace( self.name .. " obtain vehicle=" .. EQUIPMENT_DATATABLE_Get( id ).name )
end

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
	content = content .. " ]"

	return content
end


---------------------------------------
function GROUP_COMPONENT:Dump()
	print( self:ToString() )
end