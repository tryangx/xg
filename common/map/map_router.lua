--------------------------------------------------------
--
-- Generate the route
--
-- @usage
--   Route =
--   {
--     fromPlot = plot,
--     toPlot   = plot,
--
--   }
--------------------------------------------------------


--------------------------------------------------------
-- 1 unit means 1KM
PLOT_DISTANCE_UNIT = 10


--------------------------------------------------------
-- Debug functions
--------------------------------------------------------
local function Router_PlotToString( plot )
	return plot.x .. "," .. plot.y
end


local function Router_NodeToString( node )
	if not node then return "??" end
	if not node.route then return "??" end
	local from = node.route.from
	local to   = note.route.to
	return Router_PlotToString( from ) .. "->" .. Router_PlotToString( to )
end


local function Router_GenKey( plot1, plot2 )
	return plot1.id .. "_" .. plot2.id
end


local function Router_DumpPath( plot1, plot2, path )	
	if not path then return end	

	for _, plot in ipairs( path ) do
		print( plot.id, Router_PlotToString( plot ) )
	end
	
	--debug verify
	if path[1] ~= plot1 or path[#path] ~= plot2 then
		DBG_Error( "List path=" .. Router_PlotToString( plot1 ) .. "->" .. Router_PlotToString( plot2 ) .. " node=" .. #path, "Verify Failed" )
	else
		DBG_Trace( "List path=" .. Router_PlotToString( plot1 ) .. "->" .. Router_PlotToString( plot2 ) .. " node=" .. #path, "Verify OK" )
	end
end


--------------------------------------------------------
MAP_ROUTER = class()


--------------------------------------------------------
function MAP_ROUTER:__init( ... )
	-- Store the route for each plot
	--{
	--  plot1 = { route1, route2, ... },
	--  plot2 = { route1, route2, ... },
	--  ...
	--}
	self._plotInRoutes = {}


	-- Store paths and routes from plot to plot
	--{
	--  plot1 = { node1, node2, ... },
	--  plot2 = { node1, node2, ... },
	--  ...
	--}
	self._p2pPaths  = {}
	self._p2pRoutes = {}

	self._mapFinder = PATHFINDER()
end


------------------------------------------------------------
------------------------------------------------------------
function MAP_ROUTER:AddPlotInRoute( plot, route )	
	--route list for each plot
	if not self._plotInRoutes[plot] then self._plotInRoutes[plot] = {} end
	table.insert( self._plotInRoutes[plot], route )
	--print( "insert", plot, plot:ToString(), route:ToString(), #_plotInRoutes[plot] )
end


--[[
------------------------------------------------------------
-- 
------------------------------------------------------------
function MAP_ROUTER:InsertPath( route, start, target, path )
	if not path then path = {} end
	print( "insert path", #path )
	local list    = {}
	local plots   = route.nodes
	local insert  = false
	local reverse = false
	local finish  = false	
	for _, plot in ipairs( plots ) do
		if plot == start or plot == target then
			--we find the port
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
		for k = #list, 1, -1 do table.insert( path, list[k] ) end
	else
		for _, v in ipairs( list ) do table.insert( path, v ) end
	end
	print( "after insert path", #path )
	return path
end


------------------------------------------------------------
-- Find the port plot from a plot which should involved in 
-- at least one rote
--return plot if given plot is a city node
--return plot & route if given plot is a route node
------------------------------------------------------------
function MAP_ROUTER:FindPortPlot( plot )
	--Plot should be included in any route
	if not self._plotInRoutes[plot] then return end

	if #self._plotInRoutes[plot] > 1 then return plot end
	
	local route = self._plotInRoutes[plot][1]
	return route.fromPlot, route
end


------------------------------------------------------------
-- We want to find a path includes a list of plot nodes from
-- the start position to the end position
-- @note we should generate the base route for each port plot
-- like city to city at first.
------------------------------------------------------------
function MAP_ROUTER:FindPathByPlot( plot1, plot2 )	
	local id1 = Router_GenKey( plot1, plot2 )
	local id2 = Router_GenKey( plot2, plot1 )
	--print( "#Try find path=" .. id1 .. "->" .. id2 )

	--Do we have the path cache?
	local pathCache = self._p2pPaths[id1] or self._p2pPaths[id2]
	if pathCache then
		return pathCache
	end

	--Do we have the route cache?
	local route = self._p2pRoutes[id1] or self._p2pRoutes[id2]
	if route then
		--below should be modified.
		local path = self:InsertPath( route, plot1, plot2 )
		self._p2pPaths[id1] = path
		self._p2pPaths[id2] = MathUtil_Reverse( path )
		return path
	end

	--Let's find routes from plot to plot
	local startPlot, startRoute = self:FindPortPlot( plot2 )
	local destPlot, destRoute = self:FindPortPlot( plot1 )
	if not startPlot or not destPlot then
		--InputUtil_Pause( plot1:ToString("ROAD"), plot2:ToString("ROAD") )
		--error( "plot has no route" )
		return
	end

	local findNode
	local openList = {}
	local closeList = {}
	local startNode = { plot = startPlot, route = startRoute, parent = nil, dis = 0, ev = 0 }
	table.insert( openList, startNode )	
	closeList[startPlot] = startNode
	--print( startPlot:ToString(), destPlot:ToString(), startRoute, destRoute )
	--print( "start find", plot1:ToString(), plot2:ToString(), startRoute )
	
	while #openList > 0 do
		local curNode = table.remove( openList, 1 )

		--print( "check node=" .. curNode.plot:ToString(), "route=" .. ( destRoute and destRoute:ToString() or "" ) )--.id, curNode.route )

		if ( destRoute and destRoute == curNode.route ) 
			or curNode.plot == destPlot
			or ( curNode.route and curNode.route:ContainsPlot( destPlot ) ) then
			--reach the end
			findNode = curNode
			break
		end

		local needSort = false
		local routes = self._plotInRoutes[curNode.plot]
		--print( "plot=" .. curNode.plot:ToString(), "route=", routes )
		for _, route in ipairs( routes ) do
			--if route ~= curNode.route then
				local dis  = route.distance
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

	--Generate path
	local routes = {}
	local path   = {}
	local start  = destPlot

	if plot1 ~= destPlot and destRoute then		
		self:InsertPath( destRoute, plot1, start, path )
	end

	while findNode ~= nil do
		--print( "gen=" .. findNode.plot:ToString(), findNode.route )
		if findNode.route then
			local from = findNode.route.fromPlot
			local to   = findNode.route.toPlot
			--print( "route=" .. findNode.route:ToString(), findNode.parent )
			local target = nil
			if findNode.parent and findNode.parent.route then
				local parent_f = findNode.parent.route.fromPlot
				local parent_t = findNode.parent.route.toPlot
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
				self:InsertPath( findNode.route, start, target, path )
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
function MAP_ROUTER:CalcPlotDistance( plot1, plot2 )
	local path = self:FindPathByPlot( plot1, plot2 )
	if not path then DBG_TraceBug( "no route", plot1, city2.name ) return 0 end

	local distance = 0
	for _, plot in ipairs( path ) do
		distance = distance + ( plot.additions["ROAD"] or 0 )
	end
	return distance
end
--]]

------------------------------------------------------------
------------------------------------------------------------
function MAP_ROUTER:FindPath( plot1, plot2 )
	local id1 = Router_GenKey( plot1, plot2 )
	local id2 = Router_GenKey( plot2, plot1 )

	--print( "Find Path", Router_PlotToString( plot1 ) .. "->" .. Router_PlotToString( plot2 ) )	

	local route = self._p2pRoutes[id1] or self._p2pRoutes[id2]
	if route then return end

	local getter = self._mapFinder:GetEnviroment( PATHFINDER_DATA.NODE_GETTER )

	local path = self._mapFinder:FindPath( plot1.x, plot1.y, plot2.x, plot2.y )
	for _, pos in pairs( path ) do
		local plot = getter( pos.x, pos.y )
		if plot then plot.additions["ROAD"] = pos.weight end
	end

	--Create route
	local route = {}
	route.fromPlot = plot1
	route.toPlot   = plot2
	route.nodes    = {}
	local distance = 0
	local plotPath = {}
	for _, node in ipairs( path ) do
		local plot = getter( node.x, node.y )
		table.insert( route.nodes, plot )
		distance = distance + ( plot.additions["ROAD"] or 0 )
		self:AddPlotInRoute( plot, route )
	end
	route.distance = distance

	--Store the path, route for from plot and to plot
	self._p2pPaths[id1]  = plotPath
	self._p2pRoutes[id1] = route

	local rev_route = MathUtil_ShallowCopy( route )
	rev_route.plotPath = MathUtil_Reverse( plotPath )
	self._p2pPaths[id2]  = rev_route.plotPath
	self._p2pRoutes[id2] = rev_route

	--InputUtil_Pause( "Find Path", Router_PlotToString( plot1 ) .. "->" .. Router_PlotToString( plot2 ) )	
end


------------------------------------------------------------
-- Generate all routes between city to adjacent city
-- @params plots includes plots need to connect to each other
-- @usage
--   plots =
--   {
--     item = { plot = ..., adjacent = { plo1, plo2, ... },
--     ...
--   }
------------------------------------------------------------
function MAP_ROUTER:Generate( plots )	
	for _, item in ipairs( plots ) do
		local plot = item.plot
		for _, adja in ipairs( item.adjacents ) do			
			self:FindPath( plot, adja )			
		end
	end
end


------------------------------------------------------------
------------------------------------------------------------
function MAP_ROUTER:Verify()
	--plot 2 plot
	for p1, r1 in pairs( self._plotInRoutes ) do
		--print( Router_PlotToString( p1 ), #r1 )
		for p2, r2 in pairs( self._plotInRoutes ) do
			--if p1 ~= p2 then Router_DumpPath( p1, p2, self:FindPathByPlot( p1, p2 ) )	end
		end
	end
end
