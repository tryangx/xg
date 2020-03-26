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
function GANG_COMPONENT:Dump()
	print( "", "Level=" .. ( self.level or 0 ) )
	print( "", "Member=" .. #self.members )
	for _, ecsid in ipairs( self.members ) do
		local entity = ECS_FindEntity( ecsid )
		local role = entity and entity:GetComponent( "ROLE_COMPONENT" )
		if role then print( "", "", role.name ) end
	end
	if #self.actionpts > 0 then Dump( self.actionpts ) end
end