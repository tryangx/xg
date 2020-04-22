--------------------------------------------------
--------------------------------------------------
local PROCESS_DATATABLE = 
{
	[10] =
	{
		name       = "炼钢",
		type       = "SMELT",
		targetType = "STEEL",
		conditions = { commonskill={type="BLACKSMITH",lv=1}, construction={type="SMITHY"} },
		materials  = { type="IRON_ORE", quantity=100 },
		products   = {
						{ restype="STEEL", quantity=20 },
					 },
		time       = { day=60 },
	},
	[20] =
	{
		name       = "饲养",
		type       = "RAISELIVESTOK",
		targetType = "LIVESTOCK",
		conditions = { commonskill={type="STOCKMAN",lv=1}, construction={type="FARM"} },
		materials  = { },
		products   = {
						{restype="LIVESTOCK", quantity=20},
					 },
		time       = { day=180 },
	},
	[30] =
	{
		name       = "种草药",		
		type       = "PLANTHERB",
		targetType = "HERB",
		conditions = { commonskill={type="GROWER",lv=1}, construction={type="GARDEN"} },
		materials  = { },
		products   = {
						{restype="HERB", quantity=20},
					 },
		time       = { day=90 },
	},
	[40] =
	{
		name       = "制药",
		type       = "MAKEMEDICINE",
		targetType = "MEDICINE",
		conditions = { commonskill={type="APOTHECARIES",lv=1}, construction={type="PHARMACY"} },
		materials  = { type="HERB", quantity=30 },
		products   = {
			 			{itemtype="MEDICINE", itemid=100, quantity=1},
			 			{itemtype="MEDICINE", itemid=110, quantity=1},
			 			{itemtype="MEDICINE", itemid=120, quantity=1},
			 		 },
		time       = { day=30 },
	},

	[1000] =
	{
		name       = "武器打制",
		type       = "MAKEITEM",
		targetType = "WEAPON",
		conditions = { commonskill={type="BLACKSMITH",lv=5}, construction={type="ARMORY"} },
		materials  = { type="STEEL", quantity=30 },
		products   = {
						{itemtype="WEAPON", itemid=1000, quantity=1},
						{itemtype="WEAPON", itemid=1001, quantity=1},
					 },
		time       = { day=30 },
	},
	[2000] =
	{
		name       = "护甲打制",
		type       = "MAKEITEM",
		targetType = "ARMOR",
		conditions = { commonskill={type="BLACKSMITH",lv=5}, construction={type="ARMORY"} },
		materials  = { type="LEATHER", quantity=30 },
		products   = {
						{itemtype="ARMOR", itemid=2000, quantity=1},
					 },
		time       = { day=30 },
	},
	[3000] =
	{
		name       = "制鞋",
		type       = "MAKEITEM",
		targetType = "SHOES",
		conditions = { commonskill={type="TAILOR",lv=5}, construction={type="LETHER_FACTORY"} },
		materials  = { type="CLOTH", quantity=30 },
		products   = {
						{itemtype="SHOES", itemid=3000, quantity=1},
					 },
		time       = { day=30 },
	},
	[4000] =
	{
		name       = "加工",
		type       = "MAKEITEM",
		targetType = "ACCESSORY",
		conditions = { commonskill={type="TOOLMAKER",lv=5}, construction={type="FACTORY"} },
		materials  = { type="JUDE", quantity=30 },
		products   = {
						{itemtype="ACCESSORY", itemid=4000, quantity=1},
					 },
		time       = { day=30 },
	},
	[5000] =
	{
		name       = "育马",
		type       = "MAKEITEM",
		targetType = "VEHICLE",
		conditions = { commonskill={type="BLACKSMITH",lv=5}, construction={type="PASTURE"} },
		materials  = { type="STEEL", quantity=30 },
		products   = {
						{itemtype="VEHICLE", itemid=5000, quantity=1},
					 },
		time       = { day=30 },
	},
}


--------------------------------------------------
function PROCESS_DATATABLE_Get( id )
	return PROCESS_DATATABLE[id]
end


--------------------------------------------------
local function PROCESS_DATATABLE_Match( group, process, addWishList )
	if process.materials then
		if process.materials.type and group:GetNumOfResource( process.materials.type ) < process.materials.quantity then
			if addWishList then
				DBG_Trace( "no materials", process.materials.type, process.materials.quantity )
				group:AddWishResource( process.materials.type, process.materials.quantity )				
			end
			return false
		end
	end

	if process.conditions then
		if process.conditions.construction then
		 	if group:GetNumOfConstruction( process.conditions.construction.type ) <= 0 then
		 		if addWishList then
			 		DBG_Trace( "no construction", process.conditions.construction.type )
			 		group:AddWishConstruction( process.conditions.construction.type )
			 	end
		 		return false
		 	end
		end
		if process.conditions.commonskill then			
			local list = group:FindMember( function ( ecsid )
				local role = ECS_FindComponent( ecsid, "ROLE_COMPONENT" )
				if addWishList then
					DBG_Trace( "no commonskill", process.conditions.commonskill.type, process.conditions.commonskill.lv )
					return role:HasCommonSkill( process.conditions.commonskill.type, process.conditions.commonskill.lv )
				end
			end )
			if #list == 0 then
				DBG_Trace( "no common skill", process.conditions.commonskill.type )
				return false
			end
		end		
	end

	return true
end


--------------------------------------------------
function PROCESS_DATATABLE_Find( group, processType, addWishList )
	if not addWishList then addWishList = true end
	local list = {}
	for _, process in pairs( PROCESS_DATATABLE ) do
		if not types or type == process.type then
			if PROCESS_DATATABLE_Match( group, process, addWishList ) then
				table.insert( list, process )
			end
		end
	end
	return list
end


--------------------------------------------------
function PROCESS_DATATABLE_FindByItem( group, itemType, itemId, addWishList )
	if not addWishList then addWishList = true end
	local list = {}
	for _, process in pairs( PROCESS_DATATABLE ) do
		if process.targetType == itemType then			
			for _, data in ipairs( process.products ) do
				--print( "find item", data.itemtype, data.itemid, itemType, itemId )
				if data.itemtype == itemType and data.itemid == itemId then
					if PROCESS_DATATABLE_Match( group, process, addWishList ) then
						print( "match process datatable" )
						table.insert( list, process )
					end
					break
				end
			end
		end
	end
	return list
end


function PROCESS_DATATABLE_FindByResource( group, resourceType, addWishList )
	if not addWishList then addWishList = true end
	local list = {}
	for _, process in pairs( PROCESS_DATATABLE ) do
		if process.targetType == resourceType then
			for _, data in ipairs( process.products ) do
				if data.restype == resourceType then
					if PROCESS_DATATABLE_Match( group, process, addWishList ) then
						table.insert( list, process )						
					end
					break
				end
			end
		end
	end
	return list
end