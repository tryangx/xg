local function Training_Drill( role, data )
	local fighter = ECS_FindComponent( role.entityid, "FIGHTER_COMPONENT" )
	if not fighter then DBG_Error( "No fighter component" ) return end
	--local role = ECS_FindComponent( entityid, "ROLE_COMPONENT" )
	--if not role then DBG_Error( "No role component" ) return end

	--role's work
	local min = 100 - fighter.lv
	local max = role:GetTraitValue( "HARD_WORK" ) + role:GetTraitValue( "CONCENTRATION" ) + role:GetTraitValue( "INSPIRATION" )
	local inc = Random_GetInt_Sync( min, max )

	--seclude
	if data and data.exp then inc = math.ceil( inc * ( 100 + data.exp ) * 0.01 ) end

	--friends's work(todo)

	--gain exp
	fighter.exp = math.min( min, fighter.exp + inc )

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
		fighter.exp = fighter.exp - 100
	end
end


local function Training_ObtainKnowledge( role, data )
	local fighter = ECS_FindComponent( role.entityid, "FIGHTER_COMPONENT" )
	if not fighter then DBG_Error( "No fighter component" ) return end

	local min = role:GetTraitValue( "HARD_WORK" ) + role:GetTraitValue( "CONCENTRATION" ) + role:GetTraitValue( "INSPIRATION" )
	local max = fighter.lv
	local inc = fighter.lv + Random_GetInt_Sync( min, max )

	--seclude
	if data and data.knowledge then inc = math.ceil( inc * ( 100 + data.knowledge ) * 0.01 ) end

	fighter.knowledge = math.min( fighter.lv * 100, fighter.knowledge + inc )

	DBG_Trace( role.name, "seclude, gain knowledge=" .. fighter.knowledge .. "+" .. inc )		
end


local function Training_ObtainSkill( role )
	local fighter = ECS_FindComponent( role.entityid, "FIGHTER_COMPONENT" )
	if not fighter then DBG_Error( "No fighter component" ) return end
	
	local list = FIGHTSKILL_DATATABLE_Find( fighter )	
	local num = #list
	if num == 0 then return end
	local index = Random_GetInt_Sync( 1, num )
	local skill = list[index]
	fighter.knowledge = math.max( 0, fighter.knowledge - skill.conditions.knowledge )
	fighter:ObtainSkill( skill.id )
end


local TRAIN_SECLUDE_RESULT = 
{
	--{ prob=30, exp=100 },
	--{ prob=30, knowledge=100 },
	{ prob=30, skill=100 },
}
local function Training_Seclude( role )
	--Seclude leads several results:
	--  1. Gain exp
	--  2. Gain knowledge
	--  3. Obtain skill	
	local index  = Random_GetIndex_Sync( TRAIN_SECLUDE_RESULT, "prob" )
	local result = TRAIN_SECLUDE_RESULT[index]
	if result.skill then
		if Training_ObtainSkill( role ) then return end
	end
	if result.exp then Training_Drill( role, result ) end
	if result.knowledge then Training_ObtainKnowledge( role, result ) end
end


local function Training_ObtainBookSkill( role )
	local group = ECS_FindComponent( role.groupid, "GROUP_COMPONENT" )
	if not group then DBG_Error( "No group component" ) return end

	--for _, bookid in ipairs( group.books ) do
	local index = #group.books
	local bookid = group.books[index]
		local book = BOOK_DATATABLE_Get( bookid )
		if book.commonskill then
			role:ObtainCommonSkill( book )
		elseif book.passiveSkill then
			fighter:ObtainSkill( book.passiveSkill )
		elseif book.fightSkill then
			fighter:ObtainSkill( book.fightSkill )
		end
	--end
end

local TRAIN_READBOOK_RESULT = 
{
	--{ prob=30 },
	--{ prob=30, exp=100 },	
	{ prob=30, readbook=100 },
}
local function Training_ReadBook( role )
	--Read book leads several results:
	--  1. Gain knowledge
	--  2. Gain skill
	local index  = Random_GetIndex_Sync( TRAIN_READBOOK_RESULT, "prob" )
	local result = TRAIN_READBOOK_RESULT[index]
	if result.exp then Training_Drill( role, result ) end
	if result.readbook then Training_ObtainBookSkill( role ) end
end

local function Training_Train( data, deltaTime )
	if data.teacher then
		data.teacher.exp = 0
		if data.teacher.time > 0 then
			--teacher works
			data.teacher.time = data.teacher.time - time
			if data.teacher.time <= 0 then
				data.teacher.exp  = 50
			end
		end	
	end

	if data.pupils and data.time > 0 then
		data.time = data.time - deltaTime
		if data.time <= 0 then
			for _, role in ipairs( data.pupils ) do Training_Drill( role, data and data.teacher or nil ) end
		end
	end

	if data.seclude and data.seclude.time > 0 then
		data.seclude.time = data.seclude.time - deltaTime
		if data.seclude.time <= 0 then
			Training_Seclude( data.seclude.role )
		end
	end

	if data.reader and data.reader.time > 0 then
		data.reader.time = data.reader.time - deltaTime
		if data.reader.time <= 0 then
			Training_ReadBook( data.reader.role )
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
function TRAINING_SYSTEM:Update( deltaTime )
	for _, data in pairs( self._datas ) do
		Training_Train( data, deltaTime )
	end
	self._datas = {}
end

---------------------------------------
function TRAINING_SYSTEM:AddTeacher( groupid, teacher, time )
	if not groupid then groupid = role.entityid end
	if not self._datas[groupid] then self._datas[groupid] = {} end
	if not self._datas[groupid].teacher then self._datas[groupid].teacher = {} end
	print( teacher.name, "as teacher" )
	self._datas[groupid].teacher.role = teacher
	self._datas[groupid].teacher.time = time
end

---------------------------------------
function TRAINING_SYSTEM:AddPupil( groupid, role, time )
	if not groupid then groupid = role.entityid end
	if not self._datas[groupid] then self._datas[groupid] = {} end
	if not self._datas[groupid].pupils then self._datas[groupid].pupils = {} end
	--print( role.name, "as pupil" )
	self._datas[groupid].time = time
	table.insert( self._datas[groupid].pupils, role )
end

---------------------------------------
function TRAINING_SYSTEM:AddSeclude( role, time )
	local groupid = role.entityid
	if not self._datas[groupid] then self._datas[groupid] = {} end
	if not self._datas[groupid].seclude then self._datas[groupid].seclude = {} end
	--print( role.name, "as pupil" )
	self._datas[groupid].seclude.role = role
	self._datas[groupid].seclude.time = time
end

---------------------------------------
function TRAINING_SYSTEM:AddReader( role, time )
	local groupid = role.entityid
	if not self._datas[groupid] then self._datas[groupid] = {} end
	if not self._datas[groupid].reader then self._datas[groupid].reader = {} end
	--print( role.name, "as pupil" )
	self._datas[groupid].reader.role = role
	self._datas[groupid].reader.time = time
end