

-- Create a fact table that contains the important measurables from the imported staging table data. Rename some of the columns so they're more descriptive. Link foreign keys to dim tables' primary-surrogate keys.
create table fact_plays(
DimGameId int references dim_game(dimgameid),
DimBatterId int references dim_player(dimplayerid),
DimPitcherId int references dim_player(dimplayerid),
DimBattingTeamId int references dim_team(dimteamid),
DimPitchingTeamId int references dim_team(dimteamid),
Outcome varchar(150),
Inning int,
Top_bot int,
Ballpark varchar (50),
Date int,
OrderSpot int,
OutsPre int,
OutsPost int,
Baserunner1Pre varchar (50),
Baserunner2Pre varchar (50),
Baserunner3Pre varchar (50),
Baserunner1Post varchar (50),
Baserunner2Post varchar (50),
Baserunner3Post varchar (50),
VisitorScore int,
HomeScore int,
PlateAppearance int,
AtBat int,
Single int,
Double int,
Triple int,
HR int,
Walk int,
IntWalk int,
HBP int,
Strikeout int,
StrikeoutSafe int,
SacHit int,
SacFly int,
ReachOnError int,
FieldersChoice int,
NoOuts int,
OtherOut int,
GIDP int,
OthDP int,
TP int,
RunsScored int,
EarnedRuns int,
BatterRBI int,
BatterScored varchar(50),
Baserunner1Scored varchar (50),
Baserunner2Scored varchar (50),
Baserunner3Scored varchar (50),
Baserunner1RBI varchar (50),
Baserunner2RBI varchar (50),
Baserunner3RBI varchar (50),
Ballinplay int,
Bunt int,
Groundball int,
Flyball int,
Linedrive int,
FieldLocation varchar(50),
Gametype varchar(50)
);

-- Define which columns are going to receive the data
insert into fact_plays(
DimGameId,
DimBatterId,
DimPitcherId,
DimBattingTeamId,
DimPitchingTeamId,
Outcome,
Inning,
Top_bot,
Ballpark,
Date,
OrderSpot,
OutsPre,
OutsPost,
Baserunner1Pre,
Baserunner2Pre,
Baserunner3Pre,
Baserunner1Post,
Baserunner2Post,
Baserunner3Post,
VisitorScore,
HomeScore,
PlateAppearance,
AtBat,
Single,
Double,
Triple,
HR,
Walk,
IntWalk,
HBP,
Strikeout,
StrikeoutSafe,
SacHit,
SacFly,
ReachOnError,
FieldersChoice,
NoOuts,
OtherOut,
GIDP,
OthDP,
TP,
RunsScored,
EarnedRuns,
BatterRBI,
BatterScored,
Baserunner1Scored,
Baserunner2Scored,
Baserunner3Scored,
Baserunner1RBI,
Baserunner2RBI,
Baserunner3RBI,
Ballinplay,
Bunt,
Groundball,
Flyball,
Linedrive,
FieldLocation,
Gametype
)

-- import the data from the staging table to the fact table


