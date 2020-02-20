---------------------------------------
---------------------------------------
--[[
	Scene 

	1. Include a bundle of entities
	2. Implement the features of a menu, a scene, even a game.
	3. 

--]]
---------------------------------------
---------------------------------------
ECSScene = class()

---------------------------------------
ECSSceneProperties = 
{
	ecsid        = { type="NUMBER" },
	rootentity   = { type="OBJECT" },
}

---------------------------------------
function ECSScene:__init()
	self._properties = ECSSceneProperties
	--self.status = CREATED
	self.status = ECSSCENESTATUS.INITED
end

---------------------------------------
function ECSScene:GetRootEntity()
	local entity = Prop_Get( self, "rootentity" )
	if not entity then Prop_Set( self, "rootentity", ECS_CreateEntity( "RootEntity" ) ) end
	return entity
end

---------------------------------------
function ECSScene:SetRootEntity( entity )
	--should remove the exist one
	if self.rootentity then DBG_Error( "Root entity is already exist!" ) end
	entity.scene    = self
	self.rootentity = entity
end

---------------------------------------
function ECSScene:RemoveEntityById( id )
	Prop_RemoveById( self, "entities", id )
end

---------------------------------------
--
-- Regular methods
--
---------------------------------------
function ECSScene:Activate()
	if self.status ~= ECSSCENESTATUS.INITED then DBG_Error( "Current scene isn't initialized" ) return end
	print( "RootEntity=", self:GetRootEntity() )
	self:GetRootEntity():Activate()
end


function ECSScene:Deactivate()
	if self.status ~= ECSSCENESTATUS.ACTIVATED then DBG_Error( "Current scene cann't be deactivated, the status is" .. ( self.status or "UNKNOWN" ) ) return end	
	self:GetRootEntity():Deactivate()
end


function ECSScene:Update()
	if self.status ~= ECSSCENESTATUS.ACTIVATED then DBG_Error( "Current scene isn't activated" ) return end
	self:GetRootEntity():Update()
end


---------------------------------------