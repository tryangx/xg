---------------------------------------
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
---------------------------------------
GANG_TYPE = 
{
	GANG_MAIN   = 0,
	GANG_BRANCH = 1,	
}


GANG_SIZE = 
{
	FAMILY     = 1,
	SMALL      = 2,
	MID        = 3,
	BIG        = 4, --branch
	HUGE       = 5,	--
}


GANG_ACTIONPOINT = 
{
	MANAGEMENT = 1,
	STRATEGIC  = 2,
	TACTIC     = 3,
}


GANG_STATUS = 
{
	UNDER_ATTACK = 1,
}


---------------------------------------
---------------------------------------
GANG_COMPONENT = class()

---------------------------------------
GANG_PROPERTIES = 
{
	type      = { type="NUMBER", },

	name      = { type="STRING", },
	
	size      = { type="STRING", },

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
function GANG_COMPONENT:__init()
end


---------------------------------------
function GANG_COMPONENT:Activate()	
end


---------------------------------------
function GANG_COMPONENT:Deactivate()
end


---------------------------------------
function GANG_COMPONENT:Update()

end

---------------------------------------
--
-- @return default value is 0
--
---------------------------------------
function GANG_COMPONENT:GetStatusValue( type )
	return self.statuses[type] or 0
end


function GANG_COMPONENT:IncStatusValue( type, value )
	self.statuses[type] = self.statuses[type] and self.statuses[type] + value or value
	--InputUtil_Pause( self.name, "inc status", self.statuses[type], value )
end


function GANG_COMPONENT:DecStatusValue( type, value )
	self.statuses[type] = self.statuses[type] and math.max( 0, self.statuses[type] - value ) or 0
	--InputUtil_Pause( self.name, "dec status", self.statuses[type], value )
end

---------------------------------------
function GANG_COMPONENT:ToString()
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
function GANG_COMPONENT:Dump()
	print( self:ToString() )	
end