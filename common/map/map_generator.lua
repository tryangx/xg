-------------------------------------------
--   07 08 09
--  18 01 02 10
--17 06 00 03 11
--  16 05 04 12
--   15 14 13
-------------------------------------------
PLOTADJACENTOFFSET_1 = 
{
	{ x = -1, y = -1, distance = 1, },
	{ x = 0,  y = -1, distance = 1, },
	{ x = 1,  y = 0,  distance = 1, },
	{ x = 0,  y = 1,  distance = 1, },
	{ x = -1, y = 1,  distance = 1, },
	{ x = -1, y = 0,  distance = 1, },	
}

PLOTADJACENTOFFSET_2 = 
{
	{ x = -1, y = -2, distance = 2, },
	{ x = 0,  y = -2, distance = 2, },
	{ x = 1,  y = -2, distance = 2, },
	{ x = 1,  y = -1, distance = 2, },
	{ x = 2,  y = 0,  distance = 2, },
	{ x = 1,  y = 1,  distance = 2, },
	{ x = 1,  y = 2,  distance = 2, },
	{ x = 0,  y = 2,  distance = 2, },
	{ x = -1, y = 2,  distance = 2, },
	{ x = -2, y = 0,  distance = 2, },
	{ x = -2, y = -1, distance = 2, },
}

PLOTADJACENTOFFSET_3 = 
{
	{ x = -2, y = -3, distance = 3, },
	{ x = -1, y = -3, distance = 3, },
	{ x = 0,  y = -3, distance = 3, },
	{ x = 1,  y = -3, distance = 3, },	
	{ x = 2,  y = -2, distance = 3, },
	{ x = 2,  y = -1, distance = 3, },
	{ x = 3,  y = 0,  distance = 3, },
	{ x = 2,  y = 1,  distance = 3, },
	{ x = 2,  y = 2,  distance = 3, },	
	{ x = 1,  y = 3,  distance = 3, },
	{ x = 0,  y = 3,  distance = 3, },
	{ x = -1, y = 3,  distance = 3, },	
	{ x = -2, y = 3,  distance = 3, },	
	{ x = -2, y = 2,  distance = 3, },
	{ x = -3, y = 1,  distance = 3, },	
	{ x = -3, y = 0,  distance = 3, },
	{ x = -3, y = -1, distance = 3, },
	{ x = -2, y = -2, distance = 3, },	
}

local function Map_CreateKey( x, y )
	return y * 10000 + x
end

local function Map_ParseKey( id )
	return id % 10000, math.floor( id / 10000 )
end


--------------------------------------------------------------------------------------
-- @usage
--   plotTypes = 
--   {
--     { type="HILLS", terrain="PLAINS",    feature="WOODS", prob=1000 },
--     ...
--   }
--------------------------------------------------------------------------------------
local function Map_GeneratePlotType( plot, plotTypes )
	local index  = Random_GetIndex_Sync( plotTypes, "prob" )
	local item   = plotTypes[index]
	plot.type    = item.type
	plot.terrain = item.terrain
	plot.feature = item.feature
	--Dump( plot ) InputUtil_Pause( "plot")
end


--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
local function Map_AddCityToPlot( map, city )
	local plot = map:GetPlot( city.x, city.y )
	if not plot then DBG_Error( "Plot is invalid!" ) return end
	if plot.additions["DISTRICT"] then DBG_Error( "Plot has a district! x=" .. city.x .. ",y=" .. city.y ) return end
	plot.additions["DISTRICT"] = city.id

	--find the plots belonged to the city
	local offsets = PLOTADJACENTOFFSET_1
	if city.lv == 2 then offsets = PLOTADJACENTOFFSET_2 end
	local leftPlot = city.numOfPlot or 99
	local plots = {}
	for k, offset in ipairs( offsets ) do
		local plot = map:GetPlot( city.x + offset.x, city.y + offset.y )
		if plot and not plot.additions["DISTRICT"] then
			leftPlot = leftPlot - 1
			table.insert( plots, plot )
		end
		if leftPlot <= 0 then break end
	end

	for _, cityPlot in ipairs( plots ) do
		cityPlot.additions["DISTRICT"] = city.id
	end

	--InputUtil_Pause( "add city", city.x, city.y )
	local data = {}
	data.name = city.name
	data.x  = city.x
	data.y  = city.y
	data.id = Map_CreateKey( data.x, data.y )
	return data
end


-------------------------------------------
--
--
--
-------------------------------------------
MAP_GENERATOR = class()

-------------------------------------------
function MAP_GENERATOR:GetPlot( x, y )
	local key = Map_CreateKey( x, y )
	return self.plots[key]
