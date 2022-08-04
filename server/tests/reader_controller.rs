pub mod test_utils;

#[cfg(test)]
mod tests {
    use crate::test_utils::get_testing_config;
    use beer_core::errors::MyError;
    use deadpool_postgres::Client;

    use actix_web::{http::StatusCode, test, web, App};
    use beer_core::{
        dtos::{BeerRequest, BeerResponse},
        entities::UserToken,
    };
    use tokio_postgres::NoTls;

    #[actix_web::test]
    async fn test_add_beer_for_non_existing_user_token() {
        let config = get_testing_config();
        let pool = config.pg.create_pool(None, NoTls).unwrap();
        let app = test::init_service(
            App::new()
                .app_data(web::Data::new(pool.clone()))
                .service(beer_core::reader_controller::take_beer),
        )
        .await;

        let request_data: BeerRequest = serde_json::from_str(r#"{"id": "BBBBBBBB" }"#).unwrap();
        let req = test::TestRequest::post()
            .uri("/tokens/BBBBBBBB/beer")
            .set_json(request_data)
            .send_request(&app)
            .await;

        assert!(
            req.status().is_success(),
            "Failed to request beer for non existing user"
        );
        let resp: BeerResponse = test::read_body_json(req).await;
        assert!(
            !resp.valid,
            "Response for non registered user was valid when it should not"
        );
    }

    #[actix_web::test]
    async fn test_malformed_beer_request_without_id() {
        let config = get_testing_config();
        let pool = config.pg.create_pool(None, NoTls).unwrap();
        let app = test::init_service(
            App::new()
                .app_data(web::Data::new(pool.clone()))
                .service(beer_core::reader_controller::take_beer),
        )
        .await;

        let request_data: BeerRequest = serde_json::from_str(r#"{}"#).unwrap();
        let req = test::TestRequest::post()
            .uri("/tokens/BBBBBBBB/beer")
            .set_json(request_data)
            .send_request(&app)
            .await;

        assert_eq!(
            req.status(),
            StatusCode::BAD_REQUEST,
            "Server did not reject beer request without id"
        );
    }

    #[actix_web::test]
    async fn test_add_beer() {
        let config = get_testing_config();
        let pool = config.pg.create_pool(None, NoTls).unwrap();
        let app = test::init_service(
            App::new()
                .app_data(web::Data::new(pool.clone()))
                .service(beer_core::reader_controller::take_beer),
        )
        .await;

        let request_data: BeerRequest = serde_json::from_str(r#"{"id": "1A4215B1" }"#).unwrap();
        let req = test::TestRequest::post()
            .uri("/tokens/1A4215B1/beer")
            .set_json(request_data)
            .send_request(&app)
            .await;

        assert!(
            req.status().is_success(),
            "Failed to request beer for existing user"
        );
        let resp: BeerResponse = test::read_body_json(req).await;
        assert!(resp.valid, "User was valid to register a new beer");

        // Clean up created beer
        let client: Client = pool.get().await.map_err(MyError::PoolError).unwrap();
        let user = beer_core::user_service::get_user(
            &client,
            &UserToken::parse_from_string("1A4215B1".to_string()).unwrap(),
        )
        .await
        .unwrap();
        beer_core::beer_service::delete_last_beer_of_user(&client, &user).await;
    }
}
