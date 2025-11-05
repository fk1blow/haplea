const std = @import("std");
const mem = std.mem;

const LineType = union(enum) { Blank, Empty, Heading: struct { level: u8 }, Paragraph, List };

const Line = struct {
    type: LineType,
    text: []const u8,
    position: usize,

    fn is_heading(text: []const u8) ?u8 {
        var hash_count: usize = 0;
        var i: u8 = 0;

        while (i < text.len and text[i] == '#') {
            hash_count += 1;
            i += 1;
        }

        if (hash_count >= 1 and hash_count <= 6 and i < text.len and text[i] == ' ')
            return i;
        return null;
    }

    fn is_empty(text: []const u8) bool {
        var i: usize = 0;
        while (i < text.len) : (i += 1) {
            if (text[i] != ' ') return false;
        }
        return true;
    }

    fn is_list(text: []const u8) bool {
        const trimmed = mem.trimLeft(u8, text, " ");
        if (trimmed.len > 3) return false;

        const indent = text.len - trimmed.len;
        return indent < 4 and mem.startsWith(u8, trimmed, "- ");
    }

    pub fn init(text: []const u8, position: usize) Line {
        const line_type = if (is_heading(text)) |level|
            LineType{ .Heading = .{ .level = level } }
        else if (is_list(text))
            LineType{ .List = {} }
        else if (text.len == 0)
            LineType{ .Blank = {} }
        else if (is_empty(text))
            LineType{ .Empty = {} }
        else
            LineType{ .Paragraph = {} };

        return .{ .type = line_type, .text = text, .position = position };
    }
};

const Block = struct {
    //
};

pub const Parser = struct {
    allocator: mem.Allocator,
    source: []const u8,
    lines: std.ArrayList(Line),

    pub fn init(allocator: mem.Allocator, source: []const u8) Parser {
        return Parser{ .allocator = allocator, .source = source, .lines = std.ArrayList(Line){} };
    }

    pub fn deinit(self: *Parser) void {
        self.lines.deinit(self.allocator);
    }

    pub fn parse(self: *Parser) !void {
        try self.classify_lines();
        try self.assemble_blocks();
    }

    fn classify_lines(self: *Parser) !void {
        var it = std.mem.splitScalar(u8, self.source, '\n');
        var i: usize = 0;
        while (it.next()) |line| : (i += 1) {
            try self.lines.append(self.allocator, Line.init(line, i));
        }
    }

    // Phase 2: Group lines into blocks
    fn assemble_blocks(self: *Parser) !void {
        _ = self;
        //     // Group consecutive lines of same type into blocks
        //     // - consecutive .ListItem lines → List block
        //     // - consecutive .Paragraph lines → Paragraph block
        //     // - .Heading → Heading block
        //     // etc.
    }
};

test "assemble into blocks" {
    const source =
        \\# Splitting
        \\This is
        \\the start
        \\
        \\of a great journey!
        \\## Notes
        \\something something
        \\
        \\## Lists
        \\- first
        \\- second
        \\-thirdish
    ;
    const s2 = "\n   ";
    const s3 = "\n bla bla ";

    var lexer = Parser.init(std.testing.allocator, source ++ s2 ++ s3);
    defer lexer.deinit();
    try lexer.parse();

    for (lexer.lines.items) |line| {
        switch (line.type) {
            .Heading => |heading| {
                std.debug.print("  {{ .type = .Heading, .level = {d}, .position = {d}, .text = \"{s}\" }}\n", .{ heading.level, line.position, line.text });
            },
            else => {
                std.debug.print("  {{ .type = .{s}, .position = {d}, .text = \"{s}\" }}\n", .{ @tagName(line.type), line.position, line.text });
            },
        }
    }

    try std.testing.expectEqual(@as(usize, 14), lexer.lines.items.len);
}

test "classify lines" {
    const source =
        \\# Splitting
        \\This is
        \\the start
        \\
        \\of a great journey!
        \\## Notes
        \\something something
        \\
        \\## Lists
        \\- first
        \\- second
        \\-thirdish
    ;
    const s2 = "\n   ";
    const s3 = "\n bla bla ";

    var lexer = Parser.init(std.testing.allocator, source ++ s2 ++ s3);
    defer lexer.deinit();
    try lexer.parse();

    // for (lexer.lines.items) |line| {
    //     switch (line.type) {
    //         .Heading => |heading| {
    //             std.debug.print("  {{ .type = .Heading, .level = {d}, .position = {d}, .text = \"{s}\" }}\n", .{ heading.level, line.position, line.text });
    //         },
    //         else => {
    //             std.debug.print("  {{ .type = .{s}, .position = {d}, .text = \"{s}\" }}\n", .{ @tagName(line.type), line.position, line.text });
    //         },
    //     }
    // }

    try std.testing.expectEqual(@as(usize, 14), lexer.lines.items.len);
}
