DELETE FROM beer_user.beers
WHERE time = $1 and uuid = $2;