end


function MAP_GENERATOR:GetPlotById( id )
	return self.plots[id]
end


function MAP_GENERATOR:GetAdjoinPlots( x, y, list, fn )
	if not list then list = {} end
	for _, offset in ipairs( PLOTADJACENTOFFSET_1 ) do
		local adjaPlot = self:GetPlot( x + offset.x, y + offset.y )		
		if adjaPlot and ( not fn or fn( adjaPlot ) ) then
			table.insert( list, adjaPlot )
		end
	end
	return list
end


-------------------------------------------
-------------------------------------------
--[[
function MAP_GENERATOR:MatchCondition( plot, condition )
	local x = Asset_Get( plot, PlotAssetID.X )
	local y = Asset_Get( plot, PlotAssetID.Y )

	function CheckNearPlot( distance, fn )
		distance = distance or 1
		local matchCondition = false
		for _, offset in ipairs( PlotAdjacentOffsets ) do
			if offset.distance <= distance then
				local adjaPlot = self:GetPlot( x + offset.x, y + offset.y )
				if adjaPlot and fn( adjaPlot ) then matchCondition = true break end
			end
		end
		if not matchCondition then return false end
		return true
	end
	function CheckAwayFromPlot( distance, fn )
		distance = distance or 1
		local matchCondition = true
		for k, offset in ipairs( PlotAdjacentOffsets ) do
			if offset.distance <= distance then
				local adjaPlot = self:GetPlot( x + offset.x, y + offset.y )
				if adjaPlot and fn( adjaPlot ) then matchCondition = false break end
			end
		end
		if not matchCondition then return false end
		return true
	end

	if condition.type == ResourceCondition.CONDITION_BRANCH then
		for k, subCond in ipairs( condition.value ) do
			if not self:MatchCondition( plot, subCond ) then				
				return false
			end
		end
	elseif condition.type == ResourceCondition.PROBABILITY then
		if Random_GetInt_Sync( 1, 10000 ) > condition.value then return false end
	elseif condition.type == ResourceCondition.PLOT_TYPE then
		if condition.value == "LIVING" then				
			if plot:GetPlotType() ~= PlotType.HILLS and plot:GetPlotType() ~= PlotType.LAND then					
				return false
			end
		elseif plot:GetPlotType() ~= PlotType[condition.value] then
			return false
		end
	elseif condition.type == ResourceCondition.PLOT_TERRAIN_TYPE then
		if plot:GetTerrain() ~= PlotTerrainType[condition.value] then return false end
	elseif condition.type == ResourceCondition.PLOT_FEATURE_TYPE then
		if plot:GetFeature() ~= PlotFeatureType[condition.value] then return false end
	elseif condition.type == ResourceCondition.PLOT_TYPE_EXCEPT then
		if condition.value == "LIVING" then				
			if plot:GetPlotType() == PlotType.HILLS or plot:GetPlotType() == PlotType.LAND then
				return false
			end
		elseif plot:GetPlotType() == PlotType[condition.value] then
			return false
		end
	elseif condition.type == ResourceCondition.PLOT_TERRAIN_TYPE_EXCEPT then
		if plot:GetTerrain() == PlotTerrainType[condition.value] then return false end
	elseif condition.type == ResourceCondition.PLOT_FEATURE_TYPE_EXCEPT then				
		if condition.value == "ALL" then
			if plot:GetFeature() ~= PlotFeatureType.NONE then
				return false
			end
		elseif plot:GetFeature() == PlotFeatureType[condition.value] then
			return false
		end
	elseif condition.type == ResourceCondition.NEAR_PLOT_TYPE then
		CheckNearPlot( 1, function( adjaplot )
			return adjaplot:GetPlotType() == PlotType[condition.value]
		end )
	elseif condition.type == ResourceCondition.NEAR_TERRAIN_TYPE then
		return CheckNearPlot( 1, function( adjaplot )
			return adjaplot:GetTerrain() == PlotTerrainType[condition.value]
		end )
	elseif condition.type == ResourceCondition.NEAR_FEATURE_TYPE then
		return CheckNearPlot( 1, function( adjaplot )
			return adjaplot:GetFeature() == PlotFeatureType[condition.value]
		end )
	elseif condition.type == ResourceCondition.AWAY_FROM_CITY_TYPE then
		return CheckAwayFromPlot( 1, function( adjaplot )
			return adjaplot:GetPlotType() == PlotType[condition.value]
		end )
	elseif condition.type == ResourceCondition.AWAY_FROM_TERRAIN_TYPE then
		return CheckAwayFromPlot( 1, function( adjaplot )
			return adjaplot:GetTerrain() == PlotTerrainType[condition.value]
		end )
	elseif condition.type == ResourceCondition.AWAY_FROM_FEATURE_TYPE then
		return CheckAwayFromPlot( 1, function( adjaplot )
			return adjaplot:GetFeature() == PlotFeatureType[condition.value]
		end )
	else
		return false
	end
	return true
end

function MAP_GENERATOR:FindPlotSuitable( conditions )
	local plotList = {}
	Asset_Foreach( self, MapAssetID.PLOTS, function ( plot )
		local res = Asset_Get( plot, PlotAssetID.RESOURCE )
		if res then return end
		local matchCondition = true
		if conditions and #conditions > 0 then
			matchCondition = false						
			for k, condition in pairs( conditions ) do
				if self:MatchCondition( plot, condition ) then					
					matchCondition = true
				end
			end
		end
		if matchCondition then
			table.insert( plotList, plot )
		end
	end )
	return plotList
end

function MAP_GENERATOR:GeneratePlotResource( items )
	local plotNunmber = self._size

	for k, item in pairs( items ) do
	
		-- calculate how many item need can been put into the map
		local percent = item.percent or 0
		item.count = math.ceil( plotNunmber * percent * 0.01 )

		-- put resource into the map
		local resource = ResourceTable_Get( item.id )
		if resource then
			local plotList = self:FindPlotSuitable( resource.conditions )
			plotList = MathUtil_Shuffle_Sync( plotList )
			for number = 1, #plotList do
				if number > item.count then break end				
				local plot = plotList[number]
				Asset_Set( plot, PlotAssetID.RESOURCE, item.id )
				--print( "put ", resource.name, "on", Asset_Get( plot, PlotAssetID.X ), Asset_Get( plot, PlotAssetID.Y ) )
			end
		end
	end
end
]]


