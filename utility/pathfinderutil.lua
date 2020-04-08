--------------------------------------------------------
PATHFINDER_DATA = 
{
	NODE_GETTER      = 1,
	NODE_CHECKER     = 2,
	OFFSET_LIST      = 3,
	WIDTH            = 4,
	HEIGHT           = 5,
	WEIGHT_SCALE     = 6,
}


PATHCONSTANT = 
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
function PATHFINDER:GetEnviroment( type )	
	return self.env[type]
end


--------------------------------------------------------
function PATHFINDER:IsReady()
	if not self.env[PATHFINDER_DATA.NODE_GETTER] then return false end
	if not self.env[PATHFINDER_DATA.NODE_CHECKER] then return false end
	if not self.env[PATHFINDER_DATA.OFFSET_LIST] then return false end
	if not self.env[PATHFINDER_DATA.WIDTH] then return false end
	if not self.env[PATHFINDER_DATA.HEIGHT] then return false end	
	return true
end


--------------------------------------------------------
function PATHFINDER:FindPath( x1, y1, x2, y2 )
	if self:IsReady() == false then DBG_Error( "Path finder isn't ready" ) return nil end

	local node = self.env[PATHFINDER_DATA.NODE_GETTER]( x1, y1 )
	local weight = self.env[PATHFINDER_DATA.WEIGHT_SCALE]( node )
	local openList = { { x = x1, y = y1, ev = weight, weight = weight, parent = nil } }
	local closeList  = {}
	local destination = nil
	local maxDistance = 9999999
	local checkNode   = 0
	while #openList > 0 do
		local cur = table.remove( openList, 1 )
		local x, y = cur.x, cur.y				
		checkNode = checkNode + 1
		--print( "cur node: x=" .. x .. " y=" .. y .. " ev=" .. cur.ev .. " wt=" .. cur.weight )

		if x == x2 and y == y2 then destination = cur break end

		local needSort = false
		for _, offset in ipairs( self.env[PATHFINDER_DATA.OFFSET_LIST] ) do
			local tx, ty = x + offset.x, y + offset.y
			--hexagonal offset
			if offset.y ~= 0 and ty % 2 == 1 then tx = tx + 1 end
			if tx > 0 and ty > 0 and tx <= self.env[PATHFINDER_DATA.WIDTH] and ty <= self.env[PATHFINDER_DATA.HEIGHT] then
				local index = ty * 10000 + tx
				local node = self.env[PATHFINDER_DATA.NODE_GETTER]( tx, ty )
				local weight = self.env[PATHFINDER_DATA.WEIGHT_SCALE]( node )
				if weight > PATHCONSTANT.INVALID_WEIGHT then
					local dis = math.abs( tx - x2 ) + math.abs( ty - y2 )
					weight = math.abs( weight )
					local ev = cur.ev + weight -- + dis
					local next = closeList[index]
					if not next then
						--print( "Add open", tx, ty, "weight=" .. weight, "ev=" .. ev )
						next = { x=tx, y=ty, ev=ev, weight=weight, parent=cur, dis=dis, priority=checkNode }
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
						needSort    = true
					end
				end
			end
		end
		if needSort == true then
			table.sort( openList, function ( l, r )
				--depth priority
				if l.dis < r.dis then return true end
				if l.dis > r.dis then return false end
				if l.ev < r.ev then return true end
				if l.ev > r.ev then return false end
				--print( "l=", l.x, l.y, l.ev, l.dis ) print( "r=", r.x, r.y, r.ev, l.dis )
				--x priority
				return l.priority > r.priority
			end )
			--for _, d in ipairs( openList ) do print( d.x, d.y, d.ev, d.dis ) end InputUtil_Pause( "after sort" )
		end
	end
	local path = {}
	while destination ~= nil do
		--print( destination.x, destination.y )
		table.insert( path, { x = destination.x, y = destination.y, weight = destination.weight } )
		destination = destination.parent
	end
	--print( "Check Node=" .. checkNode )
	return path
end