use actix_web::web::{Json, Data};
use actix_web::{HttpResponse, Error};
use serde::{Deserialize, Serialize};

use deadpool_postgres::{Client,Pool};
use crate::constants::APPLICATION_JSON;

use crate::dtos::{CreateUserRequest, UserRequest};

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

#[get("/user_info/{id}")]
pub async fn user_info(user_req: Json<UserRequest>, db_pool: Data<Pool>) -> HttpResponse {

    HttpResponse::NotFound().finish()
}
