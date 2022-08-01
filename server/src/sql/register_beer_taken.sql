INSERT INTO beer_user.beers(time,uuid,bier_brand)
VALUES ($1,$2,$3)
RETURNING $table_fields;
