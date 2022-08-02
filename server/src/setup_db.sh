#!/bin/bash

psql -f src/sql/schema.sql dev_db
psql -f src/sql/seed_beer_brands.sql dev_db
psql -c "GRANT ALL PRIVILEGES ON SCHEMA beer_user TO test_user;" dev_db
psql -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA beer_user TO test_user;" dev_db
psql -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA beer_user TO test_user;" dev_db
