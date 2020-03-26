----------------------------------
-- @usage
-- 
-- Menu_PopupMenu( 
--			{ { c = 'c', content = "Test Button", fn = function ()
--				print( "select c" )
--			end } }
--			, "Test Menu" )
--
-- Menu_PopupMultiSelMenu( 
--			{
--				 { c = 'a',  content = "Test Button", fn = function () print( "test1" ) end },
--				 { c = 'b',  content = "Test Button", fn = function () print( "test2" ) end }, 
--				 { c = 'ab', content = "Test Button", fn = function () print( "test3" ) end }
--			}
--			, "Test Menu" )
--
----------------------------------
local _checks = nil
local _minSelection = 1
local _hint
local _options
local _defaultOption

----------------------------------
----------------------------------
local function Menu_SetHint( hint )
	_hint = hint
end


----------------------------------
----------------------------------
local function Menu_SetKeys( keys )	
	_options = keys
end


----------------------------------
----------------------------------
local function Menu_ShowMenu( multi )
	_defaultKey = nil
	for _, option in pairs( _options ) do
		if option.c then
			print( "["..option.c.."]" .. ( option.content and option.content or "" ) )
		else
			_defaultKey = option
		end
	end
end


----------------------------------
----------------------------------
local function Menu_ShowMultiMenu()
	for _, option in pairs( _options ) do
		if option.c then
			local status = "o"
			if not _checks[k] or _checks[k] == 0 then
				status = ""
			end
			print( "[" .. status .. "]["..option.c.."]" .. ( option.content or "" ) )
		end
	end
	print( "[X]End" )
end


----------------------------------
----------------------------------
local function Menu_SingleSelect()
	if #_options == 0 then return end
	print( "[MENU]MAKE YOUR CHOICE:" )
	local c = InputUtil_ReceiveInput()
	for _, option in pairs( _options ) do
		if _defaultKey and c == "" then			
			return _defaultoption.fn( key )
		elseif option.c then
			if c == string.upper( option.c ) or c == string.lower( option.c ) then				
				return option.fn( key )
			end
		end
	end
	--print( "[MENU]Invalid input!" )
	return Menu_SingleSelect()
end


----------------------------------
----------------------------------
local function Menu_MultiSelect()
	if #_options == 0 then return end
	Menu_ShowMultiMenu( true )
	print( "[MENU]MAKE YOU CHOICES:" )
	print( "========== Single Menu ===========" )
	local c = InputUtil_ReceiveInput()
	for _, option in pairs( _options ) do
		if c == string.upper( option.c ) or c == string.lower( option.c ) then
			option.fn( option )
			if not _checks[k] or _checks[k] == 0 then
				_checks[k] = 1
			elseif _checks[k] == 1 then
				_checks[k] = 0
			end
			return Menu_MultiSelect()
		end
		if c == "x" or c == "X" then
			local count = 0
			for _, check in ipairs( _checks ) do
				if check == 1 then count = count + 1 end
			end
			if count < _minSelection then
				print( "[MENU]Please choice at least " .. _minSelection .. " selection" )
				return Menu_MultiSelect()
			end
			return false
		end
	end
	--print( "[MENU]Invalid input!" )
	return Menu_MultiSelect()
end


----------------------------------
-- Single Option
----------------------------------
function Menu_PopupMenu( keys, title, params )
	if #keys <= 0 then DBG_Error( "Menu needs at least one option" ) return end
	print( "========== Single Menu ===========" )
	if title then print( "### " .. title .. " ###" ) end	
	if _hint then print( _hint ) end
	Menu_SetKeys( keys )
	Menu_ShowMenu()
	return Menu_SingleSelect()
end


----------------------------------
-- Multile Option
----------------------------------
function Menu_PopupMultiSelMenu( keys, title, params )
	if #keys <= 0 then DBG_Error( "Menu needs at least one option" ) return end
	print( "========= Multi Menu ==========" )
	if title then print( "### " .. title .. " ###" ) end	
	if _hint then print( _hint ) end
	_minSelection = 1
	if params then
		if params.minOptions and params.minOptions > 1 then
			_minSelection = math.min( #keys, minOptions )
		end
	end
	print( "[MENU]SELECT AT LEAST=", _minSelection )
	_checks = {}
	Menu_SetKeys( keys )
	return Menu_MultiSelect()	
end