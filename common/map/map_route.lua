--------------------------------------------------------
-- 1 unit means 1KM
PLOT_DISTANCE_UNIT = 10

--------------------------------------------------------
-- Route caches for plot to plot
--{ plotid1_plotid2 = route, ... }
local _routes = {}


--------------------------------------------------------
--Route caches for city to adjacent city
--{ city = { adja_city = route, ... }, ... }
local _cityRelativeRoutes = {}


--------------------------------------------------------
--Route caches for plot
--{ plot1 = { route1, route2, ... }, plot2 = { route1, route2, ... }, ... }
local _plotRoutes = {}


--------------------------------------------------------
--Route caches for plot to plot
--{ pid1_pid2 = { node1, node2, ... }, pid2_pid3 = { node1, node2, ... }, ... }
local _p2pPaths = {}

--------------------------------------------------------
local _p2pRoutes = {}

--------------------------------------------------------
local _mapFinder = PATHFINDER()


--------------------------------------------------------
-- Debug functions
--------------------------------------------------------
local function Route_PlotToString( plot )
	return plot.x .. "," .. plot.y
end


local function Route_NodeToString( node )
	if not node then return "??" end
	if not node.route then return "??" end
	local from = node.route.from
	local to   = note.route.to
	return Route_PlotToString( from ) .. "->" .. Route_PlotToString( to )
end


