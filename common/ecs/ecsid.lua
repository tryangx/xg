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

function ECS_InitID()
	_randomizer:Seed( os.time() )
end

function ECS_ResetID()
	_ecsidCounter = _ecsidDefault
end

function ECS_CreateID()
	--template solution
	--  ecsid = time_stamp + counter + random_string
	local ecsid = "eid"

	ecsid = ecsid .. os.time()

	ecsid = ecsid .. _ecsidCounter	

	_ecsidCounter  = _ecsidCounter + 1

	--_ecsids[ecsid] = ecsid

	return ecsid
end
