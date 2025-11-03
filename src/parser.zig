const std = @import("std");

const TokenType = enum { Heading, Text, Undefined };
const Token = struct { type: TokenType, value: []const u8, line: u32 };

pub const Parser = struct {
    source: []const u8,
    position: u32,
    line: u32,
    tokens: std.ArrayList(Token),
    allocator: std.mem.Allocator,

    fn advance(self: *Parser) void {
        if (self.source[self.position] == '\n') {
            self.line += 1;
        }
        self.position += 1;
    }

    fn can_advance(self: *Parser) bool {
        return self.position < self.source.len;
    }

    fn at_line_start(self: *Parser) bool {
        if (self.position == 0) return true;
        return self.source[self.position - 1] == '\n';
    }

    pub fn init(allocator: std.mem.Allocator, source: []const u8) Parser {
        return Parser{ .source = source, .position = 0, .line = 1, .tokens = std.ArrayList(Token){}, .allocator = allocator };
    }

    pub fn deinit(self: *Parser) void {
        self.tokens.deinit(self.allocator); // Pass allocator here too
    }

    pub fn debug_tokens(self: *Parser) void {
        for (self.tokens.items) |token| {
            std.debug.print("  {{ .type = .{s}, .value = \"{s}\", .line = {} }}\n", .{ @tagName(token.type), token.value, token.line });
        }
    }

    pub fn scan(self: *Parser) !void {
        const Starting = enum { Heading, Undefined };

        while (self.can_advance()) {
            var starting: Starting = .Undefined;

            if (self.source[self.position] == '#' and self.at_line_start()) {
                starting = .Heading;
            }

            switch (starting) {
                .Heading => {
                    var level: i8 = 0;
                    while (level <= 5 and self.source[self.position] == '#') {
                        level += 1;
                        self.advance();
                    }

                    if (self.source[self.position] == ' ') {
                        self.advance();
                    }

                    const text_start = self.position;
                    while (self.can_advance() and self.source[self.position] != '\n') {
                        self.advance();
                    }
                    const text = self.source[text_start..self.position];

                    try self.tokens.append(self.allocator, Token{ .type = .Heading, .value = text, .line = self.line });
                },

                .Undefined => {
                    if (self.can_advance()) self.advance();
                },
            }

            // self.advance();
        }
    }
};

test "crash when input doesn't end with newline and has heading" {
    const input = "# Title"; // No trailing newline!

    var parser = Parser.init(std.testing.allocator, input);
    defer parser.deinit();

    try parser.scan();
    parser.debug_tokens();
}

test "parse in the middle of the line" {
    const input =
        \\something
        \\bla # Title here
        \\whatever
        \\# Here it is
    ;
    // _ = input;
    var parser = Parser.init(std.testing.allocator, input);
    defer parser.deinit();
    try parser.scan();
    parser.debug_tokens();
}

test "parse one line" {
    const input = "# Recipe Title";
    _ = input;
    // var parser = Parser.init(); // 14 chars len
    // parser.scan();
}

// test "parse multiline" {
//     const input =
//         \\ # Recipe Title
//         \\
//     ;
//     var parser = Parser.init(input);
//     parser.scan();
// }

test "parse recipe with ingredients" {
    const input =
        \\# Scrambled Eggs
        \\
        \\Easy, fast and good recipe.
        \\
        \\## ingredients
        \\
        \\- eggs
        \\- cheese
    ;

    // _ = input;

    var parser = Parser.init(std.testing.allocator, input);
    defer parser.deinit();
    try parser.scan();
    parser.debug_tokens();
}

// test "parse full recipe" {
//     const input =
//         \\# Scrambled Eggs
//         \\
//         \\Easy, fast and good recipe.
//         \\
//         \\## tags
//         \\
//         \\breakfast, eggs, fast food
//         \\
//         \\## ingredients
//         \\
//         \\- eggs
//         \\- onion or leek(praz)
//         \\- cheese
//         \\- salt
//         \\- pepper
//         \\
//         \\## instructions
//         \\
//         \\how to do it...
//     ;

//     var parser = Parser.init(input);
//     parser.scan();
// }
