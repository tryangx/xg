---------------------------------------
--
-- ECSID
--
-- 1. ECSID means a string-value
-- 2.
--
---------------------------------------
local _ecsids = {}
local _ecsidDefault = 10000
local _ecsidCounter = _ecsidDefault

_randomizer = Randomizer()


---------------------------------------
---------------------------------------
function ECS_InitID()
	_randomizer:Seed( os.time() )
end


---------------------------------------
---------------------------------------
function ECS_SetIDCounter( counter )

end


---------------------------------------
---------------------------------------
function ECS_ResetID()
	_ecsidCounter = _ecsidDefault
end


---------------------------------------
---------------------------------------
function ECS_CreateID()
	--  ecsid = prefix + time_stamp + counter + random_string
	local ecsid = "i"

	ecsid = ecsid .. os.time()

	ecsid = ecsid .. _ecsidCounter

	ecsid = ecsid .. MathUtil_GenRandomString( 24 - string.len(ecsid) )

	_ecsidCounter  = _ecsidCounter + 1

	return ecsid
end
