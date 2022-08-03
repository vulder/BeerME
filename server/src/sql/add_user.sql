INSERT INTO beer_user.users(uuid,first_name,last_name,email,token)
VALUES ($1,$2,$3,$4,$5)
RETURNING $table_fields;
