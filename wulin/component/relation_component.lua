---------------------------------------
---------------------------------------
local function Relation_RaiseOpinion( relation )
	if relation.opinion == "ENEMY" then
		relation.opinion = "HOSTILE"
	elseif relation.opinion == "HOSTILE" then
		relation.opinion = "NEUTRAL"	
	elseif relation.opinion == "NEUTRAL" then
		relation.opinion = "TRUST"
	elseif relation.opinion == "TRUST" then
		relation.opinion = "FRIEND"	
	else
		return
	end
	relation.eval = 0
end

local function Relation_LowDownOpinion( relation )
	if relation.opinion == "FRIEND" then
		relation.opinion = "TRUST"
	elseif relation.opinion == "TRUST" then
		relation.opinion = "NEUTRAL"	
	elseif relation.opinion == "NEUTRAL" then
		relation.opinion = "HOSTILE"
	elseif relation.opinion == "HOSTILE" then
		relation.opinion = "ENEMY"	
	else
		return
	end
	relation.eval = 0
end


local function Relation_Update( relation, deltaTime )
	--how long since status changed
	relation.elapsed = relation.elapsed + deltaTime

	--realtions
	if relation.eval > 0 then
		relation.eval = math.max( 0, relation.eval - deltaTime )
	elseif relation.eval > 0 then
		relation.eval = math.min( 0, relation.eval + deltaTime )
	end
	local range = 100
	if relation.eval >= range then
		Relation_RaiseOpinion( relation )
	elseif relation.eval <= range then
		Relation_LowDownOpinion( relation )
	end

	--pacts
	for type, pact in pairs( relation.pacts ) do
		pact.time = pact.time - deltaTime
		pact.elapsed = pact.elapsed + deltaTime
		if type ~= "ATWAR" and pact.time <= 0 then
			relation.pacts[type] = nil
		end
	end	
end


---------------------------------------
---------------------------------------
function HandlePactResult( relation, pact )
--   1. Change Relation Status                   ==> change_status={ status=%status% }
--   2. A time counter to finish or end the pat  ==> time=%number%
--   3. Pay tribute by ratio of stock            ==> tribute_stock_ratio={ status=%status%, }
--   4. Modify the details info for each other   ==> detail={ opp=%number%, our=%number%, }
--   5. We or they should be independent         ==> independent={ opp=, our=, }	
	local time = 0

	local oppRelationCmp = ECS_FindComponent( relation.id, "RELATION_COMPONENT" )
	local oppRelation = oppRelationCmp:GetRelation( relation.entityid )
	local result = RELATION_PACT[pact].results
	if result.change_status then
		if result.change_status.our then
			relation.status = result.change_status.our
			relation.elapsed = 0
		end
		if result.change_status.opp then
			oppRelation.status = result.change_status.opp
			oppRelation.elapsed = 0
		end
	end

	if result.time then
		time = result.time
	end

	if result.tribute_stock_ratio then
		--todo
	end

	if result.detail then		
		if result.detail.our then
			for detailtype, value in pairs( result.detail.our ) do
				if not value then
					relation.details[detailtype] = relation.details[detailtype] and relation.details[detailtype] + value or value
				else
					relation.details[detailtype] = value
				end
			end
		end
		if result.detail.opp then
			for detailtype, value in pairs( result.detail.opp ) do
				if not value then
					oppRelation.details[detailtype] = oppRelation.details[detailtype] and oppRelation.details[detailtype] + value or value
				else
					oppRelation.details[detailtype] = value
				end
			end
		end
	end
	if result.independent then
		--todo
	end
	
	relation.pacts[pact] = { time=time, elapsed=0 }
end


---------------------------------------
function Relation_AlterRelationship( relation, eval )
	local range = 100
	relation.eval = math.max( -range, math.min( relation.eval + eval, range ) )
end

---------------------------------------
---------------------------------------
function Relation_GetEval( relation )
	return RELATION_OPINION[relation.opinion]
end


function Relation_CanAttack( relation )
	if relation.status == "ATWAR" then return true end
	if relation.status == "ALLY" then return false end
	if relation.status == "FRIEND" then return false end
	return true
end

function Relation_HasSameEnemy( relation )
	return false
end

function Relation_IsPotentialAlly( relation )
	return false
end

function Relation_CanGrantGift( relation )
	if relation.status ~= ATWAR then return true end
	return false
