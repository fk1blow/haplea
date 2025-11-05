const std = @import("std");

const TokenType = enum { Blank, Empty, Heading, Paragraph };

const Token = struct {
    type: TokenType,
    text: []const u8,

    fn is_heading(text: []const u8) bool {
        var hash_count: usize = 0;
        var i: usize = 0;

        while (i < text.len and text[i] == '#') {
            hash_count += 1;
            i += 1;
        }

        return hash_count >= 1 and hash_count <= 6 and i < text.len and text[i] == ' ';
    }

    fn is_empty(text: []const u8) bool {
        var i: usize = 0;
        while (i < text.len) : (i += 1) {
            if (text[i] != ' ') return false;
            i += 1;
        }
        return true;
    }

    pub fn init(text: []const u8) Token {
        const line_type = if (is_heading(text))
            TokenType.Heading
        else if (text.len == 0)
            TokenType.Blank
        else if (is_empty(text))
            TokenType.Empty
        else
            TokenType.Paragraph;

        return .{
            .type = line_type,
            .text = text,
        };
    }
};

pub const Lexer = struct {
    allocator: std.mem.Allocator,
    source: []const u8,
    lines: std.ArrayList(Token),

    fn split_source(self: *Lexer) !void {
        var it = std.mem.splitScalar(u8, self.source, '\n');
        while (it.next()) |line| {
            try self.lines.append(self.allocator, Token.init(line));
        }
    }

    pub fn init(allocator: std.mem.Allocator, source: []const u8) Lexer {
        return Lexer{ .allocator = allocator, .source = source, .lines = std.ArrayList(Token){} };
    }

    pub fn deinit(self: *Lexer) void {
        self.lines.deinit(self.allocator);
    }

    pub fn scan(self: *Lexer) !void {
        try self.split_source();
    }
};

test "split into lines" {
    const source =
        \\# Splitting
        \\This is
        \\the start
        \\
        \\of a great journey!
        \\## Notes
        \\something something
    ;
    const s2 = "\n   ";
    const s3 = "\n bla bla";

    var lexer = Lexer.init(std.testing.allocator, source ++ s2 ++ s3);
    defer lexer.deinit();
    try lexer.scan();

    for (lexer.lines.items) |line| {
        std.debug.print("  {{ .type = .{s}, .text = \"{s}\" }}\n", .{ @tagName(line.type), line.text });
    }

    try std.testing.expectEqual(@as(usize, 0), lexer.lines.items.len);
    // try std.testing.expectEqual(TokenType.Paragraph, parser.tokens.items[0].type);
    // try std.testing.expectEqualStrings(p1 ++ p2, parser.tokens.items[0].value);
    // try std.testing.expectEqual(@as(u32, 1), parser.tokens.items[0].line);
}
