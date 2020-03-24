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
	LAZY            = 3,  --changing moderate, invisible, it'll leads low efficiency in training/learning
	RESIST          = 4,  --changing moderate, invisible, it'll leads low efficiency in executing task
	TIRENESS        = 5,  --changing easy, visible, it'll leads SICK
	SICK            = 6,  --changing moderate, visible, it'll hurt
	HURT            = 7,  --changing hard, visible, it'll leads DEATH
	AMBITION        = 10, --changing hard, invisible, it'll leads betray or revolt
	AGGRESION       = 11, --changing hard, invisible, it'll leads conflict in training or event
}


ROLE_TRAITS = 
{
	--social
	FRIENDLY        = 100,
	LONELY          = 101,
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

	LOBBYIST    = 300, --Works when as a envy to negotiate to a strong gang for a weak gang
	NEGOTIATION = 301, --Works when as a envy to negotiate to a weak gang for a strong gang 
	CHEATER     = 302, --Workds when as a envy to negotiate to non-gang target
}


ROLE_STATUS = 
{
	BUSY        = 1,
	OUTING      = 2,
}

---------------------------------------
---------------------------------------
ROLE_COMPONENT = class()

---------------------------------------
ROLE_PROPERTIES = 
{
	name       = { type="STRING", },
	age        = { type="NUMBER", },
	sex        = { type="NUMBER", }, --0:male, 1:female

	category   = { type="NUMBER", }, --0

	statuses   = { type="LIST" },

	--mental
	-- valuetype: { type: string, init_value = number, post_value = number }
	mentals    = { type="LIST" },

	--common skill
	--{ {type=ROLE_COMMONSKILL, value=evaluation} }
	commonSkills = { type="OBJECT" }, 
}

---------------------------------------
function ROLE_COMPONENT:__init()
end


---------------------------------------
function ROLE_COMPONENT:Update()

end


---------------------------------------