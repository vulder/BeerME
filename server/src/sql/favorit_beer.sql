SELECT beer_brand, COUNT(beers.brand_id) as COUNT
FROM beer_user.beers
INNER JOIN beer_user.beer_brands ON beers.brand_id = beer_brands.brand_id
WHERE uuid = $1
GROUP BY beer_brand
ORDER BY COUNT DESC
LIMIT 1;
