------------------------------------------
function String_ToStr( data, item )
	if not data then
		return "[??]"
	end
	if typeof( data ) == "number" then
		return "" .. data
	end
	return data[item] or "[??]"
end

------------------------------------------
function StringUtil_Trim( str, finalLength, curLength )
	local ret
	local length = string.len( str )
	if finalLength then
		if length < finalLength then
			ret = str .. string.rep( "-", finalLength - length )
		else
			ret = string.sub( str, 1, finalLength )
		end
	elseif cutLength then
		if curLength >= length then
			ret = ""
		else
			ret = string.sub( str, 1, length - curLength )
		end
	end
	return ret
end

------------------------------------------
function StringUtil_Abbreviate( str, length )
	local ret = ""
	local len = string.len( str )
	if len < length then
		ret = str
	else
		local abStr = ""
		local left = length
		for word in string.gmatch( str, "%a+" ) do
			local c = string.sub( word, 1, 1 )		
			abStr = abStr .. c
			if left >= 1 then left = left - 1 else break end
		end
		if left > 0 then
			--ret = ret .. string.sub( str, len - left + 1, len )
			ret = ret .. string.sub( str, 1, length )
		else
			ret = abStr
		end
	end
	for k = 1, length - len do
		ret = ret .. " "
	end
	return ret
end

------------------------------------------
function StringUtil_Concat( ... )
	local content = ""
	local args = { ... }
	for i = 1, #args do
		local type = typeof( args[i] )
		if type == "string" or type == "number" then
			content = content .. args[i] .. " "
		end
	end
	return content
end