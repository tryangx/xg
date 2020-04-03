----------------------------------------------
--[[
	Tracker helper

	@useage 
		Track_Data( "Number", 5 )
		Track_Data( "Number", 10 )
		Track_Reset( true )
--]]
----------------------------------------------
local _trackerCaches = {}
local _trackerStacks = {}

local _trackerHis = {}


----------------------------------------------
--We can use below functions to track the history data changed
--@usage
--    Track_HistoryRecord( "money", { rmb = 1000 date = "2018-1-1" } )
--    Track_HistoryRecord( "money", { rmb = 1500 date = "2018-2-1" } )
--    Track_HistoryDump( "money", function( name, data )
--      print( name .. "=" .. data.rmb .. " date=" .. data.date )
--    end
--    
--    -- money=1000 date=2018-1-1
--    -- money=1500 date=2018-2-1
--
function Track_HistoryRecord( name, datas )
	if not _trackerHis[name] then
		_trackerHis[name] = {}
	end
	table.insert( _trackerHis[name], datas )
end


----------------------------------------------
function Track_HistoryDump( name, fn )
	for key, datas in pairs( _trackerHis ) do
		if not name or key == name then
			for _, item in pairs( datas ) do
				fn( key, item )
			end
		end
	end
end

----------------------------------------------
function Track_Pop( name )
	if not _trackerStacks[name] then _trackerStacks[name] = {} end
	_trackerCaches = _trackerStacks[name]
end


----------------------------------------------
--This function use to track the data what will change in the future operation
--@usage 
--  local money = 10
--  Track_Data( "money", money )
--  money = 20
--  Track_Data( "money", money )
--  Track_Dump()
--
function Track_Data( name, data, need )
	if _trackerCaches[name] then
		_trackerCaches[name].current = data or 0
		if need then _trackerCaches[name].need = need end
	else
		_trackerCaches[name] = {}
		_trackerCaches[name].init    = data or 0
		_trackerCaches[name].current = data or 0
		_trackerCaches[name].need    = need
	end
end


----------------------------------------------
function Track_Table( name, t )
	for k, v in pairs( t ) do
		local n = name .. "_" .. k
		local t = typeof(v)
		if t == "number" then
			if _trackerCaches[n] then
				_trackerCaches[n].current = v
			else
				_trackerCaches[n] = {}
				_trackerCaches[n].init    = v
				_trackerCaches[n].current = v
				--print( n, _trackerCaches[n].init, _trackerCaches[n].current )
			end
		elseif t == "table" then
		end
	end
end


----------------------------------------------
function Track_Dump( name, showall )
	print( "[TRACK_DUMP]=" .. ( name or "" ) )
	local caches = name and _trackerStacks[name] or _trackerCaches
	for k, v in pairs( caches ) do
		local delta = v.current - v.init
		if showall or delta ~= 0 then
			local percent = ""
			local percent_value = v.init > 0 and math.ceil( delta * 100 / v.init ) or 0
			if percent_value > 0 then
				percent = "(" .. percent_value .. "%)"
			end
			local content = StringUtil_Abbreviate( k, 16 ) .. "= " .. v.init .. "->" .. v.current .. ( delta > 0 and " +" .. delta or ( delta < 0 and " -" .. delta or "" ) ) .. percent
			if v.need then
				content = content .. " req=" ..  v.need
			end
			print( content )
		end
	end
	print( "[DUMP_END]" )
	--InputUtil_Pause()
end

----------------------------------------------
function Track_Reset()
	_trackerCaches = {}
end