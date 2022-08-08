use crate::entities::{BeerBrandEntity, BeerEntity, UserEntity, UserBeerCount};
use crate::errors::MyError;
use deadpool_postgres::Client;
use tokio_pg_mapper::FromTokioPostgresRow;

/// Retrieve all registered users from the database.
pub async fn get_users(client: &Client) -> Result<Vec<UserEntity>, MyError> {
    let _stmt = include_str!("sql/get_users.sql");
    let _stmt = _stmt.replace("$table_fields", &UserEntity::sql_table_fields());
    let stmt = client.prepare(&_stmt).await.unwrap();

    let op_users = client
        .query(&stmt, &[])
        .await?
        .iter()
        .map(|row| UserEntity::from_row_ref(row).unwrap())
        .collect::<Vec<UserEntity>>();

    Ok(op_users)
}

/// Inserts an entry into the database for the new user.
pub async fn create_user(client: &Client, user: &UserEntity) -> Result<UserEntity, MyError> {
    let _stmt = include_str!("sql/add_user.sql");
    let _stmt = _stmt.replace("$table_fields", &UserEntity::sql_table_fields());
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
        .map(|row| UserEntity::from_row_ref(row).unwrap())
        .collect::<Vec<UserEntity>>()
        .pop()
        .ok_or(MyError::NotFound)
}

/// Deletes and existing user from the database.
pub async fn delete_user(client: &Client, user: &UserEntity) -> Result<bool, MyError> {
    let _stmt = include_str!("sql/delete_user.sql");
    let stmt = client.prepare(&_stmt).await.unwrap();

    client
        .query(&stmt, &[&user.uuid])
        .await?
        .pop()
        .map(|x| x.get(0))
        .or_else(|| Some(false))
        .ok_or(MyError::NotFound)
}

/// Registeres a taken/consumed beer into the database.
pub async fn register_taken_beer(
    client: &Client,
    beer_entry: BeerEntity,
) -> Result<BeerEntity, MyError> {
    let _stmt = include_str!("sql/register_beer_taken.sql");
    let stmt = client.prepare(&_stmt).await.unwrap();

    client
        .query(
            &stmt,
            &[
                &beer_entry.time,
                &beer_entry.uuid,
                &beer_entry.beer_brand,
                &beer_entry.paid,
            ],
        )
        .await?
        .iter()
        .map(|row| BeerEntity::from_row_ref(row).unwrap())
        .collect::<Vec<BeerEntity>>()
        .pop()
        .ok_or(MyError::NotFound)
}

/// Deletes an beer entry from the database.
pub async fn delete_beer(client: &Client, beer: BeerEntity) -> Result<bool, MyError> {
    let _stmt = include_str!("sql/delete_beer.sql");
    let stmt = client.prepare(&_stmt).await.unwrap();

    client
        .query(&stmt, &[&beer.time, &beer.uuid])
        .await?
        .pop()
        .map(|x| x.get(0))
        .or_else(|| Some(false))
        .ok_or(MyError::NotFound)
}

/// Retrieves the last beer that was consumed by the user.
pub async fn get_last_beer_of_user(client: &Client, user: &UserEntity) -> Result<BeerEntity, MyError> {
    let _stmt = include_str!("sql/get_last_beer_of_user.sql");
    let _stmt = _stmt.replace("$table_fields", &BeerEntity::sql_table_fields());
    let _stmt = _stmt.replace("beers.beer_brand", "beer_brands.beer_brand");
    let stmt = client.prepare(&_stmt).await.unwrap();

    client
        .query(&stmt, &[&user.uuid])
        .await?
        .pop()
        .map(|row| BeerEntity::from_row_ref(&row).unwrap())
        .ok_or(MyError::NotFound)
}

/// Retrieves all beer entries that are associated with the provided user.
pub async fn beer_entries_for_user(
    client: &Client,
    user: &UserEntity,
) -> Result<Vec<BeerEntity>, MyError> {
    let _stmt = include_str!("sql/get_beer_entries_for_user.sql");
    let _stmt = _stmt.replace("$table_fields", &BeerEntity::sql_table_fields());
    let _stmt = _stmt.replace("beers.beer_brand", "beer_brands.beer_brand");
    let stmt = client.prepare(&_stmt).await.unwrap();

    let op_users = client
        .query(&stmt, &[&user.uuid])
        .await?
        .iter()
        .map(|row| BeerEntity::from_row_ref(row).unwrap())
        .collect::<Vec<BeerEntity>>();

    Ok(op_users)
}

/// Computes beer consumption statistics for the given user.
pub async fn beer_summary_values_for_user(
    client: &Client,
    user: &UserEntity,
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

/// Computes the given users favorite beer brand.
pub async fn favorite_beer_for_user(client: &Client, user: &UserEntity) -> Result<String, MyError> {
    let _stmt = include_str!("sql/favorit_beer.sql");
    let stmt = client.prepare(&_stmt).await.unwrap();

    client
        .query(&stmt, &[&user.uuid])
        .await?
        .pop()
        .map(|x| x.get(0))
        .or_else(|| Some("None".to_string()))
        .ok_or(MyError::NotFound)
}

/// Retrieves all registed beer brands.
pub async fn beer_brands(client: &Client) -> Result<Vec<BeerBrandEntity>, MyError> {
    let _stmt = include_str!("sql/beer_brands.sql");
    let _stmt = _stmt.replace("$table_fields", &BeerBrandEntity::sql_table_fields());
    let stmt = client.prepare(&_stmt).await.unwrap();

    Ok(client
        .query(&stmt, &[])
        .await?
        .iter()
        .map(|row| BeerBrandEntity::from_row_ref(row).unwrap())
        .collect::<Vec<BeerBrandEntity>>())
}
