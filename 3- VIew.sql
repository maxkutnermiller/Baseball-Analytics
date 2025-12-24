-- -- How many home runs were hit at night since 2000?
-- select dim_player.fullname, sum(fact_plays.hr) from dim_player
-- left join fact_plays on fact_plays.batter = dim_player.playerid
-- inner join dim_game on dim_game.gameid = fact_plays.gameid
-- where dim_game.daynight = 'night'
-- group by dim_player.fullname
-- order by sum(fact_plays.hr) desc

-- What were the rarest grounded-into-double-play combinations since 2000?
select outcome, count(gidp) from fact_plays
where gidp=1
group by outcome
-- having count(gidp) < 2
order by count(gidp)


--GenAI written query to filter out parts I don't want so I can just see fielder combinations in double plays
create view rare_dps as(SELECT
    MAX(date) AS most_recent,
    REGEXP_REPLACE(
        REGEXP_REPLACE(SPLIT_PART(outcome, '/', 1), '\\([0-9]+\\)', ''),
        '[^0-9]',
        ''
    ) AS double_play,
    COUNT(*) AS frequency
FROM fact_plays
WHERE gidp = 1
GROUP BY
    REGEXP_REPLACE(
        REGEXP_REPLACE(SPLIT_PART(outcome, '/', 1), '\\([0-9]+\\)', ''),
        '[^0-9]',
        ''
    )
ORDER BY
    frequency asc, most_recent desc)


--Double play searcher
select * from fact_plays where tp=1 and date ='20240624'




--GenAI written query to find the most frequent types of triple plays
create view rare_tps as (SELECT
    MAX(date) AS most_recent,
    REGEXP_REPLACE(
        REGEXP_REPLACE(SPLIT_PART(outcome, '/', 1), '\\([0-9]+\\)', ''),
        '[^0-9]',
        ''
    ) AS triple_play,
    COUNT(*) AS frequency
FROM fact_plays
WHERE tp = 1
GROUP BY
    REGEXP_REPLACE(
        REGEXP_REPLACE(SPLIT_PART(outcome, '/', 1), '\\([0-9]+\\)', ''),
        '[^0-9]',
        ''
    )
ORDER BY
    frequency asc, most_recent desc);



-- Who has the most home runs in the regular season since 2000?
create view hrs as (select dim_player.fullname, sum(fact_plays.hr) as homeruns from dim_player
left join fact_plays on fact_plays.dimbatterid = dim_player.dimplayerid
inner join dim_game on dim_game.dimgameid = fact_plays.dimgameid
where fact_plays.gametype = 'regular'
group by dim_player.fullname
order by sum(fact_plays.hr) desc)



-- -- Check home runs in regular vs postseason
-- SELECT dim_game.gametype, sum(fact_plays.hr)
-- FROM fact_plays
-- JOIN dim_game ON dim_game.gameid = fact_plays.gameid
-- join dim_player on dim_player.playerid = fact_plays.batter
-- WHERE dim_player.fullname = 'Mike Trout'
-- GROUP BY dim_game.gametype;

-- What pitchers induce the most double plays?
create view p_dps as (select dim_player.fullname, count(fact_plays.gidp) as dps from fact_plays
left join dim_player on dim_player.dimplayerid = fact_plays.dimpitcherid
where gidp=1
group by dim_player.fullname
order by count(fact_plays.gidp) desc)

-- What teams hit into the most double plays?
create view team_dps as (select dim_team.team, count(fact_hitting.gdp) as dps from fact_hitting
left join dim_team on dim_team.dimteamid = fact_hitting.dimteamid
where gdp=1
group by dim_team.team
order by count(fact_hitting.gdp) desc)

--Which batting order spots produce the most RBI?
create view order_rbis as (select orderspot, sum(rbi) as rbis from fact_hitting
group by orderspot
order by sum(rbi) desc)

--Which batting order spots ground into the most double plays?
create view order_dps as (select orderspot, count(gdp) as dps from fact_hitting
where gdp=1
group by orderspot
order by count(gdp) desc)

--For each left-handed batter, how many strikeouts vs right-handed pitchers vs left-handed pitchers?
create view v_righties as(
select dimplayerid from dim_player where throwinghand = 'R')

create view v_lefties as(
select dimplayerid from dim_player where throwinghand = 'L')

create view hand_hitting as(
select dim_player.fullname,
sum(case
when fact_plays.dimpitcherid in (select dimplayerid from v_righties) then strikeout
else 0
end) as against_righties,
sum(case
when fact_plays.dimpitcherid in (select dimplayerid from v_lefties) then strikeout
else 0
end) as against_lefties
from fact_plays
inner join dim_player on dim_player.dimplayerid= fact_plays.dimbatterid
where dim_player.battinghand = 'L'
group by dim_player.fullname
order by against_righties desc)


