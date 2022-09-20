UPDATE beer_user.beers
SET paid = true
WHERE uuid = $1;
