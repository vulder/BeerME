INSERT INTO beer_user.users(first_name,last_name,email,token)
VALUES ($1,$2,$3,$4)
RETURNING $table_fields;
