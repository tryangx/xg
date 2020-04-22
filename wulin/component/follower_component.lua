----------------------------------
---------------------------------------
FOLLOWER_COMPONENT = class()

---------------------------------------
FOLLOWER_PROPERTIES = 
{
	job          = { type="STRING" },
	
	rank         = { type="STRING", default="NONE" },
	
	masterid     = { type="ECSID"  },

	--how many days since follower joined group
	seniority    = { type="NUMBER" },

	--measure what follower did for group
	contribution = { type="OBJECT" }, --value, unrewarded

	salary       = { type="NUMBER" },
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

---------------------------------------
function FOLLOWER_COMPONENT:Contribute( contribution )
	local lv = math.ceil( self.contribution / 1000 )
	self.contribution = self.contribution + contribution
	if math.ceil( self.contribution / 1000 ) > lv then
		return true
	end
end