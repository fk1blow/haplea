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
        const indent = text.len - trimmed.len;
        return indent < 4 and mem.startsWith(u8, trimmed, "- ");
    }

    // TODO this is a function that strips unnecessary characters like `##` or `- `
    // TODO we also need to store both the original value of a line's text and the stripped text itself
    // LineType{ value: '# Scrambled Eggs', text: "Scrambled Eggs" }
    // or it should be the jobs of... another feature
    // fn sanitize_text()

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

const Block = struct { title: []const u8 = "", tags: []const u8 = "", ingredients: []const u8 = "" };

pub const Parser = struct {
    allocator: mem.Allocator,
    source: []const u8,
    lines: std.ArrayList(Line),
    block: Block,

    pub fn init(allocator: mem.Allocator, source: []const u8) Parser {
        return Parser{ .allocator = allocator, .source = source, .lines = std.ArrayList(Line){}, .block = Block{} };
    }

    pub fn deinit(self: *Parser) void {
        self.lines.deinit(self.allocator);
    }

    pub fn parse(self: *Parser) !void {
        try self.classify_lines();
        try self.assemble_block();
    }

    fn classify_lines(self: *Parser) !void {
        var it = std.mem.splitScalar(u8, self.source, '\n');
        var i: usize = 0;
        while (it.next()) |line| : (i += 1) {
            try self.lines.append(self.allocator, Line.init(line, i));
        }
    }

    fn assemble_block(self: *Parser) !void {
        const ParseStage = struct {
            title: bool,
            tags: bool,
            ingredients: bool,
        };

        var stage = ParseStage{
            .title = false,
            .tags = false,
            .ingredients = false,
        };

        // var foo: []const u8 = "";

        // const block = Block{};
        // _ = block;
        // var parsing_line: LineType = LineType.

        for (self.lines.items) |line| {
            // std.debug.print("line, idx: {}, {d}", .{ line.type, index });

            if (line.type == LineType.Heading) {
                if (line.type.Heading.level == 1) {
                    self.block.title = line.text;
                    stage.title = true;
                }

                if (line.type.Heading.level == 2 and mem.eql(u8, line.text, "## tags")) {
                    self.block.tags = line.text;
                }
            }
        }

        std.debug.print("stage: {} \n", .{stage});

        //     // Group consecutive lines of same type into blocks
        //     // - consecutive .ListItem lines → List block
        //     // - consecutive .Paragraph lines → Paragraph block
        //     // - .Heading → Heading block
        //     // etc.
    }
};

test "parse recipe from filesystem" {
    const file = try std.fs.cwd().openFile("docs/recipe-examples/scrambled-eggs-recipe.md", .{});
    defer file.close();
    const content = try file.readToEndAlloc(std.testing.allocator, 1024 * 1024);
    defer std.testing.allocator.free(content);

    var parser = Parser.init(std.testing.allocator, content);
    defer parser.deinit();
    try parser.parse();

    for (parser.lines.items) |line| {
        if (line.type == LineType.Blank) continue;

        switch (line.type) {
            .Heading => |heading| {
                std.debug.print("  {{ .type = .Heading, .level = {d}, .position = {d}, .text = \"{s}\" }}\n", .{ heading.level, line.position, line.text });
            },
            else => {
                std.debug.print("  {{ .type = .{s}, .position = {d}, .text = \"{s}\" }}\n", .{ @tagName(line.type), line.position, line.text });
            },
        }
    }

    // std.debug.print("block: {{ .title = \".{s}\", .tags = \".{s} }} \n", .{ parser.block.title, parser.block.tags });

    try std.testing.expectEqual(@as(usize, 14), parser.lines.items.len);
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
    _ = source;
    // const s2 = "\n   ";
    // const s3 = "\n bla bla ";

    // var parser = Parser.init(std.testing.allocator, source ++ s2 ++ s3);
    // defer parser.deinit();
    // try parser.parse();

    // try std.testing.expectEqual(@as(usize, 14), parser.lines.items.len);
}
