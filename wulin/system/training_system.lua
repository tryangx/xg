local function Training_Drill( role, data )
	local fighter = ECS_FindComponent( role.entityid, "FIGHTER_COMPONENT" )
	if not fighter then DBG_Error( "No fighter component" ) return end
	--local role = ECS_FindComponent( entityid, "ROLE_COMPONENT" )
	--if not role then DBG_Error( "No role component" ) return end

	--role's work
	local min = 100 - fighter.lv
	local max = role:GetTraitValue( "HARD_WORK" ) + role:GetTraitValue( "CONCENTRATION" ) + role:GetTraitValue( "INSPIRATION" )
	local exp = Random_GetInt_Sync( min, max )	

	--teacher'work
	exp = math.ceil( exp * ( 100 + ( data.teacher and data.teacher.eff or 0 ) ) * 0.01 )

	--friends's work(todo)

	--gain exp
	fighter.exp = math.min( min, fighter.exp + exp )	

	--level up
	if fighter.exp >= 100 then
		local fightertemplate = ECS_FindComponent( role.entityid, "FIGHTERTEMPLATE_COMPONENT" )
		if not fightertemplate then DBG_Error( "No fightertemplate component" ) return end
		Track_Reset()
		Track_Table( "fighter", fighter )
		ECS_GetSystem( "FIGHTER_SYSTEM" ):LevelUp( fighter, fightertemplate, 30 )
		Track_Table( "fighter", fighter )
		--Track_Dump( nil, true )
		DBG_Trace( role.name, "drill, gain exp=" .. fighter.exp .. "+" .. exp )		
		Log_Write( "role", role.name .. " LevelUp to " .. fighter.lv )
		fighter.exp = 0
	end
end

local function Training_Train( data )
	if data.teacher then
		--teacher works
		data.teacher.eff = 50
	end
	if data.pupils then
		for _, role in ipairs( data.pupils ) do
			Training_Drill( role, data )
		end
	end
end

---------------------------------------
---------------------------------------
TRAINING_SYSTEM = class()

---------------------------------------
function TRAINING_SYSTEM:__init( ... )
	local args = ...
	self._name = args and args.name or "TRAINING_SYSTEM"

	self._datas = {}
end

---------------------------------------
function TRAINING_SYSTEM:Update()
	for _, data in pairs( self._datas ) do
		Training_Train( data )
	end
	self._datas = {}
end

---------------------------------------
function TRAINING_SYSTEM:AddTeacher( groupid, teacher )
	if not groupid then groupid = role.entityid end
	if not self._datas[groupid] then
		self._datas[groupid] = {}
	end
	if not self._datas[groupid].teacher then
		self._datas[groupid].teacher = {}
	end
	print( teacher.name, "as teacher" )
	self._datas[groupid].teacher.role = teacher
end

---------------------------------------
function TRAINING_SYSTEM:AddPupil( groupid, role )
	if not groupid then groupid = role.entityid end
	if not self._datas[groupid] then
		self._datas[groupid] = {}
	end
	if not self._datas[groupid].pupils then
		self._datas[groupid].pupils = {}
	end
	--print( role.name, "as pupil" )
	table.insert( self._datas[groupid].pupils, role )
end