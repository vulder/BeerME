mod tests {
    use beer_core::daos::UserToken;
    #[test]
    fn sanitize_user_token_rm_ws() {
        assert_eq!("1F00", UserToken::sanitize("1F 00".to_string()));
    }

    #[test]
    fn sanitize_user_token_uppercase() {
        assert_eq!("1F00", UserToken::sanitize("1f00".to_string()));
    }
}
