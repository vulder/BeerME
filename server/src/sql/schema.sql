DROP SCHEMA IF EXISTS beer_user CASCADE;
CREATE SCHEMA beer_user;

CREATE TABLE beer_user.users (
    id              BIGSERIAL PRIMARY KEY,
    first_name      VARCHAR(200) NOT NULL,
    last_name       VARCHAR(200) NOT NULL,
    email           VARCHAR(200) UNIQUE NOT NULL,
    token           VARCHAR(200) UNIQUE NOT NULL
);
COMMIT;
