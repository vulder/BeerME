use deadpool_postgres::Client;

use crate::database;
use crate::entities::{UserEntity, UserToken};

pub async fn create_user(client: &Client, user: &UserEntity) -> Option<UserEntity> {
    let maybe_user = database::create_user(client, user).await;
    match maybe_user {
        Ok(user) => Some(user),
        Err(error) => {
            log::debug!("Error: {}", error);
            None
        }
    }
}

pub async fn delete_user(client: &Client, user: &UserEntity) -> bool {
    database::delete_user(client, user).await.unwrap()
}

pub async fn get_user(client: &Client, user_token: &UserToken) -> Option<UserEntity> {
    database::get_users(client)
        .await
        .unwrap()
        .iter()
        .find(|user| user.token == user_token.id)
        .cloned()
}

pub async fn get_user_from_uuid(client: &Client, uuid: String) -> Option<UserEntity> {
    database::get_users(client)
        .await
        .unwrap()
        .iter()
        .find(|user| user.uuid == uuid)
        .cloned()
}
