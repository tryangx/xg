
-----------------------------------------
-- Reflect the data into the file with json format
--
--
-----------------------------------------
FileReflection = class()

FileReflectionMode =
{
	IMPORT        = 1,
	EXPORT        = 2,
	EXPORT_APPEND = 3,
	EXPORT_PRINT  = 4,
}

---------------------------------------
function FileReflection:__init( mode )
	self._mode = mode

	self._isParsed = false
end

---------------------------------------
function FileReflection:Close( fileName )
	if self._fileHandle then
		self._fileHandle:close()
		--print( "close", self._fileHandle )
	end

	self._fileHandle = nil
end

---------------------------------------
function FileReflection:SetMode( mode )
	self._mode = mode
	self:Close()
	self:SetFile( fileName )
end

---------------------------------------
function FileReflection:SetFile( fileName )
	self:Close()

	self._fileName = fileName	
	if self._mode == FileReflectionMode.IMPORT then
		self._fileHandle = io.open( fileName, "r" )	
	elseif self._mode == FileReflectionMode.EXPORT then
		self._fileHandle = io.open( fileName, "w" )				
	elseif self._mode == FileReflectionMode.EXPORT_APPEND then
		self._fileHandle = io.open( fileName, "a" )
	end

	--if self._fileHandle then print( "file=", self._fileName, "is opened" ) end
end

---------------------------------------
function FileReflection:Read()
	if self._isParsed then return end
	self._isParsed = true;
	self._decodeDatas = json.decode( self._fileHandle:read() )
	self._parseData = self._decodeDatas
end

---------------------------------------
function FileReflection:Write( value )	
	if self._mode == FileReflectionMode.EXPORT_PRINT then
		if not self._dump then self._dump = "" end
		self._dump = self._dump .. value
		--print( "dump=" .. value )
	else
		if not self._fileHandle then
			DBG_Warning( "FileReflection:Write", "File=" .. ( self._fileName or "" ) .. " isn't opened." )
		else
			--print( "write=" .. value )
			self._fileHandle:write( value )
		end
	end
end

---------------------------------------
function FileReflection:Flush()
	if self._mode == FileReflectionMode.EXPORT_PRINT then
		if self._dump then print( self._dump ) end
	end
	self:Close()
end

---------------------------------------
function FileReflection:ImportData( object, name, data )
	if not data or not name then print( "no name=" .. name ) return end
	
	print( "set " .. name .. "=", data, object )

	local t = typeof( data )
	if t == "table" then
		object[name] = {}
		---print( "what table!!!!", object, name, object[name] )
		for k, v in pairs( data ) do
			table.insert( object[name], self:ImportValue( nil, v ) )
		end
	elseif t == "number" then
		object[name] = data;
	elseif t == "boolean" then
		object[name] = data;
	elseif t == "string" then
		object[name] = data;
	end
end

---------------------------------------
function FileReflection:ImportValue( object, data )	
	--if data then MathUtil_Dump( data, 3 ) end
	--print( "import value", object, data )
	
	local properties
	if data.ecstype == "ECSSCENE" then
		properties = ECSSceneProperties
		if not object then object = ECS_CreateScene( "UNKNOWN" ) end
	elseif data.ecstype == "ECSENTITY" then
		properties = ECSEntityProperties
		if not object then object = ECS_CreateEntity( "ECSENTITY", "UNKNOWN" ) end
	elseif data.ecstype == "ECSCOMPONENT" then
		properties = ECSProperties
		if data.name then
			if not object then object = ECS_Create( data.name, "UNKNOWN" ) end
		end
	end

	if properties then
		print( "ecstype=" .. data.ecstype )
		
		--check properties
		for pname, prop in pairs( properties ) do
			if not data[pname] then
				DBG_Trace( "missing prop=" .. pname )
			end
		end
		
		--print( "start", data.name )
		for k, v in pairs( data ) do
			--print( "prop=" .. k, v )
			self:ImportData( object, k, v )
		end
		--print( "end", data.name )

	elseif typeof( data ) == "table" then
		--if not object then object = {} print( "init obj", data.name ) end
		for k, v in pairs( data ) do
			--print( "!!!!!!!!!!!!!!!!!", k, v )			
			object = self:ImportValue( object, v )
			object.name = k
			--print( "---------------object", "name", k )
		end
	end
	return object
