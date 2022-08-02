use std::error::Error;

type TestResult = Result<(), Box<dyn Error>>;

#[test]
fn foo() -> TestResult {

    Ok(())
}