select
NVL(dim_game.dimgameID,-1) as DimGameID,
NVL(dpb.dimplayerID,-1) as DimBatterID,
NVL(dpp.dimplayerID,-1) as DimPitcherID,
NVL(dtb.dimteamID,-1) as DimBattingTeamID,
NVL(dtp.dimteamId,-1) as DimPitchingTeamID,
stage_plays.Event as Outcome,
stage_plays.Inning as Inning,
stage_plays.top_bot as top_bot,
stage_plays.site as ballpark,
stage_plays.date as date,
stage_plays.lp as orderspot,
stage_plays.outs_pre as outspre,
stage_plays.outs_post as outspost,
stage_plays.br1_pre as baserunner1pre,
stage_plays.br2_pre as baserunner2pre,
stage_plays.br3_pre as baserunner3pre,
stage_plays.br1_post as baserunner1post,
stage_plays.br2_post as baserunner2post,
stage_plays.br3_post as baserunner3post,
stage_plays.score_v as visitorscore,
stage_plays.score_h as homescore,
stage_plays.pa as plateappearance,
stage_plays.ab as atbat,
stage_plays.single as single,
stage_plays.double as double,
stage_plays.triple as triple,
stage_plays.hr as hr,
stage_plays.walk as walk,
stage_plays.iw as intwalk,
stage_plays.hbp as hbp,
stage_plays.k as strikeout,
stage_plays.k_safe as strikeoutsafe,
stage_plays.sh as sachit,
stage_plays.sf as sacfly,
stage_plays.roe as reachonerror,
stage_plays.fc as fielderschoice,
stage_plays.noout as noouts,
stage_plays.othout as otherout,
stage_plays.gdp as gidp,
stage_plays.othdp as othdp,
stage_plays.tp as tp,
stage_plays.runs as runsscored,
stage_plays.er as EarnedRuns,
stage_plays.rbi_b as batterrbi,
stage_plays.run_b as batterscored,
stage_plays.run1 as baserunner1scored,
stage_plays.run2 as baserunner2scored,
stage_plays.run3 as baserunner3scored,
stage_plays.rbi1 as baserunner1rbi,
stage_plays.rbi2 as baserunner2rbi,
stage_plays.rbi3 as baserunner3rbi,
stage_plays.bip as ballinplay,
stage_plays.bunt as bunt,
stage_plays.ground as groundball,
stage_plays.fly as flyball,
stage_plays.line as linedrive,
stage_plays.loc as fieldlocation,
stage_plays.gametype as gametype
from stage_plays
left join dim_game on dim_game.sourcegameid = stage_plays.gid

-- separate joins required to make sure we don't get duplicate values
left join dim_player dpb on dpb.sourceplayerid = stage_plays.batter

-- separate join for pitcher
left join dim_player dpp on dpp.sourceplayerid = stage_plays.pitcher

-- batting team row for this game
left join dim_team dtb on dtb.sourcegameid = stage_plays.gid
                    and dtb.team = stage_plays.batteam

-- pitching team row for this game
left join dim_team dtp on dtp.sourcegameid = stage_plays.gid
                    and dtp.team = stage_plays.pitteam





create table fact_fielding(
DimGameId int references dim_game(dimgameid),
DimPlayerID int references dim_player(dimplayerid),
DimTeamID int references dim_team(dimteamid),
SourcePlayerid varchar(55),
position int,
putouts int,
assists int,
errors int,
doubleplays int,
tripleplays int,
caughtstealing int,
gamesstarted int)

insert into fact_fielding(
DimGameId,
DimPlayerID,
DimTeamID,
Sourceplayerid,
position,
putouts,
assists,
errors,
doubleplays,
tripleplays,
caughtstealing,
gamesstarted
)


select
NVL(dim_game.dimgameID,-1) as DimGameID,
NVL(dim_player.dimplayerid,-1) as Dimplayerid,
NVL(dim_team.dimteamid,-1) as Dimteamid,
stage_fielding.id as sourceplayerid,
stage_fielding.d_pos as position,
stage_fielding.d_po as putouts,
stage_fielding.d_a as assists,
stage_fielding.d_e as errors,
stage_fielding.d_dp as doubleplays,
stage_fielding.d_tp as tripleplays,
stage_fielding.d_cs as caughstealing,
stage_fielding.d_gs as gamesstarted
from stage_fielding
left join dim_game on dim_game.sourcegameid = stage_fielding.gid
left join dim_player on dim_player.sourceplayerid = stage_fielding.id
left join dim_team on dim_team.sourcegameid = stage_fielding.gid
                    and dim_team.team = stage_fielding.team;





create table fact_hitting(
DimGameId int references dim_game(dimgameid),
DimPlayerID int references dim_player(dimplayerid),
DimTeamID int references dim_team(dimteamid),
sourceplayerid varchar(255),
orderspot int,
plateappearences int,
atbats int,
runs int,
hits int,
doubles int,
triples int,
hr int,
rbi int,
sachits int,
sacflies int,
hbp int,
walks int,
intwalks int,
strikeouts int,
stolenbases int,
caughtstealing int,
gdp int,
reachedonerror int
)

insert into fact_hitting(
DimGameId,
DimPlayerID,
DimTeamID,
sourceplayerid,
orderspot,
plateappearences,
atbats,
runs,
hits,
doubles,
triples,
hr,
rbi,
sachits,
sacflies,
hbp,
walks,
intwalks,
strikeouts,
stolenbases,
caughtstealing,
gdp,
reachedonerror
)

