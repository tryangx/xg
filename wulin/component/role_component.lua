---------------------------------------
---------------------------------------
ROLE_COMPONENT = class()

---------------------------------------
ROLE_PROPERTIES = 
{
	name       = { type="STRING", },
	age        = { type="NUMBER", },
	sex        = { type="NUMBER", }, --0:male, 1:female

	groupid    = { type="ECSID", },

	category   = { type="NUMBER", }, --0

	statuses   = { type="LIST" },

	--mental
	-- valuetype: { type: string, init_value = number, post_value = number }
	mentals    = { type="LIST" },

	traits     = { type="LIST" },

	--common skill
	--{ {type=ROLE_COMMONSKILL, value=evaluation} }
	commonSkills = { type="LIST" },
}

---------------------------------------
function ROLE_COMPONENT:__init()
end


---------------------------------------
function ROLE_COMPONENT:Update()

end

---------------------------------------
---------------------------------------
function ROLE_COMPONENT:IsMatch( params )
	if params.status_includes then
		for _, status in pairs( status_includes ) do
			local ret = self.statuses[status]
			if not ret or ret == 0 then return false end
		end
	end

	if params.status_includes then
		for _, status in pairs( status_excludes ) do
			local ret = self.statuses[status]
			if ret and ret ~= 0 then return false end
		end
	end
end


---------------------------------------
-- @return default as 0
---------------------------------------
function ROLE_COMPONENT:GetMentalValue( type )
	local ret = self.mentals[type]
	return ret or 0
end


function ROLE_COMPONENT:GetTraitValue( type )
	local ret = self.traits[type]
	return ret or 0
end


---------------------------------------
function ROLE_COMPONENT:SetStatus( statuses)
	if not self.statuses then return end
	for status, value in pairs( statuses ) do
		--print( role.name, "status=" .. status, "value=" .. value )
		role.statuses[status] = value
	end
end


---------------------------------------
function ROLE_COMPONENT:ToString()
	local content = ""
	content = content .. "[" .. self.name .. "]"
	content = content .. " " .. "Age=" .. self.age
	if self.groupid then
		local entity = ECS_FindEntity( self.groupid )
		if entity then
			content = content .. " " .. "group=" .. entity:GetComponent( "GROUP_COMPONENT" ).name
		end
	end
	return content
end

---------------------------------------
function ROLE_COMPONENT:Dump()
	print( self:ToString() )
end


---------------------------------------