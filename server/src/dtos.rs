use serde::{Deserialize, Serialize};

use crate::daos::UserToken;

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
