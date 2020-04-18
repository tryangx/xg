---------------------------------------
---------------------------------------
ENTRUST_COMPONENT = class()

---------------------------------------
ENTRUST_PROPERTIES = 
{
	--{ { id=, poolindex=, } },
	entrusts  = { type="LIST" },

	--{ entrusttype={}, ... }
	cooldowns = { type="DICT" },
}

---------------------------------------
function ENTRUST_COMPONENT:__init()
end


---------------------------------------
function ENTRUST_COMPONENT:Update( deltaTime )
	for _, data in pairs( self.cooldowns ) do
		data.cd = data.cd - deltaTime
		if data.cd <= 0 then
			data.needwait = 0
			data.cd = 0
		end
	end

	MathUtil_RemoveListItemIf( self.entrusts, function ( entrust )
		entrust.validtime = entrust.validtime - deltaTime
		return entrust.validtime <= 0
	end)
end


---------------------------------------
function ENTRUST_COMPONENT:CanIssue()
	local cityCmp = ECS_FindComponent( self.entityid, "CITY_COMPONENT" )
	if not cityCmp then DBG_Error( "No City Component" ) return end

	return #self.entrusts < cityCmp.lv * 5 + 5
end


function ENTRUST_COMPONENT:Issue( entrust, poolindex )
	Prop_Add( self, "entrusts", { id=entrust.id, poolindex=poolindex, validtime=entrust.time.valid } )

	DBG_Trace( ECS_FindComponent( self.entityid, "CITY_COMPONENT" ).name .. " Issue entrust=" .. entrust.name )
	
	if not self.cooldowns[entrust.type] then self.cooldowns[entrust.type] = {} end
	self.cooldowns[entrust.type].cd = self.cooldowns[entrust.type].cd and self.cooldowns[entrust.type].cd + entrust.time.cd or entrust.time.cd
	if self.cooldowns[entrust.type].cd > entrust.time.maxcd then self.cooldowns[entrust.type].needwait = 1 end
end


function ENTRUST_COMPONENT:Remove( index )
	table.remove( self.entrusts, index )
end


function ENTRUST_COMPONENT:IsInCooldown( entrustType )
	if not self.cooldowns[entrustType] then self.cooldowns[entrustType] = { cd=0, needwait=0 } end
	if self.cooldowns[entrustType].needwait == 1 then return true end	
	return false
end

---------------------------------------
function ENTRUST_COMPONENT:ToString( content )
	local content = ""

	content = content .. " Cooldown["
	for entrustType, data in pairs( self.cooldowns ) do
		content = content .. " " .. entrustType .. ":"
		content = content .. "CD=" .. data.cd
		if data.needwait then content = content .. " WAIT=1" end
		content = content .. ","
	end
	content = content .. "]\n"

	content = content .. " Entrust["
	for idx, entrust in ipairs( self.entrusts ) do
		if idx > 0 then content = content .. "," end
		content = content .. ENTRUST_DATATABLE_Get( entrust.id ).name
		content = content .. " PIDX=" .. entrust.poolindex
		content = content .. " time=" .. entrust.validtime
	end
	content = content .. "]"

	return content
end

function ENTRUST_COMPONENT:Dump( )
	print( self:ToString() )
end