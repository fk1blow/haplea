const std = @import("std");

const TokenType = enum { Heading, Paragraph, Undefined };
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

    fn is_new_line(self: *Parser) bool {
        return self.source[self.position] == '\n';
    }

    fn is_empty_char(self: *Parser) bool {
        return self.source[self.position] == ' ';
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
        const Starting = enum { Heading, Paragraph, Undefined };

        while (self.can_advance()) {
            var starting: Starting = .Undefined;

            if (self.is_new_line() or (self.at_line_start() and self.is_new_line())) {
                self.advance();
                continue;
            }

            if (self.at_line_start() and self.source[self.position] == '#') {
                starting = .Heading;
            }

            starting = .Paragraph;

            switch (starting) {
                .Paragraph => {
                    const start_line = self.line;
                    const text_start = self.position;
                    var text_end = self.position;
                    var text_found_in_line = false;

                    while (self.can_advance()) {
                        const current = self.source[self.position];

                        if (current == '\n') {
                            if (!text_found_in_line) {
                                break;
                            }
                            text_found_in_line = false;
                            text_end = self.position;
                            self.advance();
                        } else {
                            if (current != ' ' and current != '\t') {
                                text_found_in_line = true;
                            }
                            self.advance();
                            text_end = self.position;
                        }
                    }

                    const text = self.source[text_start..text_end];
                    try self.tokens.append(self.allocator, Token{ .type = .Paragraph, .value = text, .line = start_line });
                },

                .Heading => {
                    const current_line = self.line;

                    var level: i8 = 0;
                    while (self.can_advance() and level <= 5 and self.source[self.position] == '#') {
                        level += 1;
                        self.advance();
                    }

                    if (self.can_advance() and self.source[self.position] == ' ') {
                        self.advance();
                    }

                    const text_start = self.position;
                    while (self.can_advance() and self.source[self.position] != '\n') {
                        self.advance();
                    }
                    const text = self.source[text_start..self.position];

                    try self.tokens.append(self.allocator, Token{ .type = .Heading, .value = text, .line = current_line });
                },

                .Undefined => {
                    self.advance();
                },
            }
        }
    }
};

test "parse multiline paragraph" {
    const p1 =
        \\ This is
        \\the start
        \\of a great journey!
    ;
    const p2 = " ";
    const p3 =
        \\
        \\then another paragraph
    ;

    var parser = Parser.init(std.testing.allocator, p1 ++ p2 ++ p3);
    defer parser.deinit();

    try parser.scan();

    try std.testing.expectEqual(@as(usize, 2), parser.tokens.items.len);
    // try std.testing.expectEqual(TokenType.Paragraph, parser.tokens.items[0].type);
    // try std.testing.expectEqualStrings(p1 ++ p2, parser.tokens.items[0].value);
    // try std.testing.expectEqual(@as(u32, 1), parser.tokens.items[0].line);
}

// test "parse one line paragraph" {
//     const input = "This is a paragraph";

//     var parser = Parser.init(std.testing.allocator, input);
//     defer parser.deinit();

//     try parser.scan();

//     try std.testing.expectEqual(@as(usize, 1), parser.tokens.items.len);
//     try std.testing.expectEqual(TokenType.Paragraph, parser.tokens.items[0].type);
//     try std.testing.expectEqualStrings("This is a paragraph", parser.tokens.items[0].value);
//     try std.testing.expectEqual(@as(u32, 1), parser.tokens.items[0].line);
// }

// test "crash when input doesn't end with newline and has heading" {
//     const input = "# Title";

//     var parser = Parser.init(std.testing.allocator, input);
//     defer parser.deinit();

//     try parser.scan();

//     try std.testing.expectEqual(@as(usize, 1), parser.tokens.items.len);
//     try std.testing.expectEqual(TokenType.Heading, parser.tokens.items[0].type);
//     try std.testing.expectEqualStrings("Title", parser.tokens.items[0].value);
//     try std.testing.expectEqual(@as(u32, 1), parser.tokens.items[0].line);
// }

// test "parse in the middle of the line" {
//     const input =
//         \\something
//         \\bla # Title here
//         \\whatever
//         \\# Here it is
//     ;

//     var parser = Parser.init(std.testing.allocator, input);
//     defer parser.deinit();
//     try parser.scan();

//     // Should only match the heading at line start (last line)
//     try std.testing.expectEqual(@as(usize, 1), parser.tokens.items.len);
//     try std.testing.expectEqual(TokenType.Heading, parser.tokens.items[0].type);
//     try std.testing.expectEqualStrings("Here it is", parser.tokens.items[0].value);
//     try std.testing.expectEqual(@as(u32, 4), parser.tokens.items[0].line);
// }

// test "parse one line" {
//     const input = "# Recipe Title";

//     var parser = Parser.init(std.testing.allocator, input);
//     defer parser.deinit();
//     try parser.scan();

//     try std.testing.expectEqual(@as(usize, 1), parser.tokens.items.len);
//     try std.testing.expectEqual(TokenType.Heading, parser.tokens.items[0].type);
//     try std.testing.expectEqualStrings("Recipe Title", parser.tokens.items[0].value);
//     try std.testing.expectEqual(@as(u32, 1), parser.tokens.items[0].line);
// }

// test "parse recipe with ingredients" {
//     const input =
//         \\# Scrambled Eggs
//         \\
//         \\Easy, fast and good recipe.
//         \\
//         \\## ingredients
//         \\
//         \\- eggs
//         \\- cheese
//     ;

//     var parser = Parser.init(std.testing.allocator, input);
//     defer parser.deinit();
//     try parser.scan();

//     try std.testing.expectEqual(@as(usize, 2), parser.tokens.items.len);

//     // Title heading
//     try std.testing.expectEqual(TokenType.Heading, parser.tokens.items[0].type);
//     try std.testing.expectEqualStrings("Scrambled Eggs", parser.tokens.items[0].value);
//     try std.testing.expectEqual(@as(u32, 1), parser.tokens.items[0].line);

//     // Ingredients heading
//     try std.testing.expectEqual(TokenType.Heading, parser.tokens.items[1].type);
//     try std.testing.expectEqualStrings("ingredients", parser.tokens.items[1].value);
//     try std.testing.expectEqual(@as(u32, 5), parser.tokens.items[1].line);
// }
