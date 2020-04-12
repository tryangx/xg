----------------------------------------
----------------------------------------
RELATION_OPINION =
{
	HOSTILE    = 800,
	ENEMY      = 400,
	OLDENEMY   = 0,

	NEUTRAL    = 1000,

	TRUST      = 1200,
	FRIEND     = 1400,
	ALLY       = 1700,

	BROTHER    = 2000, --special
}


--------------------------------------------------------------------------------
-- Status Changed After Sign Pact
--
--          DECLW  NOWAR TRADE CONTES THRET PROTC TRIBU ANNEX ALLY  BREKA PEACE
-- NONE     ATWAR    o     x     x      x     x     x     x     x     x     x
-- ...
--------------------------------------------------------------------------------
RELATION_STATUSCAPACITY = 
{
	NONE       = { diplomacy=1, pacts={ DECLAREWAR=1, NOWAR=1, TRADE=1, PROTECT=1 } },
	ALLY       = { diplomacy=1, pacts={ TRADE=1, CONTEST=1, BREAK=1, HELP=1 } },
	ATWAR      = { diplomacy=1, pacts={ PEACE=1, BETRAY=1 } },
	PEACE      = { diplomacy=1, pacts={ } },
	--oppsite is our subject, can be vassal in the future
	SUBJECT    = { diplomacy=1, pacts={ CONTEST=1, THREATEN=1, TRIBUTE=1, BREAK=1 } },
	--oppsite is our suzerain
	SUZERAIN   = { diplomacy=1, pacts={ CONTEST=1, BREAK=1 } },
	--opposite is our vassal
	VASSAL     = { diplomacy=1, pacts={ CONTEST=1, TRIBUTE=1, ANNEX=1, BREAK=1 } },
	 --opposite is our monarch
	MONARCH    = { diplomacy=0, pacts={ CONTEST=1, BREAK=1 }, },
}

----------------------------------------
-- Detail means what did
----------------------------------------
RELATION_DETAIL =
{
	WE_AT_WAR          = 1,
	THEY_DECLAREWAR    = 2,

	THEY_OWE_RIGHT     = 10,
	
	THEY_BREAK_PROMISE = 20,
	WE_BREAK_PROMISE   = 21,

	THEY_BETRAYED      = 30,
	WE_BETRAYED        = 31,
}


--------------------------------------------------------------------------------
-- Sign pact need some conditions
--
-- Sign pact will leads some results:
--   1. Change Relation Status                   ==> change_status={ opp=%status%, our=%status% }
--   2. A time counter to finish or end the pat  ==> time=%number%
--   3. Pay tribute by ratio of stock            ==> tribute_stock_ratio={ status=%status%, }
--   4. Modify the details info for each other   ==> detail={ opp=%number%, our=%number%, }
--   5. We or they should be independent         ==> independent={ opp=, our=, }
--------------------------------------------------------------------------------
RELATION_PACT = 
{
	DECLAREWAR = {
					conditions = { },
					results = { change_status={ opp="ATWAR" }, detail={ opp={THEY_DECLAREWAR=1}, our={WE_AT_WAR=1} } }
				 },	
	NOWAR      = { 
					conditions = {},
					results = { time=360 },
				 },
	TRADE      = {
					conditions = {},
					results = { time=360 },
				 },
	CONTEST    = { 
					conditions = {},
					results = { time=360 },
				 },
	THREATEN   = { 
					conditions = {}, 
					results = { change_status={ opp="VASSAL", our="MONARCH" },
				 },
	PROTECT    = { 
					conditions = {}, 
					results ={ change_status={ opp="SUBJECT", our="SUBZERAIN" } },
				 },
	TRIBUTE    = { 
					conditions = {}, 
					results ={ time=180, tribute_stock_ratio={ SUBJECT=0.3, VASSAL=0.5 } } },
				 },
	ANNEX      = { 
					conditions = {}, 
					results ={ time=360 },
				 },	
	ALLY       = {
					conditions = { power_prop={min=40, max=60} },
					results ={ change_status={ opp="ALLY", our="ALLY" } },
				 },
	BREAK      = {
					conditions = {}, 
					results ={ change_status={ opp="NONE", our="NONE"}, detail={ opp={THEY_BREAK_PROMISE=1}, our={WE_BREAK_PROMISE=1} } },
				 },
	HELP       = {
					conditions = {},
					results ={ detail={ opp={THEY_OWE_RIGHT=1} } },
				 },
	BETRAY     = {
					conditions = { },
					results ={ change_status={ opp="NONE", our="NONE" }, independ={our=1} },
				 },

	PEACE      = { 
					conditions = { elapsed=360, adv_prop={min=0.4,max=0.6} },
					results = { detail={ opp={WE_AT_WAR=-1}, our={WE_AT_WAR=-1} } },
				 },
}