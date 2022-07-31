use crate::daos::UserToken;

pub fn is_token_registered(user_token: &UserToken) -> bool {
    log::debug!("Checking user token {}", user_token);

    return true;
}
