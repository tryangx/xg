--------------------------------------------------------
--
-- CSV Parser
--
--------------------------------------------------------
local default_rep = ','
--local default_rep = '	'

local function debug_msg( content )
	if nil then
	--if true then
		print( "[TXTDUTIL]", content )
	end
end

local function TxtDataUtil_Split( str, reps )
	local list = {}	
	string.gsub( str, '[^' .. reps ..']+', function( word )
		--print( "word=", word )
		local equalSign = string.find( word, "=" )
		if equalSign then
			--pattern: "y1=x1,y2=x2,..."
			local name = string.sub( word, 1, equalSign - 1 )
			local value = string.sub( word, equalSign + 1, #word )
			local number = tonumber( value )
			list[name] = number or value
			--print( typeof( list[name] ), name, typeof( number ), typeof(value ) )
		else
			--pattern: "v1,v2,v3,..."
			local number = tonumber( word )
			local value = number or word			
			table.insert( list, value )
			--print( typeof( value ), number, word )
		end		
	end )
	return list
end


--------------------------------------------------------
local function TxtDataUtil_ParseLine( line, headers )
	--headers = { "name", "value", "comment" }
	--line = "abc,110,\"a=ok,b=cancel,c=123\""
	if not line or not headers then return end	
	--print( "line=", line )
	--print( "headers=", headers )

	local data = {}
	local pos  = 1
	for _, name in ipairs( headers ) do
		--print( "try to read=" .. name, "left=" .. string.sub( line, pos, #line ) )
		local comma = string.find( line, ",", pos )
		local qmark = string.find( line, "\"*\"", pos )
		local bracketBegin = string.find( line, "{", pos )
		if bracketBegin and ( not qmark or bracketBegin < qmark ) and ( not comma or bracketBegin < comma ) then
			local bracketEnd   = string.find( line, "}", bracketBegin )
			if bracketBegin and bracketEnd then
				local str = string.sub( line, bracketBegin + 1, bracketEnd - 1 )
				--print( "Bracket", str )
				data[name] = TxtDataUtil_Split( str, "," )
			else
				error( "No backet end." )
			end
		elseif qmark and qmark < comma then
			--complex object
			local qend = string.find( line, "\"*\"", qmark + 1 )
			if not qend then error( "single quotation is illegal! line=" .. line ) end
			local bracketBegin = string.find( line, "{", qmark + 1 )
			local bracketEnd = string.find( line, "}", qmark + 1 )
			local str
			if bracketBegin and bracketEnd then
				str = string.sub( line, bracketBegin + 1, bracketEnd - 1 )
			else				
				str = string.sub( line, qmark + 1, qend - 1 )
			end
			--print( "Complex Object=", str )
			data[name] = TxtDataUtil_Split( str, "," )
			comma = string.find( line, ",", qend )
			if comma then				
				pos = comma + 1
			else
				--print( "Last Value", string.sub( line, qend, #line ) )
				break
			end
		elseif comma then
			--sinle value
			local str = string.sub( line, pos, comma - 1 )
			if string.len(str) == 0 then debug_msg( "[TXTDUTIL}Name=" .. name .. " needs a explicit value in str:".. str ) end
			local number = tonumber( str )
			data[name] = number or str
			--print( "Simple Object=", str, string.len(str), number, name, typeof(data[name]) )
			pos = comma + 1
		else
			local str = string.sub( line, pos, #line - 1 )
			--print( "Last Value=", str )
			local number = tonumber( str )			
			data[name] = number or str
			break
		end
		--if name == "lv" then InputUtil_Pause() end
	end

	--Dump( data )	InputUtil_Pause()

	return data
end


--------------------------------------------------------
function TxtDataUtil_Parse( fileName, rep )
	if rep and typeof(rep) == "string" then default_rep = rep end

	local file = io.open( fileName )
	if not file then
		print( "file load failed! filename=", fileName )
		return
	end

	print( "Parse CSV filename=", fileName )

	--read header
	local header = file:read( "*line" )
	local headers = TxtDataUtil_Split( header, default_rep )
	--print( "header:", header )

	local dict = {}

	--read data
	local line = file:read()
	while line do
		local ret = TxtDataUtil_ParseLine( line, headers )
		if not ret then
			break
		else
			table.insert( dict, ret )
			line = file:read()
		end
	end

	return dict
end

