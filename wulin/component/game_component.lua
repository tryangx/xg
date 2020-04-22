---------------------------------------
-- Global data
CurrentGame = nil

---------------------------------------
---------------------------------------
GAME_COMPONENT = class()

---------------------------------------
GAME_PROPERTIES = 
{
	scenario = { type="NUMBER" },

	--Datevalue
	curTime  = { type="NUMBER" },
	--DateValue
	startTime= { type="NUMBER" },
	--DateValue
	endTime  = { type="NUMBER" },

	rules    = { type="DICT" },

	--store each group's achievement
	--{ id={ achievement=, } }
	achievements = { type="DICT" },
	achievementList = { type="LIST" },

	--store each group's score
	--{ id={ score=, } }
	scores   = { type="DICT" },

	winner   = { type="ECSID" },
}

---------------------------------------
function GAME_COMPONENT:__init()
	self.time = TIME()
end

---------------------------------------
function GAME_COMPONENT:Activate()
	self.time:SetDateByValue( self.curTime )
	CurrentGame = self
end
	
---------------------------------------
function GAME_COMPONENT:Deactivate()
	CurrentGame = nil
end

---------------------------------------
function GAME_COMPONENT:Update( deltaTime )
	self:Elapsed( deltaTime )
end

---------------------------------------
function GAME_COMPONENT:Elapsed( deltaTime )
	self.curTime = self.curTime + deltaTime
	self.time:Update()
	self.time:ElapseHour( deltaTime )
	--print( self, "time debug", self.time.passYear, self.time.passMonth, self.time.passDay )
	--InputUtil_Pause( "Gameupdate", self.curTime, self.time:ToString(), "+" .. deltaTime )
end

---------------------------------------
function GAME_COMPONENT:IsGameOver( ... )
	--Time End
	if self.curTime >= self.endTime then return true end

	--Has winner
	if self.winner then return true end

	return false
end

---------------------------------------
function GAME_COMPONENT:GetTime()
	return self.time
end

function GAME_COMPONENT:IsNewDay()
	return self.time.passDay
end

function GAME_COMPONENT:IsNewMonth()
	return self.time.passMonth
end

function GAME_COMPONENT:IsNewYear()
	return self.time.passYear
end

function GAME_COMPONENT:GetDay()
	return self.time:GetDay()
end

function GAME_COMPONENT:GetMonth()
	return self.time:GetMonth()
end

function GAME_COMPONENT:GetYear()
	return self.time:GetYear()
end

---------------------------------------
function GAME_COMPONENT:ReachAchievement( id, type, param )
	if not self.achievements[id] then self.achievements[id] = {} end
	self.achievements[id][type] = 1

	--calculate score
	if type == "FINISH_GOAL" then
		if param == "OVERLORD" then self.winner = id end
		Pop_Add( self, "achievementList", { groupid=id, goal=type } )	
	end
end


function GAME_COMPONENT:ObtainScore( id, score )
	self.scores[id] = self.scores[id] and self.scores[id] + score or score
end


function GAME_COMPONENT:CalcScore( group )
	--Score
	--  1. Stored Score
	--  2. Ranking Score
	--  3. Evaluation Score
	--current score and ranking score
	local score = 0--self.scores[group.entityid]

	if GAME_ACHIEVEMENT_SCORE.FINISH_GOAL[param] then
		self:ObtainScore( id, GAME_ACHIEVEMENT_SCORE.FINISH_GOAL[param] )
	end

	--FINISH_GOAL_RANKING
	for index, data in ipairs( self.achievementList ) do
		if data.groupid == group.entityid then
			score = score + GAME_ACHIEVEMENT_SCORE.FINISH_GOAL[data.goal]
			score = score + ( GAME_ACHIEVEMENT_SCORE.FINISH_GOAL_RANKING[index] or 0 )
		end
	end

	--score = ranking.score
	--e.g.
	-- ranking=1 ==> score = 500
	-- ranking=100 ==> score = not
	--PERSON_RANKING      = { { ranking=1, score=400 }, { ranking=5, score=250 }, { ranking=10, score=200 }, { ranking=20, score=100 }, { ranking=9999, score=0 } },
	MathUtil_Foreach( group.members, function ( _, ecsid )
		local fighter = ECS_FindComponent( ecsid, "FIGHTER_COMPONENT" )
		for _, data in ipairs( GAME_ACHIEVEMENT_SCORE.PERSON_RANKING ) do
			if fighter.ranking <= data.ranking then
				score = score + data.score
				break
			end
		end
	end )

	--score = powre_percent * POWER_PERCENT_MOD
	score = score + math.ceil( group:GetData( "POWER" ) * GAME_ACHIEVEMENT_SCORE.POWER_PERCENT_MOD / self.totpower )

	--vassal
	local relationCmp = ECS_FindComponent( group.entityid, "RELATION_COMPONENT" )
	local numOfVassal = relationCmp:GetNumOfRelation( { status="VASSAL" } )
	for _, data in ipairs( GAME_ACHIEVEMENT_SCORE.HAS_VASSAL ) do
		if numOfVassal <= data.num then
			score = score + data.score
			break
		end
	end

	if not self._maxScore or self._maxScore < score then
		self._maxScore = score
		self.winner = group.entityid
	end
	self.scores[group.entityid] = score

	Stat_Add( "GroupScore", group.name.."=" .. score, StatType.LIST )
end


---------------------------------------
function GAME_COMPONENT:ToString()
	local content = "GameTime:"
	content = content .. Time_CreateDateDescByValue( self.curTime )
	content = content .. "/"
	content = content .. Time_CreateDateDescByValue( self.endTime )
	return content	
end

function GAME_COMPONENT:Dump()
	print( self:ToString() )
end