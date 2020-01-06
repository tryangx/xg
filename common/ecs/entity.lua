---------------------------------------
ECSEntityProperties = 
{
	status     = { type="NUMBER" },
	components = { type="LIST"},
	children   = { type="LIST" },
	parent     = { type="OBJECT"  },	
}

---------------------------------------
ECSEntityStatus =
{
	CREATED      = 0,
	INITED       = 1,
	ACTIVATING   = 2,
	ACTIVATED    = 3,
	DEACTIVATING = 4,
	DEACTIVATED  = 5,
}

---------------------------------------
ECSEntity = class()

---------------------------------------
---------------------------------------
function ECSEntity:__init()
	self._properties = ECSEntityProperties
	self.status      = ECSEntityStatus.CREATED
	print( "init ecsentity" )
end

---------------------------------------
function ECSEntity:CreateComponent( typeName )
	local component = ECS_Create( typeName )
	Prop_Add( self, "components", component )
	return component
end

---------------------------------------
function ECSEntity:AddComponent( component )
	Prop_Add( self, "components", component )
end

---------------------------------------
function ECSEntity:RemoveComponent( component )
	Prop_Remove( self, "components", component )
end

---------------------------------------
function ECSEntity:RemoveComponentById( id )
	Prop_RemoveById( self, "components", id )
end

---------------------------------------
function ECSEntity:RemoveComponentByType( name )
	Prop_RemoveByFilter( self, "components", function( component, id )
		return component.name == name
	end )
end

---------------------------------------