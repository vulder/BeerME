use crate::daos::{BeerEntry, User, UserBeerCount};
use crate::errors::MyError;
use deadpool_postgres::Client;
use tokio_pg_mapper::FromTokioPostgresRow;

pub async fn get_users(client: &Client) -> Result<Vec<User>, MyError> {
    let _stmt = include_str!("sql/get_users.sql");
    let _stmt = _stmt.replace("$table_fields", &User::sql_table_fields());
    let stmt = client.prepare(&_stmt).await.unwrap();

    let op_users = client
        .query(&stmt, &[])
        .await?
        .iter()
        .map(|row| User::from_row_ref(row).unwrap())
        .collect::<Vec<User>>();

    Ok(op_users)
}

pub async fn create_user(client: &Client, user: &User) -> Result<User, MyError> {
    let _stmt = include_str!("sql/add_user.sql");
    let _stmt = _stmt.replace("$table_fields", &User::sql_table_fields());
    let stmt = client.prepare(&_stmt).await.unwrap();

    client
        .query(
            &stmt,
            &[
                &user.uuid,
                &user.first_name,
                &user.last_name,
                &user.email,
                &user.token,
            ],
        )
        .await?
        .iter()
        .map(|row| User::from_row_ref(row).unwrap())
        .collect::<Vec<User>>()
        .pop()
        .ok_or(MyError::NotFound)
}

pub async fn register_taken_beer(
    client: &Client,
    beer_entry: BeerEntry,
) -> Result<BeerEntry, MyError> {
    let _stmt = include_str!("sql/register_beer_taken.sql");
    let stmt = client.prepare(&_stmt).await.unwrap();

    client
        .query(
            &stmt,
            &[&beer_entry.time, &beer_entry.uuid, &beer_entry.beer_brand],
        )
        .await?
        .iter()
        .map(|row| BeerEntry::from_row_ref(row).unwrap())
        .collect::<Vec<BeerEntry>>()
        .pop()
        .ok_or(MyError::NotFound)
}

pub async fn beer_entries_for_user(
    client: &Client,
    user: &User,
) -> Result<Vec<BeerEntry>, MyError> {
    let _stmt = include_str!("sql/get_beer_entries_for_user.sql");
    let _stmt = _stmt.replace("$table_fields", &BeerEntry::sql_table_fields());
    let _stmt = _stmt.replace("beers.beer_brand", "beer_brands.beer_brand");
    let stmt = client.prepare(&_stmt).await.unwrap();

    let op_users = client
        .query(&stmt, &[&user.uuid])
        .await?
        .iter()
        .map(|row| BeerEntry::from_row_ref(row).unwrap())
        .collect::<Vec<BeerEntry>>();

    Ok(op_users)
}

pub async fn beer_summary_values_for_user(
    client: &Client,
    user: &User,
) -> Result<UserBeerCount, MyError> {
    let _stmt = include_str!("sql/get_beer_user_summary.sql");
    let stmt = client.prepare(&_stmt).await.unwrap();

    client
        .query(&stmt, &[&user.uuid])
        .await?
        .iter()
        .map(|row| UserBeerCount::from_row_ref(row).unwrap())
        .collect::<Vec<UserBeerCount>>()
        .pop()
        .ok_or(MyError::NotFound)
}

pub async fn favorite_beer_for_user(client: &Client, user: &User) -> Result<String, MyError> {
    let _stmt = include_str!("sql/favorit_beer.sql");
    let stmt = client.prepare(&_stmt).await.unwrap();

    client
        .query(&stmt, &[&user.uuid])
        .await?
        .pop()
        .map(|x| x.get(0))
        .ok_or(MyError::NotFound)
}
