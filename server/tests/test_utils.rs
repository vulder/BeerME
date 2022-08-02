use beer_core::config::ServerConfig;

use ::config::Config;
use ::dotenv::from_filename;

pub fn get_testing_config() -> ServerConfig {
    from_filename("tests/test_env").ok();

    let config_ = Config::builder()
        .add_source(::config::Environment::default())
        .build()
        .unwrap();

    config_.try_deserialize().unwrap()
}
