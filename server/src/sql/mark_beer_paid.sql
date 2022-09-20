UPDATE beer_user.beers
SET paid = true
WHERE id = $2 and uuid = $1;
