--Taylor Swift Spotify Dataset - Cleaning
--2024-06-05
--Hannah Resnick
------------------------------------------------------------------------
--[1] - Import Data into SQL

--CSV imported from Kaggle 
select * from portfolioproject..taylor_swift_spotify

--Create backup table in DB
--insert into portfolioproject..taylor_swift_spotify_backup
select * from portfolioproject..taylor_swift_spotify

select * from portfolioproject..taylor_swift_spotify_backup

-------------------------------------------------------------------------
--[2] - Remove Live Albums/Playlists
select distinct album from PortfolioProject..taylor_swift_spotify

--1989
--1989 (Deluxe Edition)
--1989 (Taylor's Version)
--1989 (Taylor's Version) [Deluxe]
--evermore
--evermore (deluxe version)
--Fearless
--Fearless (Taylor's Version)
--Fearless Platinum Edition
--folklore
--folklore (deluxe version)
--folklore: the long pond studio sessions (from the Disney+ special) [deluxe edition]
--Live From Clear Channel Stripped 2008
--Lover
--Midnights
--Midnights (3am Edition)
--Midnights (The Til Dawn Edition)
--Red
--Red (Deluxe Edition)
--Red (Taylor's Version)
--reputation
--reputation Stadium Tour Surprise Song Playlist
--Speak Now
--Speak Now (Deluxe Edition)
--Speak Now (Taylor's Version)
--Speak Now World Tour Live
--Taylor Swift
--THE TORTURED POETS DEPARTMENT
--THE TORTURED POETS DEPARTMENT: THE ANTHOLOGY


--delete 
select * 
--select distinct album
from PortfolioProject..taylor_swift_spotify
where album like '%live%'
or album like '%playlist%'
or album like '%session%'

-------------------------------------------------------------------------
--[3] - Round Long Numbers in Dataset

--acousticness, danceability, etc - round to 2 decimal places for easier use

select 
	acousticness,	
	danceability,	
	energy,
	instrumentalness,	
	liveness,
	loudness,
	speechiness,	
	tempo,
	valence
	--round(instrumentalness, 2)
from portfolioproject..taylor_swift_spotify

--update portfolioproject..taylor_swift_spotify set acousticness = round(acousticness, 2)
--update portfolioproject..taylor_swift_spotify set danceability = round(danceability, 2)
--update portfolioproject..taylor_swift_spotify set energy = round(energy, 2)
--update portfolioproject..taylor_swift_spotify set instrumentalness = round(instrumentalness, 2)
--update portfolioproject..taylor_swift_spotify set liveness = round(liveness, 2)
--update portfolioproject..taylor_swift_spotify set loudness = round(loudness, 2)
--update portfolioproject..taylor_swift_spotify set speechiness = round(speechiness, 2)
--update portfolioproject..taylor_swift_spotify set tempo = round(tempo, 2)
--update portfolioproject..taylor_swift_spotify set valence = round(valence, 2)

-------------------------------------------------------------------------
--[4] - Convert Duration to Minutes from Milliseconds

--Easier to analyze and understand song length in minutes
--Add column for duration in minutes (with 2 decimal places), and fill with conversion from ms

--alter table portfolioproject..taylor_swift_spotify add duration_min float
--update PortfolioProject..taylor_swift_spotify set duration_min = round((duration_ms/(60*1000)),2)

-------------------------------------------------------------------------
--[5] - Remove Duplicate Songs

--We want both original and Taylor's Version of the songs (where applicable)
--However, there are quite a few deluxe versions of the albums, which is creating duplicates
--For example, Style (1989) and Style (1989 Deluxe) are the same, and having both in the dataset is redundant
--Going era by era, go through and remove duplicates from the dataset.

----[a] - ERA 1 - Taylor Swift (debut)
select * from PortfolioProject..taylor_swift_spotify where album = 'Taylor Swift'
--No Deluxe Version
--No Taylor's Version 

--2 versions of Teardrops on My Guitar 
--BUT looking at actual spotify, radio single has many more listens than pop version - keep that one
select * from PortfolioProject..taylor_swift_spotify where name = 'Teardrops on My Guitar - Pop Version'
--delete from PortfolioProject..taylor_swift_spotify where name = 'Teardrops on My Guitar - Pop Version'

----[b] - ERA 2 - Fearless
select * from PortfolioProject..taylor_swift_spotify where album like '%fearless%'
--Platinum Version (Deluxe)
--Taylor's Version

--Deluxe Duplicates - removing from deluxe version
select name, count(name) as songcount
into #tempfearless
from
	(select * from PortfolioProject..taylor_swift_spotify 
	where album like '%fearless%' and album not like '%version%') a
group by name
having count(name) > 1

select * from PortfolioProject..taylor_swift_spotify where name in (select name from #tempfearless) and album <> 'Fearless'
--delete from PortfolioProject..taylor_swift_spotify where name in (select name from #tempfearless) and album <> 'Fearless'

----[c] - ERA 3 - Speak Now
select * from PortfolioProject..taylor_swift_spotify where album like '%speak now%'
--Deluxe Version
--Taylor's Version

--Deluxe Duplicates
select name, count(name) as songcount
into #tempspeaknow
from
	(select * from PortfolioProject..taylor_swift_spotify 
	where album like '%speak now%' and album not like '%version%') a
group by name
having count(name) > 1

select * from PortfolioProject..taylor_swift_spotify where name in (select name from #tempspeaknow) and album <> 'Speak Now'
--delete from PortfolioProject..taylor_swift_spotify where name in (select name from #tempspeaknow) and album <> 'Speak Now'

----[d] - ERA 4 - Red
select * from PortfolioProject..taylor_swift_spotify where album like 'red%'
--Deluxe Version
--Taylor's Version

--Deluxe Duplicates
select name, count(name) as songcount
into #tempred
from
	(select * from PortfolioProject..taylor_swift_spotify 
	where album like 'red%' and album not like '%version%') a
group by name
having count(name) > 1

select * from PortfolioProject..taylor_swift_spotify where name in (select name from #tempred) and album <> 'Red'
--delete from PortfolioProject..taylor_swift_spotify where name in (select name from #tempred) and album <> 'Red'

----[e] - ERA 5 - 1989
select * from PortfolioProject..taylor_swift_spotify where album like '1989%'
--Deluxe Version
--Taylor's Version
--Taylor's Version (Deluxe)

--Deluxe Duplicates
select name, count(name) as songcount
into #temp1989
from
	(select * from PortfolioProject..taylor_swift_spotify 
	where album like '1989%' and album not like '%version%') a
group by name
having count(name) > 1

select * from PortfolioProject..taylor_swift_spotify where name in (select name from #temp1989) and album <> '1989'
--delete from PortfolioProject..taylor_swift_spotify where name in (select name from #temp1989) and album <> '1989'

--TV Deluxe Duplicates
select name, count(name) as songcount
--into #temp1989TV
from
	(select * from PortfolioProject..taylor_swift_spotify 
	where album like '1989%' and album  like '%version%') a
group by name
having count(name) > 1

--Only 1 song on 1989 TV Deluxe - Bad Blood Remix ft Kendrick Lamar - all others can be dropped

select * from PortfolioProject..taylor_swift_spotify where album like '1989%version%deluxe%' and name <> 'Bad Blood (feat. Kendrick Lamar) (Taylor''s Version)'
--delete from PortfolioProject..taylor_swift_spotify where album like '1989%version%deluxe%' and name <> 'Bad Blood (feat. Kendrick Lamar) (Taylor''s Version)'

----[f] - ERA 6 - reputation
select * from PortfolioProject..taylor_swift_spotify where album like 'rep%'
--No Deluxe Version
--No Taylor's Version 

----[g] - ERA 7 - lover
select * from PortfolioProject..taylor_swift_spotify where album like 'lover%'
--No Deluxe Version
--No Taylor's Version - All albums from here on are owned by Taylor and won't be rerecorded - no need to check TV

----[h] - ERA 8 - folklore
select * from PortfolioProject..taylor_swift_spotify where album like 'folklore%'
--Deluxe Version

--Deluxe Duplicates
select name, count(name) as songcount
into #tempfolk
from
	(select * from PortfolioProject..taylor_swift_spotify 
	where album like 'folklore%') a
group by name
having count(name) > 1

select * from PortfolioProject..taylor_swift_spotify where name in (select name from #tempfolk) and album <> 'folklore'
--delete from PortfolioProject..taylor_swift_spotify where name in (select name from #tempfolk) and album <> 'folklore'

----[i] - ERA 9 - evermore
select * from PortfolioProject..taylor_swift_spotify where album like 'evermore%'
--Deluxe Version

--Deluxe Duplicates
select name, count(name) as songcount
into #tempever
from
	(select * from PortfolioProject..taylor_swift_spotify 
	where album like 'evermore%') a
group by name
having count(name) > 1

select * from PortfolioProject..taylor_swift_spotify where name in (select name from #tempever) and album <> 'evermore'
--delete from PortfolioProject..taylor_swift_spotify where name in (select name from #tempever) and album <> 'evermore'

----[j] - ERA 10 - Midnights
select * from PortfolioProject..taylor_swift_spotify where album like 'midnights%'
--Til Dawn Edition (Deluxe)
--3am Edition (Deluxe)

--Deluxe Duplicates
select name, count(name) as songcount
into #tempmid
from
	(select * from PortfolioProject..taylor_swift_spotify 
	where album like 'midnights%') a
group by name
having count(name) > 1

--Til Dawn Edition - 3 occurrences of songs
select * from PortfolioProject..taylor_swift_spotify where name in (select name from #tempmid where songcount = 3) and album <> 'midnights'
--delete from PortfolioProject..taylor_swift_spotify where name in (select name from #tempmid where songcount = 3) and album <> 'midnights'

--3am Edition - 2 occurrences of songs
select * from PortfolioProject..taylor_swift_spotify where name in (select name from #tempmid where songcount = 2) and album not like '%3am%'
--delete from PortfolioProject..taylor_swift_spotify where name in (select name from #tempmid where songcount = 2) and album not like '%3am%'

----[k] - ERA 11 - THE TORTURED POETS DEPARTMENT
select * from PortfolioProject..taylor_swift_spotify where album like '%department%'
--THE ANTHOLOGY - technically a double album, for this process I'll be treating all of these songs like deluxe/bonus songs

--Deluxe Duplicates
select name, count(name) as songcount
into #tempttpd
from
	(select * from PortfolioProject..taylor_swift_spotify 
	where album like '%department%') a
group by name
having count(name) > 1

select * from PortfolioProject..taylor_swift_spotify where name in (select name from #tempttpd) and album like '%anthology%'
--delete from PortfolioProject..taylor_swift_spotify where name in (select name from #tempttpd) and album like '%anthology%'

-------------------------------------------------------------------------
--[6] - Remove Memos/Demos/Remixes

--Demos/Memos aren't real songs and Remixes are duplicates - go through these
--Note from Era 1 - already deleted extra Teardrops on My Guitar - KEEP the "radio remix"

select * from PortfolioProject..taylor_swift_spotify 
where name like '%memo%' or name like '%demo%' or name like '%mix%' and name not like '%teardrops%'

--delete from PortfolioProject..taylor_swift_spotify where name like '%memo%' or name like '%demo%' or name like '%mix%' and name not like '%teardrops%'

-------------------------------------------------------------------------
--[7] - Remove Filler Columns

--"Column 0" (index), id (Spotify), uri (Spotify), duration_ms (have new minutes column) - all can be dropped

select [Column 0], id, uri, duration_ms from PortfolioProject..taylor_swift_spotify
--alter table PortfolioProject..taylor_swift_spotify drop column [Column 0], id, uri, duration_ms

-------------------------------------------------------------------------
--[8] - Add Columns with More Detail

--Columns Needed:
----TV: note whether an album is Taylor's Version or not
----era: which era does the album correspond to
----track_type: regular track, bonus, or vault
----feature: whether the track features another artist

--alter table PortfolioProject..taylor_swift_spotify add TV int, era int, track_type varchar(50), feature bit

----[a] - Taylor's Version (TV)
--Update Taylor's Version column
--0 = Original, NOT TV
--1 = TV re-release
--2 = Original but also TV (albums dropped after label dispute, she already owns and will not need to re-record)

select * from PortfolioProject..taylor_swift_spotify where album like '%taylor''s version%'
--update PortfolioProject..taylor_swift_spotify set TV = 1 where album like '%taylor''s version%'

select * from PortfolioProject..taylor_swift_spotify where album like 'lover%' or album like 'folk%' or album like 'ever%' or album like 'midnight%' or album like '%poet%'
--update PortfolioProject..taylor_swift_spotify  set TV = 2 where album like 'lover%' or album like 'folk%' or album like 'ever%' or album like 'midnight%' or album like '%poet%'

select * from PortfolioProject..taylor_swift_spotify where TV is null
--update PortfolioProject..taylor_swift_spotify set TV = 0 where TV is null

select distinct album, TV from PortfolioProject..taylor_swift_spotify

----[b] - Eras

select * from PortfolioProject..taylor_swift_spotify where album = 'taylor swift'
--update PortfolioProject..taylor_swift_spotify set era = 1 where album = 'taylor swift'

select * from PortfolioProject..taylor_swift_spotify where album like 'fearless%'
--update PortfolioProject..taylor_swift_spotify set era = 2 where album like 'fearless%'

select * from PortfolioProject..taylor_swift_spotify where album like 'speak%'
--update PortfolioProject..taylor_swift_spotify set era = 3 where album like 'speak%'

select * from PortfolioProject..taylor_swift_spotify where album like 'red%'
--update PortfolioProject..taylor_swift_spotify set era = 4 where album like 'red%'

select * from PortfolioProject..taylor_swift_spotify where album like '1989%'
--update PortfolioProject..taylor_swift_spotify set era = 5 where album like '1989%'

select * from PortfolioProject..taylor_swift_spotify where album = 'reputation'
--update PortfolioProject..taylor_swift_spotify set era = 6 where album = 'reputation'

select * from PortfolioProject..taylor_swift_spotify where album = 'lover'
--update PortfolioProject..taylor_swift_spotify set era = 7 where album = 'lover'

select * from PortfolioProject..taylor_swift_spotify where album like 'folk%'
--update PortfolioProject..taylor_swift_spotify set era = 8 where album like 'folk%'

select * from PortfolioProject..taylor_swift_spotify where album like 'ever%'
--update PortfolioProject..taylor_swift_spotify set era = 9 where album like 'ever%'

select * from PortfolioProject..taylor_swift_spotify where album like 'midnight%'
--update PortfolioProject..taylor_swift_spotify set era = 10 where album like 'midnight%'

select * from PortfolioProject..taylor_swift_spotify where album like '%poets%'
--update PortfolioProject..taylor_swift_spotify set era = 11 where album like '%poets%'

select distinct album, era from PortfolioProject..taylor_swift_spotify
order by era

----[c] - Features
select * from PortfolioProject..taylor_swift_spotify where name like '%feat%'
--update PortfolioProject..taylor_swift_spotify set feature = 1 where name like '%feat%'
--update PortfolioProject..taylor_swift_spotify set feature = 0 where feature is null

select name, feature from PortfolioProject..taylor_swift_spotify

----[d] - Track Type
select distinct album, track_type from PortfolioProject..taylor_swift_spotify

--Vault Tracks (only on TV albums)
select * from PortfolioProject..taylor_swift_spotify where name like '%vault%'
--update PortfolioProject..taylor_swift_spotify set track_type = 'Vault' where name like '%vault%'

--Bonus Tracks (only/all on Deluxe albums - removed regular songs duplicated on deluxe albums earlier)
select * from PortfolioProject..taylor_swift_spotify where album like '%deluxe%' or album like '%edition%' or album like '%anthology%'
--update PortfolioProject..taylor_swift_spotify set track_type = 'Bonus' where album like '%deluxe%' or album like '%edition%' or album like '%anthology%'

--Bonus Tracks TV
--More in detail as Taylor's Version albums don't show if the track was originally a bonus track

--update TV set track_type = 'Bonus'
select TV.name, TV.TV, bonus.name, bonus.TV, bonus.album
from PortfolioProject..taylor_swift_spotify TV
join PortfolioProject..taylor_swift_spotify bonus on TV.name = bonus.name + ' (Taylor''s Version)'
where bonus.track_type = 'bonus' and bonus.tv = 0

select * from PortfolioProject..taylor_swift_spotify where track_type = 'bonus'
order by era, track_number

--Missed: 
----fearless TV: forever & always piano
----speak now TV: if this was a movie, back to december and haunted acoustic
----red TV: state of grace acoustic
----1989 regular: bad blood w kendrick

--Fearless TV
select track_number, name, track_type from PortfolioProject..taylor_swift_spotify 
where era = 2 and TV = 1
--16	Forever & Always (Piano Version) (Taylor's Version)
--20	Today Was A Fairytale (Taylor's Version) - not released on deluxe originally, but released during that era - count as bonus

select * from PortfolioProject..taylor_swift_spotify where era = 2 and TV = 1 and track_number in (16, 20)
--update PortfolioProject..taylor_swift_spotify set track_type = 'Bonus' where era = 2 and TV = 1 and track_number in (16, 20)

--Speak Now TV
select track_number, name, track_type from PortfolioProject..taylor_swift_spotify 
where era = 3 and TV = 1
--Acoustic tracks and If This Was a Movie not on TV - skip

--Red TV
select track_number, name, track_type from PortfolioProject..taylor_swift_spotify 
where era = 4 and TV = 1
--20	State Of Grace (Acoustic Version) (Taylor's Version)
--21	Ronan (Taylor's Version) - not released on deluxe originally, but released during that era - count as bonus

select * from PortfolioProject..taylor_swift_spotify where era = 4 and TV = 1 and track_number in (20, 21)
--update PortfolioProject..taylor_swift_spotify set track_type = 'Bonus' where era = 4 and TV = 1 and track_number in (20, 21)

--1989 Regular
select track_number, name, track_type from PortfolioProject..taylor_swift_spotify 
where era = 5 and TV = 0
--Bad Blood Remix not on original album - skip

select era, album, count(name) 
from PortfolioProject..taylor_swift_spotify 
where track_type = 'bonus'
and era < 7
group by album, era
order by era
--Counts check out with above notes of missing or added songs

--Regular Tracks
select * from PortfolioProject..taylor_swift_spotify where track_type is null
--update PortfolioProject..taylor_swift_spotify set track_type = 'Regular' where track_type is null

-------------------------------------------------------------------------
--[9] - Final Checks

select name,
	album,
	track_number,
	TV,
	era, 
	track_type,
	feature
from PortfolioProject..taylor_swift_spotify 
order by era, TV, track_number

--Fearless Platinum tracks were added to beginning of album - makes the track listing a little odd - move them to the end of the regular Fearless listing
select * from PortfolioProject..taylor_swift_spotify where era = 2 and TV = 0 
--track listing + 13 to bonus tracks
select * from PortfolioProject..taylor_swift_spotify where era = 2 and TV = 0  and track_type = 'bonus'
--update PortfolioProject..taylor_swift_spotify set track_number = track_number+13 where era = 2 and TV = 0 and track_type = 'bonus'

-------------------------------------------------------------------------
--[10] - Final Dataset

select * from PortfolioProject..taylor_swift_spotify 
order by era, TV, track_number