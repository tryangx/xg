FIGHTERTEMPLATE_GRADE = 
{
	COMMON     = 1,--lv 10~20
	RARE       = 2,--lv 20~40
	VERY_RARE  = 3,--lv 20~60
	SUPER_RARE = 4,--lv 60~80
	SS_RARE    = 5,--lv 70~90
	ULTRA_RARE = 6,--lv 80~100
}


FIGHTERTEMPLATE_PROPERTIES = 
{
	grade     = { type="STRING" },
	traits    = { type="OBJECT" },

	--generated by grade and traits
	potential = { type="NUMBER" },
	hp        = { type="NUMBER" },
	st        = { type="NUMBER" },
	mp        = { type="NUMBER" },
	strength  = { type="NUMBER" },
	internal  = { type="NUMBER" },
	technique = { type="NUMBER" },
	agility   = { type="NUMBER" },

	skills    = { type="OBJECT" },
}


---------------------------------------
---------------------------------------
FIGHTERTEMPLATE_COMPONENT = class()

---------------------------------------
function FIGHTERTEMPLATE_COMPONENT:Activate()
end

---------------------------------------