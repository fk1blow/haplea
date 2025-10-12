mod scanner;
mod token;
use crate::scanner::Scanner;

/// Parse a markdown recipe and return structured data
pub fn parse_recipe(markdown: &str) -> String {
    let mut scanner = Scanner::new(String::from(markdown));
    scanner.scan();

    "Parsed Recipe Stub".to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_recipe() {
        // let foo = Token {
        //     filename: String::from("test"),
        //     token_type: TokenType::Title,
        // };
        // println!("{:?}", foo);

        // alternative to inline markdown
        // const MARKDOWN: &str = include_str!("test.md");
        let markdown_1 = r#"# My first recipe

        "#;

        let _markdown_3 = r#"
            # hello world

            this is a markdown document
        "#;

        let _markdown_2 = r#"
            # hello world

            this is a markdown document

            ## ingredients list
            - butter
            - olive oil
            - chicken
            - salt

            ## notes
            some notes about this recipe
        "#;

        parse_recipe(markdown_1);

        // assert_eq!(result, "Parsed Recipe Stub");
        // assert_eq!(true, true);
    }
}
