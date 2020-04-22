----------------------------------------------------
--
--  Time
--
----------------------------------------------------
MONTH_IN_YEAR     = 12
MONTH_IN_HALFYEAR = 6
MONTH_IN_SEASON   = 3
DAY_IN_MONTH      = 30
DAY_IN_SEASON     = DAY_IN_MONTH * MONTH_IN_SEASON
DAY_IN_HALF_YEAR  = math.floor( MONTH_IN_YEAR * DAY_IN_MONTH * 0.5 )
DAY_IN_YEAR       = MONTH_IN_YEAR * DAY_IN_MONTH
HOUR_IN_DAY       = 24


----------------------------------------------------
-- 
-- Set the time
--
--   There're two way to set the time.
--   1. By specified year, month, day
--   2. By a date value which means a huge number
--
----------------------------------------------------
function Time_CalcDateValue( year, month, day, hour, beforeChrist )
	local ret = 0
	ret = ret + ( year - 1 ) * MONTH_IN_YEAR * DAY_IN_MONTH * HOUR_IN_DAY
	ret = ret + ( month - 1 ) * DAY_IN_MONTH * HOUR_IN_DAY
	ret = ret + ( day - 1 ) * HOUR_IN_DAY
	if hour then ret = ret + hour end
	return beforeChrist == 1 and -ret or ret
end


----------------------------------------------------
function Time_ConvertDateByValue( dateValue )
	local beforeChrist = 0
	if dateValue < 0 then beforeChrist = 1 dateValue = -dateValue end
	local year  = math.floor( dateValue / ( MONTH_IN_YEAR * DAY_IN_MONTH * HOUR_IN_DAY ) )
	dateValue   = dateValue - year * ( MONTH_IN_YEAR * DAY_IN_MONTH * HOUR_IN_DAY )
	local month = math.floor( dateValue / ( DAY_IN_MONTH * HOUR_IN_DAY ) )
	dateValue   = dateValue - month * ( DAY_IN_MONTH * HOUR_IN_DAY )
	local day   = math.floor( dateValue / HOUR_IN_DAY )
	local hour  = ( dateValue - day * HOUR_IN_DAY )	
	return year + 1, month + 1, day + 1, hour, beforeChrist
end


----------------------------------------------------
function Time_CreateDateDesc( year, month, day, hour, beforeChrist, byDay, byMonth, byHour )
	local content = ( beforeChrist == 1 and "BC " or "AD " )
	--[[
	year = year + 1
	month = month + 1
	day = day + 1
	hour = hour + 1
	]]
	if byHour then
		content = content..year.."Y"..( month < 10 and "0"..month or month ).."M"..( day < 10 and "0"..day or day ).."D"..( hour < 10 and "0"..hour or hour ).."H"
	elseif byDay then
		content = content..year.."Y"..( month < 10 and "0"..month or month ).."M"..( day < 10 and "0"..day or day ).."D"
	elseif byMonth then
		content = content..year.."Y"..( month < 10 and "0"..month or month ) .."M"
	else
		content = content..year.."Y" 
	end
	return content
end


function Time_CreateDateDescByValue( dateValue, byDay, byMonth, byHour )
	if not dateValue then return "" end
	if not byMonth then byMonth = true end
	if not byDay then byDay = true end
	if not byHour then byHour = true end
	local year, month, day, hour, beforeChrist = Time_ConvertDateByValue( dateValue )
	return Time_CreateDateDesc( year, month, day, hour, beforeChrist, byDay, byMonth, byHour )
end


----------------------------------------------------
----------------------------------------------------
TIME = class()

function TIME:__init()
	self.year  = 2000
	--month from 1 ~ 12
	self.month = 1
	--day from 1~30
	self.day   = 1
	--hour form 0 ~ 23
	self.hour  = 0
	--1 or 0
	self.beforeChrist = 0
	--manual compute without datas?
	self.leapYear = 0

	--flag
	self.passYear  = false
	self.passMonth = false
	self.passDay   = false
end

function TIME:Init()
end

-- TIME:SetDate( 2000, 1, 1, false )
function TIME:SetDate( year, month, day, hour, beforeChrist )
	self.month = month or self.month	
	self.day   = day or self.day	
	self.year  = math.abs( year or self.year )	
	self.hour  = hour or self.hour
	self.beforeChrist = beforeChrist

	self.passYear  = true
	self.passMonth = true
	self.passDay   = true
