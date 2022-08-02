#!/bin/bash

psql -f src/sql/schema.sql test_db
psql -f tests/sql/init_db.sql test_db
psql -c "GRANT ALL PRIVILEGES ON SCHEMA beer_user TO test_user;" test_db
psql -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA beer_user TO test_user;" test_db
psql -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA beer_user TO test_user;" test_db
