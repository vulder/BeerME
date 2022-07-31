use actix_web::HttpResponse;
use actix_web::web::Json;
use serde::{Deserialize, Serialize};

use crate::constants::APPLICATION_JSON;


pub fn is_token_registered(beer_request: &Json<BeerRequest>) -> bool {
    return true;
}

#[derive(Debug, Deserialize, Serialize)]
pub struct BeerRequest {
    pub id: Option<String>,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct BeerResponse {
    pub valid: bool,
}

#[post("/take_beer")]
pub async fn take_beer(beer_request: Json<BeerRequest>) -> HttpResponse {
    log::debug!("Register_beer for {:?}", beer_request);

    let mut response = BeerResponse{valid: false};
    if is_token_registered(&beer_request) {
        // increment counter
        response.valid = true;
    }

    HttpResponse::Ok()
        .content_type(APPLICATION_JSON)
        .json(response)
}