end


----------------------------------------------------
--
-- Get the year
--
----------------------------------------------------
function TIME:GetYear()
	return self.year
end


----------------------------------------------------
--
-- Get the day
--
-- @return the month's range is 1 ~ 12
--
----------------------------------------------------
function TIME:GetMonth( delta )
	local month = self.month
	if delta then
		month = month + delta
		while month > MONTH_IN_YEAR do
			month = month - MONTH_IN_YEAR
		end
	end
	return month
end


----------------------------------------------------
--
-- Get the day
--
-- @return the day's range is 1~31
--
----------------------------------------------------
function TIME:GetDay()
	return self.day
end


----------------------------------------------------
--
-- Get the value of the time data
--
-- @return a huge number
--
----------------------------------------------------
function TIME:GetDateValue()
	return Time_CalcDateValue( self.year, self.month, self.day, self.hour, self.beforeChrist )
end


function TIME:SetDateByValue( dateValue )
	self:SetDate( Time_ConvertDateByValue( dateValue ) )
end


----------------------------------------------------
-- 
-- Create time description
--
--   Return in different formats, such as YYMMDD
--
----------------------------------------------------
function TIME:CreateDesc( byDay, byMonth, byHour )
	if not byMonth then byMonth = true end
	if not byDay then byDay = true end
	if not byHour then byHour = true end
	return Time_CreateDateDesc( self.year, self.month, self.day, self.hour, self.beforeChrist, byDay, byMonth, byHour )
end


function TIME:ToString()
	return self:CreateDesc()
end


----------------------------------------------------
function TIME:Update()
	self.passYear  = false
	self.passMonth = false
	self.passDay   = false
end


----------------------------------------------------
function TIME:ElapseYear( passYear )
	self.passYear  = true
	self.passMonth = true
	self.passDay   = true
	if not passYear then passYear = 1 end
	if self.beforeChrist == 1 then
		--e.g
		--   current year is BC 3
		--   pass 10 year
		--   the new date should be AD 7
		if self.year > passYear then
			self.year = self.year - passYear
		else
			self.year = passYear - self.year + 1
			self.beforeChrist = 0
		end
	else
		self.year = self.year + 1
	end	
end


----------------------------------------------------
--
-- Time operation, pass a month
--
----------------------------------------------------
function TIME:ElapseMonth( passMonth )
	self.passMonth = true
	self.passDay   = true
	self.month = self.month + ( passMonth or 1 )
	while self.month > MONTH_IN_YEAR do
		self.month = self.month - MONTH_IN_YEAR
		self:ElapseYear( 1 )
	end
end


----------------------------------------------------
--
-- Time operation, pass a day
--
----------------------------------------------------
function TIME:ElapseDay( passDay )
	self.passDay = true
	self.day  = self.day + ( passDay or 1 )
	while self.day > DAY_IN_MONTH do
		self.day = self.day - DAY_IN_MONTH
		self:ElapseMonth( 1 )
	end
end


----------------------------------------------------
--
-- Time operation, pass a hour
--
----------------------------------------------------
function TIME:ElapseHour( passHour )
	self.hour = self.hour + ( passHour or 1 )
	while self.hour >= HOUR_IN_DAY do
		self.hour = self.hour - HOUR_IN_DAY
		self:ElapseDay( 1 )
	end
end


----------------------------------------------------
--
-- Calculate the difference years between the given
-- year and current time.
--
-- @return number of the difference years
--
----------------------------------------------------
function TIME:CalcDiffYear( year, beforeChrist )
	year = math.abs( year )
	print( "diff bc", beforeChrist, self.beforeChrist )
	if beforeChrist ~= self.beforeChrist then		
		return year + self.year
	end
	return math.abs( year - self.year )
end


----------------------------------------------------
--
-- Calculate the difference years between the given
-- time and current time.
--
-- @return number of the difference years
--
----------------------------------------------------
function TIME:CalcDiffYearByDate( dateValue )
	if not dateValue then return 0 end
	local year, month, day, hour, beforeChrist = Time_ConvertDateByValue( dateValue )	
	return self:CalcDiffYear( year, beforeChrist )
end


