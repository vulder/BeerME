use std::fmt;
use serde::{Deserialize, Serialize};
use tokio_pg_mapper_derive::PostgresMapper;
use tokio_pg_mapper::FromTokioPostgresRow;

pub struct UserToken {
    pub id: String,
}

impl UserToken {
    pub fn new(id: String) -> Self {
        Self { id }
    }
}

impl fmt::Display for UserToken {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        writeln!(f, "UserToken{{ id: {} }}", self.id)
    }
}

#[derive(Deserialize, PostgresMapper, Serialize, Debug)]
#[pg_mapper(table = "users")]
pub struct User {
    pub first_name: String,
    pub last_name: String,
    pub email: String,
    pub token: String,
}

impl User {
    pub fn new(first_name: String, last_name: String, email: String, token: String) -> Self {
        Self {
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
        writeln!(f, "User{{ first_name: {} }}", self.first_name)
    }
}

