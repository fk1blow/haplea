#[derive(Debug)]
pub enum TokenType {
    Title,
    Tags,
    Description,
    Unknown,
}

#[derive(Debug)]
pub struct Token {
    pub token_type: TokenType,
    pub content: String,
    pub filename: String,
}

// impl Token {
//     fn new(title: ) {
//         Token {

//         }
//     }
// }
