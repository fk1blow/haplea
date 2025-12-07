const std = @import("std");
const mem = std.mem;

pub const LineType = union(enum) {
    Blank,
    Empty,
    Paragraph,
    Heading: struct { level: u8 },
    List,
};

pub const Line = struct {
    type: LineType,
    text: []const u8,
    position: usize,

    fn is_heading(text: []const u8) ?u8 {
        var hash_count: u8 = 0;
        var i: usize = 0;

        while (i < text.len and text[i] == '#') {
            hash_count += 1;
            i += 1;
        }

        if (hash_count >= 1 and hash_count <= 6 and i < text.len and text[i] == ' ')
            return hash_count;
        return null;
    }

    fn is_empty(text: []const u8) bool {
        for (text) |char| {
            if (char != ' ' and char != '\t' and char != '\r') return false;
        }
        return true;
    }

    fn is_list(text: []const u8) bool {
        const trimmed = mem.trimLeft(u8, text, " \t");
        const indent = text.len - trimmed.len;

        // List items must have < 4 spaces indent and start with "- "
        if (indent >= 4) return false;

        return mem.startsWith(u8, trimmed, "- ") or mem.startsWith(u8, trimmed, "* ");
    }

    pub fn init(text: []const u8, position: usize) Line {
        const line_type = if (text.len == 0)
            LineType{ .Blank = {} }
        else if (is_empty(text))
            LineType{ .Empty = {} }
        else if (is_heading(text)) |level|
            LineType{ .Heading = .{ .level = level } }
        else if (is_list(text))
            LineType{ .List = {} }
        else
            LineType{ .Paragraph = {} };

        return .{ .type = line_type, .text = text, .position = position };
    }
};

pub const Parser = struct {
    allocator: mem.Allocator,
    source: []const u8,
    lines: std.ArrayList(Line),

    pub fn init(allocator: mem.Allocator, source: []const u8) Parser {
        return .{
            .allocator = allocator,
            .source = source,
            .lines = std.ArrayList(Line){},
        };
    }

    pub fn deinit(self: *Parser) void {
        self.lines.deinit(self.allocator);
    }

    pub fn parse(self: *Parser) ![]Line {
        var it = mem.splitScalar(u8, self.source, '\n');
        var position: usize = 0;

        while (it.next()) |line_text| : (position += 1) {
            try self.lines.append(self.allocator, Line.init(line_text, position));
        }

        return self.lines.items;
    }
};

test "Line classification - headings" {
    const line1 = Line.init("# Heading 1", 0);
    try std.testing.expectEqual(LineType.Heading, @as(std.meta.Tag(LineType), line1.type));
    try std.testing.expectEqual(@as(u8, 1), line1.type.Heading.level);

    const line2 = Line.init("## Heading 2", 1);
    try std.testing.expectEqual(LineType.Heading, @as(std.meta.Tag(LineType), line2.type));
    try std.testing.expectEqual(@as(u8, 2), line2.type.Heading.level);

    const line6 = Line.init("###### Heading 6", 2);
    try std.testing.expectEqual(LineType.Heading, @as(std.meta.Tag(LineType), line6.type));
    try std.testing.expectEqual(@as(u8, 6), line6.type.Heading.level);
}

test "Line classification - malformed headings" {
    // No space after hashes
    const line1 = Line.init("#NoSpace", 0);
    try std.testing.expectEqual(LineType.Paragraph, @as(std.meta.Tag(LineType), line1.type));

    // Too many hashes
    const line2 = Line.init("####### Seven", 1);
    try std.testing.expectEqual(LineType.Paragraph, @as(std.meta.Tag(LineType), line2.type));
}

test "Line classification - lists" {
    const line1 = Line.init("- List item", 0);
    try std.testing.expectEqual(LineType.List, @as(std.meta.Tag(LineType), line1.type));

    const line2 = Line.init("  - Indented item", 1);
    try std.testing.expectEqual(LineType.List, @as(std.meta.Tag(LineType), line2.type));

    const line3 = Line.init("* Asterisk item", 2);
    try std.testing.expectEqual(LineType.List, @as(std.meta.Tag(LineType), line3.type));

    // Too much indent (4+ spaces = code block)
    const line4 = Line.init("    - Code block", 3);
    try std.testing.expectEqual(LineType.Paragraph, @as(std.meta.Tag(LineType), line4.type));
}

test "Line classification - blank and empty" {
    const blank = Line.init("", 0);
    try std.testing.expectEqual(LineType.Blank, @as(std.meta.Tag(LineType), blank.type));

    const empty = Line.init("   ", 1);
    try std.testing.expectEqual(LineType.Empty, @as(std.meta.Tag(LineType), empty.type));

    const empty_tabs = Line.init("\t\t", 2);
    try std.testing.expectEqual(LineType.Empty, @as(std.meta.Tag(LineType), empty_tabs.type));
}

test "Line classification - paragraphs" {
    const para = Line.init("Regular text paragraph", 0);
    try std.testing.expectEqual(LineType.Paragraph, @as(std.meta.Tag(LineType), para.type));
}

test "Parser - full document" {
    const allocator = std.testing.allocator;

    const source =
        \\# Heading 1
        \\## Heading 2
        \\
        \\Regular paragraph
        \\- List item
        \\  - Nested item
    ;

    var parser = Parser.init(allocator, source);
    defer parser.deinit();

    const lines = try parser.parse();

    try std.testing.expectEqual(@as(usize, 6), lines.len);

    try std.testing.expectEqual(LineType.Heading, @as(std.meta.Tag(LineType), lines[0].type));
    try std.testing.expectEqual(@as(u8, 1), lines[0].type.Heading.level);

    try std.testing.expectEqual(LineType.Heading, @as(std.meta.Tag(LineType), lines[1].type));
    try std.testing.expectEqual(@as(u8, 2), lines[1].type.Heading.level);

    try std.testing.expectEqual(LineType.Blank, @as(std.meta.Tag(LineType), lines[2].type));
    try std.testing.expectEqual(LineType.Paragraph, @as(std.meta.Tag(LineType), lines[3].type));
    try std.testing.expectEqual(LineType.List, @as(std.meta.Tag(LineType), lines[4].type));
    try std.testing.expectEqual(LineType.List, @as(std.meta.Tag(LineType), lines[5].type));
}
