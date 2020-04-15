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


ROLE_ACTION = 
{

}


ROLE_MENTAL = 
{
	--MOOD            = 1,  --changing easy, visible, when it reach maximum, it'll leads buff / debuff, the latter is more often.	
	PRESSURE        = 1,  --change easy, visible, Increase by the Fight/Event 
	DISSATISFACTION = 2,  --changing moderate, invisible, when it reach maximum, it'll leads betray or revolt, resist
	
	TIRENESS        = 10,  --changing easy, visible, it'll leads SICK	
	SICK            = 11,  --changing moderate, visible, it'll hurt

	--
	LOYALITY        = 100, --changing very hard, invisible, it'll leads betray or revolt
	AMBITION        = 101, --changing very hard, invisible, it'll leads betray or revolt
	AGGRESION       = 110, --changing very hard, invisible, it'll leads conflict in training or event	
	
	--Social
	TEAM_WORK       = 200,
	GRIGARIOUS      = 201,
	SOLO            = 210,
	EXCLUSIVE       = 211,

	OBEDIENCE       = 220, --occasion, always to follower order
	RESIST          = 221, --invisible, it'll leads low efficiency in executing task
}


ROLE_TRAITS = 
{
	IQ              = 10,
	EQ              = 11,
	AQ              = 12,

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
	MANAGEMENT  = 10,
	STRATEGIC   = 20,  --Increase strategic points
	TACTIC      = 30,  --Increase tactic points

	--Survive
	COLLLECTER = 100,
	FISHER      = 110,
	FARMER      = 120,
	MINER       = 130,
	BLACKSMITH  = 140,
	TOOLMAKER   = 150,
	BUILDER     = 160,
	TAILOR      = 170,
	LOGGER      = 180,
	CARPENTER   = 181,
	HERDSMAN    = 190,
	STOCKMAN    = 200,
	GROWER      = 210,
	MEDIC       = 220,
	APOTHECARIES= 230,
	TEXTILE_MILL= 240,	

	LEADERSHIP  = 400,  --Increase Management points
	TEACHER     = 410,
	LOBBYIST    = 420, --Works when as a envy to negotiate to a strong group for a weak group
	NEGOTIATION = 430, --Works when as a envy to negotiate to a weak group for a strong group 
	CHEATER     = 440, --Workds when as a envy to negotiate to non-group target
}


ROLE_STATUS = 
{
	BUSY        = 1,
	OUTING      = 2,

	NEED_REWARD        = 10,

	TESTFIGHT_INTERVAL = 100,
	TESTFIGHT_APPLY    = 101,
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
	READBOOK    = 23,

	SKRIMMAGE   = 30,  --interior dule
	TESTFIGHT   = 31,  --elder vs follower
	TESTFIGHT_OFFICER = 32,

	CHAMPIONSHIP= 40,  --all group union dules

	PRODUCE     = 100,
}


ROLE_GOAL = 
{
	SURVIVE   = 0,
	MASTER    = 10,		
}


ROLE_EQUIP = 
{
	WEAPON    = 1,
	ARMOR     = 2,
	SHOES     = 3,
	ACCESSORY = 4,
	VEHICLE   = 5,
}