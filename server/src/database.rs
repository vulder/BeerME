use deadpool_postgres::Client;
use crate::daos::User;
use tokio_pg_mapper::FromTokioPostgresRow;
use crate::errors::MyError;

pub async fn get_users(client: &Client) -> Result<Vec<User>, MyError> {
    let _stmt = include_str!("sql/get_users.sql");
    let _stmt = _stmt.replace("$table_fields", "*");
    let stmt = client.prepare(&_stmt).await.unwrap();

    let op_users = client.query(&stmt, &[])
        .await?
        .iter()
        .map(|row| User::from_row_ref(row).unwrap())
        .collect::<Vec<User>>();

    // println!("{:?}", op_users);

    Ok(op_users)
}

pub async fn create_user(client: &Client, user: &User) -> Result<User, MyError> {
    let _stmt = include_str!("sql/add_user.sql");
    let _stmt = _stmt.replace("$table_fields", &User::sql_table_fields());
    let stmt = client.prepare(&_stmt).await.unwrap();

    client.query(
        &stmt,
        &[
            &user.uuid,
            &user.first_name,
            &user.last_name,
            &user.email,
            &user.token,
        ],
        ).await?
        .iter()
        .map(|row| User::from_row_ref(row).unwrap())
        .collect::<Vec<User>>()
        .pop()
        .ok_or(MyError::NotFound)
}