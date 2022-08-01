use actix_web::web::{Json, Data, Path};
use actix_web::{HttpResponse, Error};
use serde::{Deserialize, Serialize};

use deadpool_postgres::{Client,Pool};
use crate::constants::APPLICATION_JSON;

use crate::dtos::{CreateUserRequest, UserRequest};

use crate::daos::UserToken;
use crate::errors::MyError;
use crate::user_service;
use crate::rfid_service;

#[post("/create_user")]
pub async fn create_user(create_user_req: Json<CreateUserRequest>, db_pool: Data<Pool>) -> Result<HttpResponse, Error> {

    let maybe_user = create_user_req.to_user();

    match &maybe_user {
        Some(user) => {
            let client: Client = db_pool.get().await.map_err(MyError::PoolError)?;
            if rfid_service::is_token_registered(&client, &user.get_token()).await {
                Ok(HttpResponse::Conflict().reason("Token was already registered").finish())
            } else {
                let created_user = user_service::create_user(&client, user).await;
                Ok(HttpResponse::Created().json(created_user))
            }
        },
        None => Ok(HttpResponse::BadRequest().reason("Token not registered").finish()),
    }
}

#[get("/tokens/{token_id}/user")]
pub async fn user_info(path: Path<String>, db_pool: Data<Pool>) -> Result<HttpResponse, Error> {
    let maybe_user_token = UserToken::parse_from_string(path.into_inner());

    match &maybe_user_token {
        Some(user_token) => {
            let client: Client = db_pool.get().await.map_err(MyError::PoolError)?;
            println!("Form Path {:?}", user_token);

            let user = user_service::get_user(&client, &user_token).await;
            if let Some(user) = user {
                Ok(HttpResponse::Ok().json(user))
            } else {
                Ok(HttpResponse::NotFound().reason("Token was not registered").finish())
            }

        },
        None => Ok(HttpResponse::BadRequest().reason("Token id was wrongly formatted").finish()),
    }
}
