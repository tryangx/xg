MathCompareMethod =
{
	EQUALS = 0,
	
	MORE_THAN = 1,
	
	LESS_THAN = 2,
	
	MORE_THAN_AND_EQUALS = 3,
	
	LESS_THAN_AND_EQUALS = 4,
}

function MathUtil_Size( dict )
	local size = 0
	for _, _ in pairs( dict ) do
		size = size + 1
	end
	return size
end

--[[
	Clamp the given value
	
	@usage 
		print( MathUtil_Clamp( 100, 2, 80 ) ) -- 80
		print( MathUtil_Clamp( 1, 2, 80 ) )   -- 2

]]
function MathUtil_Clamp( value, min, max, default )
	if not value then return default end
	if min and value < min then
		value = min
	elseif max and value > max then
		value = max
	end
	return value
end


--only list, no dict
function MathUtil_Reverse( list )
	local newList = {}
	for k = #list, 1, -1 do
		table.insert( newList, list[k] )
	end
	return newList
end

--[[
	Shuffle Table
	
	-- @usage 
		MathUtil_Shuffle( { 1, 3, 5 } ) -- { 3, 5, 1 }
]]
function MathUtil_Shuffle_Sync( source, desc )	
	if not source then return end
	local length = #source
	if length > 1 then
		for i = 1, length do			
			local t = Random_GetInt_Sync( 1, length - 1, desc ) + 1
			local temp = source[i]
			source[i] = source[t]
			source[t] = temp
		end
	end
	return source
end
function MathUtil_Shuffle_Unsync( source, desc )
	local length = #source
	if length > 1 then
		for i = 1, length do			
			local t = Random_GetInt_Unsync( 1, length - 1, desc ) + 1
			local temp = source[i]
			source[i] = source[t]
			source[t] = temp
		end
	end
	return source
end
function MathUtil_Shuffle_Filter( source, filter, desc )
	local length = #source
	if length > 1 then
		for i = 1, length do
			local t = filter( 1, length - 1, desc ) + 1
			local temp = source[i]
			source[i] = source[t]
			source[t] = temp
		end
	end
	return source
end


--[[
	Call for each in Table with function

	-- @usage MathUtil_Foreach( table, function( ket, value ) print( value ) end )
]]
function MathUtil_Foreach( source, fn )	
	for k, v in pairs( source ) do
		if type( v ) == "table" then
			MathUtil_Foreach( k, v, fn )
		else
			fn( k, v )
		end
	end
end

--[[
--]]
function MathUtil_FindTableKey_Descend( source, value )
	local findKey = nil
	local findValue = nil
	for k, v in pairs(source) do		
		if value >= v then
			if not findValue or v > findValue then				
				findKey = k
				findValue = v
			end
		end
	end
	return findKey
end
function MathUtil_FindTableKey_Ascend( source, value )
	local findKey = nil
	local findValue = nil
	for k, v in pairs(source) do
		if value <= v then
			if not findValue or v < findValue then
				findKey = k
				findValue = v
			end
		end
	end
	return findKey
end

function MathUtil_ToString( source )
	local content = ""
	for k, v in pairs( source ) do
		local brackets = false
		if typeof( k ) == "object" or typeof( k ) == "class" then
			content = content .. "{"
			brackets = true
		elseif typeof( v ) == "number" then
			content = content .. k .. "=" .. v .. ","
		elseif typeof( v ) == "string" then
			content = content .. v .. ","
		end
		if brackets == true then
			brackets = content .. "}"
		end
	end	
	return content
end