end

---------------------------------------
---------------------------------------
function Relation_MakeVassal( monarchid, vassalid )
	local monarchRelationCmp = ECS_FindComponent( monarchid, "RELATION_COMPONENT" )
	local vassalRelationCmp = ECS_FindComponent( vassalid, "RELATION_COMPONENT" )
	local monarchRelation = monarchRelationCmp:GetRelation( vassalid )
	local vassalRelation = vassalRelationCmp:GetRelation( monarchid )

	vassalRelation.status  = "VASSAL"
	vassalRelation.elapsed = 0
	vassalRelation.eval    = 0
	
	monarchRelation.status = "MONARCH"
	monarchRelation.elapsed = 0
	monarchRelation.eval    = 0
	monarchRelationCmp.details["WE_ARE_MONARCH"] = 1

	Dump( vassalRelationCmp.details )
	if vassalRelationCmp.details["WE_ARE_MONARCH"] then
		InputUtil_Pause( "vassal is monarch" )
		for _, relation in pairs( vassalRelationCmp.relations ) do
			if relation.id ~= monarchid and relation.status == "VASSAL" then
				relation.status  = "NONE"
				relation.elapsed = 0
				relation.eval    = 0
				print(  ECS_FindComponent( monarchid, "GROUP_COMPONENT" ).name )
				 print( ECS_FindComponent( relation.id, "GROUP_COMPONENT" ).name )
				 InputUtil_Pause( "vassal's vassal" )
				Relation_MakeVassal( monarchid, relation.id )
			end
		end
	end

	InputUtil_Pause( ECS_FindComponent( monarchid, "GROUP_COMPONENT" ).name .. " make " .. ECS_FindComponent( vassalid, "GROUP_COMPONENT" ).name .. " as vassal" )
end

---------------------------------------
---------------------------------------
RELATION_COMPONENT = class()


---------------------------------------
RELATION_PROPERTIES = 
{
	------------------------------------------------------------------------------
	-- Store the relations to other groups
	-- @note data structure: id={ opinion=0, status=0, eval=0, pact={} },
	------------------------------------------------------------------------------
	relations = { type="DICT" },

	------------------------------------------------------------------------------
	-- Relation details to affect the diplomacy policy probability
	---------------------------------------
	details   = { type="DICT" },

	---------------------------------------
	-- How long since status changed
	---------------------------------------
	elapsed   = { type="NUMBER", default=0 },
}

---------------------------------------
function RELATION_COMPONENT:Update( deltaTime )
	--How long stay at the current status
	self.elapsed = self.elapsed + deltaTime

	--Update each relation
	for _, relation in pairs( self.relations ) do Relation_Update( relation, deltaTime ) end
end

---------------------------------------
function RELATION_COMPONENT:Foreach( fn )
	for _, relation in pairs( self.relations ) do
		fn( relation )
	end
end

---------------------------------------
function RELATION_COMPONENT:GetRelation( id )
	if not self.relations[id] then
		self.relations[id] = { entityid=self.entityid, id=id, opinion="NEUTRAL", status="NONE", eval=0, elapsed=0, pacts={}, details={} }
	end
	return self.relations[id]
end

function RELATION_COMPONENT:GetNumOfRelation( params )
	local num = 0
	for _, relation in pairs( self.relations ) do
		if params.status and relation.status == params.status then num = num + 1 end
	end
	return num
end

---------------------------------------
function RELATION_COMPONENT:SetStatus()

end

---------------------------------------
function RELATION_COMPONENT:GetDetailStatus( type )
	return self.details[type] or 0
end

---------------------------------------
function RELATION_COMPONENT:SignPact( id, type, time )
	local relation = self:GetRelation( id )	
	HandlePactResult( relation, pact )
end


function RELATION_COMPONENT:EndPact( id, type )
	local relation = self:GetRelation( id )
	relation.pacts[type] = nil
end


function RELATION_COMPONENT:AddPactStatus( id, pacttype, name, value )
	local relation = self:GetRelation( id )
	local pact = relation.pacts[type]
	if pact then pact[name] = pact[name] and pact[name] + value or value end
	error( "add pact" )
end

---------------------------------------
function RELATION_COMPONENT:SetOpinion( id, type )
	local relation = self:GetRelation( id )
	relation.opinion = type
end
