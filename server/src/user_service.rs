use deadpool_postgres::Client;

use crate::daos::{User, UserToken};
use crate::database;

pub async fn create_user(client: &Client, user: &User) -> User {
    database::create_user(client, user).await.unwrap()
}

pub async fn get_user(client: &Client, user_token: &UserToken) -> Option<User> {
    database::get_users(client).await.unwrap().iter().find(|user| user.token == user_token.id ).cloned()
}