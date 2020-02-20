Randomizer = class()

function Randomizer:__init( seed )
	self.seed = seed or 0
	self.times = 0
end

function Randomizer:GetSeed( seed )
	return self.seed
end

function Randomizer:SetSeed( seed )
	self.seed = seed
end

--return value in range of [min, max]
function Randomizer:GetInt( min, max )
	self.times = self.times + 1		
	self.seed = ( self.seed * 32765 + 12345 ) % 2147483647
	if min < max then
		return self.seed % ( max - min + 1 ) + min
	elseif min > max then
		return self.seed % ( min - max + 1 ) + max
	end
	return min
end

-------------------------------------------

local _randomizer       = Randomizer()
local _unsyncRandomizer = Randomizer()
local _constRandomizer  = Randomizer()

function Random_Result()
	Log_Add( "random", "seed1=" .. _randomizer:GetSeed() .. "+" .. _randomizer.times )
	--Log_Add( "random", "seed2=" .. _unsyncRandomizer:GetSeed() .. "+" .. _unsyncRandomizer.times )
	--Log_Add( "random", "seed3=" .. _constRandomizer:GetSeed() .. "+" .. _constRandomizer.times )
end

function Random_SetSeed_Sync( seed )
	Log_Add( "random", "seed1_init=" .. seed )
	_randomizer:SetSeed( seed )
end
function Random_SetSeed_Unsync( seed )
	Log_Add( "random", "seed2_init=" .. seed )
	_unsyncRandomizer:SetSeed( seed )
end
function Random_SetSeed( seed )
	Log_Add( "random", "gameid=" .. g_gameId )
	Random_SetSeed_Sync( seed )
end
function Random_GetInt_Sync( min, max, desc )
	if desc then
		--Log_Add( "random", "time=" .. _randomizer.times .. " seed=" .. _randomizer.seed .. " min=" .. min .. " max=" .. max .. ( desc and " desc=" .. desc or "" ) )
	end
	local ret = _randomizer:GetInt( min, max )	
	return ret
end
function Random_GetInt_Unsync( min, max )
	return _unsyncRandomizer:GetInt( min, max )
end

-------------------------------------------------

--[[
function Random_GetInt( min, max, desc )
	return Random_GetInt_Sync( min, max, desc )
end
]]

function Random_GetInt_Const( min, max, seed )
	if not seed then error( "no seed" ) end
	_constRandomizer:SetSeed( seed )
	return _constRandomizer:GetInt( min, max )
end

--[[
	@usage
	local list = 
	{
		{ prob = 10, ret = 1 },
		{ prob = 20, ret = 1 },
	}
	print( Random_GetIndex_Sync( list, "prob" ) )
--]]
function Random_GetIndex_Sync( list, probName )
	local totalProb = Cache_Get( list )
	if not totalProb then
		totalProb = MathUtil_SumIf( list, probName, nil, probName )
		Cache_Set( list, totalProb )
	end
	local prob = Random_GetInt_Sync( 1, totalProb )
	for index, data in pairs( list ) do
		if prob <= data[probName] then
			return index
		else
			prob = prob - data[probName]
		end
	end
	return nil
end

--[[
	@usage
	local list = 
	{
		{ prob = 10, ret = 1 },
		{ prob = 20, ret = 1 },
	}
	print( Random_GetTable_Sync( list, "prob" ) )
--]]
function Random_GetTable_Sync( list, probName )
	local totalProb = Cache_Get( list )
	if not totalProb then
		totalProb = MathUtil_SumIf( list, probName, nil, probName )
		Cache_Set( list, totalProb )
	end
	local prob = Random_GetInt_Sync( 1, totalProb )
	for index, data in pairs( list ) do
		if prob <= data[probName] then
			return list[index], index
		else
			prob = prob - data[probName]
		end
	end
	return nil
end

function Random_GetDictData( entity, id )
	local list = Asset_GetListFromDict( entity, id )
	if #list then return nil end
	return list[Random_GetInt_Sync( 1, #list )]
end

function Random_GetListData( entity, id )
	local number = Asset_GetListSize( entity, id )
	if number == 0 then return nil end
	return Asset_GetListItem( entity, id, Random_GetInt_Sync( 1, number ) )
end

function Random_GetListItem( list )
	local number = #list
	if number == 0 then return nil end
	if number == 1 then return list[1] end
	return list[Random_GetInt_Sync( 1, number )]
end


-- Randomizer
function Random_LocalGetRange( min, max, desc )
	local value = g_asyncRandomizer:GetInt( min, max )
	if desc then 
		Debug_Log( "Gen Random ["..value.."] in ["..min..","..max.."] : " .. desc )
	end
	return value
end

function Random_SyncGetRange( min, max, desc )
	local value = g_syncRandomizer:GetInt( min, max )
	if desc then 
		Debug_Log( "Gen Random ["..value.."] in ["..min..","..max.."] : " .. desc )
	end
	return value
end

function Random_SyncGetProb( desc )
	local value = g_syncRandomizer:GetInt( 1, 10000 )
	if desc then 
		Debug_Log( "Gen Random ["..value.."] in ["..min..","..max.."] : " .. desc )
	end
	return value
end