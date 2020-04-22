---------------------------------------
---------------------------------------
FIGHTER_ATTR = 
{
	INTERNAL   = 10, --Affect MP, INT action damage/resist
	STRENGTH   = 11, --Resist ST, PHY action damage/resist
	TECHNIQUE  = 20, --Affect Hit Accuracy, Critical( Physical Damage )
	AGILITY    = 21, --Affect Evade, Attack Sequence
}


FIGHTER_ELEMENT = 
{
	STRENGTH = 1,
	ELEMENT  = 2,
}


FIGHTER_BUFFER = 
{
	BLIND              = 10,    --Short Duration, Reduce hit accuracy	
	HAND_HURT          = 11,    --Short Duration, Reudce atk power
	LEG_HURT           = 12,    --Short Duration, Reudce evd
	BODY_HURT          = 13,    --Short Duration, Reudce def power
	STUN               = 15,    --Short Duration, Cann't defend

	BLEEDING           = 20,    --Short Duration, Lose Hp 	
	POISION            = 21,    --Short Duration, Lose Hp
	RESTORE            = 22,    --Short Duration, Gain Hp

	MARK               = 30,    --Short Duration, Easy to be hit

	MEDICINE_RESISTENCE= 40,    --Short Duration, 

	STRENGTH_ENHNACED  = 100,
	STRENGTH_WEAKEN    = 101,
	INTERNAL_ENHANCED  = 110,
	INTERNAL_WEAKEN    = 111,
	DEFENSE_ENHANCED   = 120,
	DEFENSE_BROKEN     = 121,
	TECHNIQUE_ENHANCED = 130,
	TECHNIQUE_WEAKEN   = 131,
	AGILITY_ENHANCED   = 140,
	AGILITY_WEAKEN     = 141,
}


FIGHTERTEMPLATE_GRADE = 
{
	COMMON     = 1,--lv 10~20
	RARE       = 2,--lv 20~40
	VERY_RARE  = 3,--lv 20~60
	SUPER_RARE = 4,--lv 60~80
	SS_RARE    = 5,--lv 70~90
	ULTRA_RARE = 6,--lv 80~100
}


FIGHTERTEMPLATE_GENERATOR =
{
	[1]={ skill={max=2}, lv={min=10, max=30},  hp={ base=100,mod=60 }, st={ base=50,mod=50 },  mp={ base=40,mod=50 },  str={ base=40,mod=4 },   int={ base=20,mod=4 },  agi={ base=40,mod=4 },  tec={ base=50,mod=4 }, },
	[2]={ skill={max=3}, lv={min=20, max=45},  hp={ base=120,mod=70 }, st={ base=60,mod=55 },  mp={ base=50,mod=55 },  str={ base=50,mod=5 },   int={ base=30,mod=5 },  agi={ base=50,mod=5 },  tec={ base=60,mod=5 }, },
	[3]={ skill={max=4}, lv={min=35, max=60},  hp={ base=150,mod=75 }, st={ base=80,mod=60 },  mp={ base=60,mod=60 },  str={ base=60,mod=6 },   int={ base=40,mod=6 },  agi={ base=60,mod=6 },  tec={ base=80,mod=6 }, },
	[4]={ skill={max=6}, lv={min=55, max=80},  hp={ base=180,mod=80 }, st={ base=100,mod=65 }, mp={ base=80,mod=65 },  str={ base=80,mod=7 },   int={ base=60,mod=7 },  agi={ base=80,mod=7 },  tec={ base=100,mod=7 }, },
	[5]={ skill={max=7}, lv={min=75, max=90},  hp={ base=210,mod=85 }, st={ base=120,mod=70 }, mp={ base=100,mod=70 }, str={ base=100,mod=8 },  int={ base=80,mod=8 },  agi={ base=100,mod=8 }, tec={ base=120,mod=8 }, },
	[6]={ skill={max=8}, lv={min=85, max=100}, hp={ base=250,mod=90 }, st={ base=150,mod=75 }, mp={ base=120,mod=75 }, str={ base=120,mod=9 },  int={ base=100,mod=9 }, agi={ base=120,mod=9 }, tec={ base=140,mod=9 }, },
}
