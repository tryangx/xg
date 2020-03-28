---------------------------------------
---------------------------------------
ROLE_SEX =
{
	MALE      = 0,
	FEMALE    = 1,
	ANIMAL    = 2,
}


ROLE_CATEGORY = 
{
	FICTION   = 0,
	IMPORTANT = 1,
}


ROLE_MENTAL = 
{
	MOOD            = 1,  --changing easy, visible, when it reach maximum, it'll leads buff / debuff, the latter is more often.
	DISSATISFACTION = 2,  --changing moderate, invisible, when it reach maximum, it'll leads betray or revolt, resist
	
	TIRENESS        = 10,  --changing easy, visible, it'll leads SICK	
	SICK            = 11,  --changing moderate, visible, it'll hurt

	--
	LOYALITY        = 100, --changing very hard, invisible, it'll leads betray or revolt
	AMBITION        = 101, --changing very hard, invisible, it'll leads betray or revolt
	AGGRESION       = 110, --changing very hard, invisible, it'll leads conflict in training or event	
	LAZY            = 111, --changing moderate, invisible, it'll leads low efficiency in training/learning
	
	--Social
	TEAM_WORK       = 200,
	GRIGARIOUS      = 201,
	SOLO            = 210,
	EXCLUSIVE       = 211,
	OBEDIENCE       = 220,	
	RESIST          = 221, --changing moderate, invisible, it'll leads low efficiency in executing task
}


ROLE_TRAITS = 
{
	--social
	FRIENDLY        = 100,
	LONELY          = 101,

	--growth
	HARD_WORK       = 200,
	CONCENTRATION   = 201,
	INSPIRATION     = 202,	
}


ROLE_COMMONSKILL = 
{
	--Master	
	MANAGEMENT  = 20,
	STRATEGIC   = 30,  --Increase strategic points
	TACTIC      = 40,  --Increase tactic points

	--Survive
	COLLLECTING = 100,
	FISHER      = 100,
	FARMER      = 100,
	MINER       = 100,
	BLACKSMITH  = 100,
	TOOLMAKER   = 100,
	BUILDER     = 100,
	TAILOR      = 100,
	CARPENTER   = 100,
	HERDSMAN    = 100,
	STOCKMAN    = 100,
	GROWER      = 100,
	MEDIC       = 100,
	APOTHECARIES= 100,

	LEADERSHIP  = 200,  --Increase Management points

	LOBBYIST    = 300, --Works when as a envy to negotiate to a strong group for a weak group
	NEGOTIATION = 301, --Works when as a envy to negotiate to a weak group for a strong group 
	CHEATER     = 302, --Workds when as a envy to negotiate to non-group target
}


ROLE_STATUS = 
{
	BUSY        = 1,
	OUTING      = 2,
}


ROLE_COMMAND =
{
	IDLE        = 0,
	REST        = 1,   --rest at the group
	STROLL      = 2,   --stroll at the street
	TRAVEL      = 3,

	DRILL       = 20,  --All together
	TEACH       = 21,  --elder, master, senior
	SECLUDE     = 22,  --elder, master

	SKRIMMAGE   = 30,  --interior dule
	CHAMPIONSHIP= 31,  --all group union dules

	PRODUCE     = 100,
}


MATERIAL_TYPE = 
{
	FOOD        = 100,

	MEDICINE    = 200,

	WOOD        = 300,

	MINERAL     = 400,
}
