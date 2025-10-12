use crate::token::*;

#[derive(Debug)]
pub struct Scanner {
    source: String,
    chars: Vec<char>,
    pos: usize,
    line: usize,
}

impl Scanner {
    pub fn new(source: String) -> Self {
        let chars = source.chars().collect();
        Scanner {
            source,
            chars,
            pos: 0,
            line: 0,
        }
    }

    fn is_at_end(&self) -> bool {
        self.pos >= self.chars.len()
    }

    fn is_heading(&self) -> bool {
        let mut current_pos = self.pos;
        let mut heading_level: usize = 0;

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

    pub fn scan(&mut self) {
        while !self.is_at_end() {
            println!("pos: {}, {}", self.pos, self.chars[self.pos]);

            if self.is_heading() {
                println!("heading detected, {}, {}", self.pos, self.chars[self.pos])
                // now extract into a Heading token
            }

            // after all
            self.pos += 1;
        }
    }
}

fn is_new_line(char: char) -> bool {
    char == '\n'
}
