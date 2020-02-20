---------------------------------------
--
--
--
---------------------------------------
REFLECTION_SEPERATOR =
{
	ARRAY      = 1,
	OBJECT     = 2,	
}

---------------------------------------
function Reflection_Import( reflection, object )
	--if not object then object = {} end
	if object and object._properties then		
		for _, prop in pairs( object._properties ) do
			reflection:ImportValue( object, prop.name )
		end
	else
		object = reflection:Import( object )
	end	
	return object
end

---------------------------------------
function Reflection_Export( reflection, object )
	if not object then DBG_TraceBug( "object is invalid to export" ) return end
	if object._properties then
		--print( "Object=", object._type or object.name or "", " has properties" )
		reflection:ExportBegin( object.TYPE, REFLECTION_SEPERATOR.OBJECT )
		reflection:ExportValue( object.type or object.name or "", object )
		reflection:ExportEnd( object.TYPE, REFLECTION_SEPERATOR.OBJECT )
	else
		--object doesn't has properties, it seems not component, just hanlde it with the normal way
		--print( "Object=", object._type or object.name or "", " has no properties, use the default method" )
		reflection:ExportBegin( object.TYPE )
		reflection:ExportValue( object.type or object.name or "", object )
		reflection:ExportEnd( object.TYPE )		
	end
end

---------------------------------------
function Reflection_Flush( reflection )	
	reflection:Flush()
end

---------------------------------------