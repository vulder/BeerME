use crate::daos::UserToken;
use deadpool_postgres::Client;

use crate::database::get_users;

pub async fn is_token_registered(client: &Client, user_token: &UserToken) -> bool {
    log::debug!("Checking user token {}", user_token);

    get_users(client).await.unwrap().iter().any(|user| user.token == user_token.id )
}
