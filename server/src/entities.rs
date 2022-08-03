use serde::{Deserialize, Serialize};
use std::fmt;
use tokio_pg_mapper_derive::PostgresMapper;
use uuid::Uuid;

#[derive(Debug)]
pub struct UserToken {
    pub id: String,
}

impl UserToken {
    pub fn new(id: String) -> Self {
        Self {
            id: UserToken::sanitize(id),
        }
    }

    pub fn parse_from_string(raw_string: String) -> Option<UserToken> {
        Some(UserToken::new(raw_string))
    }

    pub fn sanitize(raw_token: String) -> String {
        raw_token
            .chars()
            .filter(|c| !c.is_whitespace())
            .map(|c| c.to_uppercase().to_string())
            .collect()
    }
}

impl fmt::Display for UserToken {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        writeln!(f, "UserToken{{ id: {} }}", self.id)
    }
}

#[derive(Deserialize, PostgresMapper, Serialize, Debug, Clone)]
#[pg_mapper(table = "users")]
pub struct User {
    pub uuid: String,
    pub first_name: String,
    pub last_name: String,
    pub email: String,
    pub token: String,
}

impl User {
    pub fn new(
        uuid: Uuid,
        first_name: String,
        last_name: String,
        email: String,
        token: String,
    ) -> Self {
        Self {
            uuid: uuid.to_string(),
            first_name,
            last_name,
            email,
            token,
        }
    }

    pub fn get_token(&self) -> UserToken {
        UserToken::new(self.token.to_string())
    }
}

impl fmt::Display for User {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        writeln!(
            f,
            "User{{ uuid: {}, first_name: {} }}",
            self.uuid, self.first_name
        )
    }
}

#[derive(Deserialize, PostgresMapper, Serialize, Debug, Clone)]
#[pg_mapper(table = "beers")]
pub struct BeerEntry {
    pub uuid: String,
    pub time: chrono::NaiveDateTime,
    pub beer_brand: String,
}

impl BeerEntry {
    pub fn new(uuid: String, time: chrono::NaiveDateTime, beer_brand: String) -> Self {
        Self {
            uuid,
            time,
            beer_brand,
        }
    }
}

impl fmt::Display for BeerEntry {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        writeln!(
            f,
            "BeerEntry{{ uuid: {}, time: {}, bier_brand: {} }}",
            self.uuid,
            self.time.format("%Y-%m-%d %H:%M:%S").to_string(),
            self.beer_brand
        )
    }
}

#[derive(Deserialize, PostgresMapper, Serialize, Debug, Clone)]
#[pg_mapper(table = "beers")]
pub struct UserBeerCount {
    pub total: i64,
    pub today: i64,
    pub week: i64,
    pub month: i64,
}

#[derive(Deserialize, PostgresMapper, Serialize, Debug, Clone)]
#[pg_mapper(table = "beer_brands")]
pub struct BeerBrandEntry {
    beer_brand: String,
    beer_type: String,
}

impl fmt::Display for BeerBrandEntry {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        writeln!(
            f,
            "BeerBrandEntry{{ beer_brand: {}, beer_type: {} }}",
            self.beer_brand, self.beer_type,
        )
    }
}
