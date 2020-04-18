---------------------------------------
---------------------------------------
function Relation_EndRelation( group )	
	local relationCmp = ECS_FindComponent( group.entityid, "RELATION_COMPONENT" )
	for _, relation in pairs( relationCmp.relations ) do
		local targetRelation = ECS_FindComponent( relation.id, "RELATION_COMPONENT" )
		targetRelation.relations[group.entityid] = nil
	end
end


---------------------------------------
-- End all relations, mostly used when group terminated
---------------------------------------
function RELATION_COMPONENT:EndAllRelation()

end

function RELATION_COMPONENT:EndRelation( fromId )

end

---------------------------------------
---------------------------------------
RELATION_SYSTEM = class()


---------------------------------------
---------------------------------------
function RELATION_SYSTEM:__init( ... )
	local args = ...
	self._name = args and args.name or "RELATION_SYSTEM"
end


---------------------------------------
---------------------------------------
function RELATION_SYSTEM:Update( deltaTime )
end