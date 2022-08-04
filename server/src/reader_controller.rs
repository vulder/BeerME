use actix_web::web::{Data, Json};
use actix_web::{Error, HttpResponse};

use crate::constants::APPLICATION_JSON;
use deadpool_postgres::{Client, Pool};

use crate::dtos::{BeerRequest, BeerResponse};
use crate::errors::MyError;
use crate::beer_service;

#[post("/tokens/{token_id}/beer")]
pub async fn take_beer(
    beer_request: Json<BeerRequest>,
    db_pool: Data<Pool>,
) -> Result<HttpResponse, Error> {
    log::debug!("Register_beer for {:?}", beer_request);

    let maybe_token = beer_request.to_user_token();

    match &maybe_token {
        Some(token) => {
            let client: Client = db_pool.get().await.map_err(MyError::PoolError)?;
            let mut response = BeerResponse { valid: false };
            if beer_service::is_token_registered(&client, token).await {
                let success = beer_service::register_taken_beer(&client, token);
                if !success.await {
                    return Ok(HttpResponse::InternalServerError()
                        .reason("Could not register taken beer")
                        .finish());
                }
                response.valid = true;
            }

            Ok(HttpResponse::Ok()
                .content_type(APPLICATION_JSON)
                .json(response))
        }
        None => Ok(HttpResponse::BadRequest()
            .reason("No token provided")
            .finish()),
    }
}
