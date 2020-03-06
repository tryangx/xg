---------------------------------------
ECSEntityProperties = 
{
	ecsid        = { type="NUMBER" },
	components   = { type="LIST" },
	children     = { type="LIST" },
}


---------------------------------------
ECSEntity = class()

---------------------------------------
---------------------------------------
function ECSEntity:__init()
	self._properties = ECSEntityProperties
	self.status      = ECSENTITYSTATUS.CREATED
	--print( "init ecsentity" )
end

---------------------------------------
--
-- Children interfaces
--
-- Include Add(), Remove(), Get(), etc.
--
---------------------------------------
function ECSEntity:AddChild( entity )
	if entity.parent then
		DBG_Error( "Entity already has parent" )
		return
	end
	entity.parent = self
	Prop_Add( self, "children", entity )
end


function ECSEntity:RemoveChild( entity )
	Prop_Remove( self, "children", entity )
end


function ECSEntity:GetChild( index )
	return self.children and self.children[index] or 0
end


function ECSEntity:GetNumOfChildren()
	return self.children and #self.children or 0
end


function ECSEntity:GetComponent( typeName, Index )
	return Prop_GetByIndex( self, "components", Index or 1, "ecsname", typeName )
end


---------------------------------------
--
--
--
---------------------------------------
function ECSEntity:CreateComponent( typeName )
	local component = ECS_CreateComponent( typeName )
	self:AddComponent( component )
	return component
end


---------------------------------------
--
-- Operation Interfaces
--
-- Include Add(), Remove()
--
---------------------------------------
function ECSEntity:AddComponent( component )
	--component's senity checker
	if not ECS_IsComponent( component ) then DBG_Error( "component is invalid" ) return end
	component.entityid = self.ecsid
	Prop_Add( self, "components", component )
end


function ECSEntity:RemoveComponent( component )
	Prop_Remove( self, "components", component )
end


function ECSEntity:RemoveComponentById( id )
	Prop_RemoveById( self, "components", id )
end


function ECSEntity:RemoveComponentByType( name )
	Prop_RemoveByFilter( self, "components", function( component, id )
		return component.name == name
	end )
end


---------------------------------------
function ECSEntity:ForeachChild( fn )
	if not self.children then return end
	Prop_Foreach( self, "children", fn )
end


---------------------------------------
--
-- Regular methods
--
---------------------------------------
function ECSEntity:Activate()
	--print( "Activate Entity" )
	entity = self
	Prop_Foreach( self, "components", function ( component )
		component.status = ECSENTITYSTATUS.ACTIVATING
		--Loading 
		component.entityid = entity.ecsid
		component.parent   = entity
		--print( "Activate component", component.ecsname, component.Activate )
		--Dump( component )
		if component.Activate then component:Activate() end		
		component.status = ECSENTITYSTATUS.ACTIVATED
	end)
	Prop_Foreach( self, "children", function ( child )
		child:Activate()
	end)
end


function ECSEntity:Deactivate()
	--print( "Deactivate Entity" )
	Prop_Foreach( self, "components", function ( component )
		component.status = ECSENTITYSTATUS.DEACTIVATING
		if component.Deactivate then component:Deactivate() end
		component.status = ECSENTITYSTATUS.DEACTIVATED
	end )
	Prop_Foreach( self, "children", function ( child )
		child:Activate()
	end)
end


function ECSEntity:Update()
	Prop_Foreach( self, "components", function ( component )
		component:Update()
	end )
	Prop_Foreach( self, "children", function ( child )
		child:Update()
	end)
end

---------------------------------------