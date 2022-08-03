pub mod test_utils;

#[cfg(test)]
mod tests {
    use crate::test_utils::get_testing_config;

    use actix_web::{http::StatusCode, test, web, App};
    use beer_core::{
        dtos::{BeerSummary, CreateUserRequest},
        entities::{BeerBrandEntry, User},
    };
    use tokio_postgres::NoTls;

    #[actix_web::test]
    async fn test_create_existing_user() {
        let config = get_testing_config();
        let pool = config.pg.create_pool(None, NoTls).unwrap();
        let app = test::init_service(
            App::new()
                .app_data(web::Data::new(pool.clone()))
                .service(beer_core::app_controller::create_user),
        )
        .await;

        let request_data: CreateUserRequest = serde_json::from_str(
            r#"{"first_name": "A", "last_name": "a", "email": "a@a.com", "token": "AAAAAAAA"}"#,
        )
        .unwrap();
        let req = test::TestRequest::post()
            .uri("/users")
            .set_json(request_data)
            .send_request(&app)
            .await;

        assert_eq!(
            req.status(),
            StatusCode::CONFLICT,
            "Server did not reject creation of an existing user"
        );
    }

    #[actix_web::test]
    async fn test_get_user_by_token() {
        let config = get_testing_config();
        let pool = config.pg.create_pool(None, NoTls).unwrap();
        let app = test::init_service(
            App::new()
                .app_data(web::Data::new(pool.clone()))
                .service(beer_core::app_controller::user_info),
        )
        .await;

        let req = test::TestRequest::get()
            .uri("/tokens/AAAAAAAA/user")
            .send_request(&app)
            .await;

        assert!(req.status().is_success(), "Failed to request user");
        let user: User = test::read_body_json(req).await;
        assert_eq!(
            "aa981764-76f7-4098-9cc6-525473dec7aa", user.uuid,
            "Missmatch of uuid"
        );
        assert_eq!("A", user.first_name, "Missmatch of first_name");
        assert_eq!("a", user.last_name, "Missmatch of last_name");
        assert_eq!("a@a.com", user.email, "Missmatch of email");
        assert_eq!("AAAAAAAA", user.token, "Missmatch of token");
    }

    #[actix_web::test]
    async fn test_get_user_by_token_error() {
        let config = get_testing_config();
        let pool = config.pg.create_pool(None, NoTls).unwrap();
        let app = test::init_service(
            App::new()
                .app_data(web::Data::new(pool.clone()))
                .service(beer_core::app_controller::user_info),
        )
        .await;

        let req = test::TestRequest::get()
            .uri("/tokens/ZZZZZZZZ/user")
            .send_request(&app)
            .await;

        assert_eq!(
            req.status(),
            StatusCode::NOT_FOUND,
            "Server did not reject unknown user"
        );
    }

    #[actix_web::test]
    async fn test_get_empty_beer_summary() {
        let config = get_testing_config();
        let pool = config.pg.create_pool(None, NoTls).unwrap();
        let app = test::init_service(
            App::new()
                .app_data(web::Data::new(pool.clone()))
                .service(beer_core::app_controller::beers_summary),
        )
        .await;

        let req = test::TestRequest::get()
            // No beer user
            .uri("/users/aaaa1764-76f7-4098-9cc6-525473dec7aa/beers/summary")
            .send_request(&app)
            .await;

        assert!(req.status().is_success(), "Failed to request beer summary");
        let summary: BeerSummary = test::read_body_json(req).await;
        assert_eq!(summary.today, 0);
        assert_eq!(summary.week, 0);
        assert_eq!(summary.month, 0);
        assert_eq!(summary.total, 0);
        assert_eq!(summary.unpaid, 0);
        assert!(summary.recent_beers.is_empty());
        assert_eq!(summary.favorite_beer, "None");
    }

    #[actix_web::test]
    async fn test_get_beer_brands() {
        let config = get_testing_config();
        let pool = config.pg.create_pool(None, NoTls).unwrap();
        let app = test::init_service(
            App::new()
                .app_data(web::Data::new(pool.clone()))
                .service(beer_core::app_controller::beer_brands),
        )
        .await;

        let req = test::TestRequest::get()
            .uri("/beers/brands")
            .send_request(&app)
            .await;

        assert!(req.status().is_success(), "Failed to request beer brands");
        let brands: Vec<BeerBrandEntry> = test::read_body_json(req).await;

        let maybe_unknown = brands
            .iter()
            .find(|brand| brand.beer_brand == "Unknown".to_string());
        assert!(
            maybe_unknown.is_some(),
            "Could not get default beer brand unknown"
        );
        let unknown = maybe_unknown.unwrap();
        assert_eq!(unknown.beer_brand, "Unknown");
        assert_eq!(unknown.beer_type, "Unknown");

        let augustiner = brands
            .iter()
            .find(|brand| brand.beer_brand == "Augustiner".to_string())
            .unwrap();
        assert_eq!(augustiner.beer_brand, "Augustiner");
        assert_eq!(augustiner.beer_type, "Hell");
    }
}
