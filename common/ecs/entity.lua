---------------------------------------
---------------------------------------
local function ImportComponent( entity )
	for _, component in ipairs( entity.components ) do
		component.entityid = entity.ecsid
		--print( "import component", entity.ecsid )
	end
end

local function ImportChild( entity )
	for _, child in ipairs( entity.children ) do
		child.parentid = entity.ecsid
		--print( "import child", entity.ecsid )
	end
end

ECSENTITYPROPERTIES = 
{
	components   = { type="LIST", import=ImportComponent },
	children     = { type="LIST", import=ImportChild },
}


---------------------------------------
---------------------------------------
ECSEntity = class()

---------------------------------------
---------------------------------------
function ECSEntity:__init()
	self._properties = ECSENTITYPROPERTIES
	
	--local datas
	self.status      = ECSSTATUS.CREATED
	self.parentid    = nil
end

---------------------------------------
--
-- Children interfaces
--
-- Include Add(), Remove(), Get(), etc.
--
---------------------------------------
function ECSEntity:AddChild( entity )
	if entity.parentid then
		DBG_Error( "Entity already has parent" )
		return
	end
	entity.parentid = self.ecsid
	Prop_Add( self, "children", entity )
	--print( entity.ecsid, "set parent=", self.ecsid )
end


function ECSEntity:RemoveChild( entity )
	entity.parentid = nil
	Prop_Remove( self, "children", entity )
end


function ECSEntity:RemoveFromParent()
	local parent = ECS_FindEntity( self.parentid )
	if not parent then DBG_Error( "Parent entity is invalid! Id=" .. self.parentid ) end
	parent:RemoveChild( self )	
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
	return Prop_Remove( self, "components", component )
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
	if self.status ~= ECSSTATUS.INITED and self.status ~= ECSSTATUS.DEACTIVATED then DBG_Error( "Current entity isn't initialized! Status=" .. self.status ) return end	
	self.status = ECSSTATUS.ACTIVATING
	entity = self
	Prop_Foreach( self, "components", function ( component )
		component.status = ECSSTATUS.ACTIVATING
		--Loading 
		component.entityid = entity.ecsid
		component.parent   = entity
		--print( "Activate component", component.ecsname )
		if component.Activate then component:Activate() end		
		component.status = ECSSTATUS.ACTIVATED
	end)
	Prop_Foreach( self, "children", function ( child )
		child:Activate()
	end)
	self.status = ECSSTATUS.ACTIVATED
end


function ECSEntity:Deactivate()
	--print( "Deactivate Entity" )
	self.status = ECSSTATUS.DEACTIVATING
	Prop_Foreach( self, "components", function ( component )		
		component.status = ECSSTATUS.DEACTIVATING
		if component.Deactivate then component:Deactivate() end
		component.status = ECSSTATUS.DEACTIVATED
	end )
	Prop_Foreach( self, "children", function ( child )
		child:Activate()
	end)
	self.status = ECSSTATUS.DEACTIVATED
end


function ECSEntity:Update( deltaTime )
	Prop_Foreach( self, "components", function ( component )
		--print( "Update component", component.ecsname )
		if component.Update then component:Update( deltaTime ) end
	end )
	Prop_Foreach( self, "children", function ( child ) child:Update( deltaTime ) end )
end

---------------------------------------