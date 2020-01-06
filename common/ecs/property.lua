---------------------------------------
---------------------------------------
PropertyType =
{
	NUMBER = 0,
	STRING = 1,
	OBJECT = 2,	

	--
	LIST   = 3,

	--
	DICT   = 4,
}

---------------------------------------
--
-- @usage:
--   Prop_Add( table, "array", data )
--
--
function Prop_Add( target, name, data, id )
	if not target or not target._properties then error( "why here1" ) end	
	local prop = target._properties[name]
	--MathUtil_Dump( target._properties )
	if prop.type == "NUMBER" then
		target[name] = data
		print( "insert number=", data )
	elseif prop.type == "STRING" then
		target[name] = data
		print( "insert string=", data )
	elseif prop.type == "LIST" then
		if not target[name] then target[name] = {} end
		table.insert( target[name], data )
		--print( "insert", data, "into", name, #target[name] )
	elseif prop.type == "DICT" then
		if not id then 
			table.insert( target[name], data )
		else
			target[name][id] = data
		end		
	end
end

---------------------------------------
function Prop_Remove( target, name, data )
	if not target._properties then DBG_Error( "only use in ecs object" ) return end
	
	local prop = target._properties[name]

	local t = typeof( target[name] )

	if t == "table" then
		for k, v in pairs( target[name] ) do
			if v == data then
				table.remove( target[name], k )
				break
			end
		end
	else
		DBG_Error( "unhandle prop name=" .. name .. " id=" .. id )
	end
end

---------------------------------------
function Prop_RemoveById( target, name, id )
	--target is a ecs object
	if not target._properties then DBG_Error( "only use in ecs object" ) return end
	
	local prop = target._properties[name]

	local t = typeof( target[name] )

	if not id then
		--id is null, means to clear the data		
		if t == "string" then
			target[name] = prop and prop.default or nil
		elseif t == "number" then
			target[name] = prop and prop.default or 0
		elseif t == "boolean" then
			target[name] = prop and prop.default or false
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
			target[name][id] = nil
			print( "remove dict" )
			return true
		end
	else
		DBG_Error( "unhandle prop name=" .. name .. " id=" .. id )
	end
end

---------------------------------------
function Prop_RemoveByIndex( target, name, index )
	if not target._properties then DBG_Error( "only use in ecs object" ) return end;

	local t = typeof( target[name] )
	if t == "table" then
		table.remove( target[name], k )
		print( "remove data by index=" .. index )
	else
		DBG_Error( "Don't remove the item when it isn't list or dict." );
	end
end

---------------------------------------
function Prop_RemoveByFilter( target, name, filter )
	if not target._properties then DBG_Error( "only use in ecs object" ) return end;

	local t = typeof( target[name] )
	if t == "table" then		
		for k, v in pairs( target[name] ) do
			if filter( v, k ) then
				print( "remove data by filter key=" .. key )
				target[name][k] = nil
			end
		end		
	else
		DBG_Error( "Don't remove the item when it isn't list or dict." );
	end
end

---------------------------------------