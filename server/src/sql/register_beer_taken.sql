INSERT INTO beer_user.beers(time,uuid,brand_id)
VALUES ($1,$2,(SELECT brand_id FROM beer_user.beer_brands WHERE beer_brand = $3))
RETURNING beers.uuid, beers.time, $3 as beer_brand;
