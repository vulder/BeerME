use std::fmt;
use serde::{Deserialize, Serialize};
use tokio_pg_mapper_derive::PostgresMapper;
use tokio_pg_mapper::FromTokioPostgresRow;
use uuid::Uuid;

#[derive(Debug)]
pub struct UserToken {
    pub id: String,
}

impl UserToken {
    pub fn new(id: String) -> Self {
        Self { id: UserToken::sanitize(id) }
    }

    pub fn parse_from_string(raw_string: String) -> Option<UserToken> {
        Some(UserToken::new(raw_string))
    }

    pub fn sanitize(raw_token: String) -> String {
        raw_token.chars().filter(|c| !c.is_whitespace()).map(|c| c.to_uppercase().to_string()).collect()
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
    pub fn new(uuid: Uuid, first_name: String, last_name: String, email: String, token: String) -> Self {
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
        writeln!(f, "User{{ uuid: {}, first_name: {} }}", self.uuid, self.first_name)
    }
}