--Which ballparks see the most double plays of any type?
create view park_dps as (select ballpark, sum(gidp+othdp) as dps from fact_plays
where gidp=1 or othdp=1
group by ballpark
order by sum(gidp+othdp) desc)

--What are the most common double plays that don't involve a ground ball?
create view othdps as (select outcome, sum(othdp) as dps from fact_plays
where othdp=1
group by outcome
order by sum(othdp) desc)

--When do double plays happen most often?
create view when_dps as (select inning,
sum(case
when top_bot=0 then gidp+othdp
else 0
end) as top,
sum(case
when top_bot=1 then gidp+othdp
else 0
end) as bottom
from fact_plays
where gidp=1 or othdp=1
group by inning
order by top desc)

--Which pitchers allow the fewest walks per start?
create view pit_walks as (select dim_player.fullname as name, count(fact_pitching.gamesstarted) as starts, sum(fact_pitching.walks) as walks, (sum(fact_pitching.walks) * 1.0 / nullif(count(fact_pitching.gamesstarted), 0)) as walks_per_start from fact_pitching
inner join dim_player on dim_player.dimplayerid = fact_pitching.dimplayerid
group by dim_player.fullname
having (SUM(fact_pitching.walks) * 1.0 / NULLIF(COUNT(fact_pitching.gamesstarted), 0)) is not null
order by count(fact_pitching.gamesstarted) desc)

--Which batters reach on error most often?
create view roes as (select dim_player.fullname, (sum(fact_plays.reachonerror) * 1.0/ nullif(sum(fact_plays.plateappearance),0)) as reached_on_errors_per_PA from dim_player
inner join fact_plays on fact_plays.dimbatterid = dim_player.dimplayerid
group by dim_player.fullname
order by count(fact_plays.plateappearance) desc)

-- Which teams draw the most walks?
create view team_walks as (select substr(fact_plays.date,0,4) as year, dim_team.team, sum(fact_plays.walk) as walks from fact_plays
inner join dim_team on dim_team.dimteamid = fact_plays.dimbattingteamid
group by dim_team.team, substr(fact_plays.date,0,4)
order by sum(fact_plays.walk) desc)

--Which teams score the most runs late in games?
create view late_scoring as(select substr(fact_plays.date,0,4) as year, dim_team.team, sum(fact_plays.runsscored) as runs from fact_plays
inner join dim_team on dim_team.dimteamid = fact_plays.dimbattingteamid
where fact_plays.inning >=6
group by dim_team.team, substr(fact_plays.date,0,4)
order by sum(fact_plays.runsscored) desc)

--Which pitcher–ballpark combos result in the most strikeouts?
create view park_ks as (select dim_player.fullname, sum(fact_plays.strikeout) as ks, fact_plays.ballpark from fact_plays
inner join dim_player on dim_player.dimplayerid = fact_plays.dimpitcherid
group by fact_plays.ballpark, dim_player.fullname
order by sum(fact_plays.strikeout) desc)

--Which pitcher–ballpark combos result in the most strikeouts away from home?
create view away_pitcher as(select dim_player.fullname, sum(fact_plays.strikeout) as ks, fact_plays.ballpark from fact_plays
inner join dim_player on dim_player.dimplayerid = fact_plays.dimpitcherid
inner join dim_team on dim_team.dimteamid = fact_plays.dimpitchingteamid
where dim_team.vishome = 'v'
group by fact_plays.ballpark, dim_player.fullname
order by sum(fact_plays.strikeout) desc)

--Which parks generate the most flyballs vs groundballs?
create view hittypes as(select ballpark,
sum(case
when groundball =1 then groundball
else 0
end) as groundballs,
sum(case
when flyball=1 then flyball
else 0
end) as flyballs
from fact_plays
group by ballpark
order by flyballs desc)

--Which pitchers hit the most batters?
create view hitmost as (select dim_player.fullname, sum(fact_plays.hbp) as hits from fact_plays
inner join dim_player on dim_player.dimplayerid = fact_plays.dimpitcherid
group by dim_player.fullname
order by sum(fact_plays.hbp) desc)

--Which batters bat with runners on base most often?
create view runnerson as(select dim_player.fullname, sum(fact_plays.plateappearance) as pas from fact_plays
inner join dim_player on dim_player.dimplayerid = fact_plays.dimbatterid
where  fact_plays.baserunner1pre is not null or fact_plays.baserunner2pre is not null or fact_plays.baserunner3pre is not null
group by dim_player.fullname
order by sum(fact_plays.plateappearance) desc)

