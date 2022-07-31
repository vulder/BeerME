use actix_web::web::Json;
use actix_web::HttpResponse;

use crate::constants::APPLICATION_JSON;

use crate::dtos::{BeerRequest, BeerResponse};
use crate::rfid_service::is_token_registered;

#[post("/take_beer")]
pub async fn take_beer(beer_request: Json<BeerRequest>) -> HttpResponse {
    log::debug!("Register_beer for {:?}", beer_request);

    let maybe_token = beer_request.to_user_token();

    match &maybe_token {
        Some(token) => {
            let mut response = BeerResponse { valid: false };
            if is_token_registered(token) {
                // increment counter
                response.valid = true;
            }

            HttpResponse::Ok()
                .content_type(APPLICATION_JSON)
                .json(response)
        }
        None => HttpResponse::BadRequest()
            .reason("No token provided")
            .finish(),
    }
}
