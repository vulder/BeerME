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

/// Represent a registed user
#[derive(Deserialize, PostgresMapper, Serialize, Debug, Clone)]
#[pg_mapper(table = "users")]
pub struct UserEntity {
    /// Universally unique identifier for the user
    pub uuid: String,
    pub first_name: String,
    pub last_name: String,
    pub email: String,
    /// Registered RFID token
    pub token: String,
}

impl UserEntity {
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

impl fmt::Display for UserEntity {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        writeln!(
            f,
            "User{{ uuid: {}, first_name: {} }}",
            self.uuid, self.first_name
        )
    }
}

/// Represent a beer that was consumed by a specific user at a specific point in time.
#[derive(Deserialize, PostgresMapper, Serialize, Debug, Clone)]
#[pg_mapper(table = "beers")]
pub struct BeerEntity {
    pub id: i64,
    /// Point of time when the beer was consumed/bought
    pub time: chrono::NaiveDateTime,
    /// Universally unique identifier for the user
    pub uuid: String,
    pub beer_brand: String,
    pub paid: bool,
}

impl BeerEntity {
    pub fn new(
        id: i64,
        uuid: String,
        time: chrono::NaiveDateTime,
        beer_brand: String,
        paid: bool,
    ) -> Self {
        Self {
            id,
            uuid,
            time,
            beer_brand,
            paid,
        }
    }
}

impl fmt::Display for BeerEntity {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        writeln!(
            f,
            "BeerEntity{{ id: {}, uuid: {}, time: {}, bier_brand: {} }}",
            self.id,
            self.uuid,
            self.time.format("%Y-%m-%d %H:%M:%S").to_string(),
            self.beer_brand
        )
    }
}

#[derive(Deserialize, PostgresMapper, Serialize, Debug, Clone)]
#[pg_mapper(table = "beers")]
pub struct UserBeerCount {
    /// Total amount of beers consumed
    pub total: i64,
    /// Total amount of beers consumed in the last day
    pub today: i64,
    /// Total amount of beers consumed in the last week
    pub week: i64,
    /// Total amount of beers consumed in the last month
    pub month: i64,
}

/// Represent a specific beer brand, containing all relevant information about the brand.
#[derive(Deserialize, PostgresMapper, Serialize, Debug, Clone)]
#[pg_mapper(table = "beer_brands")]
pub struct BeerBrandEntity {
    pub beer_brand: String,
    pub beer_type: String,
}

impl fmt::Display for BeerBrandEntity {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        writeln!(
            f,
            "BeerBrandEntity{{ beer_brand: {}, beer_type: {} }}",
            self.beer_brand, self.beer_type,
        )
    }
}
