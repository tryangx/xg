---------------------------------------
-- Global data
CurrentMap = nil

---------------------------------------
---------------------------------------
MAP_COMPONENT = class()

---------------------------------------
MAP_PROPERTIES = 
{
	width  = { type="NUMBER" },
	height = { type="NUMBER" },
	plots  = { type="DICT" },
	cities = { type="LIST" },
}

---------------------------------------
function MAP_COMPONENT:__init()
	self.map    = MAP_GENERATOR()
	self.router = MAP_ROUTER()
end

---------------------------------------
function MAP_COMPONENT:Activate()
	local cmp = self
	ECS_AddListener( self, "Get", nil, function( ... ) return cmp end )

	CurrentMap = self

	self.map.width  = self.width
	self.map.height = self.height
	self.map.plots  = self.plots
	self.map.cities = self.cities
end

---------------------------------------
function MAP_COMPONENT:Dectivate()
	local cmp = self
	ECS_RemoveListener( self, "Get", nil, function( ... ) return cmp end )

	CurrentMap = nil
end

---------------------------------------
function MAP_COMPONENT:GetPlot( x, y )	
	return self.map:GetPlot( x, y )
end

---------------------------------------
function MAP_COMPONENT:GetPlotById( id )
	return self.map:GetPlotById( id )
end

function MAP_COMPONENT:GetCity( id )
	return self.cities[id]
end

------------------------------------------------------------
function MAP_COMPONENT:Setup( data )
	local router = self.router
	local map    = self.map
	--Find path
	function WeightScale( plot )		
		local weight = 0
		if plot then
			weight = weight + PLOT_WEIGHT[plot.type]
			weight = weight + ( plot.terrain and PLOT_WEIGHT[plot.terrain] or 0 )
			weight = weight + ( plot.feature and PLOT_WEIGHT[plot.feature] or 0 )
		else
			error( "no plot" )
		end
		return weight
	end		
	function NodeChecker( node )
		local weight = PATHCONSTANT.INVALID_WEIGHT
		local weightScale = router._mapFinder:GetEnviroment( PATHFINDER_DATA.WEIGHT_SCALE )
		if not weightScale then weightScale = WeightScale end
		return weightScale( map:GetPlot( node.x, node.y ) )
	end

	router._mapFinder:SetEnviroment( PATHFINDER_DATA.NODE_GETTER, function ( x, y )
		return self.map:GetPlot( x, y )
	end )
	router._mapFinder:SetEnviroment( PATHFINDER_DATA.OFFSET_LIST,  PLOTADJACENTOFFSET_1 )
	router._mapFinder:SetEnviroment( PATHFINDER_DATA.WIDTH,        data.width )
	router._mapFinder:SetEnviroment( PATHFINDER_DATA.HEIGHT,       data.height )
	router._mapFinder:SetEnviroment( PATHFINDER_DATA.NODE_CHECKER, NodeChecker )
	router._mapFinder:SetEnviroment( PATHFINDER_DATA.WEIGHT_SCALE, WeightScale )
end

---------------------------------------
function MAP_COMPONENT:Generate( data )	
	self.map:GeneratePlots( data )
	self.map:GenereateCities( data )

	self.width  = self.map.width
	self.height = self.map.height
	self.plots  = self.map.plots
	self.cities = self.map.cities
end


---------------------------------------
function MAP_COMPONENT:GenerateRoutes( data )	
	local list = {}
	for _, cityData in pairs( data.cities ) do
		local city = self.cities[cityData.id]
		local item = {}
		item.plot  = city.plot
		item.adjacents = {}
		for _, id in ipairs( cityData.adjacents ) do
			adjaCity = self.cities[id]
			if adjaCity then
				table.insert( item.adjacents, adjaCity.plot )
			end
		end
		table.insert( list, item )
	end

	self.router:Generate( list )
	self.router:Verify()
end


---------------------------------------
local function Map_Printer( plot )
	local content = ""
	content = content .. string.sub( plot.type, 1, 1 )
	if plot.additions["DISTRICT"] then content = content .. "D" end
	if plot.additions["ROAD"] then content = content .. "R" end	
	--if plot.additions["ROAD"] then content = "R" end	
	return StringUtil_Abbreviate( content, 4 )
end


---------------------------------------
function MAP_COMPONENT:Update()
	--self.map:Draw( Map_Printer )
end