use serde::Deserialize;
use std::fmt;

#[derive(Debug, Default, Deserialize)]
pub struct ServerConfig {
    pub server_addr: String,
    pub server_port: String,
    pub pg: deadpool_postgres::Config,
}

impl fmt::Display for ServerConfig {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        writeln!(
            f,
            "ServerConfig{{ server_addr: {:?}, server_port: {:?}, pb.user: {:?}, pg: {:?}}}",
            self.server_addr, self.server_port, self.pg.user, self.pg.dbname
        )
    }
}
