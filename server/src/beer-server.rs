#[macro_use]
extern crate actix_web;
extern crate log;

use std::{env, io};

use actix_web::{middleware, App, HttpServer, web};

mod beer_controller;
mod beerer;
mod config;
mod constants;
mod daos;
mod database;
mod dtos;
mod rfid_service;
mod user_service;
mod errors;
mod app_controller;

use crate::config::ServerConfig;
use ::config::Config;
use ::dotenv::dotenv;
use tokio_postgres::NoTls;

pub const SERVER_IP: &str = "0.0.0.0";
// pub const SERVER_IP: &str = "192.168.20.162";
pub const SERVER_PORT: &str = "8090";

#[actix_web::main]
async fn main() -> io::Result<()> {
    env::set_var(
        "RUST_LOG",
        "actix_web=debug,actix_server=info,beer_server=debug",
    );
    env_logger::init();

    dotenv().ok();

    let config_ = Config::builder()
        .add_source(::config::Environment::default())
        .build()
        .unwrap();

    let config: ServerConfig = config_.try_deserialize().unwrap();

    println!("{}", config);

    let pool = config.pg.create_pool(None, NoTls).unwrap();

    HttpServer::new(move || {
        App::new()
            .wrap(middleware::Logger::default())
            .app_data(web::Data::new(pool.clone()))
            .service(beerer::beer)
            .service(beerer::create)
            .service(beer_controller::take_beer)
            .service(app_controller::create_user)
            .service(app_controller::user_info)
    })
    .bind(SERVER_IP.to_owned() + ":" + SERVER_PORT)?
    .run()
    .await
}
