use actix_web::HttpResponse;

use crate::constants::APPLICATION_JSON;

#[get("/beer")]
pub async fn beer() -> HttpResponse {
    HttpResponse::Ok()
        .content_type(APPLICATION_JSON)
        .json("{Foo:\"Bar\"}")
}
