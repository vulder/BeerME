SELECT $table_fields
FROM beer_user.beers
INNER JOIN beer_user.beer_brands ON beers.brand_id = beer_brands.brand_id
WHERE uuid = $1;
