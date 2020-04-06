----------------------------------
---------------------------------------
FOLLOWER_COMPONENT = class()

---------------------------------------
FOLLOWER_PROPERTIES = 
{
	job          = { type="STRING" },
	rank         = { type="STRING" },
	seniority    = { type="NUMBER" }, --days
	contribution = { type="OBJECT" }, --value, unrewarded
}

---------------------------------------
function FOLLOWER_COMPONENT:__init()
end

---------------------------------------
function FOLLOWER_COMPONENT:Update()

end

---------------------------------------