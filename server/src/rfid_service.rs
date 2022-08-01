use crate::daos::UserToken;
use deadpool_postgres::Client;
use crate::user_service;
use crate::daos::BeerEntry;

use crate::database;

pub async fn is_token_registered(client: &Client, user_token: &UserToken) -> bool {
    log::debug!("Checking user token {}", user_token);

    database::get_users(client).await.unwrap().iter().any(|user| user.token == user_token.id )
}

pub async fn register_taken_beer(client: &Client, user_token: &UserToken) -> bool {
    let maybe_user = user_service::get_user(client, user_token).await;

    match &maybe_user {
        Some(user) => {
            database::register_taken_beer(client, BeerEntry::new(user.uuid.clone(), chrono::Local::now().naive_local(), "ByNFlowsMom".to_string())).await.is_ok()
        },
        None => false,
    }

}