function MathUtil_Dump( source, depth, indent )
	if not depth then depth = 3 end
	if not indent then indent = 0 end

	function DumpWithTab( content, indent )
		io.write( string.rep (" ", indent) .. content .. "\n" )
		--print( str )
	end

	if not source or ( typeof( source ) ~= "table" and typeof( source ) ~= "object" ) then
		print( "Dump source is invalid!", typeof(source) )
		return
	end
	if indent > depth then
		--print( "Depth too high" )
		return
	end
	DumpWithTab( "{", indent )	
	for k, v in pairs( source ) do
		local key
		if typeof( k ) == "object" or typeof( k ) == "class" then
			key = ""
		else
			key = k
		end
		if type( v ) == "object" then
			if typeof( k ) == "object" or typeof( k ) == "class" then
				print( k )
			else				
				DumpWithTab( key .. "=", indent + 1 )
			end
			MathUtil_Dump( v, depth - 1, indent + 1 )
		elseif type( v ) == "string" then					
			DumpWithTab( key .. "=\"" .. v .. "\"", indent + 1 )
		elseif type( v ) == "boolean" then
			if v then 
				DumpWithTab( key .. "=true", indent + 1 )
			else
				DumpWithTab( key .. "=false", indent + 1 )
			end
		elseif type( v ) == "function" then
			break
		elseif type( v ) == "object" then
			break
		elseif type( v ) == "table" or type( v ) == "object" then
			if depth > 1 then
				if type( key ) == "table" or type( key ) == "object" then
					DumpWithTab( "[table]" .. "=", indent + 1 )
				else
					DumpWithTab( k .. "=", indent + 1 )
				end				
				MathUtil_Dump( v, depth - 1, indent + 1 )
			else
				DumpWithTab( k .. " is Table", indent + 1 )
			end
		else
			DumpWithTab( key .. "=" .. v, indent + 1 )
		end
	end
	DumpWithTab( "}", indent )
end


--[[
	set value to table with index increased by degree
--]]
function MathUtil_ReassignEnum( source )
	local index = 1
	for k, v in pairs( source ) do
		source[k] = index
		index = index + 1
	end
end

--[[
	return the table combined by two tables together
--]]
function MathUtil_Merge( left, right, condition )
	if not right then return left end	
	local destination = {}
	for k, v in pairs( left ) do
		if not condition or condition( v ) then
			table.insert( destination, v )
		end
	end
	for k, v in pairs( right ) do
		if not condition or condition( v ) then
			table.insert( destination, v )
		end
	end
	return destination
end

--[[
	Copy Table	
	-- @usage copied = MathUtil_Copy(results)
	-- @usage MathUtil_Copy(results, newcopy)
--]]
function MathUtil_Copy(source, destination)
	if not destination then destination = {} end
	if source then
		for field, value in pairs(source) do
			if value then
				if typeof(value) == "table" then
					destination[field] = {}
					MathUtil_Copy( value, destination[field] )
				else
					--print( "rawset", field, value )
					rawset(destination, field, value )
				end
			end
		end
	end
	return destination
end

--[[
	Shallow copy table
--]]
function MathUtil_ShallowCopy( source, destination )
	if not destination then destination = {} end
	if source then
		for field, value in pairs(source) do
			destination[field] = value
		end
	end
	return destination
end

--[[
	@return return index of the item in the table
	
	@usage 
		list = { 1, 2, 3 }
		if MathUtil_IndexOf( list, 2 ) then
			print( "find" )
		end
--]]
function MathUtil_IndexOf( source, target, name )
	if not source then return nil end
	if not name then
		for k, v in pairs( source ) do
			if v == target then return k end
		end
	else
		for k, v in pairs( source ) do
			if v[name] == target then return k end
		end
	end
	return nil
end

--[[
	@return retrun the data by given value and name

	@usage
		local table = 
		{
			{ key = "11", value = 1 },
			{ key = "22", value = 2 },
		}
		print( MathUtil_FindData( talbe, "11", "key" ) )
		--1
--]]
function MathUtil_FindData( source, target, name )
	if not source then return nil end
	if not name then
		for k, v in pairs( source ) do
			if v == target then return v end
		end
	else
		for k, v in pairs( source ) do
			if v[name] == target then return v end
		end
	end
	return nil
end

function MathUtil_FindDataList( source, target, name )
	local ret = {}
	if not source then return ret end
	if not name then
		for k, v in pairs( source ) do
			if v == target then table.insert( ret, v ) end
		end
	else
		for k, v in pairs( source ) do
			if v[name] == target then table.insert( ret, v ) end
		end
	end
	return ret
