use thiserror::Error;

#[derive(Error, Debug)]
pub enum HapleaError {
    #[error("Configuration error: {0}")]
    Config(String),

    #[error("Parser error: {0}")]
    Parser(String),

    #[error("Network error: {0}")]
    Network(String),

    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Unknown error: {0}")]
    Unknown(String),
}

pub type Result<T> = std::result::Result<T, HapleaError>;