--------------------------------------------------------
--
--------------------------------------------------------
local function Route_DumpPath( plot1, plot2, path )	
	if not path then return end	

	for _, plot in ipairs( path ) do
		--print( plot.id, plot.x .. "," .. plot.y )
	end
	
	--debug verify
	if path[1] ~= plot1 or path[#path] ~= plot2 then
		error( "List path=" .. plot1:ToString() .. "->" .. plot2:ToString() .. " path=" .. #path, "Verify Failed" )
	else
		print( "List path=" .. plot1:ToString() .. "->" .. plot2:ToString() .. " path=" .. #path, "Verify OK" )
	end
end


------------------------------------------------------------
------------------------------------------------------------
function Route_Verify()
	--plot 2 plot
	for p1, r1 in pairs( _plotRoutes ) do
		for p2, r2 in pairs( _plotRoutes ) do
			if p1 ~= p2 then
				--Route_DumpPath( p1, p2, Route_FindPathByPlot( p1, p2 ) )
			end
		end
	end

	--city 2 city
	Entity_Foreach( EntityType.CITY, function ( city )
		Entity_Foreach( EntityType.CITY, function ( adjaCity )
			if city == adjaCity then return end

			local path = Route_FindPathByCity( city, adjaCity )
			print( city.name .. "->" .. adjaCity.name, "path=" .. #path )

			--[[
			if Asset_HasItem( city, CityAssetID.ADJACENTS, adjaCity ) == true then return end
			local path = Route_FindPathByCity( city, adjaCity )
			print( city.name .. "-->" .. adjaCity.name, "path=" .. ( path and #path or 0 ) )
			]]
		end)
	end)
end


------------------------------------------------------------
------------------------------------------------------------
local function Route_InsertPath( route, start, target, path )
	if not path then path = {} end
	--print( "insert", start:ToString(), target:ToString(), route:ToString() )
	local list    = {}
	local plots   = Asset_GetList( route, RouteAssetID.NODES )
	local insert  = false
	local reverse = false
	local finish  = false
	for _, plot in ipairs( plots ) do
		if plot == start or plot == target then
			--print( "find start/target", plot.id, start.id, target.id )
			if insert == false then
				if plot == target then reverse = true end
				insert = true
			elseif insert == true then
				finish = true
			end
			if path[#path] ~= plot then
				table.insert( list, plot )
			end
		end
		if finish == true then break end			
	end
	if reverse == true then
		for k = #list, 1, -1 do
			--print( list[k]:ToString() )
			table.insert( path, list[k] )
		end
	else
		for _, v in ipairs( list ) do
			--print( v:ToString() )
			table.insert( path, v )
		end
	end		
	return path
end


------------------------------------------------------------
--return plot if given plot is a city node
--return plot & route if given plot is a route node
------------------------------------------------------------
local function Route_FindPortPlot( plot )		
	if not _plotRoutes[plot] then return end
	if #_plotRoutes[plot] > 1 then return plot end
	local route = _plotRoutes[plot][1]
	return Asset_Get( route, RouteAssetID.FROM_PLOT ), route
end


------------------------------------------------------------
-- We want to find a path includes a list of plot nodes from
-- the start position to the end position
------------------------------------------------------------
function Route_FindPathByPlot( plot1, plot2 )
	--print( "#Try find path=" .. plot1.id .. "->" .. plot2.id )
	local id1 = plot1.id .. "_" .. plot2.id
	local id2 = plot2.id .. "_" .. plot1.id	
	--Do we have the path cache?
	local pathCache = _p2pPaths[id1] or _p2pPaths[id2]
	if pathCache then return pathCache end

	--do we have the route cache?
	local route = _p2pRoutes[id1] or _p2pRoutes[id2]
	if route then
		--below should be modified.
		local path = Route_InsertPath( route, plot1, plot2 )
		_p2pPaths[id1] = path
		_p2pPaths[id2] = MathUtil_Reverse( path )
		return path
	end

	--let's find routes from plot to plot
	local startPlot, startRoute = FindPortPlot( plot2 )
	local destPlot, destRoute = FindPortPlot( plot1 )
	if not startPlot or not destPlot then
		InputUtil_Pause( plot1:ToString("ROAD"), plot2:ToString("ROAD") )
		--error( "plot has no route" )
		return
	end

	local openList = {}
	local closeList = {}
	local startNode = { plot = startPlot, route = startRoute, parent = nil, dis = 0, ev = 0 }
	table.insert( openList, startNode )
	closeList[startPlot] = startNode
	--print( startPlot:ToString(), destPlot:ToString(), startRoute, destRoute )
	--print( "start find", plot1:ToString(), plot2:ToString(), startRoute )
	local findNode
	while #openList > 0 do
		local curNode = openList[1]
		table.remove( openList, 1 )

		--print( "check node=" .. curNode.plot:ToString(), "route=" .. ( destRoute and destRoute:ToString() or "" ) )--.id, curNode.route )

		if ( destRoute and destRoute == curNode.route ) 
			or curNode.plot == destPlot
			or ( curNode.route and curNode.route:ContainsPlot( destPlot ) ) then
			findNode = curNode
			break
		end

		local needSort = false
		local routes = _plotRoutes[curNode.plot]
		--print( "plot=" .. curNode.plot:ToString(), "route=", routes )
		for _, route in ipairs( routes ) do
			--if route ~= curNode.route then
				local dis  = Asset_Get( route, RouteAssetID.DISTANCE )
				local ev   = curNode.ev + dis
				local nextPlot = route:FindPort( curNode.plot )
				local nextNode = closeList[nextPlot]
				if not nextNode then
					nextNode = { plot = nextPlot, route = route, parent = curNode, dis = dis, ev = ev }
					if curNode.route == route then
						--print( "dup" )
						nextNode.parent = nil
					end				
					closeList[nextPlot] = nextNode
					table.insert( openList, nextNode )
					needSort = true
					--print( "open route=" .. route:ToString(), nextNode.plot:ToString() )--, "parent=" .. NodeToString( nextNode.parent ) )
				else
					if nextNode.ev > ev then
						nextNode.parent = curNode
						nextNode.dis    = dis
						nextNode.ev     = ev
						needSort        = true
					end
					--print( "exist=" .. from.id .. "->" ..to.id )
				end
			--end
		end

		if needSort then
			table.sort( openList, function ( l, r )
				if l.ev < r.ev then return true end
				if l.ev > r.ev then return false end
				return l.dis < r.dis
			end )
		end
	end

	--generate path
	local routes = {}
	local path = {}
	local start = destPlot

	if plot1 ~= destPlot and destRoute then		
		InsertPath( destRoute, plot1, start, path )
	end

	while findNode ~= nil do
		--print( "gen=" .. findNode.plot:ToString(), findNode.route )
		if findNode.route then
			local from = Asset_Get( findNode.route, RouteAssetID.FROM_PLOT )
			local to   = Asset_Get( findNode.route, RouteAssetID.TO_PLOT )
			--print( "route=" .. findNode.route:ToString(), findNode.parent )
			local target = nil
			if findNode.parent and findNode.parent.route then
				local parent_f = Asset_Get( findNode.parent.route, RouteAssetID.FROM_PLOT )
				local parent_t = Asset_Get( findNode.parent.route, RouteAssetID.TO_PLOT )
				--print( "parent ", parent_f.id .."->" .. parent_t.id )
				if from == parent_f or from == parent_t then
					target = from
				elseif to == parent_f or to == parent_t then		
					target = to
				end
			else
				target = plot2
				--print( "parent ", start:ToString(), target:ToString() )
			end
			if target then
				InsertPath( findNode.route, start, target, path )
				start = target
			end
		end		
		findNode = findNode.parent
	end

	return path
end


------------------------------------------------------------
--return the distance between plot1 to plot2
------------------------------------------------------------
function Route_CalcPlotDistance( plot1, plot2 )
	local path = Route_FindPathByPlot( plot1, plot2 )
	if not path then
		InputUtil_Pause( "no route", plot1, city2.name )
		return 0
	end

	local dur = 0
	for _, plot in ipairs( path ) do
		dur = dur + Asset_Get( plot, PlotAssetID.ROAD )
	end
	return dur
end


------------------------------------------------------------
--from city to city, should modify to plot to plot
------------------------------------------------------------
function Route_CalcCityDistance( city1, city2 )	
	local plot1 = Asset_Get( city1, CityAssetID.CENTER_PLOT )
	local plot2 = Asset_Get( city2, CityAssetID.CENTER_PLOT )
	return Route_CalcPlotDistance( plot1, plot2 )
end


------------------------------------------------------------
--manhattan
------------------------------------------------------------
function Route_CalcCityCoorDistance( city1, city2 )
	local plot1 = Asset_Get( city1, CityAssetID.CENTER_PLOT )
	local plot2 = Asset_Get( city2, CityAssetID.CENTER_PLOT )
	local dist = math.abs( Asset_Get( plot1, PlotAssetID.X ) - Asset_Get( plot2, PlotAssetID.X ) ) + math.abs( Asset_Get( plot2, PlotAssetID.X ) - Asset_Get( plot2, PlotAssetID.X ) )		
	return dist * PLOT_DISTANCE_UNIT
end


------------------------------------------------------------
--Make all route between city to adjacent city
function Route_Generate()
	Entity_Foreach( EntityType.CITY, function ( city )
		if not _cityRelativeRoutes[city] then _cityRelativeRoutes[city] = {} end
		Asset_Foreach( city, CityAssetID.ADJACENTS, function( adjaCity )
			if not adjaCity or type( adjaCity ) == "number" then return end

			local route = _cityRelativeRoutes[city][adjaCity] or _cityRelativeRoutes[city][adjaCity]
			if not route then
				local path = Route_FindPathBetweenCity( city, adjaCity )
				for _, pos in pairs( path ) do
					local plot = g_map:GetPlot( pos.x, pos.y )
					if plot then
						Asset_Set( plot, PlotAssetID.ROAD, pos.weight )
					end
				end

				local route = Entity_New( EntityType.ROUTE )				
				local fromplot = Asset_Get( adjaCity, CityAssetID.CENTER_PLOT )
				local toplot =  Asset_Get( city, CityAssetID.CENTER_PLOT )
				Asset_Set( route, RouteAssetID.FROM_PLOT, fromplot )
				Asset_Set( route, RouteAssetID.TO_PLOT, toplot )
				Asset_Set( route, RouteAssetID.FROM_CITY, adjaCity )
				Asset_Set( route, RouteAssetID.TO_CITY, city )
				
				local distance = 0
				local plotPath = {}
				for _, node in ipairs( path ) do
					local plot = g_map:GetPlot( node.x, node.y )					
					table.insert( plotPath, plot )

					distance = distance + Asset_Get( plot, PlotAssetID.ROAD )

					--route list for each plot
					if not _plotRoutes[plot] then _plotRoutes[plot] = {} end
					table.insert( _plotRoutes[plot], route )
					--print( "insert", plot, plot:ToString(), route:ToString(), #_plotRoutes[plot] )
				end
				Asset_CopyList( route, RouteAssetID.NODES, plotPath )
				Asset_Set( route, RouteAssetID.DISTANCE, distance )

				--route cache for plot to plot
				local id1 = fromplot.id .. "_" .. toplot.id
				local id2 = toplot.id .. "_" .. fromplot.id
				_p2pPaths[id1] = plotPath
				_p2pPaths[id2] = MathUtil_Reverse( plotPath )
				_p2pRoutes[id1] = route
				_p2pRoutes[id2] = route
				--print( city.name, adjaCity.name, id1, id2, #plotPath, route )
				
				--print( "find way", city.name .. "->", adjaCity.name )
				if not _cityRelativeRoutes[adjaCity] then _cityRelativeRoutes[adjaCity] = {} end
				_cityRelativeRoutes[city][adjaCity] = route
				_cityRelativeRoutes[adjaCity][city] = route
			else
				--print( "route already exist between", city.name, adjaCity.name )
			end
		end )
	end )
end

--[[
--Find the path between city to city
function Route_FindPathBetweenCity( fromCity, toCity )
	if not fromCity or not toCity then InputUtil_Pause( "invalid city, no route" ) return end

	local cx, cy = Asset_Get( fromCity, CityAssetID.X ), Asset_Get( fromCity, CityAssetID.Y )
	local tx, ty = Asset_Get( toCity, CityAssetID.X ), Asset_Get( toCity, CityAssetID.Y )	
	_mapFinder:SetEnviroment( PathDataType.NODE_GETTER, function( x, y ) return g_map:GetPlot( x, y ) end )
	_mapFinder:SetEnviroment( PathDataType.OFFSET_LIST, PlotRouteOffsets )
	_mapFinder:SetEnviroment( PathDataType.WIDTH, Asset_Get( g_map, MapAssetID.WIDTH ) )
	_mapFinder:SetEnviroment( PathDataType.HEIGHT, Asset_Get( g_map, MapAssetID.HEIGHT ) )
	_mapFinder:SetEnviroment( PathDataType.NODE_CHECKER, function( node )
		local weight = PathConstant.INVALID_WEIGHT
		local temp = Asset_Get( node, PlotAssetID.TEMPLATE )
		if temp then
			--weight = 10 * ( math.abs( Asset_Get( cur, PlotAssetID.X ) - Asset_Get( node, PlotAssetID.X ) ) + math.abs( Asset_Get( cur, PlotAssetID.Y ) - Asset_Get( node, PlotAssetID.Y ) ) )

			if temp.type == PlotType.LAND then
				weight = 10
			elseif temp.type == PlotType.HILLS then
				weight = 40
			elseif temp.type == PlotType.MOUNTAIN then
				weight = 100
			elseif temp.type == PlotType.WATER then
				weight = -20
			end

			if temp.terrain == PlotTerrainType.NONE then
			elseif temp.terrain == PlotTerrainType.PLAINS then
				weight = weight + 10
			elseif temp.terrain == PlotTerrainType.GRASSLAND then
				weight = weight + 10
			elseif temp.terrain == PlotTerrainType.DESERT then
				weight = weight + 50
			elseif temp.terrain == PlotTerrainType.TUNDRA then
				weight = weight + 50
			elseif temp.terrain == PlotTerrainType.SNOW then
				weight = weight + 50
			elseif temp.terrain == PlotTerrainType.COAST then
				weight = weight + 20
			elseif temp.terrain == PlotTerrainType.OCEAN then
				weight = weight - 10
			end

			if temp.feature == PlotFeatureType.ALL then
			elseif temp.feature == PlotFeatureType.WOODS then
				weight = weight + 10
			elseif temp.feature == PlotFeatureType.RAIN_FOREST then
				weight = weight + 20
			elseif temp.feature == PlotFeatureType.MARSH then
				weight = weight + 30
			elseif temp.feature == PlotFeatureType.OASIS then
				weight = weight + 0
			elseif temp.feature == PlotFeatureType.FLOOD_PLAIN then
				weight = weight + 0
			elseif temp.feature == PlotFeatureType.ICE then
				weight = weight + 30
			elseif temp.feature == PlotFeatureType.FALLOUT then
				weight = weight + 0
			end			
			--print( node.name, "weight=" .. weight )
		end
		return weight
	end )
	-- "find", fromCity.name.."("..cx..","..cy..")" .. "->", toCity.name .."("..tx..","..ty..")" )
	return _mapFinder:FindPath( cx, cy, tx, ty )
end
]]

------------------------------------------------------------
------------------------------------------------------------
--[[
function Route_FindPathByCity( city1, city2 )
	if not city1 or not city2 then return end
	--print( String_ToStr( city1, "name" ), String_ToStr( city2, "name" ) )
	local plot1 = Asset_Get( city1, CityAssetID.CENTER_PLOT )
	local plot2 = Asset_Get( city2, CityAssetID.CENTER_PLOT )
	if not plot1 then
		error( String_ToStr( city1, "name" ) .. " no centerplot" )
	end
	if not plot2 then
		error( String_ToStr( city1, "name" ) .. " no centerplot" )
	end
	return Route_FindPathByPlot( plot1, plot2 )
end
]]