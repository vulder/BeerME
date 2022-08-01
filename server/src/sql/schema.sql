DROP SCHEMA IF EXISTS beer_user CASCADE;
CREATE SCHEMA beer_user;

CREATE TABLE beer_user.users (
    uuid            VARCHAR(36) NOT NULL PRIMARY KEY,
    first_name      VARCHAR(200) UNIQUE NOT NULL,
    last_name       VARCHAR(200) NOT NULL,
    email           VARCHAR(200) UNIQUE NOT NULL,
    token           VARCHAR(200) UNIQUE NOT NULL
);

CREATE TABLE beer_user.beers (
    time            timestamptz,
    uuid            VARCHAR(36) NOT NULL,
    bier_brand      VARCHAR(200)
);
COMMIT;
