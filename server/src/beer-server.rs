extern crate actix_web;

use beer_core;
use std::io;

#[actix_web::main]
async fn main() -> io::Result<()> {
    beer_core::run().await
}