-------------------------------------------
--
-- Generate the map's plot data
--
-- @params data is the user custom parameters
-- @usage
--   data =
--   {
--     width  = 100,
--     heigth = 100,
--     plotTypes = 
--     {
--       { type="LAND",  terrain="PLAINS",    feature="",      prob=1000 },
--       { type="LAND",  terrain="GRASSLAND", feature="",      prob=1000 },
--       { type="LAND",  terrain="GRASSLAND", feature="MARSH", prob=1000 },
--       { type="HILLS", terrain="PLAINS",    feature="WOODS", prob=1000 },
--     }
--   }
-------------------------------------------
function MAP_GENERATOR:GeneratePlots( data )	
	if data.width > 10000 then DBG_Error( "Maximum width is 10000" ) return end
	-- initialize
	self.plots  = {}
	self.width  = data.width
	self.height = data.height
	self.numOfPlot = self.width * self.height
	for y = 1, data.height do
		for x = 1, data.width do
			local plot = {}
			plot.x = x
			plot.y = y
			plot.additions = {}
			Map_GeneratePlotType( plot, data.plotTypes )
			self.plots[Map_CreateKey(x, y)] = plot			
		end
	end

	--[[
	self:GeneratePlotResource( datas.strategicResources )
	self:GeneratePlotResource( datas.bonusResources )
	self:GeneratePlotResource( datas.luxuryResources )
	--self:GeneratePlotResource( artificialResourceItems )	
	]]
end


-------------------------------------------
-- @usage
--   data =
--   {
--     
--     cities = 
--     {
--       id = "1", --a key to the city data
--       name = "京城",
--       x = 1, y = 1,
--       lv=1, --1 means village/town/city, 2 means city/metro
--     },
--   }
-------------------------------------------
function MAP_GENERATOR:GenereateCities( data )
	--1st, allocate plots to city
	self.cities = {}
	for _, city in ipairs( data.cities ) do		
		table.insert( self.cities, Map_AddCityToPlot( self, city ) )
	end

	--2nd, todo
end


-------------------------------------------
function MAP_GENERATOR:Draw()
	local rowWidth = 3
	local colWidth = 3

	local printer = function( plot )
		local content = ""
		content = content .. string.sub( plot.type, 1, 1 )
		if plot.additions["DISTRICT"] then
			content = content .. "D"
		end
		return StringUtil_Abbreviate( content, colWidth )
	end

	--row
	local header = string.rep( " ", rowWidth )
	for x = 1, self.width do
		header = header .. StringUtil_Abbreviate( x, colWidth )
	end
	print( header )

	for y = 1, self.height do
		local row = StringUtil_Abbreviate( y, rowWidth )
		for x = 1, self.width do
			row = row .. printer( self:GetPlot( x, y ) )
		end
		print( row )
	end
end