----------------------------------------------------
--
-- Calculate the difference months between the given
-- time and current time.
--
-- @return number of the difference months
--
----------------------------------------------------
function TIME:CalcDiffMonthByDate( dateValue )	
	if not dateValue then return 0 end
	local year, month, day, hour, beforeChrist = Time_ConvertDateByValue( dateValue )
	
	if beforeChrist ~= self.beforeChrist then
		if beforeChrist == 1 then
			local totalMonth1 = ( year - 1 ) * MONTH_IN_YEAR + ( MONTH_IN_YEAR - month )
			local totalMonth2 = ( self.year - 1 ) * MONTH_IN_YEAR + self.month
			return totalMonth1 + totalMonth2
		elseif self.beforeChrist == 1 then
			local totalMonth1 = ( year - 1 ) * MONTH_IN_YEAR + month
			local totalMonth2 = ( self.year - 1 ) * MONTH_IN_YEAR + ( MONTH_IN_YEAR - self.month )
			return totalMonth1 + totalMonth2
		end		
	end
	local totalMonth1 = ( year - 1 ) * MONTH_IN_YEAR + month
	local totalMonth2 = ( self.year - 1 ) * MONTH_IN_YEAR + self.month
	return math.abs( totalMonth2 - totalMonth1 )
end


----------------------------------------------------
--
-- calculate the difference days between two time
--
----------------------------------------------------
local function CalcDiffDayByDate( y1, m1, d1, b1, y2, m2, d2, b2 )
	local diffDays = 0

	if b2 ~= b1 then
		if beforeChrist == 1 then
			local totalDays1 = ( y2 - 1 ) * MONTH_IN_YEAR * DAY_IN_MONTH + ( MONTH_IN_YEAR - m2 ) * DAY_IN_MONTH + ( DAY_IN_MONTH - d2 )
			local totalDays2 = ( y1 - 1 ) * MONTH_IN_YEAR * DAY_IN_MONTH + ( m1 - 1 ) * DAY_IN_MONTH + d1
			return totalDays1 + totalDays2
		else
			local totalDays1 = ( y2 - 1 ) * MONTH_IN_YEAR * DAY_IN_MONTH + ( m2 - 1 ) * DAY_IN_MONTH + d2
			local totalDays2 = ( y1 - 1 ) * MONTH_IN_YEAR * DAY_IN_MONTH + ( MONTH_IN_YEAR - m1 ) * DAY_IN_MONTH + ( DAY_IN_MONTH - d1 )
			return totalDays1 + totalDays2
		end		
	end
	
	local totalDays1 = ( y2 - 1 ) * MONTH_IN_YEAR * DAY_IN_MONTH + ( m2 - 1 ) * DAY_IN_MONTH + d2
	local totalDays2 = ( y1 - 1 ) * MONTH_IN_YEAR * DAY_IN_MONTH + ( m1 - 1 ) * DAY_IN_MONTH + d1
	return math.abs( totalDays2 - totalDays1 )
end


----------------------------------------------------
--
-- Calculate the difference days between the given 
-- time and current time.
--
-- @return number of the difference days
--
----------------------------------------------------
function TIME:CalcDiffDayByDateValue( dateValue )
	if not dateValue then return 0 end
	local year, month, day, hour, beforeChrist = Time_ConvertDateByValue( dateValue )
	return CalcDiffDayByDate( self.year, self.month, self.day, self.beforeChrist, year, month, day, beforeChrist )
end


----------------------------------------------------
--
-- Calculate the difference days between two times
--
-- @return number of the difference days
--
----------------------------------------------------
function TIME:CalcDiffDayByDateValues( dateValue1, dateValue2 )
	local year1, month1, day1, hour1, beforeChrist1 = Time_ConvertDateByValue( dateValue1 )
	local year2, month2, day2, hour2, beforeChrist2 = Time_ConvertDateByValue( dateValue2 )
	return CalcDiffDayByDate( year1, month1, day1, beforeChrist1, year2, month2, day2, beforeChrist2 )
end


----------------------------------------------------
-- Test Case
----------------------------------------------------
--[[
t1 = TIME()
t2 = TIME()

t1:SetDate( 1, 1, 1, 0, 0 )
t2:SetDate( 3, 1, 1, 0, 0 )
print( "diff", t1:CalcDiffDayByDateValue( t2:GetDateValue() ) )

t = TIME()
local times = 0
while( 1 ) do
	times = times + 1
	local v = t:GetDateValue()
	print( v, t:CreateDateDescByValue( v ) )
	t:ElapseMonth()
	if times % 30 == 0 then InputUtil_Pause() end
end
--]]