--Sort pitchers into types of outs that they create
create view outtypes as(select dim_player.fullname,
sum(case
when fact_plays.strikeout=1 then strikeout
else 0
end) as strikeouts,
sum(case
when fact_plays.groundball=1 then groundball
else 0
end) as groundouts,
sum(case
when fact_plays.flyball =1 then flyball
end) as flyouts,
sum(case
when fact_plays.linedrive =1 then linedrive
else 0
end) as lineouts
from dim_player
inner join fact_plays on fact_plays.dimpitcherid = dim_player.dimplayerid
where fact_plays.single =0 and fact_plays.double=0 and fact_plays.triple=0 and fact_plays.hr=0 and fact_plays.walk=0 and fact_plays.intwalk=0 and fact_plays.hbp=0 and fact_plays.gametype = 'regular'
group by dim_player.fullname
order by strikeouts desc)

create view outtypes2 as(select
case
when strikeouts > groundouts and strikeouts > flyouts and strikeouts > lineouts then fullname
end as strikeout_pitchers,
case
when groundouts > strikeouts and groundouts > flyouts and groundouts > lineouts then fullname
end as groundball_pitchers,
case
when flyouts > strikeouts and flyouts > groundouts and flyouts > lineouts then fullname
end as flyball_pitchers,
case
when lineouts > strikeouts and lineouts > groundouts and lineouts > flyouts then fullname
end as linedrive_pitchers
from outtypes)

create view kpitchers as (select fullname as strikeout_pitchers , strikeouts from outtypes
where strikeouts > groundouts and strikeouts > flyouts and strikeouts > lineouts
order by strikeouts desc)


create view gbpitchers as (select fullname  as groundball_pitchers, groundouts from outtypes
where groundouts > strikeouts and groundouts > flyouts and groundouts > lineouts
order by groundouts desc)

create view flypitchers as (select fullname as flyball_pitchers , flyouts from outtypes
where flyouts > strikeouts and flyouts > groundouts and flyouts > lineouts
order by flyouts desc)

create view linepitchers as (select fullname as lineout_pitchers ,  lineouts from outtypes
where lineouts > strikeouts and lineouts > groundouts and lineouts > flyouts
order by lineouts desc)

--Bunts by inning
create view bunts as(select inning, sum(bunt) as bunts from fact_plays
group by inning
order by sum(bunt) desc)


--Runs scored by outs
create view runsouts as (select
sum(case
when outspre = 0 then runsscored
end) as no_outs,
sum(case
when outspre =1 then runsscored
end) as one_out,
sum(case
when outspre=2 then runsscored
end) as two_outs
from fact_plays)

--Batting average per lineup spot


-- create view hits as
-- select dim_player.fullname, sum(fact_plays.single) + sum(fact_plays.double) + sum(fact_plays.triple) +sum(fact_plays.hr) as hits from fact_plays
-- inner join dim_player on dim_player.dimplayerid = fact_plays.dimbatterid
-- group by dim_player.fullname
-- order by sum(fact_plays.single) + sum(fact_plays.double) + sum(fact_plays.triple) +sum(fact_plays.hr)  desc;

-- create view avg as
-- select dim_player.fullname, (sum(fact_plays.single) + sum(fact_plays.double) + sum(fact_plays.triple) +sum(fact_plays.hr)) *1.0 / nullif(sum(fact_plays.atbat),0) as avg from fact_plays
-- inner join dim_player on dim_player.dimplayerid = fact_plays.dimbatterid
-- group by dim_player.fullname
-- having sum(fact_plays.atbat) >= 500
-- order by (sum(fact_plays.single) + sum(fact_plays.double) + sum(fact_plays.triple) +sum(fact_plays.hr)) *1.0 / nullif(sum(fact_plays.atbat),0) desc;


create view runouts as (select fact_plays.orderspot, (sum(fact_plays.single) + sum(fact_plays.double) + sum(fact_plays.triple) +sum(fact_plays.hr)) *1.0 / nullif(sum(fact_plays.atbat),0) as hits from fact_plays
group by fact_plays.orderspot
having sum(fact_plays.atbat) >= 500
order by (sum(fact_plays.single) + sum(fact_plays.double) + sum(fact_plays.triple) +sum(fact_plays.hr)) *1.0 / nullif(sum(fact_plays.atbat),0) desc)

--Scoring by month
create view monthscoring as(select
sum(case when substr(date, 5, 2) = 04 then runsscored
end) as April,
sum(case when substr(date, 5, 2) = 05 then runsscored
end) as May,
sum(case when substr(date, 5, 2) = 06 then runsscored
end) as June,
sum(case when substr(date, 5, 2) = 07 then runsscored
end) as July,
sum(case when substr(date, 5, 2) = 08 then runsscored
end) as August,
sum(case when substr(date, 5, 2) = 09 then runsscored
end) as September,
sum(case when substr(date, 5, 2) = 10 then runsscored
end) as October
from fact_plays)