end

---------------------------------------
function FileReflection:Import( object )
	if not self._parseData then self:Read() end
	if self._parseData then
		return self:ImportValue( object, self._parseData )
	end
end

---------------------------------------
function FileReflection:ExportBegin( name, seperator )	
	if seperator == REFLECTION_SEPERATOR.ARRAY then
		self:Write( "[" )				
		self._isArray = true
	elseif seperator == REFLECTION_SEPERATOR.OBJECT then
		self:Write( "{" )
		self._isArray = nil
	else
		self._isArray = true
	end
end

---------------------------------------
function FileReflection:ExportEnd( name, seperator )
	self._isArray = nil
	if seperator == REFLECTION_SEPERATOR.ARRAY then
		self:Write( "]" )		
	elseif seperator == REFLECTION_SEPERATOR.OBJECT then
		self:Write( "}" )
	else
	end
end

---------------------------------------
function FileReflection:ExportValue( name, value )
	if not name or not value then DBG_Trace( "name=", name, "value=", value, "one of them is invalid" ) return end

	local t = type( value )
	--print( "deal", name, value, t )

	if t == "table" then
		if not self._isArray and name then self:Write( "\"" .. name .. "\":" ) end

		--check if it is an ecs object
		if value._properties then
			--print( "it's ecs object", name, value )

			self:ExportBegin( value.TYPE, REFLECTION_SEPERATOR.OBJECT )

			local firstValue = true
			--write ecs data
			for subName, prop in pairs( ECSProperties ) do
				--print( "ecsdata", subName, prop.type, value[subName] )
				local subValue = value[subName]
				if subValue then
					if not firstValue then self:Write( "," ) end
					self:ExportValue( subName, value[subName] )
					firstValue = false
				end
			end

			--write its own data
			for subName, prop in pairs( value._properties ) do
				local subValue = value[subName]
				--print( "owndata", subName, prop.type, value[subName] )
				if subValue then
					if not firstValue then self:Write( "," ) end
					self:ExportValue( subName, subValue )
					firstValue = false
				end				
			end
			self:ExportEnd( value.TYPE, REFLECTION_SEPERATOR.OBJECT )
		else
			--check if it is an array or object
			local isArray = true
			for k, v in pairs( value ) do if typeof( k ) ~= "number" then isArray = false break end end

			--save the current state
			local lastState = self._isArray
			self._isArray = isArray

			local firstValue = true

			print( "isarray=", isArray )

			--process the object by the different methods depends on whether it is array or object.
			if self._isArray then
				self:ExportBegin( name, REFLECTION_SEPERATOR.ARRAY )
				for k, v in ipairs( value ) do
					if not firstValue then self:Write( "," ) end
					self:ExportValue( k, v )
					firstValue = false
				end
				self:ExportEnd( name, REFLECTION_SEPERATOR.ARRAY )
			else
				self:ExportBegin( name, REFLECTION_SEPERATOR.OBJECT )
				for k, v in pairs( value ) do
					if not firstValue then self:Write( "," ) end
					self:ExportValue( k, v )
					firstValue = false
				end
				self:ExportEnd( name, REFLECTION_SEPERATOR.OBJECT )
			end

			--restore the array state
			self._isArray  = lastState
		end
	else
		if not self._isArray and name then self:Write( "\"" .. name .. "\":" ) end

		if t == "string" then self:Write( "\"" .. value .. "\"" )
		elseif t == "number" then self:Write( value )
		elseif t == "boolean" then self:Write( ( value and "true" or "false" ) )
		else
			DBG_Error( "unhandle", name, item, t )
		end
	end
	self._singleValue = false
end