end

--[[
	@param descending true/false

	@usage 
		list = { { v = 1 }, { v = 3 }, { v = 5 } 
		MathUtil_Insert( list, { v = 4 }, "v" )
		--output
		--{ { v = 1 }, { v = 3 }, { v = 4 }, { v = 5 } }
]]
function MathUtil_Insert( list, target, name, descending )
	if descending then
		if name then
			for k, v in ipairs( list ) do
				if v[name] < target[name] then
					table.insert( list, k, target )
					return k
				end
			end
		else
			for k, v in ipairs( list ) do
				if v < target then
					table.insert( list, k, target )
					return k
				end
			end
		end
	else
		if name then
			for k, v in ipairs( list ) do
				if v[name] > target[name] then
					table.insert( list, k, target )
					return k
				end
			end
		else
			for k, v in ipairs( list ) do
				if v > target then
					table.insert( list, k, target )
					return k
				end
			end		
		end
	end
	table.insert( list, target )
	return #list - 1
end

--[[
	push target into the back of table without duplicated

]]
function MathUtil_PushBack( list, target, name )
	if not name then
		for k, v in ipairs( list ) do
			if v == target then return false end
		end
	else
		for k, v in ipairs( list ) do
			if v[name] == target then return false end
		end
	end
	table.insert( list, target )
	return true
end

--[[
	This is not really remove, just set id to nil
	
	@param target is the item in the list which should be 'removed'
]]
function MathUtil_RemoveAndReserved( list, target, name )
	if not list then return end
	if not name then
		for k, v in pairs( list ) do
			if v == target then
				list[k] = nil
				return true
			end
		end
	else
		for k, v in pairs( list ) do
			if v[name] == target then
				list[k] = nil
				return true
			end
		end
	end
	return false
end

--[[
	
]]
function MathUtil_Remove( list, target, name )
	if not list then 
		print( "List is invalid", list, target, name )
		return false
	end
	if not name then 
		for k, v in pairs( list ) do
			if v == target then
				table.remove( list, k )
				return true
			end
		end
	else
		for k, v in pairs( list ) do
			if v[name] == target then
				table.remove( list, k )
				return true
			end
		end
	end
	return false
end

--[[
	@usage
	local datas = 
	{
		{ prob = 10, ret = 1 },
		{ prob = 10, ret = 3 },
		{ prob = 20, ret = 5 },
	}
	print( MathUtil_SumIf( datas, nil, nil, "ret" ) )
	--9

	local datas2 = 
	{
		{ prob = 10, ret = 1 },
		{ prob = 10, ret = 3 },
		{ prob = 20, ret = 5 },
	}
	print( MathUtil_SumIf( datas2, "prob", 10, "ret" ) )
	--4

	local datas3 =
	{
		prob = 10, { a = 10, b = 15, c = 20 }
	}
	print( MathUtil_SumIf( datas3[1] ) )
	--4	
--]]
function MathUtil_SumIf( datas, itemName, itemValue, countName )
	local ret = 0	
	for _, data in pairs( datas ) do
		local cur = itemName and data[itemName] or data
		if not itemValue or cur == itemValue then
			ret = ret + ( countName and data[countName] or data )
		end
	end
	return ret
end

function MathUtil_Sum( datas, itemName )
	local number = 0
	for k, v in pairs( datas ) do
		local value = itemName and v[itemName] or v
		number = number + value
	end
	return number
end

function MathUtil_CountIf( datas, condition )
	local number = 0
	for k, v in pairs( datas ) do
		if condition( v ) then
			number = number + 1
		end
	end
	return number
end

--[[
	Return the string name equal the given value in the enum list
]]
function MathUtil_FindName( enumList, value )
	for k, v in pairs( enumList ) do
		if v == value then return k end
	end
	return ""
end

--[[
	Return the key of the right name in the enum list
]]
function MathUtil_FindKey( enumList, value )
	for k, v in pairs( enumList ) do
		if v == value then return k end
	end
	return 0
end

function MathUtil_ClearInvalid( source )
	local destination = {}	
	if source then
		for field, value in pairs(source) do
			table.insert( destination, value )
		end
	end
	return destination
end

--[[
	Find median
]]
function MathUtil_FindMedian( list, keyName )
	local list = {}
	if keyName then
		for k, v in pairs( list ) do
			MathUtil_Insert( list, v[keyName], keyName )
		end
	else
		for k, v in pairs( list ) do
			MathUtil_Insert( list, v )
		end
	end
	local number = #list
	if number == 0 then return 0 end
	return list[math.ceil(number/2)]
end

function MathUtil_Filter( list, condition )
	local ret = {}
	for k, data in ipairs( list ) do
		if condition( data ) then
			table.insert( ret, data )
		end
	end
	return ret
end

--[[
	(Test not pass)Return an array with index limited by the given range
]]
function MathUtil_CreateRandomIndexs( min, max, num )
	local len = math.abs( max - min )
	if max < min then
		min, max = max, min
	end
	local try = 0
	local array = {}
	repeat
		try = try + 1
		local ret = math.random( min, max )
		if not MathUtil_IndexOf( array, ret ) then
			table.insert( array, ret )
		end
		--print( #array, num, try, ret, min, max )
	until #array >= num or try >= len
	
	if #array < num and num < len then
		for k = min, max do
			if not MathUtil_IndexOf( array, k ) then
				table.insert( array, k )
			end
			if #array > num then
				break
			end
		end
	end
	
	return array
end

function MathUtil_CountLength( list )
	local len = 0
	for k, v in pairs( list ) do
		len = len + 1
	end
	return len
end

--[[
--Sqrt Positive Integer Below 10
local _SqrtPIB10 = nil
function MathUtil_SqrtPIBBelow10( number )
	if number <= 0 then return 0 end 
	if number > 10 then return math.sqrt( number ) end
	if not _SqrtPIB10 then
		_SqrtPIB10 = {}
		for k = 1, 100 do
			_SqrtPIB10[k] = { sqrt = math.sqrt( k * 0.1 ) }
		end
	end
	local index = math.ceil( number / 0.1 )	
	--print( number, index, _SqrtPIB10[index].sqrt, math.sqrt( number ) )
	return _SqrtPIB10[index].sqrt
end

local _SqrtPIB1 = nil
function MathUtil_SqrtPIB1( number )
	if number <= 0 then return 0 end 
	if number > 1 then return math.sqrt( number ) end
	if not _SqrtPIB1 then
		_SqrtPIB1 = {}
		for k = 1, 100 do
			_SqrtPIB1[k] = { sqrt = math.sqrt( k * 0.01 ) }
		end
	end
	local index = math.ceil( number / 0.01 )	
	--print( number, _SqrtPIB1[index].sqrt, math.sqrt( number ) )
	return _SqrtPIB1[index].sqrt
end
]]

--[[
	@usage 
		local enum = 
		{
			power = 1,
			speed = 2,	
		}

		list_a = {
			[1] = 100,
			[2] = 50,
		}

		local list = list_a
		local list_b = MathUtil_ConvertKeyToString( enum, list )
		list = list_a
		MathUtil_Dump( list ) 
		--{
		--  1 = 100,
		--  2 = 50,
		--}
		list = list_b
		MathUtil_Dump( list )		
		--{	
		--  speed = 50,
		--  power = 100,
		--}
		
		local list_c = MathUtil_ConvertKeyToID( enum, list_b )
		list = list_c
		MathUtil_Dump( list )
		--{
		--  1 = 100,
		--  2 = 50,
		--}
]]
function MathUtil_ConvertKeyToString( keyEnum, list )
	local newList = {}
	if not list then return newList end
	for k, v in pairs( list ) do	
		newList[MathUtil_FindKey( keyEnum, k )] = v
	end
	return newList
end

-- Reverse from MathUtil_ConvertKeyToString()
function MathUtil_ConvertKeyToID( keyEnum, list )
	local newList = {}	
	if not list then return newList end
	for k, v in pairs( list ) do
		if not keyEnum[k] then
			error( "invalid key=" .. k )
		end
		newList[keyEnum[k]] = v
	end
	return newList
end

-- Convert string in dictionary to id
--[[
	@usage
		local enum = 
		{
			A = 1,
			B = 2,
		}
		local list = 
		{
			"A",
			"B",
		}
		list = MathUtil_ConvertDataStringToID( enum, list )
		MathUtil_Dump( list )
		--{
		--  1 = 1,
		--  2 = 2,
		--}
--]]

function MathUtil_ConvertDataStringToID( keyEnum, list )
	local newList = {}
	for k, v in pairs( list ) do
		newList[k] = keyEnum[v]
	end
	return newList
end

--[[
	Float interpolate

	@usage
	print( MathUtil_Interpolate( 50, 0, 100, 1, 10 )
	-->>5.5
]]
function MathUtil_Interpolate( value, value_min, value_max, dest_min, dest_max )
	return dest_min + ( value - value_min ) * ( dest_max - dest_min ) / ( value_max - value_min )
end

function MathUtil_InterpolateRange( value, value_min, value_max, dest_min, dest_max, min_range, max_range )
	if min_range ~= nil and value < value_min then return min_range end
	if max_range ~= nil and value > value_max then return max_range end
	return dest_min + ( value - value_min ) * ( dest_max - dest_min ) / ( value_max - value_min )	
end

function MathUtil_ConvertKey2ID( oldDatas, enumlist )
	local newDatas = {}
	for k, v in pairs( oldDatas ) do
		newDatas[enumlist[k]] = v
	end
	return newDatas
end


--Permutation a list
--@usage
--  local list = { "A", "B", "C" }
--  MathUtil_Permutation( list, 1, #a, function() print( MathUtil_ToString( list ) ) end )
--  A,B,C
--  A,C,B  
--  B,A,C
--  B,C,A
--  C,B,A
--  C,A,B
function MathUtil_Permutation( list, first, last, fn )
	if first == last then
		fn( list )
		return		
	end

	function SwapPos( list, p1, p2, comment )
		if p1 == p2 then return end
		--print( "#" .. MathUtil_ToString( list ), p1, p2, list[p1], list[p2], comment )
		local t  = list[p1]
		list[p1] = list[p2]
		list[p2] = t
	end

	for k = first, last do
		SwapPos( list, k, first )
		MathUtil_Permutation( list, first + 1, last, fn )
		SwapPos( list, k, first )
	end
end

--Find list item by given value, in default descend, return the item when given value is bigger than item's value
--@usage
--[[
list1 = 
{
	{ score = 90, grade = "A", },
	{ score = 70, grade = "B", },
	{ score = 50, grade = "C", },
	{ score = 0, grade = "D", },
}
list2 = 
{
	{ score = 50, grade = "D", },
	{ score = 70, grade = "C", },
	{ score = 90, grade = "B", },
	{ score = 100, grade = "A", },
}
print( MathUtil_Approximate( 90, list1, "score" ).grade )
print( MathUtil_Approximate( 60, list1, "score" ).grade )
print( MathUtil_Approximate( 30, list1, "score" ).grade )
print( MathUtil_Approximate( 90, list2, "score", true ).grade )
print( MathUtil_Approximate( 60, list2, "score", true ).grade )
print( MathUtil_Approximate( 30, list2, "score", true ).grade )
--A
--C
--D
--A
--C
--D
]]
function MathUtil_Approximate( value, list, name, ascend )
	local default
	if not ascend then
		for key, item in pairs( list ) do
			if value >= ( name and item[name] or key ) then
				return item
			end
			default = item
		end
	else
		for key, item in pairs( list ) do
			if value < ( name and item[name] or key ) then
				return item
			end
			default = item
		end
	end
	return default
end

Dump = MathUtil_Dump