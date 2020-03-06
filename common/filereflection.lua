
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

	if self._fileHandle then
		--print( "file=", self._fileName, "is opened" )
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
	--MathUtil_Dump( self._parseData, 10 )
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

function FileReflection:ImportData( data, name )
	if not data or not name then error( "Wrong Data" ) end

	--print( "import data=", data, "name=", name )

	local t = typeof( data )
	if t == "string" or t == "number" or t == "boolean" then
		--print( "data", name .. "=" .. data )
		return data		
	end

	--check ecs object
	local object	
	if data.ecstype == "ECSSCENE" then				
		properties = ECSProperties
		object     = ECS_CreateScene( "UNKNOWN" )
		--print( "creat scene", object )
	elseif data.ecstype == "ECSENTITY" then		
		properties = ECSProperties
		object     = ECS_CreateEntity( "ECSENTITY", "UNKNOWN" )
		--print( "creat entity", object )
	elseif data.ecstype == "ECSCOMPONENT" then
		properties = ECSComponentProperties
		object     = ECS_CreateComponent( data.ecsname, "UNKNOWN" )
		--print( "creat component", object )
	end

	if object then
		--print( "ecstype=" .. data.ecstype, object )
		for itemname, item in pairs( properties ) do
			if not data[itemname] then error( "why no property=" .. itemname ) end
			--print( "!!!!!!!set", itemname, data[itemname] )
			object[itemname] = data[itemname]
		end
	else
		object = {}
	end
	
	for key, value in pairs( data ) do
		--print( "prop=" .. key, value, object[key] )
		if not object[key] then			
			local child = self:ImportData( value, key )
			--print( "set key=" .. key .. " data=", child )
			object[key] = child			
		end
	end

	return object
end

--[[
---------------------------------------
function FileReflection:ImportData( object, name, data )
	if not data or not name then print( "no name=" .. name ) return end
	
	--print( "set " .. name .. "=", data, object )

	local t = typeof( data )
	if t == "table" then
		object[name] = {}
		for k, v in pairs( data ) do			
			t = typeof( v )
			if t == "string" or t == "number" or t == "boolean" then
				object[name] = data
			else				
				local child = self:ImportValue( nil, v )
				if child.ecstype == "ECSENTITY" then					
					if object.ecstype == "ECSSCENE" then
						if object.rootEntity then DBG_Error( "Why root entity is already exist?" ) end
						object:SetRootEntity( child )
						print( "Add rootentity into scene", child )
					elseif object.ecstype == "ECSENTITY" then
						object:AddChild( child )
						print( "Add child into entity", child )
					end
				else
					object[name][k] = child
					--print( name, k, child )
				end
			end
			--table.insert( object[name], self:ImportValue( nil, v ) )
		end
	elseif t == "string" or t == "number" or t == "boolean" then
		object[name] = data;
	end
end

---------------------------------------
function FileReflection:ImportValue( parent, data )	
	--if data then MathUtil_Dump( data, 3 ) end
	--print( "import value", object, data )

	local object

	local properties
	if data.ecstype == "ECSSCENE" then		
		properties = ECSSceneProperties
		object     = ECS_CreateScene( "UNKNOWN" )
	elseif data.ecstype == "ECSENTITY" then
		properties = ECSEntityProperties
		object     = ECS_CreateEntity( "ECSENTITY", "UNKNOWN" )
	elseif data.ecstype == "ECSCOMPONENT" then
		properties = ECSProperties		
		object     = ECS_CreateComponent( data.ecsname, "UNKNOWN" )				
	end

	if properties then	
		--check properties
		print( "ecstype=" .. data.ecstype )
		--for pname, prop in pairs( properties ) do if not data[pname] then DBG_Trace( "missing prop=" .. pname ) end end
		
		print( "  start ecs", data.ecsname, data )
		for k, v in pairs( data ) do
			print( "prop=" .. k, v, v.ecstype )
			Dump( v )
			self:ImportData( object, k, v )
		end
		print( "  end ecs", data.ecsname )

	elseif typeof( data ) == "table" then
		if not parent then error( "why none data" ) end--object = {} end-- print( "init obj", data.name ) end
		for k, v in pairs( data ) do
			parent[k] = self:ImportValue( object, v )
			--print( "---------------object", "name", k, object )
		end
	end
	return object
end

--]]

---------------------------------------
function FileReflection:Import( object )
	if not self._parseData then self:Read() end
	if self._parseData then
		local load =  self:ImportData( self._parseData, "FILE_LOADED" )		
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
	if not name or not value then DBG_Trace( "name=", name, "value=", value, "one of them is invalid" ) return end

	local t = type( value )
	--print( "deal", name, value, t )

	if t == "table" then
		if not self._isArray and name then self:Write( "\"" .. name .. "\":" ) end

		--print( "name=" .. name, "isarray=" .. ( ( self._isArray == true ) and "true" or "false" ) )

		--if name == "parent" then error( "" ) end

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
					--self._isArray = true
					self:ExportValue( subName, value[subName] )
					firstValue = false
				end
			end

			--write its own data, data not in properties will not be exported
			for subName, prop in pairs( value._properties ) do
				local subValue = value[subName]
				--print( "owndata", subName, prop.type, value[subName] )
				if subValue then					
					--self._isArray = true
					if prop.type == "ID" then
						if subValue.ecsid then
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
			--print( "it's not ecs object", name, value )

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

		--print( "  end", name, value )
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