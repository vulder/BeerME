#[macro_use]
extern crate actix_web;
extern crate log;

use std::{env, io};

use actix_web::{middleware, App, HttpServer};

mod beerer;
mod beer_controller;
mod constants;
mod dtos;
mod daos;
mod rfid_service;

pub const SERVER_IP: &str = "127.0.0.1";
pub const SERVER_PORT: &str = "8090";

#[actix_web::main]
async fn main() -> io::Result<()> {
    env::set_var("RUST_LOG", "actix_web=debug,actix_server=info,beer_server=debug");
    env_logger::init();

    HttpServer::new(|| {
        App::new()
            .wrap(middleware::Logger::default())
            .service(beerer::beer)
            .service(beerer::create)
            .service(beer_controller::take_beer)
    })
    .bind(SERVER_IP.to_owned() + ":" + SERVER_PORT)?
    .run()
    .await
}
