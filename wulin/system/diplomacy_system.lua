---------------------------------------
-- When received a diplomacy, player has 
-- some options to select.
--   1. Accept
--   2. Decline
--   3. Ask for suggest
--     3.a Agree suggest  ==> Increase loyality
--     3.b Refuse suggest ==> Decrease loyality
--   4. Ask for more gifts
---------------------------------------
DIPLOMACY_SYSTEM = class()

---------------------------------------
function DIPLOMACY_SYSTEM:__init( ... )
	local args = ...
	self._name = args and args.name or "DIPLOMACY_SYSTEM"

	--store the fight_component's entity-id
	self._fights = {}
end


---------------------------------------
function DIPLOMACY_SYSTEM:Activate()
end
