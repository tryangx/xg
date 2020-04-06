--------------------------------------------------------
PATHFINDER_DATA = 
{
	NODE_GETTER      = 1,
	OFFSET_LIST      = 2,
	WIDTH            = 3,
	HEIGHT           = 4,
	NODE_CHECKER     = 5,
}


PathConstant = 
{
	INVALID_WEIGHT = -10000,
}

--------------------------------------------------------
PATHFINDER = class()

--------------------------------------------------------
function PATHFINDER:__init()
	self.env = {}
end

--------------------------------------------------------
function PATHFINDER:SetEnviroment( type, value )	
	self.env[type] = value
end

--------------------------------------------------------
function PATHFINDER:IsReady()
	for _, index in pairs( PATHFINDER_DATA ) do
		if self.env[index] == nil then
			return false
		end
	end
	return true
end

function PATHFINDER:FindPath( x1, y1, x2, y2 )
	if self:IsReady() == false then DBG_Error( "Path finder isn't ready" ) return nil end

	local node = self.env[PATHFINDER_DATA.NODE_GETTER]( x1, y1 )
	local openList = { { x = x1, y = y1, ev = 0, weight = self.env[PATHFINDER_DATA.NODE_CHECKER]( node ), parent = nil } }
	local closeList  = {}
	local destination = nil
	local maxDistance = 9999999
	while #openList > 0 do
		local cur = openList[1]
		local x, y = cur.x, cur.y
		table.remove( openList, 1 )

		--InputUtil_Pause( "cur node: x=" .. x .. " y=" .. y .. " ev=" .. cur.ev )

		if x == x2 and y == y2 then
			--InputUtil_Pause( "Find destination" )
			destination = cur
			break
		end
		local needSort = false
		for _, offset in ipairs( self.env[PATHFINDER_DATA.OFFSET_LIST] ) do
			local tx, ty = x + offset.x, y + offset.y
			if tx > 0 and ty > 0 and tx <= self.env[PATHFINDER_DATA.WIDTH] and ty <= self.env[PATHFINDER_DATA.HEIGHT] then
				local index = ty * 100000 + tx
				local node = self.env[PATHFINDER_DATA.NODE_GETTER]( tx, ty )
				local weight = self.env[PATHFINDER_DATA.NODE_CHECKER]( node )
				if weight > PathConstant.INVALID_WEIGHT then
					local dis = math.abs( tx - x2 ) + math.abs( ty - y2 )
					weight = math.abs( weight )
					local ev = cur.ev + weight
					local next = closeList[index]
					if not next then
						--print( "Add open", tx, ty, "weight=" .. weight, "ev=" .. ev )
						next = { x = tx, y = ty, ev = ev, weight = weight, parent = cur, dis = dis }
						closeList[index] = next
						table.insert( openList, next )
						needSort = true
					elseif next.ev > ev then
						--print( "Up short", tx, ty, "weight=" .. weight, "ev=" .. ev )
						next.x      = tx
						next.y      = ty
						next.ev     = ev
						next.weight = weight
						next.parent = cur
						next.node   = node
						node.dis    = dis
						needSort = true
					end					
				end
			end
		end
		if needSort == true then
			--MathUtil_Dump( openList )
			table.sort( openList, function ( l, r )
				if l.ev < r.ev then return true end
				if l.ev > r.ev then return false end
				return l.dis < r.dis
			end )
			--print( "after sort" )
			--MathUtil_Dump( openList )
		end
	end
	local path = {}
	while destination ~= nil do
		--print( destination, destination.x, destination.y, destination.parent )
		table.insert( path, { x = destination.x, y = destination.y, weight = destination.weight } )
		destination = destination.parent
	end
	return path
end

-------------------------------------
local _pathFinder = PATHFINDER()


-------------------------------------
function PathFinder_SetEnviroment( type, value )
	_pathFinder:SetEnviroment( type, value )
end


-------------------------------------
function PathFinder_FindPath( x1, y1, x2, y2 )
	return _pathFinder:FindPath( x1, y1, x2, y2 )
end