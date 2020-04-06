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
	self.map = MAP_GENERATOR()
end

---------------------------------------
function MAP_COMPONENT:Activate()
	local cmp = self
	ECS_AddListener( self, "Get", nil, function( ... ) return cmp end )
end

---------------------------------------
function MAP_COMPONENT:Dectivate()
	local cmp = self
	ECS_AddListener( self, "Get", nil, function( ... ) return cmp end )
end

---------------------------------------
function MAP_COMPONENT:GetPlot( x, y )	
	return self.map:GetPlot( x, y )
end

---------------------------------------
function MAP_COMPONENT:GetPlotById( id )
	return self.map:GetPlotById( id )
end

---------------------------------------
function MAP_COMPONENT:Generate( data )	
	self.map:GeneratePlots( data )
	self.map:GenereateCities( data )

	self.width  = self.map.width
	self.height = self.map.width
	self.plots  = self.map.plots
	self.cities = self.map.cities
end


---------------------------------------
function MAP_COMPONENT:Update()
	self.map:Draw()
end