--Difference between strikeout rate with bases empty vs bases loaded

-- with strikeouts as(
-- select dimplayerid, dim_player.fullname, count(fact_plays.outcome) as strikeouttotal from fact_plays
-- inner join dim_player on dim_player.dimplayerid = fact_plays.dimpitcherid
-- where outcome='K'
-- group by dim_player.fullname, dimplayerid),
-- PAs as(
-- select dimplayerid, dim_player.fullname, count(fact_plays.outcome) as PATotal from fact_plays
-- inner join dim_player on dim_player.dimplayerid = fact_plays.dimpitcherid
-- where plateappearance=1 and outcome='K'
-- group by dim_player.fullname, dimplayerid),
-- basesempty as(
-- select dimpitcherid, strikeouts.strikeouttotal / PAs.PATotal as empty from fact_plays
-- inner join strikeouts on strikeouts.dimplayerid = fact_plays.dimpitcherid
-- inner join PAs on PAs.dimplayerid = fact_plays.dimpitcherid
-- where fact_plays.baserunner1pre is null and baserunner2pre is null and baserunner3pre is null and outcome='K'
-- ),
-- basesloaded as(select dimpitcherid, strikeouts.strikeouttotal / PAs.PATotal as loaded from fact_plays
-- inner join strikeouts on strikeouts.dimplayerid = fact_plays.dimpitcherid
-- inner join PAs on PAs.dimplayerid = fact_plays.dimpitcherid
-- where fact_plays.baserunner1pre is not null and baserunner2pre is not null and baserunner3pre is not  null and outcome='K'
-- )
-- select dim_player.fullname, (basesempty.empty - basesloaded.loaded) from dim_player
-- inner join basesempty on basesempty.dimpitcherid = dim_player.dimplayerid
-- inner join basesloaded on basesloaded.dimpitcherid = dim_player.dimplayerid
-- order by 2 desc

create view ktypes as (with empty as(select * from fact_plays where baserunner1pre is null and baserunner2pre is null and baserunner3pre is null),

loaded as (select * from fact_plays where baserunner1pre is not null and baserunner2pre is not null and baserunner3pre is not null),

emptyk as (select dimpitcherid, count(outcome) as ek from empty where outcome='K' group by dimpitcherid),

emptypa as (select dimpitcherid, count(outcome) as epa from empty where plateappearance=1 group by dimpitcherid),

emptyrate as (select emptyk.dimpitcherid, sum(emptyk.ek / emptypa.epa) as ert from emptyk
inner join emptypa on emptypa.dimpitcherid = emptyk.dimpitcherid
group by emptyk.dimpitcherid),

loadk as (select dimpitcherid, count(outcome) as lk from loaded where outcome='K' group by dimpitcherid),

loadpa as (select dimpitcherid, count(outcome) as lpa from loaded where plateappearance=1 group by dimpitcherid having sum(plateappearance) > 30),

loadedrate as (select loadk.dimpitcherid, sum(loadk.lk / loadpa.lpa) as lrt from loadk
inner join loadpa on loadpa.dimpitcherid = loadk.dimpitcherid
group by loadk.dimpitcherid)


select dim_player.fullname, sum(emptyrate.ert - loadedrate.lrt) as totrate from loadedrate
inner join dim_player on dim_player.dimplayerid = loadedrate.dimpitcherid
inner join emptyrate on emptyrate.dimpitcherid = loadedrate.dimpitcherid
group by dim_player.fullname
order by sum(emptyrate.ert - loadedrate.lrt) desc)

--Earned runs allowed by inning in complete games
create view cgs as (select inning, sum(fact_plays.earnedruns) as ers from fact_plays
inner join fact_pitching on fact_pitching.dimgameid = fact_plays.dimgameid
and fact_pitching.dimplayerid = fact_plays.dimpitcherid
where fact_pitching.completegames =1
group by inning
order by inning)

--Errors in a year
create view errors as (select dim_player.fullname, sum(fact_fielding.errors) as errors, substr(dim_game.date, 0, 4) as year from fact_fielding
inner join dim_player on dim_player.dimplayerid = fact_fielding.dimplayerid
inner join dim_game on dim_game.dimgameid = fact_fielding.dimgameid
group by dim_player.fullname, substr(dim_game.date, 0, 4)
order by sum(fact_fielding.errors) desc)



select * from fact_hitting limit 10
select * from fact_pitching limit 10
select * from fact_plays limit 10
select * from fact_fielding limit 10

select * from dim_player limit 10
select * from dim_team limit 10
select * from dim_game limit 10

select * from stage_team limit 10

select * from stage_plays
