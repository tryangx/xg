----------------------------------
---------------------------------------
FOLLOWER_COMPONENT = class()

---------------------------------------
FOLLOWER_PROPERTIES = 
{
	job          = { type="STRING" },
	rank         = { type="STRING", default="NONE" },
	masterid     = { type="ECSID"  },
	seniority    = { type="NUMBER" }, --days
	contribution = { type="OBJECT" }, --value, unrewarded
}

---------------------------------------
function FOLLOWER_COMPONENT:__init()
	self._status = {}
end

---------------------------------------
function FOLLOWER_COMPONENT:Update()
	self.seniority = self.seniority + 1
end

---------------------------------------
function FOLLOWER_COMPONENT:Apprenticed( masterid )
	self.masterid = masterid
end