use crate::token::*;

#[derive(Debug)]
pub struct Scanner {
    source: String,
    tokens: Vec<Token>,
    chars: Vec<char>,
    pos: usize,
    line: usize,
}

impl Scanner {
    pub fn new(source: String) -> Self {
        let chars = source.chars().collect();
        Scanner {
            source,
            tokens: Vec::new(),
            chars,
            pos: 0,
            line: 0,
        }
    }

    fn at_end_of_file(&self) -> bool {
        self.pos >= self.chars.len()
    }

    fn at_end_of_line(&self) -> bool {
        self.at_end_of_file() || self.chars[self.pos] == '\n'
    }

    fn advance(&mut self) {
        self.pos += 1
    }

    fn consume(&mut self) -> Option<char> {
        if self.pos < self.chars.len() {
            let ch = self.chars[self.pos];
            self.advance();
            return Some(ch);
        }
        None
    }

    // fn consume_line(&mut self) -> Option<char> {
    //     while !self.at_end_of_line() {
    //         return self.consume();
    //     }
    //     None
    // }

    fn is_heading(&self) -> bool {
        let mut current_pos = self.pos;
        let mut heading_level: usize = 0;

        // first char is not a hash, it's not a heading
        if self.chars[current_pos] != '#' {
            return false;
        }

        // find the heading level by counting all the #
        while current_pos < self.chars.len() && self.chars[current_pos] == '#' {
            heading_level += 1;
            if heading_level > 6 {
                return false;
            }
            current_pos += 1;
        }

        // if next char is not a space, it's not a heading
        if current_pos >= self.chars.len() || self.chars[current_pos] != ' ' {
            return false;
        }

        true
    }

    fn heading(&mut self) -> String {
        // TODO can i use something like `can_advance` which would check
        // if self.pos is less than self.chars.len() ?
        while self.pos < self.chars.len() && self.chars[self.pos] == '#' {
            self.advance()
        }

        while self.pos < self.chars.len() && self.chars[self.pos] == ' ' {
            self.advance()
        }

        let mut heading_text = String::from("");

        while let Some(ch) = self.consume_line() {
            heading_text.push(ch);
        }

        String::from("")

        // self.chars[text_starts_at..self.pos].iter().collect()
    }

    // need an algorithm that
    // takes as between 1 and 6 # chars
    // takes at leas one space char
    // goes until the end of line or file

    pub fn scan(&mut self) {
        let ccc = 's';
        // ccc.as_s
        // self.chars.as_str();

        while !self.at_end_of_file() {
            println!("pos: {}, {}", self.pos, self.chars[self.pos]);

            if self.is_heading() {
                // println!("heading detected, {}, {}", self.pos, self.chars[self.pos]);
                let heading = self.heading();
                self.tokens.push(Token {
                    content: heading,
                    filename: String::from("unknown filename"),
                    token_type: TokenType::Title,
                });
                println!("heading: {:?}", self.tokens);
            }

            // after all
            self.advance();
        }
    }
}
