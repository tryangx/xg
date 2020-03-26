-----------------------------------------
-----------------------------------------
FileReflectionMode =
{
	IMPORT        = 1,
	EXPORT        = 2,
	EXPORT_APPEND = 3,
	EXPORT_PRINT  = 4,
}


-----------------------------------------
local function debugmsg( ... )
	--if true then
	if nil then
		print( ... )
	end
end


-----------------------------------------
-- Reflect the data into the file with json format
--
--
-----------------------------------------
FileReflection = class()


-----------------------------------------

---------------------------------------
function FileReflection:__init( mode )
	self._mode = mode

	self._isParsed = false
end

---------------------------------------
function FileReflection:Close( fileName )
	if self._fileHandle then
		self._fileHandle:close()
		debugmsg( "close", self._fileHandle )
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

	if self._fileHandle then
		debugmsg( "file=", self._fileName, "is opened" )
	else
		DBG_Error( "Open File [" .. fileName .. "] failed!" )
	end
end

---------------------------------------
function FileReflection:Read()
	if not self._fileHandle then DBG_Error( "File handler is invalid" ) return end
	if self._isParsed then return end
	self._isParsed  = true;
	self._content   = self._fileHandle:read()
	self._parseData = json.decode( self._content )
	--print( self._content )	
	--Log_Write( "Json", self._parseData )
	--Dump( self._parseData, 8 )
end

---------------------------------------
function FileReflection:Write( value )
	if self._mode == FileReflectionMode.EXPORT_PRINT then
		if not self._dump then self._dump = "" end
		self._dump = self._dump .. value
		debugmsg( "dump=" .. value )
	else
		if not self._fileHandle then
			DBG_Warning( "FileReflection:Write", "File=" .. ( self._fileName or "" ) .. " isn't opened." )
		else			
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

function FileReflection:ImportData( data, name )
	if not data or not name then error( "Wrong Data" ) end

	debugmsg( "import data=", data, "name=", name )

	local t = typeof( data )
	if t == "string" or t == "number" or t == "boolean" then
		debugmsg( "data", name .. "=" .. data )
		return data		
	end

	local properties
	--check ecs object
	local object	
	if data.ecstype == "ECSSCENE" then				
		properties = ECSPROPERTIES
		object     = ECS_CreateScene( "UNKNOWN" )
		debugmsg( "creat scene", object )
	elseif data.ecstype == "ECSENTITY" then		
		properties = ECSPROPERTIES
		object     = ECS_CreateEntity( "ECSENTITY", "UNKNOWN" )
		debugmsg( "creat entity", object )
	elseif data.ecstype == "ECSCOMPONENT" then
		properties = ECSCOMPONENTPROPERTIES
		object     = ECS_CreateComponent( data.ecsname, "UNKNOWN" )
		debugmsg( "creat component", object )
	end

	--process with ecs object
	if object then
		debugmsg( "ecstype=" .. data.ecstype, object )
		for propname, prop in pairs( properties ) do
			if prop.type == "ECSID" then InputUtil_Pause( "ecsid" )	end
			if not data[propname] then error( "why no property=" .. propname ) end
			debugmsg( "!!!!!!!set " .. propname .. "=", data[propname] )
			object[propname] = data[propname]
		end
	else
		object = {}
	end
	
	--Load datas
	debugmsg( "Data has children=" .. MathUtil_GetSize( data ) )
	for key, value in pairs( data ) do		
		debugmsg( "prop=" .. key, value, object[key] )		
		--if not object[key] then
		if not properties or not MathUtil_FindByKey( properties, key ) then
			debugmsg( "process key=", key )
			local child = self:ImportData( value, key )			
			object[key] = child
		end
	end

	return object
end

---------------------------------------
function FileReflection:Import( object )
	if not self._parseData then self:Read() end
	if self._parseData then
		local load = self:ImportData( self._parseData, "FILE_LOADED" )		
		return load
		--return self:ImportValue( object, self._parseData )
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
	if not name or not value then debugmsg( "name=", name, "value=", value, "one of them is invalid" ) return end

	local t = type( value )
	debugmsg( "deal", name, value, t )

	if t == "table" then
		if not self._isArray and name then self:Write( "\"" .. name .. "\":" ) end

		debugmsg( "name=" .. name, "isarray=" .. ( ( self._isArray == true ) and "true" or "false" ) )

		--check if it is an ecs object
		if value._properties then
			debugmsg( "it's ecs object", name, value )

			self:ExportBegin( value.TYPE, REFLECTION_SEPERATOR.OBJECT )

			local firstValue = true
			--write ecs data
			for subName, prop in pairs( ECSPROPERTIES ) do
				debugmsg( "ecsdata", subName, prop.type, value[subName] )
				local subValue = value[subName]
				if subValue then
					if not firstValue then self:Write( "," ) end
					--self._isArray = true
					self:ExportValue( subName, value[subName] )
					firstValue = false
				end
			end

			--write its own data, data not in properties will not be exported
			for subName, prop in pairs( value._properties ) do
				local subValue = value[subName]
				debugmsg( "owndata", subName, prop.type, value[subName] )
				if subValue then					
					--self._isArray = true
					if prop.type == "ECSID" then
						if subValue.ecsid then
							InputUtil_Pause( "export Id", subValue.ecsid )
							if not firstValue then self:Write( "," ) end
							self:ExportValue( subName, subValue.ecsid )
						end
					else
						if not firstValue then self:Write( "," ) end
						self:ExportValue( subName, subValue )
					end
					firstValue = false
				end				
			end

			self:ExportEnd( value.TYPE, REFLECTION_SEPERATOR.OBJECT )
		else
			debugmsg( "it's not ecs object", name, value )

			--check if it is an array or object
			local isArray = true
			for k, v in pairs( value ) do if typeof( k ) ~= "number" then isArray = false break end end

			--save the current state
			local lastState = self._isArray
			self._isArray = isArray

			local firstValue = true

			--process the object by the different methods depends on whether it is array or object.
			if self._isArray then
				self:ExportBegin( name, REFLECTION_SEPERATOR.ARRAY )
				for k, v in ipairs( value ) do
					if not firstValue then self:Write( "," ) end
					self._isArray = true
					self:ExportValue( k, v )
					firstValue = false
				end
				self:ExportEnd( name, REFLECTION_SEPERATOR.ARRAY )
			else
				self:ExportBegin( name, REFLECTION_SEPERATOR.OBJECT )
				for k, v in pairs( value ) do
					if not firstValue then self:Write( "," ) end
					--self._isArray = true
					self:ExportValue( k, v )
					firstValue = false
				end
				self:ExportEnd( name, REFLECTION_SEPERATOR.OBJECT )			
			end

			--restore the array state
			self._isArray  = lastState
		end

		debugmsg( "  end", name, value )
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