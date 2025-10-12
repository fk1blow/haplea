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

    fn is_at_end(&self) -> bool {
        self.pos >= self.chars.len()
    }

    fn advance(&mut self) {
        self.pos += 1
    }

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

        let text_starts_at = self.pos;

        while self.pos < self.chars.len() && self.chars[self.pos] != '\n' {
            self.advance()
        }

        self.chars[text_starts_at..self.pos].iter().collect()
    }

    pub fn scan(&mut self) {
        while !self.is_at_end() {
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
            self.pos += 1;
        }
    }
}
