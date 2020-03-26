------------------------------------------------------------------------------
--
--  Property
--
--  Bundle of properties will be stored in a container.
--  Here are the interfaces to access, append and remove the properties in the container
--  Specially, property is stored by the key-value structure, it's key is "name":
--    pattern: container[key] = data
--    
------------------------------------------------------------------------------
PROPERTY_TYPE =
{
	NUMBER     = 0,
	STRING     = 1,
	OBJECT     = 2,
	ECSID      = 4,

	--
	LIST       = 10,	
	DICT       = 11,
	LIST_ECSID = 12,
}


---------------------------------------
function Prop_Get( container, name )
	if not container or not container._properties then error( "container is invalid" ) end	
	local prop = container._properties[name]	
	return container[name]
end

---------------------------------------
-- Index, Key, Data
function Prop_GetByIndex( container, name, Index, Key, Data )
	if not container or not container._properties then error( "container is invalid" ) end			
	local prop = container._properties[name]	
	if prop.type == "LIST" or prop.type == "DICT" then
		if not Index or Index < 1 then Index = 1 end
		local data = container[name]
		if not data then print( name, "isn't exist" ) return end
		for _, v in pairs( data ) do			
			--MathUtil_Dump( v ) print( "try", v[Key], Data, name )
			if ( not Key and not Data ) or v[Key] == Data then
				if Index == 1 then					
					return v	
				end
				Index = Index - 1
			end			
		end
	else
		DBG_Error( "Not supported property type." .. prop.type )
	end
end

function Prop_GetByFilter( container, name, filter )
	if not container or not container._properties then error( "container is invalid" ) end	
	local prop = container._properties[name]
	if prop.type == "LIST" or prop.type == "DICT" or prop.type == "LIST_ECSID" then
		for _, v in pairs( container ) do
			if filter( v ) then
				return v
			end
		end
	else
		DBG_Error( "Not supported property type." .. prop.type )
	end
end

---------------------------------------
function Prop_Set( container, name, data, id )
	--print( "set", name, data, id )
	if not container or not container._properties then error( "container is invalid" ) end	
	local prop = container._properties[name]
	if prop.type == "NUMBER" then
		container[name] = data
	elseif prop.type == "STRING" then
		container[name] = data
	elseif prop.type == "ECSID" then
		container[name] = data
	elseif prop.type == "OBJECT" then
		container[name] = data
	elseif prop.type == "LIST" then
		DBG_Error( "Shouldn't use Prop_Set() for " .. prop.type )
	elseif prop.type == "DICT" then
		DBG_Error( "Shouldn't use Prop_Set() for " .. prop.type )
	elseif prop.type == "LIST_ECSID" then
		DBG_Error( "Shouldn't use Prop_Set() for " .. prop.type )
	else
		DBG_Error( "Unhanlde type=" .. prop.type )	
	end
end

---------------------------------------
--
-- @usage:
--   Prop_Add( table, "array", data )
--
--
function Prop_Add( container, name, data, id )
	if not container or not container._properties then error( "container is invalid" ) end	
	local prop = container._properties[name]
	--MathUtil_Dump( container._properties )
	if prop.type == "NUMBER" then
		container[name] = data
		--print( "insert number=", data )
	elseif prop.type == "STRING" then
		container[name] = data
		--print( "insert string=", data )
	elseif prop.type == "OBJECT" then
		container[name] = data
	elseif prop.type == "LIST" then
		if not container[name] then container[name] = {} end		
		local t = typeof(data)
		if t == "table" then
			for _, v in ipairs( data ) do
				table.insert( container[name], v )
			end
		else
			table.insert( container[name], data )
		end
		--print( "insert", data, "into", name, #container[name] )
	elseif prop.type == "DICT" then
		if not id then
			local t = typeof(data)
			if t == "table" then
				for id, v in pairs( data ) do
					container[name][id] = v
				end
			else
				table.insert( container[name], data )
			end
		else
			container[name][id] = data
		end
	else
		DBG_Error( "Unhanlde type=" .. prop.type )
	end
end

---------------------------------------
function Prop_Remove( container, name, data )
	if not container._properties then DBG_Error( "only use in ecs object" ) return end
	
	local prop = container._properties[name]

	local t = typeof( container[name] )

	if t == "table" then
		for k, v in pairs( container[name] ) do
			if v == data then
				table.remove( container[name], k )
				return true
			end
		end
	else
		DBG_Error( "unhandle prop name=" .. name .. " id=" .. id )
	end
end

---------------------------------------
function Prop_RemoveById( container, name, id )
	--container is a ecs object
	if not container._properties then DBG_Error( "only use in ecs object" ) return end
	
	local prop = container._properties[name]

	local t = typeof( container[name] )

	if not id then
		--id is null, means to clear the data		
		if t == "string" then
			container[name] = prop and prop.default or nil
		elseif t == "number" then
			container[name] = prop and prop.default or 0
		elseif t == "boolean" then
			container[name] = prop and prop.default or false
		elseif t == "table" then
			DBG_Error( "cann't remove the item in array/dict by id ")
			return
		end
		return true
	elseif t == "table" then
		--when id is valid, only
		if prop.type == "LIST" then
			DBG_Error( "Don't remove the item in list by id" )
		else
			container[name][id] = nil
			print( "remove dict" )
			return true
		end
	else
		DBG_Error( "unhandle prop name=" .. name .. " id=" .. id )
	end
end

---------------------------------------
function Prop_RemoveByIndex( container, name, index )
	if not container._properties then DBG_Error( "only use in ecs object" ) return end;

	local t = typeof( container[name] )
	if t == "table" then
		table.remove( container[name], k )
		print( "remove data by index=" .. index )
	else
		DBG_Error( "Don't remove the item when it isn't list or dict." );
	end
end

---------------------------------------
function Prop_RemoveByFilter( container, name, filter )
	if not container._properties then DBG_Error( "only use in ecs object" ) return end;

	local t = typeof( container[name] )
	if t == "table" then		
		for k, v in pairs( container[name] ) do
			if filter( v, k ) then
				print( "remove data by filter key=" .. key )
				container[name][k] = nil
			end
		end		
	else
		DBG_Error( "Don't remove the item when it isn't list or dict." );
	end
end


---------------------------------------
--
-- Traversal Interfaces
--
-- Include Foreach(), Once(), Match()
--
---------------------------------------
function Prop_Foreach( container, name, fn )
	if not container._properties then DBG_Error( "only use in ecs object" ) return end
	
	local prop = container._properties[name]
	
	if prop.type == "LIST" or prop.type == "DICT" then
		if not container[name ] then return end
		for _, v in pairs( container[name] ) do
			fn( v )
		end
	else
		fn( v )
	end
end


function Prop_Once( container, name, fn )
	if not container._properties then DBG_Error( "only use in ecs object" ) return end
	
	local prop = container._properties[name]
	
	if prop.type == "LIST" or prop.type == "DICT" then
		if not container[name ] then return end
		for _, v in pairs( container[name] ) do
			if fn( v ) then return end
		end
	else
		fn( v )
	end
end


function Prop_Match( container, name, fn, number )
	if not number then number = -1 end
	
	if not container._properties then DBG_Error( "only use in ecs object" ) return end
	
	local prop = container._properties[name]
	
	local list = {}
	if prop.type == "LIST" or prop.type == "DICT" then
		if not container[name ] then return end
		for _, v in pairs( container[name] ) do
			if fn( v ) then table.insert( list, v ) end
		end
	else
		if fn( v ) then table.insert( list, v ) end
	end

	return list
end