use serde::{Deserialize, Serialize};

use crate::entities::{BeerEntry, User, UserToken};
use uuid::Uuid;

#[derive(Debug, Deserialize, Serialize)]
pub struct BeerRequest {
    pub id: Option<String>,
}

impl BeerRequest {
    pub fn to_user_token(&self) -> Option<UserToken> {
        // TODO: needs verification
        match &self.id {
            Some(id) => Some(UserToken::new(id.to_string())),
            None => None,
        }
    }
}

#[derive(Debug, Deserialize, Serialize)]
pub struct BeerResponse {
    pub valid: bool,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct CreateUserRequest {
    pub first_name: Option<String>,
    pub last_name: Option<String>,
    pub email: Option<String>,
    pub token: Option<String>,
}

impl CreateUserRequest {
    pub fn to_user(&self) -> Option<User> {
        if let (Some(first_name), Some(last_name), Some(email), Some(token)) = (
            self.first_name.as_ref(),
            self.last_name.as_ref(),
            self.email.as_ref(),
            self.token.as_ref(),
        ) {
            Some(User::new(
                Uuid::new_v4(),
                first_name.to_string(),
                last_name.to_string(),
                email.to_string(),
                UserToken::sanitize(token.to_string()),
            ))
        } else {
            None
        }
    }
}

#[derive(Debug, Deserialize, Serialize)]
pub struct CreateUserResponse {
    pub success: bool,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct UserRequest {
    pub id: Option<String>,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct UserResponse {
    pub first_name: String,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct BeerSummary {
    pub today: i64,
    pub week: i64,
    pub month: i64,
    pub total: i64,
    pub unpaid: i8,
    pub recent_beers: Vec<BeerEntry>,
    pub favorite_beer: String,
}

impl BeerSummary {
    pub fn new(
        today: i64,
        week: i64,
        month: i64,
        total: i64,
        unpaid: i8,
        recent_beers: Vec<BeerEntry>,
        favorite_beer: String,
    ) -> Self {
        Self {
            today,
            week,
            month,
            total,
            unpaid,
            recent_beers,
            favorite_beer,
        }
    }
}
