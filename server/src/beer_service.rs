use crate::dtos::BeerSummary;
use crate::entities::{BeerBrandEntry, BeerEntry, User, UserToken};
use crate::user_service;
use deadpool_postgres::Client;

use crate::database;

pub async fn is_token_registered(client: &Client, user_token: &UserToken) -> bool {
    log::debug!("Checking user token {}", user_token);

    database::get_users(client)
        .await
        .unwrap()
        .iter()
        .any(|user| user.token == user_token.id)
}

pub async fn register_taken_beer(client: &Client, user_token: &UserToken) -> bool {
    let maybe_user = user_service::get_user(client, user_token).await;

    match &maybe_user {
        Some(user) => database::register_taken_beer(
            client,
            BeerEntry::new(
                user.uuid.clone(),
                chrono::Local::now().naive_local(),
                "ByNFlowsMom".to_string(),
            ),
        )
        .await
        .is_ok(),
        None => false,
    }
}

pub async fn delete_beer(client: &Client, beer: BeerEntry) -> bool {
    database::delete_beer(client, beer).await.unwrap()
}

pub async fn delete_last_beer_of_user(client: &Client, user: &User) -> bool {
    let last_beer = get_last_beer_of_user(client, user).await;
    delete_beer(client, last_beer).await
}

pub async fn get_last_beer_of_user(client: &Client, user: &User) -> BeerEntry {
    database::get_last_beer_of_user(client, user).await.unwrap()
}

pub async fn calculate_beer_summary(client: &Client, user: &User) -> BeerSummary {
    let user_beer_entries = database::beer_entries_for_user(client, user).await;

    let count = database::beer_summary_values_for_user(client, user)
        .await
        .unwrap();
    let recent_beers: Vec<BeerEntry> = user_beer_entries
        .unwrap()
        .into_iter()
        .take(10)
        .collect::<Vec<BeerEntry>>();
    let fav_beer = database::favorite_beer_for_user(client, user)
        .await
        .unwrap();
    let unpaid = 0;

    BeerSummary::new(
        count.today,
        count.week,
        count.month,
        count.today,
        unpaid,
        recent_beers,
        fav_beer,
    )
}

pub async fn beer_brands(client: &Client) -> Vec<BeerBrandEntry> {
    database::beer_brands(client).await.unwrap()
}
