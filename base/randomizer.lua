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
	Log_Write( "random", "seed1=" .. _randomizer:GetSeed() .. "+" .. _randomizer.times )
end

function Random_SetSeed_Sync( seed )
	Log_Write( "random", "seed1_init=" .. seed )
	_randomizer:SetSeed( seed )
end
function Random_SetSeed_Unsync( seed )
	Log_Write( "random", "seed2_init=" .. seed )
	_unsyncRandomizer:SetSeed( seed )
end
function Random_SetSeed( seed )
	Log_Write( "random", "gameid=" .. g_gameId )
	Random_SetSeed_Sync( seed )
end

-------------------------------------------------
--
-- Get synchronize random number
-- @note It should be used in internal process
-- which is important.
-- 
-------------------------------------------------
function Random_GetInt_Sync( min, max, desc )
	if desc then
		--Log_Write( "random", "time=" .. _randomizer.times .. " seed=" .. _randomizer.seed .. " min=" .. min .. " max=" .. max .. ( desc and " desc=" .. desc or "" ) )
	end
	local ret = _randomizer:GetInt( min, max )	
	return ret
end


-------------------------------------------------
--
-- Get unsynchronize random number
-- @note It always used in Display logical which
-- isn't important.
--
-------------------------------------------------
function Random_GetInt_Unsync( min, max )
	return _unsyncRandomizer:GetInt( min, max )
end


-------------------------------------------------
--
-- Get the certain random 
-- @note It always used in special logical which
-- can be repeated.
--
-------------------------------------------------
function Random_GetInt_Const( min, max, seed )
	if not seed then error( "no seed" ) end
	_constRandomizer:SetSeed( seed )
	return _constRandomizer:GetInt( min, max )
end


-------------------------------------------------
--	@usage
--	local list = 
--	{
--		{ prob = 10, ret = 1 },
--		{ prob = 20, ret = 1 },
--	}
--	print( Random_GetIndex_Sync( list, "prob" ) )
-------------------------------------------------
function Random_GetIndex_Sync( list, probName )
	local totalProb = MathUtil_Sum( list, probName )
	local prob = Random_GetInt_Sync( 1, totalProb )
	for index, data in pairs( list ) do
		if prob <= data[probName] then
			return index
		else
			prob = prob - data[probName]
		end
	end
end


-------------------------------------------------
--	@usage
--	local list = 
--	{
--		{ prob = 10, ret = 1 },
--		{ prob = 20, ret = 1 },
--	}
--	print( Random_GetTable_Sync( list, "prob" ) )
-------------------------------------------------
function Random_GetTable_Sync( list, probName )
	local totalProb = MathUtil_Sum( list, probName )
	local prob = Random_GetInt_Sync( 1, totalProb )
	for index, data in pairs( list ) do
		if prob <= data[probName] then
			return list[index], index
		else
			prob = prob - data[probName]
		end
	end
end