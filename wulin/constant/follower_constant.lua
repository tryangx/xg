---------------------------------------
---------------------------------------
FOLLOWER_RANK = 
{
	NONE      = 0,
	JUNIOR    = 1,	
	SENIOR    = 2,
	ELDER     = 3,
}


FOLLOWER_JOB =
{
	FOLLOWER = 0,
	MASTER   = 1,	
}


FOLLOWER_RANK_ABILITY = 
{
	NONE   = {},
	JUNIOR = { DRILL=1, },
	SENIOR = { DRILL=1, READBOOK=1, TEACH=1, },
	ELDER  = { DRILL=0, READBOOK=1, TEACH=1, SECLUDE=1 },
}