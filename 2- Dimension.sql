
-- Create dim tables that contains the important measurables from the imported staging table data. Rename some of the columns so they're more descriptive.
create table dim_player(
dimplayerid INT IDENTITY(1,1) CONSTRAINT PK_dim_player PRIMARY KEY NOT NULL,
sourceplayerid varchar(50),
fullname varchar (50),
firstname varchar(50),
lastname varchar(50),
battinghand varchar (50),
throwinghand varchar(50)
)


-- Handle for unknowns first
insert into dim_player(
sourceplayerid,
fullname,
firstname,
lastname,
battinghand,
throwinghand
)

values(
-1,
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown'
)

insert into dim_player(
sourceplayerid,
fullname,
firstname,
lastname,
battinghand,
throwinghand
)

-- The source data had duplicate players which was messing up our stats, so we had to just pick the max of each player's info to reduce to one line for each player.


SELECT
    id AS sourceplayerid,
    MAX(CONCAT(stage_add_players.first, ' ', stage_add_players.last)) AS fullname,
    MAX(stage_add_players.first) AS firstname,
    MAX(stage_add_players.last) AS lastname,
    MAX(stage_add_players.bat) AS battinghand,
    MAX(stage_add_players.throw) AS throwinghand
FROM stage_add_players
GROUP BY id;


select * from dim_game order by date asc

create table dim_game(
dimgameid INT IDENTITY(1,1) CONSTRAINT PK_dim_game PRIMARY KEY NOT NULL,
sourcegameid varchar (50),
visitingteam varchar(50),
hometeam varchar (50),
ballpark varchar (50),
date int,
starttime time,
daynight varchar(50),
innings int,
timeofgame int,
attendance int,
fieldcond varchar (50),
precip varchar (50),
sky varchar (50),
temp int,
windspeed int,
winningpitcher varchar(50),
losingpitcher varchar(50),
save varchar (50),
gametype varchar(50),
winningteam varchar(50),
losingteam varchar(50)
)


insert into dim_game(
sourcegameid,
visitingteam,
hometeam,
ballpark,
date,
starttime,
daynight,
innings,
timeofgame,
attendance,
fieldcond,
precip,
sky,
temp,
windspeed,
winningpitcher,
losingpitcher,
save,
gametype,
winningteam,
losingteam
)


values(
-1,
'Unknown',
'Unknown',
'Unknown',
-1,
'00:00:00',
'Unknown',
-1,
-1,
-1,
'Unknown',
'Unknown',
'Unknown',
-1,
-1,
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown')





insert into dim_game(
sourcegameid,
visitingteam,
hometeam,
ballpark,
date,
starttime,
daynight,
innings,
timeofgame,
attendance,
fieldcond,
precip,
sky,
temp,
windspeed,
winningpitcher,
losingpitcher,
save,
gametype,
winningteam,
losingteam
)

select
STAGE_ADD_GAME.gid as sourcegameid,
STAGE_ADD_GAME.visteam as visitingteam,
STAGE_ADD_GAME.hometeam as hometeam,
STAGE_ADD_GAME.site as ballpark,
STAGE_ADD_GAME.date as date,
STAGE_ADD_GAME.starttime as starttime,
STAGE_ADD_GAME.daynight as daynight,
STAGE_ADD_GAME.innings as innings,
STAGE_ADD_GAME.timeofgame as timeofgame,
STAGE_ADD_GAME.attendance as attendance,
STAGE_ADD_GAME.fieldcond as fieldcond,
STAGE_ADD_GAME.precip as precip,
STAGE_ADD_GAME.sky as sky,
STAGE_ADD_GAME.temp as temp,
STAGE_ADD_GAME.windspeed as windspeed,
STAGE_ADD_GAME.wp as winningpitcher,
STAGE_ADD_GAME.lp as losingpitcher,
STAGE_ADD_GAME.save as save,
STAGE_ADD_GAME.gametype as gametype,
STAGE_ADD_GAME.wteam as winningteam,
STAGE_ADD_GAME.lteam as losingteam
from STAGE_ADD_GAME



create table dim_team(
dimteamid INT IDENTITY(1,1) CONSTRAINT PK_dim_team PRIMARY KEY NOT NULL,
sourcegameid varchar(50),
team varchar(50),
managerid varchar(50),
leadoff varchar(50),
lineup2 varchar(50),
lineup3 varchar(50),
cleanup varchar(50),
lineup5 varchar(50),
lineup6 varchar(50),
lineup7 varchar(50),
lineup8 varchar(50),
lineup9 varchar(50),
startingpitcher varchar(50),
catcher varchar(50),
firstbase varchar(50),
secondbase varchar(50),
thirdbase varchar(50),
shortstop varchar(50),
leftfield varchar(50),
centerfield varchar(50),
rightfield varchar(50),
DesignatedHitter varchar(50),
date int,
ballpark varchar(50),
opponent varchar(50),
gametype varchar(50)
)


insert into dim_team(
sourcegameid,
team,
managerid,
leadoff,
lineup2,
lineup3,
cleanup,
lineup5,
lineup6,
lineup7,
lineup8,
lineup9,
startingpitcher,
catcher,
firstbase,
secondbase,
thirdbase,
shortstop,
leftfield,
centerfield,
rightfield,
DesignatedHitter,
date,
ballpark,
opponent,
gametype
)

values(
-1,
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown',
'Unknown',
-1,
'Unknown',
'Unknown',
'Unknown'
)




insert into dim_team(
sourcegameid,
team,
managerid,
leadoff,
lineup2,
lineup3,
cleanup,
lineup5,
lineup6,
lineup7,
lineup8,
lineup9,
startingpitcher,
catcher,
firstbase,
secondbase,
thirdbase,
shortstop,
leftfield,
centerfield,
rightfield,
DesignatedHitter,
date,
ballpark,
opponent,
gametype
)

select
stage_team.gid as sourcegameid,
stage_team.team as team,
stage_team.mgr as managerid,
stage_team.start_l1 as leadoff,
stage_team.start_l2 as lineup2,
stage_team.start_l3 as lineup3,
stage_team.start_l4 as cleanup,
stage_team.start_l5 as lineup5,
stage_team.start_l6 as lineup6,
stage_team.start_l7 as lineup7,
stage_team.start_l8 as lineup8,
stage_team.start_l9 as lineup9,
stage_team.start_f1 as startingpitcher,
stage_team.start_f2 as catcher,
stage_team.start_f3 as firstbase,
stage_team.start_f4 as secondbase,
stage_team.start_f5 as thirdbase,
stage_team.start_f6 as shortstop,
stage_team.start_f7 as leftfield,
stage_team.start_f8 as centerfield,
stage_team.start_f9 as rightfield,
stage_team.start_f10 as DesignatedHitter,
stage_team.date as date,
stage_team.site as ballpark,
stage_team.opp as opponent,
stage_team.gametype as gametype
from stage_team
