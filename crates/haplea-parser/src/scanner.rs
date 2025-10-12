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

        // count the heading level
        while current_pos < self.chars.len() && self.chars[current_pos] == '#' {
            heading_level += 1;
            if heading_level > 6 {
                return false;
            }
            current_pos += 1;
        }

        // must have at leas one space after the hashes
        if current_pos > self.chars.len() || self.chars[current_pos] != ' ' {
            return false;
        }

        // skip all spaces
        while current_pos < self.chars.len() && self.chars[current_pos] == ' ' {
            current_pos += 1;
        }

        if current_pos > self.chars.len() || self.chars[current_pos] == '\n' {
            return false;
        }

        true
    }

    fn is_heading_old(&self) -> bool {
        let mut current_pos = self.pos;
        // 1-6, starts at 0 instead of 1 to account for the first increment
        let mut heading_level: usize = 0;

        if self.chars[current_pos] != '#' {
            return false;
        }

        while current_pos < self.chars.len() && self.chars[current_pos] != '\n' {
            if heading_level > 6 {
                return false;
            }

            match self.chars[current_pos] {
                ' ' => {
                    current_pos += 1;
                }
                '#' => {
                    heading_level += 1;
                    current_pos += 1;
                }
                _ => {
                    // have to check if the previous char was a space
                    // beware that `current_post - 1` might be buggy in some cases!
                    return self.chars[current_pos - 1] == ' ';
                }
            }
        }

        false
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
