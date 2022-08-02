pub mod test_utils;

#[cfg(test)]
mod tests {
    use crate::test_utils::get_testing_config;

    use actix_web::{test, web, App, http::StatusCode};
    use beer_core::{daos::User, dtos::BeerSummary};
    use tokio_postgres::NoTls;

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
        assert_eq!("aa981764-76f7-4098-9cc6-525473dec7aa" , user.uuid, "Missmatch of uuid");
        assert_eq!("A" , user.first_name, "Missmatch of first_name");
        assert_eq!("a" , user.last_name, "Missmatch of last_name");
        assert_eq!("a@a.com" , user.email, "Missmatch of email");
        assert_eq!("AAAAAAAA" , user.token, "Missmatch of token");
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

        assert_eq!(req.status(), StatusCode::NOT_FOUND, "Server did not reject unknown user");
    }
}
