---------------------------------------------------
---------------------------------------------------
require "fightskilltemplate_datatable"
require "roletemplate_datatable"

require "fightskill_datatable"
require "passiveskill_datatable"
require "role_datatable"
require "construction_datatable"
require "group_datatable"
require "book_datatable"
require "map_datatable"
require "equipment_datatable"
require "process_datatable"
require "item_datatable"
require "produce_datatable"
require "city_datatable"
require "facility_datatable"
require "entrust_datatable"


---------------------------------------------------
---------------------------------------------------
function DataTable_CreateComponent( componentType, tabledata )
	local component = ECS_CreateComponent( componentType )
	if tabledata then
		--use properties
		for name, _ in pairs( component._properties ) do
			if tabledata[name] then
				component[name] = MathUtil_ShallowCopy( tabledata[name] )
			end
		end
	end
	return component
end

--[[
function create_component_bydatatableid( componentType, getter, id )
	local component = ECS_CreateComponent( componentType )
	local tabledata = getter( id )
	if tabledata then
		--use properties	
		--print( "properties", component._properties )
		for name, _ in pairs( component._properties ) do
			if tabledata[name] then
				component[name] = MathUtil_ShallowCopy( tabledata[name] )
				--print( "set", name, component[name] )
			end			
		end
	end
	--MathUtil_ShallowCopy( getter( id ), component )	
	return component
end
]]