select
NVL(dim_game.dimgameID,-1) as DimGameID,
NVL(dim_player.dimplayerid,-1) as Dimplayerid,
NVL(dim_team.dimteamid,-1) as Dimteamid,
stage_batting.id as sourceplayerid,
stage_batting.b_lp as orderspot,
stage_batting.b_pa as plateappearances,
stage_batting.b_ab as atbats,
stage_batting.b_h as hits,
stage_batting.b_r as runs,
stage_batting.b_d as doubles,
stage_batting.b_t as triples,
stage_batting.b_hr as hr,
stage_batting.b_rbi as rbi,
stage_batting.b_sh as sachits,
stage_batting.b_sf as sacflies,
stage_batting.b_hbp as hbp,
stage_batting.b_w as walks,
stage_batting.b_iw as intwalks,
stage_batting.b_k as strikeouts,
stage_batting.b_sb as stolenbases,
stage_batting.b_cs as caughtstealing,
stage_batting.b_gdp as gdp,
stage_batting.b_roe as reachedonerror
from stage_batting
left join dim_player on dim_player.sourceplayerid = stage_batting.id
left join dim_game on dim_game.sourcegameid = stage_batting.gid
left join dim_team on dim_team.sourcegameid = stage_batting.gid
                    and dim_team.team = stage_batting.team;



create table fact_pitching(
DimGameId int references dim_game(dimgameid),
DimPlayerID int references dim_player(dimplayerid),
DimTeamID int references dim_team(dimteamid),
sourceplayerid varchar(255),
outsmade int,
battersfaced int,
hitsallowed int,
doublesallowed int,
triplesallowed int,
hrallowed int,
runsallowed int,
earnedruns int,
walks int,
intwalks int,
strikeouts int,
hitbatters int,
wildpitches int,
balks int,
sachitsallowed int,
sacfliesallowed int,
stolenbasesallowed int,
runnerscaughtstealing int,
passedballs int,
gamesstarted int,
gamesfinished int,
completegames int
)


insert into fact_pitching(
DimGameId,
DimPlayerID,
DimTeamID,
sourceplayerid,
outsmade,
battersfaced,
hitsallowed,
doublesallowed,
triplesallowed,
hrallowed,
runsallowed,
earnedruns,
walks,
intwalks,
strikeouts,
hitbatters,
wildpitches,
balks,
sachitsallowed,
sacfliesallowed,
stolenbasesallowed,
runnerscaughtstealing,
passedballs,
gamesstarted,
gamesfinished,
completegames
)


select
NVL(dim_game.dimgameID,-1) as DimGameID,
NVL(dim_player.dimplayerid,-1) as Dimplayerid,
NVL(dim_team.dimteamid,-1) as Dimteamid,
stage_pitching.id as sourceplayerid,
stage_pitching.p_ipouts as outsmade,
stage_pitching.p_bfp as battersfaced,
stage_pitching.p_h as hitsallowed,
stage_pitching.p_d as doublesallowed,
stage_pitching.p_t as triplesallowed,
stage_pitching.p_hr as hrallowed,
stage_pitching.p_r as runsallowed,
stage_pitching.p_er as earnedruns,
stage_pitching.p_w as walks,
stage_pitching.p_iw as intwalks,
stage_pitching.p_k as strikeouts,
stage_pitching.p_hbp as hitbatters,
stage_pitching.p_wp as wildpitches,
stage_pitching.p_bk as balks,
stage_pitching.p_sh as sachitsallowed,
stage_pitching.p_sf as sacfliesallowed,
stage_pitching.p_sb as stolenbasesallowed,
stage_pitching.p_cs as runnerscaughtstealing,
stage_pitching.p_pb as passedballs,
stage_pitching.p_gs as gamesstarted,
stage_pitching.p_gf as gamesfinished,
stage_pitching.p_cg as completegames
from stage_pitching
left join dim_player on dim_player.sourceplayerid = stage_pitching.id
left join dim_game on dim_game.sourcegameid = stage_pitching.gid
left join dim_team on dim_team.sourcegameid = stage_pitching.gid
                    and dim_team.team = stage_pitching.team;
