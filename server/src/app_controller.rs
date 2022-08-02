use actix_web::web::{Data, Json, Path};
use actix_web::{Error, HttpResponse};

use crate::constants::APPLICATION_JSON;
use deadpool_postgres::{Client, Pool};

use crate::dtos::CreateUserRequest;

use crate::daos::UserToken;
use crate::errors::MyError;
use crate::rfid_service;
use crate::user_service;

#[post("/users")]
pub async fn create_user(
    create_user_req: Json<CreateUserRequest>,
    db_pool: Data<Pool>,
) -> Result<HttpResponse, Error> {
    let maybe_user = create_user_req.to_user();

    match &maybe_user {
        Some(user) => {
            let client: Client = db_pool.get().await.map_err(MyError::PoolError)?;
            if rfid_service::is_token_registered(&client, &user.get_token()).await {
                Ok(HttpResponse::Conflict()
                    .reason("Token was already registered")
                    .finish())
            } else {
                let created_user = user_service::create_user(&client, user).await;
                Ok(HttpResponse::Created().json(created_user))
            }
        }
        None => Ok(HttpResponse::BadRequest()
            .reason("Token not registered")
            .finish()),
    }
}

#[get("/tokens/{token_id}/user")]
pub async fn user_info(path: Path<String>, db_pool: Data<Pool>) -> Result<HttpResponse, Error> {
    let maybe_user_token = UserToken::parse_from_string(path.into_inner());

    match &maybe_user_token {
        Some(user_token) => {
            let client: Client = db_pool.get().await.map_err(MyError::PoolError)?;

            let user = user_service::get_user(&client, &user_token).await;
            if let Some(user) = user {
                Ok(HttpResponse::Ok().json(user))
            } else {
                Ok(HttpResponse::NotFound()
                    .reason("Token was not registered")
                    .finish())
            }
        }
        None => Ok(HttpResponse::BadRequest()
            .reason("Token id was wrongly formatted")
            .finish()),
    }
}

#[get("/users/{user_id}/beers/summary")]
pub async fn beers_summary(path: Path<String>, db_pool: Data<Pool>) -> Result<HttpResponse, Error> {
    let client: Client = db_pool.get().await.map_err(MyError::PoolError)?;
    let user_uuid = path.into_inner();
    let maybe_user = user_service::get_user_from_uuid(&client, user_uuid).await;

    match &maybe_user {
        Some(user) => {
            let beer_summary = rfid_service::calculate_beer_summary(&client, user).await;
            Ok(HttpResponse::Ok()
                .content_type(APPLICATION_JSON)
                .json(beer_summary))
        }
        None => Ok(HttpResponse::NotFound()
            .reason("User was not registered in the system")
            .finish()),
    }
}

#[get("/beers/brands")]
pub async fn beer_brands(db_pool: Data<Pool>) -> Result<HttpResponse, Error> {
    let client: Client = db_pool.get().await.map_err(MyError::PoolError)?;
    let brand_list = rfid_service::beer_brands(&client).await;

    Ok(HttpResponse::Ok()
       .content_type(APPLICATION_JSON)
       .json(brand_list)
    )
}
