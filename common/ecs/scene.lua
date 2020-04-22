---------------------------------------
---------------------------------------
local function ImportRootEntity( scene )
	scene.rootEntity.sceneid = scene.ecsid
end

ECSSCENEPROPERTIES = 
{
	rootEntity   = { type="OBJECT", import=ImportRootEntity },
}


---------------------------------------
---------------------------------------
--[[
	Scene 

	1. Include a bundle of entities
	2. Implement the features of a menu, a scene, even a game.
	3. 

--]]
---------------------------------------
ECSScene = class()


---------------------------------------
function ECSScene:__init()
	self._properties = ECSSCENEPROPERTIES
	--self.status = CREATED
	self.status = ECSSTATUS.CREATED
end

---------------------------------------
function ECSScene:GetRootEntity()
	local entity = Prop_Get( self, "rootEntity" )
	if not entity then
		InputUtil_Pause( "it isn't recommended" )
		Prop_Set( self, "rootEntity", ECS_CreateEntity( "RootEntity" ) )
	end
	return entity
end

---------------------------------------
function ECSScene:SetRootEntity( entity )
	--should remove the exist one
	if self.rootEntity then DBG_Error( "Root entity is already exist!" ) return end
	entity.sceneid  = self.ecsid
	self.rootEntity = entity
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
	--print( "Activate Scene" )
	if self.status ~= ECSSTATUS.INITED and self.status ~= ECSSTATUS.DEACTIVATED then DBG_Error( "Current scene isn't initialized! Status=" .. self.status ) return end
	self.status = ECSSTATUS.ACTIVATING
	self:GetRootEntity():Activate()
	self.status = ECSSTATUS.ACTIVATED
end


function ECSScene:Deactivate()
	--print( "Deactivate Scene" )
	if self.status ~= ECSSTATUS.ACTIVATED then DBG_Error( "Current scene cann't be deactivated, the status is" .. ( self.status or "UNKNOWN" ) ) return end	
	self.status = ECSSTATUS.DEACTIVATING
	self:GetRootEntity():Deactivate()
	self.status = ECSSTATUS.DEACTIVATED
end


function ECSScene:Update( deltaTime )
	if self.status ~= ECSSTATUS.ACTIVATED then DBG_Error( "Current scene isn't activated", self.status ) return end
	self:GetRootEntity():Update( deltaTime )
end