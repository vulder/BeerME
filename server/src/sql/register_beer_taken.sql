INSERT INTO beer_user.beers(time,uuid,brand_id,paid)
VALUES ($1,$2,(SELECT brand_id FROM beer_user.beer_brands WHERE beer_brand = $3),$4)
RETURNING beers.id, beers.time, beers.uuid, $3 as beer_brand, beers.paid;
