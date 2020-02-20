---------------------------------------
--
-- ECSID
--
-- 1. ECSID means a string-value
-- 2.
--
---------------------------------------
local _ecsids = {}
local _ecsidCounter = 10000

_randomizer = Randomizer()

function ECS_InitID()
	_randomizer:Seed( os.time() )
end

function ECS_CreateID()
	--template solution
	--  ecsid = time_stamp + counter + random_string
	local ecsid = ""

	ecsid = ecsid .. os.time()

	ecsid = ecsid .. _ecsidCounter	

	_ecsidCounter  = _ecsidCounter + 1

	--_ecsids[ecsid] = ecsid

	return ecsid
end