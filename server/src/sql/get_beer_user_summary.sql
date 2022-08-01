select * from
 (select count(*) as total from beer_user.beers where uuid = $1) as total,
 (select count(*) as today from beer_user.beers where uuid = $1 and time > current_date - interval '1 day') as today,
 (select count(*) as week  from beer_user.beers where uuid = $1 and time > current_date - interval '1 week') as week,
 (select count(*) as month from beer_user.beers where uuid = $1 and time > current_date - interval '1 month') as month;
