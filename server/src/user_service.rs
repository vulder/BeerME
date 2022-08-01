use crate::daos::UserToken;
use deadpool_postgres::Client;

use crate::daos::User;
use crate::database;

pub async fn create_user(client: &Client, user: &User) -> User {
    database::create_user(client, user).await.unwrap()
}
