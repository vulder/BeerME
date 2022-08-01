SELECT bier_brand, COUNT(beers.bier_brand) as COUNT
FROM beer_user.beers
WHERE uuid = $1
GROUP BY bier_brand
ORDER BY COUNT DESC
LIMIT 1;
