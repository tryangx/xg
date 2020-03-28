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
	type      = { type="NUMBER", },

	name      = { type="STRING", },
	
	size      = { type="STRING", default="FAMILY" },

	statuses  = { type="DICT" },

	--roles
	members   = { type="LIST", }, --list of role entity id
	masterid  = { type="ECSID", }, --role entity id

	--action points
	actionpts = { type="DICT" },

	--template
	membertemplates = { type="LIST" }, --list of number
}

---------------------------------------
function GROUP_COMPONENT:__init()
end


---------------------------------------
function GROUP_COMPONENT:Activate()	
end


---------------------------------------
function GROUP_COMPONENT:Deactivate()
end


---------------------------------------
function GROUP_COMPONENT:Update()

end

---------------------------------------
function GROUP_COMPONENT:FindMember( fn )
	local roles = {}
	MathUtil_Foreach( group.members, function ( _, ecsid )
		if fn( ecsid ) == true then table.insert( roles, ecsid ) end
	end )
	return roles
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
	self.statuses[type] = self.statuses[type] and self.statuses[type] + value or value
	--InputUtil_Pause( self.name, "inc status", self.statuses[type], value )
end


function GROUP_COMPONENT:DecStatusValue( type, value )
	self.statuses[type] = self.statuses[type] and math.max( 0, self.statuses[type] - value ) or 0
	--InputUtil_Pause( self.name, "dec status", self.statuses[type], value )
end

---------------------------------------
function GROUP_COMPONENT:ToString()
	local content = ""
	content = content .. "[" .. self.name .. "]"
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

	return content
end

---------------------------------------
function GROUP_COMPONENT:Dump()
	print( self:ToString() )	
end