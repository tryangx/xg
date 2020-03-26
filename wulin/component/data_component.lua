---------------------------------------
---------------------------------------
DATA_COMPONENT = class()

---------------------------------------
DATA_PROPERTIES = 
{
	type = { type="STRING" },
}

---------------------------------------
function DATA_COMPONENT:__init()
end


---------------------------------------
function DATA_COMPONENT:Activate()
	Data_SetRootEntity( self.type, self.entityid )
end
