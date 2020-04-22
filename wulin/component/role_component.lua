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

	groupid    = { type="ECSID", },

	statuses   = { type="LIST" },

	---------------------------------------
	--
	---------------------------------------
	actions    = { type="DICT" },

	assets     = { type="DICT" },

	--mental
	-- valuetype: { type: string, init_value = number, post_value = number }
	mentals    = { type="DICT" },

	traits     = { type="DICT" },

	--common skill
	--{ {type=ROLE_COMMONSKILL, value=evaluation} }
	commonSkills = { type="DICT" },

	--bags, include equipment, medicine
	--{ { type="EQUIPMENT", id=, } }
	bags       = { type="LIST" },

	--equips
	equips     = { type="DICT" },
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
	if not self.statuses then self.statuses[type] = 0 end
	self.statuses[type] = value
end

function ROLE_COMPONENT:IncStatusValue( type, value )
	if not self.statuses[type] then self.statuses[type] = 0 end
	self.statuses[type] = self.statuses[type] + value	
end

function ROLE_COMPONENT:GetStatusValue( type )
	return self.statuses[type] or 0
end


---------------------------------------
function ROLE_COMPONENT:ObtainAssets( type, value )
	self.assets[type] = ( self.assets[type] or 0 ) + value
end

function ROLE_COMPONENT:ConsumeAssets( type, value )
	if not self.assets[type] then self.assets[type] = 0 end
	if self.assets[type] < value then
		DBG_Trace( self.name .. " doesn't have " .. type .. "=" .. math.abs( value ) )
		value = self.assets[type]
		self.assets[type] = 0
	else
		self.assets[type] = self.assets[type] - value
	end
	return value
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
	return self.mentals[type] or 0
end

function ROLE_COMPONENT:SetMentalValue( type, value )
	if not self.statuses then self.statuses[type] = 0 end
	self.mentals[type] = math.min( 100, value )
end

function ROLE_COMPONENT:IncMentalValue( type, value )
	if not self.mentals[type] then self.mentals[type] = 0 end
	self.mentals[type] = math.min( 100, self.mentals[type] + value )
end


---------------------------------------
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
	self.equips[equip.type] = { id=id }
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
	content = content .. " statues="
	for type, value in pairs(self.statuses) do
		content = content ..  " " .. type .. "=" .. value
	end

	--actions
	content = content .. " actpts="
	for type, value in pairs(self.actions) do
		content = content ..  " " .. type .. "=" .. value
	end

	--assets
	content = content .. " assets="
	for type, value in pairs(self.assets) do
		content = content ..  " " .. type .. "=" .. value
	end

	--mental
	content = content .. " mentals="
	for type, value in pairs(self.mentals) do
		content = content ..  " " .. type .. "=" .. value
	end

	--traits
	content = content .. " traits="
	for type, value in pairs(self.traits) do
		content = content ..  " " .. type .. "=" .. value
	end

	--commonskill
	content = content .. " commonsk="
	for type, value in pairs( self.commonSkills ) do
		content = content .. " " .. type .. "=" .. value
	end

	--equips
	content = content .. " equips="
	for type, data in pairs(self.equips) do
		content = content ..  " " .. type .. "=" .. EQUIPMENT_DATATABLE_Get( data.id ).name
	end

	--bags
content = content .. " bags="
	for type, data in pairs(self.bags) do
		if ROLE_EQUIP[type] then
			content = content ..  " " .. type .. "=" .. EQUIPMENT_DATATABLE_Get( data.id ).name
		elseif type == "MEDICINE" then
			content = content ..  " " .. type .. "=" .. ITEM_DATATABLE_Get( data.id ).name
		end
	end

	return content
end

---------------------------------------
function ROLE_COMPONENT:Dump()
	print( self:ToString() )
end


---------------------------------------