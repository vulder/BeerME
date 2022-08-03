pub mod test_utils;

#[cfg(test)]
mod tests {
    use crate::test_utils::get_testing_config;

    use actix_web::{http::StatusCode, test, web, App};
    use beer_core::dtos::{BeerRequest, BeerResponse};
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

        let request_data: BeerRequest = serde_json::from_str(
            r#"{"id": "BBBBBBBB" }"#,
        )
        .unwrap();
        let req = test::TestRequest::post()
            .uri("/tokens/BBBBBBBB/beer")
            .set_json(request_data)
            .send_request(&app)
            .await;

        assert!(req.status().is_success(), "Failed to request beer for non existing user");
        let resp: BeerResponse = test::read_body_json(req).await;
        assert!(!resp.valid, "Response for non registered user was valid when it should not");
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

        let request_data: BeerRequest = serde_json::from_str(
            r#"{}"#,
        )
        .unwrap();
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
}
