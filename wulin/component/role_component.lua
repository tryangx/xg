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

	bags       = { type="LIST" },

	--common skill
	--{ {type=ROLE_COMMONSKILL, value=evaluation} }
	commonSkills = { type="DICT" },
}

---------------------------------------
function ROLE_COMPONENT:__init()
end


---------------------------------------
function ROLE_COMPONENT:Update()
end

---------------------------------------
---------------------------------------
function ROLE_COMPONENT:MatchStatus( params )
	if params.status_includes then
		for _, status in pairs( params.status_includes ) do
			local ret = self.statuses[status]
			if not ret or ret == 0 then return false end
		end
	end

	if params.status_excludes then		
		for _, status in pairs( params.status_excludes ) do
			local ret = self.statuses[status]
			if ret and ret ~= 0 then return false end
		end
	end
	
	return true
end

function ROLE_COMPONENT:SetStatusValue( type, value )
	if not self.statuses then return end
	self.statuses[type] = value
end

function ROLE_COMPONENT:IncStatusValue( type, value )
	if not self.statuses then return end
	self.statuses[type] = self.statuses[type] and self.statuses[type] + value or value
end

function ROLE_COMPONENT:GetStatusValue( type )
	return self.statuses[type] or 0
end

---------------------------------------
function ROLE_COMPONENT:AppendBag( item )
	Prop_Add( self, "bags", item )
end


---------------------------------------
function ROLE_COMPONENT:RemoveBag( bag )
	Prop_Remove( self, "bags", item )
end


---------------------------------------
function ROLE_COMPONENT:ObtainCommonSkill( book )
	Prop_Add( self, "commonSkills", book.lv, book.commonskill )
	DBG_Trace( self.name .. " obtain commonskill=" .. book.name .. " lv=" .. Prop_Get( self, "commonSkills" )[book.commonskill] .. "+" .. book.lv )
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
function ROLE_COMPONENT:ToString()
	local content = ""
	content = content .. "[" .. self.name .. "]"
	content = content .. " " .. "Age=" .. self.age
	
	if self.groupid then
		local entity = ECS_FindEntity( self.groupid )
		if entity then content = content .. " " .. "group=" .. entity:GetComponent( "GROUP_COMPONENT" ).name end
	end

	for type, value in pairs(self.statuses) do
		content = content ..  " " .. type .. "=" .. value
	end

	return content
end

---------------------------------------
function ROLE_COMPONENT:Dump()
	print( self:ToString() )
end


---------------------------------------