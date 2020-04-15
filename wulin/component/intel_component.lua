---------------------------------------
---------------------------------------
local function Intel_RaiseIntelGrade( intel )
	if intel.grade == "UNKNOWN" then
		intel.grade = "LOW"
	elseif intel.grade == "LOW" then
		intel.grade = "MID"	
	elseif intel.grade == "MID" then
		intel.grade = "HIGH"
	elseif intel.grade == "HIGH" then
		intel.grade = "FULL"	
	else
		return
	end
	intel.eval = 0
end

local function Intel_LowDownIntelGrade( intel )
	if intel.grade == "FULL" then
		intel.grade = "HIGH"
	elseif intel.grade == "HIGH" then
		intel.grade = "MID"	
	elseif intel.grade == "MID" then
		intel.grade = "LOW"
	elseif intel.grade == "LOW" then
		intel.grade = "UNKNOWN"
	else
		return
	end
	intel.eval = 0
end

local function Intel_Update( intel, deltaTime )
	if intel.eval > 0 then
		intel.eval = math.max( 0, intel.eval - deltaTime )
	elseif intel.eval > 0 then
		intel.eval = math.min( 0, intel.eval + deltaTime )
	end
	local range = 100
	if intel.eval >= range then
		Intel_RaiseIntelGrade( intel )
	elseif intel.eval <= range then
		Intel_LowDownIntelGrade( intel )
	end
end


---------------------------------------
---------------------------------------
function Intel_GetEval( intel )
	return INTEL_GRADE[intel.grade] + intel.eval
end


function Intel_GetGroupPower( intel )
	local group = ECS_FindComponent( intel.id, "GROUP_COMPONENT" )
	local power = group:GetAttr( "POWER" )	
	local seed  = MathUtil_ToNumber( intel.entityid ) + MathUtil_ToNumber( intel.id )
	local mod = Random_GetInt_Const( 80, 120, seed )
	power = math.ceil( power * mod * 0.01 )
	return power
end


---------------------------------------
---------------------------------------
INTEL_COMPONENT = class()

---------------------------------------
INTEL_PROPERTIES = 
{
	--id={ grade=0, eval=0 },
	groupintels = { type="DICT" },

	--id={ grade=0, eval=0 },
	roleintels  = { type="DICT" },
}


---------------------------------------

function INTEL_COMPONENT:Update( deltaTime )
	for _, intel in pairs( self.groupintels ) do Intel_Update( intel, deltaTime ) end
	for _, intel in pairs( self.roleintels ) do Intel_Update( intel, deltaTime ) end
end

---------------------------------------
function INTEL_COMPONENT:GetGroupIntel( id )
	if not self.groupintels[id] then
		self.groupintels[id] = { entityid=self.entityid, id=id, grade="UNKNOWN", eval=0 }
		Dump( self.groupintels[id] )		
	end
	return self.groupintels[id]
end


function INTEL_COMPONENT:GetRoleIntel( id )
	if not self.roleintels[id] then
		self.roleintels[id] = { grade="UNKNOWN", eval=0 }
	end
	return self.roleintels[id]
end

function INTEL_COMPONENT:ForeachGroupIntel( fn )
	for _, intel in pairs( self.groupintels ) do
		fn( intel )
	end
end

function INTEL_COMPONENT:ForeachRoleIntel( fn )
	for _, intel in pairs( self.roleintels ) do
		fn( intel )
	end
end

---------------------------------------
function INTEL_COMPONENT:AcquireGroupIntel( id, eval )
	local intel = self:GetGroupIntel( id )
	local range = 100
	intel.eval  = math.max( -range, math.min( range, intel.eval + eval ) )
end

function INTEL_COMPONENT:AcquireRoleIntel( id, eval )
	local intel = self:GetRoleIntel( id )
	local range = 100
	intel.eval  = math.max( -range, math.min( range, intel.eval + eval ) )
end