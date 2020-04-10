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

	actionpts       = { type="DICT" },

	lands           = { type="DICT" },
	
	assets          = { type="DICT" },
	resources       = { type="DICT" },
	books           = { type="LIST" },
	--stored equipments, consumables
	inventories     = { type="LIST" },

	constructions   = { type="LIST" },

	--datatable
	membertemplates = { type="LIST" }, --list of number	

	--runtime data
	affairs         = { type="LIST" }, 
}

---------------------------------------
function GROUP_COMPONENT:__init()
	self._attrs = {}
	self._tempStatuses = {}
end


---------------------------------------
function GROUP_COMPONENT:Activate()
end


---------------------------------------
function GROUP_COMPONENT:Deactivate()
end


---------------------------------------
function GROUP_COMPONENT:Update()
	self._tempStatuses = {}
end

---------------------------------------
function GROUP_COMPONENT:GetAttr( type )
	return self._attrs[type] or 0
end

---------------------------------------
function GROUP_COMPONENT:GetTempStatusValue( type )
	return self._tempStatuses[type] or 0
end

function GROUP_COMPONENT:IncTempStatusValue( type )
	return self._tempStatuses[type] or 0
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
	MathUtil_Foreach( self.members, function ( _, ecsid )
		if fn( ecsid ) == true then table.insert( roles, ecsid ) end
	end )
	return roles
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
		if affair.type == type then
			num = num + 1
		end
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
	for _, cid in ipairs( self.constructions ) do
		if cid == id then
			num = num + 1
		else
			local constr = CONSTRUCTION_DATATABLE_Get( cid )
			if constr and constr.type == type then num = num + 1 end
		end
	end
	return num
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
function GROUP_COMPONENT:GetNumOfResource( type )
	if not self.resources[type] then self.resources[type] = 0 end
	return self.resources[type]
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

function GROUP_COMPONENT:ObtainResource( type, value )
	self.resources[type] = self.resources[type] and self.resources[type] + value or value
end

---------------------------------------
function GROUP_COMPONENT:ObtainBook( id )
	Prop_Add( self, "books", id )
	DBG_Trace( self.name .. " obtain book=" .. BOOK_DATATABLE_Get( id ).name )
end


function GROUP_COMPONENT:ObtainItem( type, id )
	Prop_Add( self, "inventories", { type=type, id=id } )
	DBG_Trace( self.name .. " obtain inventory=" .. type .. "," .. id )
end


---------------------------------------
function GROUP_COMPONENT:CompleteConstruction( id )
	Prop_Add( self, "constructions", id )
	DBG_Trace( self.name .. " complete construction=" .. CONSTRUCTION_DATATABLE_Get( id ).name )
end

function GROUP_COMPONENT:DestroyConstruction( id )
	--MathUtil_Remove( self.constructions, id )
	--not pass test
	Prop_Remove( self, "constructions", id )
	DBG_Trace( self.name .. " destroy construction=" .. CONSTRUCTION_DATATABLE_Get( id ).name )
end

---------------------------------------



---------------------------------------
function GROUP_COMPONENT:ToString()
	local content = ""
	content = content .. "[" .. self.name .. "]"

	--leader
	content = content .. " Leader=" .. ECS_FindComponent( self.leaderid, "ROLE_COMPONENT" ).name

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
		content = content .. "]"
	end

	--actionpts
	for type, pts in pairs( self.actionpts ) do
		content = content .. " " .. type .. "=" .. pts
	end

	--statues
	for type, status in pairs( self.statuses ) do
		content = content .. " " .. type .. "=" .. status
	end

	--constructions
	content = content .. " constructions=["
	for inx, id in ipairs( self.constructions ) do
		content = content .. ( inx > 1 and "," or "" ) .. CONSTRUCTION_DATATABLE_Get( id ).name
	end
	content = content .. "]"

	return content
end

---------------------------------------
function GROUP_COMPONENT:Dump()
	print( self:ToString() )
end