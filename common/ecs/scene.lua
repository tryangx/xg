--[[
	Scene 

	1. Include a bundle of entities
	2. Implement the features of a menu, a scene, even a game.
	3. 

--]]
---------------------------------------
ECSSceneStatus =
{
	CREATED      = 0,
	INITED       = 1,
	ACTIVATING   = 2,
	ACTIVATED    = 3,
	DEACTIVATING = 4,
	DEACTIVATED  = 5,
}

---------------------------------------
ECSScene = class()

---------------------------------------
ECSSceneProperties = 
{
	status   = { type="NUMBER" },
	entities = { type="LIST" },
}

---------------------------------------
function ECSScene:__init()
	self._properties = ECSSceneProperties
	self.status = CREATED
	print( "init ecsscene" )
end

---------------------------------------
function ECSScene:CreateEntity( name )
	local entity = ECS_CreateEntity( name )
	Prop_Add( self, "entities", entity )
	return entity
end

---------------------------------------
function ECSScene:RemoveEntityById( id )
	Prop_RemoveById( self, "entities", id )
end

---------------------------------------
