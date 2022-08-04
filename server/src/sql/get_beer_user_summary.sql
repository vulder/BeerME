select * from
 (select count(*) as total from beer_user.beers where uuid = $1) as total,
 (select count(*) as today from beer_user.beers where uuid = $1 and time > date_trunc('day', now())) as today,
 (select count(*) as week  from beer_user.beers where uuid = $1 and time > date_trunc('week', now())) as week,
 (select count(*) as month from beer_user.beers where uuid = $1 and time > date_trunc('month', now())) as month;
 