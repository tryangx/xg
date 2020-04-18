---------------------------------------
---------------------------------------
CITY_COMPONENT = class()

---------------------------------------
CITY_PROPERTIES = 
{
	name        = { type="STRING" },

	--
	lv          = { type="NUMBER" },

	cityid      = { type="NUMBER" },

	--
	plots       = { type="LIST" },

	--{ { type="", id= }, { type="", id= }, ... }
	facilities  = { type="LIST" },

	--{ { type=, num=, } }
	populations = { type="DICT" },

	---------------------------------------
	--data structures
	--  { groupid={ { eval=, influence= } }, groupid={ ... }, ... }
	--eval
	--influence
	viewpoints  = { type="DICT" },
}

---------------------------------------
function CITY_COMPONENT:__init()	
end

---------------------------------------
function CITY_COMPONENT:Activate()
	local cmp = self
	ECS_AddListener( self, "Get", function( id )
		if id == cmp.cityid then return cmp end
	end )
end

function CITY_COMPONENT:Deactivate()
	ECS_RemoveListener( self, "Get" )
end

---------------------------------------
function CITY_COMPONENT:GetGroupViewPoint( group )
	return self.viewpoints[group.entityid]
end


function CITY_COMPONENT:GetNumOfFacility( type, id )
	local num = 0
	for _, data in ipairs( self.facilities ) do
		if ( not type or data.type == type ) or ( not id or data.id == id ) then num = num + 1 end
	end
	return num
end


---------------------------------------
function CITY_COMPONENT:OccupyPlot( plot )
	Pop_Add( self, "plots", plot )
end


---------------------------------------
function CITY_COMPONENT:GroupAffect( group )
	local viewpoint = self.viewpoints[group.entityid]
	if not viewpoint then
		local influence = GROUP_SIZE[group.size] * 5 + 10
		--self.viewpoints[group.entityid] = { influence=influence, eval=math.ceil( influence * 0.5 ) }
		self.viewpoints[group.entityid] = { influence=influence, eval=influence }
		viewpoint = self.viewpoints[group.entityid]
	end

	viewpoint.eval = viewpoint.eval + Random_GetInt_Sync( 1, GROUP_SIZE[group.size] )
end


function CITY_COMPONENT:RemoveEffect( group )
	self.viewpoints[group.entityid] = nil
end

---------------------------------------
function CITY_COMPONENT:Update( deltaTime )
end


---------------------------------------
function CITY_COMPONENT:ToString()
	local content = ""
	content = content .. "[" .. self.name .. "]"

	content = content .. " Lv." .. self.lv .. "\n"

	content = content .. " vp=["
	for groupid, data in pairs( self.viewpoints ) do
		content = content .. ECS_FindComponent( groupid, "GROUP_COMPONENT" ).name
		content = content .. " " .. data.eval .. "/" .. data.influence
	end
	content = content .. "]"

	return content
end

---------------------------------------
function CITY_COMPONENT:Dump()
	print( self:ToString() )
end