---------------------------------------
---------------------------------------
ROLE_COMPONENT = class()

---------------------------------------
ROLE_PROPERTIES = 
{
	name       = { type="STRING", },
	age        = { type="NUMBER", },
	sex        = { type="NUMBER", }, --0:male, 1:female	
	category   = { type="STRING", }, --0

	statuses   = { type="LIST" },

	groupid    = { type="ECSID", },

	---------------------------------------
	--
	---------------------------------------
	renown     = { type="NUMBER" },

	actions    = { type="DICT" },

	--mental
	-- valuetype: { type: string, init_value = number, post_value = number }
	mentals    = { type="LIST" },

	traits     = { type="LIST" },

	--bags, include equipment, medicine
	--{ { type="EQUIPMENT", id=, } }
	bags       = { type="LIST" },

	equips     = { type="DICT" },

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
function ROLE_COMPONENT:ObtainCommonSkill( book )
	Prop_Add( self, "commonSkills", book.lv, book.commonskill )
	DBG_Trace( self.name .. " obtain commonskill=" .. book.name .. " lv=" .. Prop_Get( self, "commonSkills" )[book.commonskill] .. "+" .. book.lv )
end


function ROLE_COMPONENT:HasCommonSkill( type, lv )
	return self.commonSkills[type] and self.commonSkills[type] >= ( lv or 0 ) or false
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
function ROLE_COMPONENT:AddToBag( type, id )
	Prop_Add( self, "bags", { type=type, id=id } )
	if ROLE_EQUIP[type] then
		DBG_Trace( self.name .. " add " .. EQUIPMENT_DATATABLE_Get( id ).name .. " into bag." )
	else
		DBG_Trace( self.name .. " add " .. ITEM_DATATABLE_Get( id ).name .. " into bag." )
	end
end


function ROLE_COMPONENT:RemoveFromBag( type, id )
	for _, data in pairs( self.bags ) do
		if data.type == type and data.id == id then
			table.remove( self.bags, k )
			return
		end
	end
end


function ROLE_COMPONENT:CanAddToBag( num )
	if not num then num = 1 end
	return num < 5
end

---------------------------------------
-- @params type reference to EQUIPMENT_TYPE
---------------------------------------
function ROLE_COMPONENT:GetEquip( type )
	return self.equips[type]
end


function ROLE_COMPONENT:SetupEquip( id )
	local equip = EQUIPMENT_DATATABLE_Get( id )
	if self.equips[equip.type] then
		--takeoff
		self:RemoveFromBag( equip.type, self.equips[equip.type].id )
		DBG_Trace( self.name .. " takeoff equipment=" .. equip.type )
	end
	self.equips[equip.type] = id
	DBG_Trace( self.name .. " put on equipment=" .. equip.name )
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

	--status
	for type, value in pairs(self.statuses) do
		content = content ..  " " .. type .. "=" .. value
	end

	--commonskill
	for type, value in pairs( self.commonSkills ) do
		content = content .. " " .. type .. "=" .. value
	end

	return content
end

---------------------------------------
function ROLE_COMPONENT:Dump()
	print( self:ToString() )
end


---------------------------------------