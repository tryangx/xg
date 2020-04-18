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


ROLE_STATUS = 
{
	BUSY        = 1,
	OUTING      = 2,

	NEED_REWARD        = 10,

	TESTFIGHT_INTERVAL = 100,
	TESTFIGHT_APPLY    = 101,
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